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
/// <summary>
///   Chapmanworld Logging system library.
/// </summary>
library lib_cwLog;
{$ifdef fpc}{$mode delphiunicode}{$endif}
uses
  sysutils //[RTL] for exception
, cwUnicode
, cwUnicode.Standard
, cwTypes
;

const
  cVersionMajor = 1;
  cVersionMinor = 0;

function getVersionMajor: nativeuint; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
begin
  Result := cVersionMajor;
end;

function getVersionMinor: nativeuint; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
begin
  Result := cVersionMinor;
end;

function RegisterLogEntry( const lpszEntryString: pointer ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
var
  Str: TUnicodeString;
begin
  Result := TStatus.Unknown;
  try
    Str.AsPtr := lpszEntryString;
    Log.RegisterLogEntry(Str.AsString);
  except
    on E: Exception do begin
      exit;
    end;
    else exit;
  end;
  Result := TStatus.Success;
end;

function InsertLogEntryByString( const lpszLogEntry: pointer; const Severity: TLogSeverity; const lpszParameters: pointer ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
var
  Str: TUnicodeString;
  ParamStr: TUnicodeString;
  Params: TArrayOfString;
begin
  Result := TStatus.Unknown;
  try
    Str.AsPtr := lpszLogEntry;
    ParamStr.AsPtr := lpszParameters;
    Params := ParamStr.AsString.Explode(LF);
    Result := Log.Insert(Str.AsString,Severity,Params);
  except
    on E: Exception do begin
      exit;
    end;
    else exit;
  end;
end;

function getLastEntry( const lpszBuffer: pointer; out szBuffer: nativeuint ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
var
  Str: TUnicodeString;
begin
  Result := TStatus.Unknown;
  try
    Str.AsString := Log.getLastEntry;
    szBuffer := Str.Size;
    if not assigned(lpszBuffer) then begin
      Result := TStatus.Success;
      exit;
    end;
    Move( Str.AsPtr^, lpszBuffer^, szBuffer );
  except
    on E: Exception do begin
      exit;
    end;
    else exit;
  end;
  Result := TStatus.Success;
end;

/// Adds a proxy log target to the actual log.
/// When the proxy log target .Insert() method is called, it forwards
/// the log message to the provided Method.
function AddProxyLogTarget( const Obj: pointer; const Method: TProxyLogMethod ): TStatus; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
begin
  Result := TStatus.Unknown;
  try
    Log.AddLogTarget(TProxyLogTarget.Create(Method,Obj));
  except
    on E: Exception do begin
      exit;
    end;
    else exit;
  end;
  Result := TStatus.Success;
end;

exports
  getVersionMajor
, getVersionMinor
, RegisterLogEntry
, InsertLogEntryByString
, getLastEntry
, AddProxyLogTarget
;

begin
end.
