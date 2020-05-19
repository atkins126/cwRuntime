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
  syncobjs
, cwLog
, cwCollections
;

const
  cLogEntryGranularity = 32;

type
  (* Duplicate in cwTypes, but here to prevent circular reference *)
  TArrayOfString = array of string;

type
  TLog = class( TInterfacedObject, ILog )
  private
    fLogTargets: IList<ILogTarget>;
    fLogEntryIDs: array of TGUID;
    fLogEntryTexts: array of string;
    fLogEntryCount: nativeuint;
    fInsertionCS: TCriticalSection;
  private
    function ParseParameters(const SourceString: string): TArrayOfString;
    function FindLogEntry( const GUID: TGUID; out FoundIdx: nativeuint ): boolean;
  strict private //- ILog -//
    function RegisterEntry( const LogEntry: TStatus; const DefaultText: string ): boolean;
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
    destructor Destroy; override;
  end;

///  <summary>
///    Returns a singleton instance of ILog.
///    Ignore the override log parameter, this is used internally to
///    override a static log with a dynamic log.
///  </summary>
function Log: ILog;

implementation
uses
  sysutils  //[RTL] For IsEqualGUID
, cwTypes
, cwCollections.Standard
, cwIO
, cwIO.Standard
, cwlog.translationparser.standard
, cwLog.Common
;

//- Record last log entry for each thread so that it may be recalled if required.
threadvar
  LastEntry: string;

function Log: ILog;
begin
  if not assigned(SingletonLog) then begin
    SingletonLog := TLog.Create;
  end;
  Result := SingletonLog;
end;

function TLog.FindLogEntry(const GUID: TGUID; out FoundIdx: nativeuint): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fLogEntryCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(fLogEntryCount) do begin
    if IsEqualGUID(GUID,fLogEntryIDs[idx]) then begin
      FoundIdx := idx;
      Result := True;
      exit;
    end;
  end;
end;

function TLog.RegisterEntry( const LogEntry: TStatus; const DefaultText: string ): boolean;
var
  foundIdx: nativeuint;
  L: nativeuint;
begin
  Result := False;
  if FindLogEntry( LogEntry, foundIdx ) then begin
    fLogEntryTexts[foundIdx] := DefaultText;
    exit;
  end;
  //- Ensure there is space in the arrays.
  L := Length(fLogEntryIDs);
  if fLogEntryCount>=L then begin
    SetLength( fLogEntryIDs, Length(fLogEntryIDs)+cLogEntryGranularity );
    SetLength( fLogEntryTexts, Length(fLogEntryTexts)+cLogEntryGranularity );
  end;
  fLogEntryIDs[fLogEntryCount] := LogEntry;
  fLogEntryTexts[fLogEntryCount] := DefaultText;
  inc( fLogEntryCount );
  Result := True;
end;

procedure TLog.AddTarget(const LogTarget: ILogTarget);
begin
  fInsertionCS.Acquire;
  try
    fLogTargets.Add(LogTarget);
  finally
    fInsertionCS.Release;
  end;
end;

function TLog.ExportTranslationFile(const FilePath: string): TStatus;
var
  FS: IUnicodeStream;
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
    for idx := 0 to pred( fLogEntryCount ) do begin
      {$ifdef fpc}
      GUIDStr := GUIDToString(fLogEntryIDs[idx]).AsString;
      {$else}
      GUIDStr := GUIDToString(fLogEntryIDs[idx]);
      {$endif}
      EntryText := fLogEntryTexts[idx];
      EntryText := EntryText.StringReplace('"','\"',TRUE,TRUE);
      FS.WriteString('{ "EntryID": "'+GUIDStr+'", "EntryText": "'+EntryText+'"}', TUnicodeFormat.utf8 );
      if idx<pred(fLogEntryCount) then begin
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
  MessageText: string;
  ParameterPlaceholders: TArrayOfString;
  foundIdx: nativeuint;
  idx: nativeuint;
  TS: TDateTime;
begin
  Result.Value := LogEntry;
  TS := Now;

  //- Get the message translation
  MessageText := '';
  if not FindLogEntry( Result.Value, foundIdx ) then begin
    Result := Insert(stLogEntryNotRegistered, lsFatal, [LogEntry] );
    exit;
  end;
  MessageText := fLogEntryTexts[foundIdx];

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
  fInsertionCS.Acquire;
  try
    if fLogTargets.Count>0 then begin
      for idx := 0 to pred(fLogTargets.Count) do begin
        fLogTargets[idx].Insert(Result.Value,MessageText,TS,Severity,Parameters);
      end;
    end;
  finally
    fInsertionCS.Release;
  end;
end;

(* Returns an array of strings containing the names of parameters within the
   Source string. The parameter names are uppercased and trimmed *)
function TLog.ParseParameters( const SourceString: string ): TArrayOfString;
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
      ParamName := Uppercase(Trim(ParamName));
      if not AlreadyExists(Result,ParamName) then begin
        Result[Counter] := Uppercase(Trim(ParamName));
        inc(Counter);
      end else begin
        SetLength(Result,pred(Length(Result)));
      end;
    end;
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
  fInsertionCS := TCriticalSection.Create;
  LastEntry := '';
  //- Insertion handler
  fLogTargets := TList<ILogTarget>.Create;
  //- Initialize dynamic arrays
  fLogEntryCount := 0;
  SetLength( fLogEntryIDs, cLogEntryGranularity );
  SetLength( fLogEntryTexts, cLogEntryGranularity );
end;

destructor TLog.Destroy;
begin
  fLogTargets := nil;
  SetLength( fLogEntryIDs, 0 );
  SetLength( fLogEntryTexts, 0 );
  {$ifdef fpc}
  fInsertionCS.Free;
  {$else}
  fInsertionCS.DisposeOf;
  {$endif}
  inherited Destroy;
end;

initialization
  SingletonLog := nil;

finalization
  SingletonLog := nil;

end.
