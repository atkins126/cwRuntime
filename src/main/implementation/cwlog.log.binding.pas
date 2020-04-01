{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwLog.Log.Binding;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
, cwDynLib
;

type
  TProxyLogMethod = procedure( const _Obj: pointer; const LogEntry: TGUID; const lpszTranslatedText: pointer; const TS: TDateTime; const Severity: TLogSeverity; const lpszParameters: pointer ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}

type
  TLogBinding = record
    DynLib: IDynLib;
    //- Binds
    getVersionMajor: function: nativeuint; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    getVersionMinor: function: nativeuint; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    RegisterLogEntry: function( const lpszEntryString: pointer ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    InsertLogEntryByString: function( const lpszLogEntry: pointer; const Severity: TLogSeverity; const Parameters: pointer ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    getLastEntry: function( const lpszBuffer: pointer; out szBuffer: nativeuint ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    AddProxyLogTarget: function( const Obj: pointer; const Method: TProxyLogMethod ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
    //- factory
    class function Create( out LogBinding: TLogBinding ): TStatus; static;
  end;

type
  TProxyLogTarget = class( TInterfacedObject, IInterface )
  private
    fProxyLogTarget: ILogTarget;
    fLogBinding: TLogBinding;
  public
    procedure Insert( const LogEntry: TGUID; const lpszTranslatedText: pointer; const TS: TDateTime; const Severity: TLogSeverity; const lpszParameters: pointer );
  public
    constructor Create(const LogTarget: ILogTarget; const LogBinding: TLogBinding); reintroduce;
  end;

implementation
uses
  cwTypes
, cwUnicode.Standard
, cwDynLib.Standard
;

{$region ' Shared object library filename (used when using dynamic binding)'}
const
  {$ifdef MSWINDOWS}
   cLibName = 'lib_cwLog.dll';
  {$else}
    {$ifdef MACOS}
      cLibName = 'lib_cwLog.dynlib';
    {$else}
      cLibName = 'lib_cwLog.so';
    {$endif}
  {$endif}
{$endregion}

procedure ProxyMethod( const _Obj: pointer; const LogEntry: TGUID; const lpszTranslatedText: pointer; const TS: TDateTime; const Severity: TLogSeverity; const lpszParameters: pointer ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  TProxyLogTarget(_Obj).Insert( LogEntry, lpszTranslatedText, TS, Severity, lpszParameters );
end;

class function TLogBinding.Create(out LogBinding: TLogBinding): TStatus;
  function GetProcAddress( var DynLib: IDynLib; const MethodName: string; var MethodPtr: pointer ): boolean;
  begin
    Result := False;
    if not DynLib.GetProcAddress(MethodName,MethodPtr) then begin
      DynLib := nil;
      MethodPtr := nil;
      exit;
    end;
    Result := True;
  end;
begin
  Result := TStatus.Unknown;
  LogBinding.DynLib := TDynLib.Create;
  if not LogBinding.DynLib.LoadLibrary(cLibName) then begin
    LogBinding.DynLib := nil;
    exit;
  end;
  if not GetProcAddress( LogBinding.DynLib, 'getVersionMajor',        @LogBinding.getVersionMajor )        then exit;
  if not GetProcAddress( LogBinding.DynLib, 'getVersionMinor',        @LogBinding.getVersionMinor )        then exit;
  if not GetProcAddress( LogBinding.DynLib, 'RegisterLogEntry',       @LogBinding.RegisterLogEntry )       then exit;
  if not GetProcAddress( LogBinding.DynLib, 'InsertLogEntryByString', @LogBinding.InsertLogEntryByString ) then exit;
  if not GetProcAddress( LogBinding.DynLib, 'getLastEntry',           @LogBinding.getLastEntry )           then exit;
  if not GetProcAddress( LogBinding.DynLib, 'AddProxyLogTarget',      @LogBinding.AddProxyLogTarget )      then exit;
  Result := TStatus.Success;
end;

procedure TProxyLogTarget.Insert(const LogEntry: TGUID; const lpszTranslatedText: pointer; const TS: TDateTime; const Severity: TLogSeverity; const lpszParameters: pointer);
var
  TextUTF: TUnicodeString;
  ParamUTF: TUnicodeString;
  ParamStr: string;
  Parameters: TArrayOfString;
begin
  TextUTF.AsPtr := lpszTranslatedText;
  ParamUTF.AsPtr := lpszParameters;
  ParamStr := ParamUTF.AsString;
  Parameters := ParamStr.Explode(LF);
  fProxyLogTarget.Insert(LogEntry,TextUTF.AsString,TS,Severity,Parameters);
end;

constructor TProxyLogTarget.Create(const LogTarget: ILogTarget; const LogBinding: TLogBinding);
begin
  inherited Create;
  fProxyLogTarget := LogTarget;
  fLogBinding := LogBinding;
  fLogBinding.AddProxyLogTarget(Self,@ProxyMethod);
end;


end.

