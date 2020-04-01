{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwlog.log.dynamic;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
, cwTypes
, cwCollections
, cwLog.Log.Binding
;

type
  TLog = class( TInterfacedObject, ILog )
  private
    fLogBinding: TLogBinding;
    fProxyLogTargets: IList<IInterface>;
  strict private //- ILog -//
    function RegisterLogEntry( const EntryString: string ): boolean;
    procedure AddLogTarget( const LogTarget: ILogTarget );
    function ExportTranslationFile( const FilePath: string ): TStatus;
    function ImportTranslationFile( const FilePath: string ): TStatus;
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity ): TStatus; overload;
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: string; const Severity: TLogSeverity ): TStatus; overload;
    function getLastEntry: string;
  public
    constructor Create( const LogBinding: TLogBinding ); reintroduce;
    destructor Destroy; override;
  end;

///  <summary>
///    Returns the singleton instance of ILog.
///  </summary>
function Log: ILog;

implementation
uses
  cwUnicode.Standard
, cwCollections.Standard
;

var
  SingletonLog: ILog = nil;

function Log: ILog;
var
  LogBinding: TLogBinding;
begin
  if not assigned(SingletonLog) then begin
    if not TLogBinding.Create( LogBinding ).IsSuccess then begin
      Result := nil;
      exit;
    end;
    SingletonLog := TLog.Create(LogBinding);
  end;
  Result := SingletonLog;
end;

function TLog.RegisterLogEntry(const EntryString: string): boolean;
var
  Str: TUnicodeString;
begin
  Result := False;
  Str.AsString := EntryString;
  if not fLogBinding.RegisterLogEntry( Str.AsPtr ).IsSuccess then begin
    exit;
  end;
  Result := True;
end;

procedure TLog.AddLogTarget(const LogTarget: ILogTarget);
begin
  fProxyLogTargets.Add( TProxyLogTarget.Create( LogTarget, fLogBinding ) );
end;

function TLog.ExportTranslationFile(const FilePath: string): TStatus;
begin
  //-
end;

function TLog.ImportTranslationFile(const FilePath: string): TStatus;
begin
  //-
end;

function TLog.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity): TStatus;
var
  Str: TUnicodeString;
begin
  Str.AsString := LogEntry.AsString;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,nil);
end;

function TLog.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  Str: TUnicodeString;
  ParamStr: TUnicodeString;
  ParamArray: TArrayOfString;
  StrParameters: string;
begin
  Str.AsString := LogEntry.AsString;
  {$warnings off} ParamArray.AssignArray(Parameters); {$warnings on}
  StrParameters.Combine(LF,ParamArray);
  ParamStr.AsString := StrParameters;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,ParamStr.AsPtr);
end;

function TLog.Insert(const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  Str: TUnicodeString;
  ParamStr: TUnicodeString;
  ParamArray: TArrayOfString;
begin
  Str.AsString := LogEntry;
  {$warnings off} ParamArray.AssignArray(Parameters); {$warnings on}
  ParamStr.AsString.Combine(LF,ParamArray);
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,ParamStr.AsPtr);
end;

function TLog.Insert(const LogEntry: string; const Severity: TLogSeverity): TStatus;
var
  Str: TUnicodeString;
begin
  Str.AsString := LogEntry;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,nil);
end;

function TLog.getLastEntry: string;
var
  Buffer: array of uint8;
  Size: nativeuint;
  Str: TUnicodeString;
begin
  Result := '';
  if not fLogBinding.getLastEntry(nil,Size).IsSuccess then begin
    exit;
  end;
  {$hints off} SetLength(Buffer,Size); {$hints on}
  try
    if not fLogBinding.getLastEntry(@Buffer[0],Size).IsSuccess then begin
      exit;
    end;
    Str.AsPtr := @Buffer[0];
    Result := Str.AsString;
  finally
    SetLength(Buffer,0);
  end;
end;

constructor TLog.Create( const LogBinding: TLogBinding );
begin
  inherited Create;
  fProxyLogTargets := TList<IInterface>.Create;
  fLogBinding := LogBinding;
end;

destructor TLog.Destroy;
begin
  fProxyLogTargets := nil;
  inherited Destroy;
end;

{$endregion}

{$ifdef fpc}
{$hints off}
function IterateResourceStrings( Name, Value: AnsiString; Hash: Longint; arg: pointer ): AnsiString;
var
  ValueStr: string;
begin
  Result := Value;
  if not assigned(SingletonLog) then begin
    Log();
  end;
  if not assigned(SingletonLog) then begin
    exit;
  end;
  ValueStr := string(Value);
  SingletonLog.RegisterLogEntry(ValueStr);
end;
{$hints on}
{$endif}

initialization
  {$ifdef fpc}SetResourceStrings(IterateResourceStrings,nil);{$endif}

finalization
  SingletonLog := nil;

end.

