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
  TLogDynamic = class( TInterfacedObject, ILog )
  private
    fLogBinding: TLogBinding;
    fProxyLogTargets: IList<IInterface>;
  strict private //- ILog -//
    function RegisterLogEntry( const EntryString: string ): boolean;
    procedure AddLogTarget( const LogTarget: ILogTarget );
    function ExportTranslationFile( const FilePath: string ): TStatus;
    function ImportTranslationFile( const FilePath: string ): TStatus;
    {$if defined(fpc) or defined(MSWINDOWS)}
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity ): TStatus; overload;
    {$endif}
    {$if defined(fpc) or defined(MSWINDOWS)}
    function Insert( const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    {$endif}
    function Insert( const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;
    function Insert( const LogEntry: string; const Severity: TLogSeverity ): TStatus; overload;
    function getLastEntry: string;
  public
    constructor Create( const LogBinding: TLogBinding ); reintroduce;
    destructor Destroy; override;
  end;

function Log: ILog;

implementation
uses
  cwUnicode.Standard
, cwCollections.Standard
, cwLog.Common
;

function Log: ILog;
var
  LogBinding: TLogBinding;
begin
  Result := nil;
  if (
       assigned(SingletonLog) and (not (SingletonLog is TLogDynamic))
     ) or
     (not assigned(SingletonLog)) then begin
    if not TLogBinding.Create( LogBinding ).IsSuccess then begin
      exit;
    end;
    SingletonLog := TLogDynamic.Create(LogBinding);
  end;
  Result := SingletonLog;
end;

function TLogDynamic.RegisterLogEntry(const EntryString: string): boolean;
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

procedure TLogDynamic.AddLogTarget(const LogTarget: ILogTarget);
begin
  fProxyLogTargets.Add( TProxyLogTarget.Create( LogTarget, fLogBinding ) );
end;

function TLogDynamic.ExportTranslationFile(const FilePath: string): TStatus;
var
  Unifilepath: TUnicodeString;
begin
  UniFilepath.AsString := FilePath;
  Result := fLogBinding.ExportTranslations(UniFilepath.AsPtr);
end;

function TLogDynamic.ImportTranslationFile(const FilePath: string): TStatus;
var
  Unifilepath: TUnicodeString;
begin
  UniFilepath.AsString := FilePath;
  Result := fLogBinding.ImportTranslations(UniFilepath.AsPtr);
end;

{$if defined(fpc) or defined(MSWINDOWS)}
function TLogDynamic.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity): TStatus;
var
  Str: TUnicodeString;
begin
  Str.AsString := LogEntry.AsString;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,nil);
end;
{$endif}

{$if defined(fpc) or defined(MSWINDOWS)}
function TLogDynamic.Insert(const LogEntry: AnsiString; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  Str: TUnicodeString;
  ParamStr: TUnicodeString;
  ParamArray: TArrayOfString;
  StrParameters: string;
begin
  Str.AsString := LogEntry.AsString;
  {$warnings off} ParamArray.AssignArray(Parameters); {$warnings on}
  StrParameters := '';
  StrParameters.Combine(LF,ParamArray);
  ParamStr.AsString := StrParameters;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,ParamStr.AsPtr);
end;
{$endif}

function TLogDynamic.Insert(const LogEntry: string; const Severity: TLogSeverity; const Parameters: array of string): TStatus;
var
  S: string;
  Str: TUnicodeString;
  ParamStr: TUnicodeString;
  ParamArray: TArrayOfString;
begin
  Str.AsString := LogEntry;
  {$warnings off} ParamArray.AssignArray(Parameters); {$warnings on}
  S := '';
  S.Combine(LF,ParamArray);
  ParamStr := S;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,ParamStr.AsPtr);
end;

function TLogDynamic.Insert(const LogEntry: string; const Severity: TLogSeverity): TStatus;
var
  Str: TUnicodeString;
begin
  Str.AsString := LogEntry;
  Result := fLogBinding.InsertLogEntryByString(Str.AsPtr,Severity,nil);
end;

function TLogDynamic.getLastEntry: string;
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

constructor TLogDynamic.Create( const LogBinding: TLogBinding );
begin
  inherited Create;
  fProxyLogTargets := TList<IInterface>.Create;
  fLogBinding := LogBinding;
end;

destructor TLogDynamic.Destroy;
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

