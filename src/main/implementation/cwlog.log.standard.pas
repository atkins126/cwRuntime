{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.

  3. Neither the name of the copyright holder nor the names of its contributors may be
     used to endorse or promote products derived from this software without specific prior
     written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
{$endif}
unit cwlog.log.standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
;

type
  (* Duplicate in cwTypes, but here to prevent circular reference *)
  TArrayOfString = array of string;

type
  TLog = class( TInterfacedObject, ILog, IChainLog )
  strict private //- IChainLog -//
    procedure setChainLog( const ChainLog: pointer );
    function getChainLog: pointer;
  strict private //- ILog -//
    procedure RegisterEntry( const LogEntry: TStatus; const DefaultText: string );
    procedure AddTarget( const LogTarget: ILogTarget );
    function ExportTranslationFile( const FilePath: string ): TStatus;
    function ImportTranslationFile( const FilePath: string ): TStatus;
    function Insert( const LogEntry: TStatus; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: TStatus; const Severity: TLogSeverity ): TStatus; overload;
    function Insert( const LogEntry: TGUID; const Severity: TLogSeverity ): TStatus; overload;
    function Insert( const LogEntry: TGUID; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function getLastEntry: string;
  public
    constructor Create; reintroduce;
  end;

///  <summary>
///    Returns the singleton instance of ILog for the current thread.
///  </summary>
function Log: ILog;

implementation
uses
  sysutils //- for Now()
, cwTypes
, cwIO
, cwIO.Standard
, cwlog.translationparser.standard
, cwLog.Common
, cwThreading
, cwThreading.Standard
, cwUnicode
, cwUnicode.Standard
, cwRuntime.Collections
, cwRuntime.Collections.Standard
;


{$region ' Unit Global...'}
threadvar
  SingletonLog: ILog;

//------------------------------------------------------------------------------
//  Log Entries and Targets have been made global now that Log is a threadvar
//  singleton. This allows multiple threads to each have their own instance
//  of log, but for those instances to share targets and entries as though
//  they were a global singleton.
//  Critical Sections must be used to ensure that no two instances of ILog
//  attempt to add log entries or send entries to log targets at the same time.
//------------------------------------------------------------------------------
threadvar
  LastEntry: string;

type
  TChainLog = record
    gInsert: function (const LogEntry: TGUID; const Severity: TLogSeverity; const lparParameters: pointer; const ParamCount: nativeuint ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    gRegisterEntry: procedure ( const LogEntry: TGUID; const lpszDefaultText: pointer ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
  end;
  pChainLog = ^TChainLog;

var
  LocalChain: TChainLog;
  ChainLogPtr: pChainLog;
  LogEntries: ILogEntryDictionary = nil;
  LogTargets: ILogTargetList = nil;
  InsertionCS: ICriticalSection = nil;
  RegisterCS: ICriticalSection = nil;

(* Returns an array of strings containing the names of parameters within the
   Source string. The parameter names are uppercased and trimmed *)
function ParseParameters( const SourceString: string ): TArrayOfString;
  function AlreadyExists( const Parameters: TArrayOfString; const ParameterName: string ): boolean;
  var
    idx: nativeuint;
  begin
    Result := False;
    if Length(Parameters)=0 then begin
      exit;
    end;
    for idx := 0 to pred(Length(Parameters)) do begin
      if Parameters[idx]=ParameterName then begin
        Result := True;
        exit;
      end;
    end;
  end;
var
  Src: string;
  ParamName: string;
  Counter: nativeuint;
begin
  //- Count the parameters
  Src := SourceString;
  Counter := 0;
  while (Pos('(%',Src)>0) do begin
    Src := Src.RightStr(pred(Length(Src)-Pos('(%',Src)));
    if Pos('%)',Src)>0 then begin
      ParamName := Src.LeftStr(pred(Pos('%)',Src)));
      if pred(pred(Length(Src)-Length(ParamName)))>0 then begin
        Src := Src.RightStr(pred(pred(Length(Src)-Length(ParamName))));
      end else begin
        Src := '';
      end;
      inc(Counter);
    end;
  end;

  //- Return the parameters
  {$warnings off}
  SetLength(Result,Counter);
  {$warnings on}
  if Counter=0 then begin
    exit;
  end;
  Src := SourceString;
  Counter := 0;
  while (Pos('(%',Src)>0) do begin
    Src := Src.RightStr(pred(Length(Src)-Pos('(%',Src)));
    if Pos('%)',Src)>0 then begin
      ParamName := Src.LeftStr(pred(Pos('%)',Src)));
      if pred(pred(Length(Src)-Length(ParamName)))>0 then begin
        Src := Src.RightStr(pred(pred(Length(Src)-Length(ParamName))));
      end else begin
        Src := '';
      end;
      ParamName := ParamName.UppercaseTrim;
      if not AlreadyExists(Result,ParamName) then begin
        Result[Counter] := ParamName.UppercaseTrim;
        inc(Counter);
      end else begin
        SetLength(Result,pred(Length(Result)));
      end;
    end;
  end;
end;


procedure gRegisterEntry( const LogEntry: TGUID; const lpszDefaultText: pointer ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
var
  uDefaultText: TUnicodeString;
begin
  uDefaultText.UnicodeFormat := TUnicodeFormat.utf8;
  uDefaultText.AsPtr := lpszDefaultText;
  RegisterCS.Acquire;
  try
    LogEntries.setValueByKey(LogEntry,uDefaultText.AsString);
  finally
    RegisterCS.Release;
  end;
end;

//- Parameters are passed as a pointer to an array of pchar (utf8 zero terminated)
function gInsert(const LogEntry: TGUID; const Severity: TLogSeverity; const lparParameters: pointer; const ParamCount: nativeuint ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
var
  LogEntryStr: string;
  uLogEntryStr: TUnicodeString;
  Parameters: TArrayOfString;
  ParametersPtr: pointer;
  uParameter: TUnicodeString;
  MessageText: string;
  ParameterPlaceholders: TArrayOfString;
  Max: nativeuint;
  idx: nativeuint;
  TS: TDateTime;
begin
  Result.Value := LogEntry;
  TS := Now;

  //- Decode the parameters passed as a LF separated array in a utf8 zero-terminated string.
  {$hints off} SetLength(Parameters,ParamCount); {$hints on} //- Managed type is initialized here.
  try
    if ParamCount>0 then begin
      ParametersPtr := lparParameters;
      for idx := 0 to pred(ParamCount) do begin
        uParameter.UnicodeFormat := TUnicodeFormat.utf8;
        uParameter.AsPtr := pointer(ParametersPtr^);
        Parameters[idx] := uParameter.AsString;
        {$hints off} ParametersPtr := pointer( nativeuint(ParametersPtr) + sizeof(Pointer) ); {$hints on} //- Conversion betwen ordinals and pointers is portable if the ordinal is pointer sized.
      end;
    end;

    //- Get the message translation
    MessageText := '';
    RegisterCS.Acquire;
    try
      if not LogEntries.getKeyExists(Result.Value) then begin
        {$ifdef fpc}
        LogEntryStr := GUIDToString(LogEntry).AsString;
        {$else}
        LogEntryStr := GUIDToString(LogEntry);
        {$endif}
        uLogEntryStr.UnicodeFormat := TUnicodeFormat.utf8;
        uLogEntryStr.AsString := LogEntryStr;
        Result := gInsert(stLogEntryNotRegistered.Value, lsFatal, uLogEntryStr.AsPtr, 1 );
        exit;
      end;
      MessageText := LogEntries.getValueByKey(Result.Value);
    finally
      RegisterCS.Release;
    end;

    //- Parse Parameters and substitute.
    ParameterPlaceholders := ParseParameters(MessageText);
    if Length(ParameterPlaceholders)<=Length(Parameters) then begin
      if Length(ParameterPlaceholders)>0 then begin
        for idx := 0 to pred(Length(ParameterPlaceholders)) do begin
          MessageText := MessageText.StringReplace('(%'+ParameterPlaceholders[idx]+'%)',Parameters[idx],True,True);
        end;
      end;
    end;

    //- Embelish translated string.
    case Severity of
      TLogSeverity.lsInfo:    MessageText := '[INFO] '+MessageText;
      TLogSeverity.lsHint:    MessageText := '[HINT] '+MessageText;
      TLogSeverity.lsWarning: MessageText := '[WARNING] '+MessageText;
      TLogSeverity.lsError:   MessageText := '[ERROR] '+MessageText;
      TLogSeverity.lsFatal:   MessageText := '[FATAL] '+MessageText;
    end;
    LastEntry := MessageText;
    MessageText := '('+ string(FormatDateTime('YYYY-MM-DD HH:nn:SS:ssss',TS)) +') ' + MessageText;

    //- Insert using log insertion handler.
    Max := LogTargets.Count;
    if Max=0 then begin
      exit;
    end;
    for idx := 0 to pred(Max) do begin
      InsertionCS.Acquire;
      try
        LogTargets[idx].Insert(Result.Value,MessageText,TS,Severity,Parameters);
      finally
        InsertionCS.Release;
      end;
    end;
  finally
    SetLength(Parameters,0);
  end;
end;


//------------------------------------------------------------------------------
{$endregion}

function Log: ILog;
begin
  //- Ensure the critical sections are created for the first call to the log.
  if not assigned(InsertionCS) then begin
    InsertionCS := TCriticalSection.Create;
  end;
  if not assigned(RegisterCS) then begin
    RegisterCS := TCriticalSection.Create;
  end;
  //- Ensure log targets list is created
  if not assigned(LogTargets) then begin
    InsertionCS.Acquire;
    try
      LogTargets := TLogTargetList.Create;
    finally
      InsertionCS.Release;
    end;
  end;
  //- Ensure the log entries dictionary is created
  if not assigned(LogEntries) then begin
    RegisterCS.Acquire;
    try
      LogEntries := TLogEntryDictionary.Create;
    finally
      RegisterCS.Release;
    end;
  end;
  //- Instance a log if one is not already instanced for this thread.
  if not assigned(SingletonLog) then begin
    SingletonLog := cwLog.Log.Standard.TLog.Create;
  end;
  //- Return the log instance.
  Result := SingletonLog;
end;

procedure TLog.setChainLog(const ChainLog: pointer);
var
  uDefaultText: TUnicodeString;
  idx: nativeuint;
begin
  // Set the chain log pointer to the new log.
  ChainLogPtr := ChainLog;
  if ChainLogPtr=@LocalChain then begin
    exit;
  end;
  //- Re-register all local messages with the new log.
  //- No need to critical section as all log calls are now being
  //- handled by the chain target.
  if LogEntries.Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(LogEntries.Count) do begin
    uDefaultText.AsString := LogEntries.getValueByIndex(idx);
    uDefaultText.UnicodeFormat := TUnicodeFormat.utf8;
    pChainLog(ChainLogPtr)^.gRegisterEntry(LogEntries.getKeyByIndex(idx),uDefaultText.AsPtr);
  end;
  LogEntries.Clear;
  LogTargets.Clear;
end;

function TLog.getChainLog: pointer;
begin
  Result := @LocalChain;
end;

procedure TLog.RegisterEntry( const LogEntry: TStatus; const DefaultText: string );
var
  uDefaultText: TUnicodeString;
begin
  uDefaultText.AsString := DefaultText;
  uDefaultText.UnicodeFormat := TUnicodeFormat.utf8;
  pChainLog(ChainLogPtr)^.gRegisterEntry( LogEntry.Value, uDefaultText.AsPtr );
end;

procedure TLog.AddTarget(const LogTarget: ILogTarget);
begin
  InsertionCS.Acquire;
  try
    LogTargets.Add(LogTarget);
  finally
    InsertionCS.Release;
  end;
end;

function TLog.ExportTranslationFile(const FilePath: string): TStatus;
var
  FS: IUnicodeStream;
  Max: nativeuint;
  idx: nativeuint;
  GUIDStr: string;
  EntryText: string;
begin
  Result := TStatus.Unknown;
  if FileExists(FilePath) then begin
    DeleteFile(FilePath);
  end;
  FS := TFileStream.Create(FilePath,False);
  try
    FS.WriteBOM( TUnicodeFormat.utf8 );
    FS.WriteString('['+CR+LF, TUnicodeFormat.utf8 );
    Max := LogEntries.Count;
    for idx := 0 to pred( Max ) do begin
      RegisterCS.Acquire;
      try
        {$ifdef fpc}
        GUIDStr := GUIDToString(LogEntries.getKeyByIndex(idx)).AsString;
        {$else}
        GUIDStr := GUIDToString(LogEntries.getKeyByIndex(idx));
        {$endif}
        EntryText := LogEntries.getValueByIndex(idx);
        EntryText := EntryText.StringReplace('"','\"',TRUE,TRUE);
      finally
        RegisterCS.Release;
      end;
      FS.WriteString('{ "EntryID": "'+GUIDStr+'", "EntryText": "'+EntryText+'"}', TUnicodeFormat.utf8 );
      if idx<pred(Max) then begin
        FS.WriteString(','+CR+LF, TUnicodeFormat.utf8 );
      end else begin
        FS.WriteString(','+CR+LF, TUnicodeFormat.utf8 );
      end;
    end;
    FS.WriteString(']'+CR+LF, TUnicodeFormat.utf8 );
  finally
    FS := nil;
  end;
  Result := TStatus.Success;
end;

function TLog.ImportTranslationFile(const FilePath: string): TStatus;
var
  FS: IUnicodeStream;
  TranslationParser: TTranslationParser;
  idx: nativeuint;
begin
  Result := TStatus.Unknown;
  if not FileExists(FilePath) then begin
    exit;
  end;
  FS := TFileStream.Create(FilePath,TRUE);
  try
    if not TranslationParser.ParseTranslations(FS) then begin
      exit;
    end;
    if TranslationParser.EntryCount=0 then begin
      Result := TStatus.Success;
      exit;
    end;
    for idx := 0 to pred(TranslationParser.EntryCount) do begin
      RegisterEntry(TranslationParser.GUIDs[idx],TranslationParser.Texts[idx]);
    end;
  finally
    FS := nil;
  end;
  Result := TStatus.Success;
end;

function TLog.Insert(const LogEntry: TStatus; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  idx: nativeuint;
  uParameterArray: array of TUnicodeString;
  ParameterArray: array of pointer;
begin
  if Length(Parameters)=0 then begin
    Result := pChainLog(ChainLogPtr)^.gInsert( LogEntry.Value, Severity, nil, 0 );
    exit;
  end;
  {$hints off} SetLength(uParameterArray,Length(Parameters)); {$hints on} // Managed type is initialized here.
  {$hints off} SetLength(ParameterArray,Length(Parameters));  {$hints on} // Managed type is initialized here.
  try
    for idx := 0 to pred( Length(Parameters) ) do begin
      uParameterArray[idx].UnicodeFormat := TUnicodeFormat.utf8;
      uParameterArray[idx].AsString := Parameters[idx];
      ParameterArray[idx] := uParameterArray[idx].AsPtr;
    end;
    Result := pChainLog(ChainLogPtr)^.gInsert( LogEntry.Value, Severity, @ParameterArray[0], Length(Parameters) );
  finally
    SetLength(uParameterArray,Length(Parameters));
    SetLength(ParameterArray,Length(Parameters));
  end;
end;

function TLog.Insert(const LogEntry: TStatus; const Severity: TLogSeverity): TStatus;
begin
  Result := Insert( LogEntry, Severity, [] );
end;

function TLog.Insert(const LogEntry: TGUID; const Severity: TLogSeverity): TStatus;
begin
  Result := Insert( TStatus(LogEntry), Severity );
end;

function TLog.Insert(const LogEntry: TGUID; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
begin
  Result := Insert( TStatus(LogEntry), Severity, Parameters );
end;

function TLog.getLastEntry: string;
begin
  Result := LastEntry;
end;

constructor TLog.Create;
begin
  inherited Create;
  LastEntry := '';
  if not assigned(ChainLogPtr) then begin
    ChainLogPtr := @LocalChain;
    pChainLog(ChainLogPtr)^.gInsert := @gInsert;
    pChainLog(ChainLogPtr)^.gRegisterEntry := @gRegisterEntry;
  end;
end;

initialization
  SingletonLog := nil;
  InsertionCS := nil;
  RegisterCS := nil;
  ChainLogPtr := nil;

finalization
  SingletonLog := nil;
  InsertionCS := nil;
  RegisterCS := nil;

end.
