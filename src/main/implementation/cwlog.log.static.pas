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
unit cwlog.log.static;
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
    function ParseLogEntryDeclaration(const SourceStr: string; out GUID: string; out MessageText: string): boolean;
    function ParseParameters(const SourceString: string): TArrayOfString;
    function FindLogEntry( const GUID: TGUID; out FoundIdx: nativeuint ): boolean;
  strict private //- ILog -//
    function RegisterLogEntry( const EntryString: string ): boolean;
    procedure AddLogTarget( const LogTarget: ILogTarget );
    function ExportTranslationFile( const FilePath: string ): TStatus;
    function ImportTranslationFile( const FilePath: string ): TStatus;
    function Insert( const LogEntry: TGUID; const EntryText: string; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: string; const Severity: TLogSeverity ): TStatus; overload;
    {$if defined(fpc) or defined(MSWINDOWS)}
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity ): TStatus; overload;
    {$endif}
    {$if defined(fpc) or defined(MSWINDOWS)}
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    {$endif}
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

function TLog.RegisterLogEntry(const EntryString: string): boolean;
var
  foundIdx: nativeuint;
  GUID: TGUID;
  UIDStr: string;
  MessageStr: string;
  L: nativeuint;
begin
  Result := False;
  if not ParseLogEntryDeclaration(EntryString,UIDStr,MessageStr) then begin
    exit;
  end;
  {$ifdef fpc}
  GUID := StringToGUID(ansistring(UIDStr));
  {$else}
  GUID := StringToGUID(UIDStr);
  {$endif}
  if FindLogEntry( GUID, foundIdx ) then begin
    fLogEntryTexts[foundIdx] := MessageStr;
    exit;
  end;
  //- Ensure there is space in the arrays.
  L := Length(fLogEntryIDs);
  if fLogEntryCount>=L then begin
    SetLength( fLogEntryIDs, Length(fLogEntryIDs)+cLogEntryGranularity );
    SetLength( fLogEntryTexts, Length(fLogEntryTexts)+cLogEntryGranularity );
  end;
  fLogEntryIDs[fLogEntryCount] := GUID;
  fLogEntryTexts[fLogEntryCount] := MessageStr;
  inc( fLogEntryCount );
  Result := True;
end;

procedure TLog.AddLogTarget(const LogTarget: ILogTarget);
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
      RegisterLogEntry(TranslationParser.GUIDs[idx]+' '+TranslationParser.Texts[idx]);
    end;
  finally
    FS := nil;
  end;
  Result := TStatus.Success;
end;

function TLog.Insert(const LogEntry: TGUID; const EntryText: string; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  ErrorStr: string;
  MessageText: string;
  ParameterPlaceholders: TArrayOfString;
  foundIdx: nativeuint;
  idx: nativeuint;
  TS: TDateTime;
begin
  Result.Value := LogEntry;
  TS := Now;

  //- Get the message translation
  MessageText := EntryText;
  if FindLogEntry( Result.Value, foundIdx ) then begin
    MessageText := fLogEntryTexts[foundIdx];
  end else begin
    {$ifdef fpc}
    ErrorStr := 'Unable to locate log entry for insertion "'+GuidToString(LogEntry).AsString+'".';
    raise
      Exception.Create(ErrorStr.AsAnsiString);
    {$else}
    ErrorStr := 'Unable to locate log entry for insertion "'+GuidToString(LogEntry)+'".';
    raise
      Exception.Create(ErrorStr);
    {$endif}
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

function TLog.ParseLogEntryDeclaration(const SourceStr: string; out GUID: string; out MessageText: string): boolean;
const
  cGUIDLen = 38;
var
  RemainingChars: nativeuint;
begin
  GUID := '';
  MessageText := '';
  Result := False;
  if Length(SourceStr)<cGUIDLen then begin
    exit;
  end;
  //- No opening brace means this is not a log entry.
  if SourceStr.LeftStr(1)<>'{' then begin
    exit;
  end;
  //- 38th character should be closing brace else, not a log entry.
  {$ifdef NEXTGEN}
  if SourceStr[pred(cGUIDLen)]<>'}' then begin
  {$else}
  if SourceStr[cGUIDLen]<>'}' then begin
  {$endif}
    exit;
  end;
  //- Get the GUID.
  {$ifdef NEXTGEN}
  GUID := Copy(SourceStr,0,cGUIDLen);
  {$else}
  GUID := Copy(SourceStr,1,cGUIDLen);
  {$endif}
  //- Get the remaining text.
  if Length(SourceStr)=cGUIDLen then begin
    Result := True;
    exit;
  end;
  RemainingChars := Length(SourceStr)-cGUIDLen;
  {$ifdef NEXTGEN}
  MessageText := Trim(Copy(SourceStr,cGUIDLen,RemainingChars));
  {$else}
  MessageText := Trim(Copy(SourceStr,succ(cGUIDLen),RemainingChars));
  {$endif}
  Result := True;
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

function TLog.Insert(const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  GUID: TGUID;
  GUIDStr: string;
  EntryString: string;
begin
  Result := TStatus.Unknown;
  //- Separate out the GUID and MessageText.
  if not ParseLogEntryDeclaration(string(LogEntry), GUIDStr, EntryString) then begin
    {$ifdef fpc}
    raise
      EInvalidLogEntry.Create(ansistring('Unable to parse log entry "'+LogEntry+'"'));
    {$else}
    raise
      EInvalidLogEntry.Create('Unable to parse log entry "'+LogEntry+'"');
    {$endif}
  end;
  {$ifdef fpc}
  GUID := StringToGUID(ansistring(GUIDStr));
  {$else}
  GUID := StringToGUID(GUIDStr);
  {$endif}
  Result := Insert( GUID, EntryString, Severity, Parameters );
end;

function TLog.Insert(const LogEntry: string; const Severity: TLogSeverity): TStatus;
begin
  Result := Insert( LogEntry, Severity, [] );
end;

{$if defined(fpc) or defined(MSWINDOWS)}
function TLog.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity ): TStatus;
begin
  Result := Insert( string(LogEntry), Severity );
end;
{$endif}

{$if defined(fpc) or defined(MSWINDOWS)}
function TLog.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
begin
  Result := Insert( string(LogEntry), Severity, Parameters );
end;
{$endif}

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

{$ifdef fpc}
{$hints off}
function IterateResourceStrings( Name, Value: AnsiString; Hash: Longint; arg: pointer ): AnsiString;
var
  ValueStr: string;
begin
  Result := Value;
  ValueStr := string(Value);
  Log.RegisterLogEntry(ValueStr);
end;
{$hints on}
{$endif}

initialization
  {$ifdef fpc}SetResourceStrings(IterateResourceStrings,nil);{$endif}

finalization
  SingletonLog := nil;

end.
