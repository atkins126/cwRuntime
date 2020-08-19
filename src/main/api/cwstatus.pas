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
unit cwStatus;
{$ifdef fpc}
  {$mode delphiunicode}
  {$MODESWITCH ADVANCEDRECORDS}
  {$MODESWITCH TYPEHELPERS}
{$endif}

interface
uses
  sysutils  // for Exception & TGUID
, cwStatus.Parameterized
;

{$region ' Exceptions which may be raised by cwStatus'}

type
  /// <summary>
  ///   Exception raised when the TStatus.Raize method is called.
  /// </summary>
  EStatus = class(Exception)
  private
    function getMessage: string;
    procedure setMessage( const value: string );
  public
    property Message: string read getMessage write setMessage;
  end;

  /// <summary>
  ///  This exception is raised if an attempt is made to set a status
  ///  using an ansi-string which does not contain a valid guid.
  /// </summary>
  EInvalidStatusGUID = class(Exception);

{$endregion}

{$region ' The TStatus data type.'}
type
  /// <summary>
  /// </summary>
  TStatus = record
  private
    GUID: TGUID;
    Parameterized: IStatusParameterizedMessage;
  private
    procedure ParameterizeMessage(const Parameters: array of string);
    function GetText: string; overload;
  public
    class operator Implicit(const a: TStatus): string;
    class operator Explicit(const a: TStatus): string;
    class operator Implicit(const a: ansistring): TStatus;
    class operator Explicit(const a: ansistring): TStatus;

    class operator Implicit(const a: TStatus): Boolean;
    class operator Explicit(const a: TStatus): Boolean;
    class operator LogicalNot(const a: TStatus): Boolean;
    class operator Equal( const a: TStatus; const b: TStatus ): boolean;
    class operator NotEqual( const a: TStatus; const b: TStatus ): boolean;

    class operator Equal( const a: TStatus; const b: ansistring ): boolean;
    class operator NotEqual( const a: TStatus; const b: ansistring ): boolean;
    class operator Equal( const a: ansistring; const b: TStatus ): boolean;
    class operator NotEqual( const a: ansistring; const b: TStatus ): boolean;

    class function Unknown: TStatus; static;
    class function Success: TStatus; static;
    procedure Raize( const Parameters: array of string ); overload;
    procedure Raize; overload;
    class procedure Raize( const Status: TStatus; const Parameters: array of string ); overload; static;
    class procedure Raize( const Status: TStatus ); overload; static;
    function Return( const Parameters: array of string ): TStatus; overload;
    function Return: TStatus; overload;
    class function Return( const Status: TStatus; const Parameters: array of string ): TStatus; overload; static;
    class function Return( const Status: TStatus ): TStatus; overload; static;
    class procedure Register(const a: ansistring); static;
  end;

{$endregion}

implementation
uses
  cwStatus.Messages
, cwStatus.Placeholders
;

resourcestring
  {$hints off} stSuccess = '{00000000-0000-0000-0000-000000000000} SUCCESS'; {$hints on}
  {$hints off} stUnknown = '{01010101-0101-0101-0101-010101010101} UNKNOWN'; {$hints on}

const
  cSuccess : TGUID = '{00000000-0000-0000-0000-000000000000}';
  cUnknown : TGUID = '{01010101-0101-0101-0101-010101010101}';


function EStatus.getMessage: string;
begin
  Result := string(inherited Message);
end;

procedure EStatus.setMessage(const value: string);
begin
  inherited Message := ansistring(value);
end;

class operator TStatus.Implicit(const a: TStatus): string;
begin
  Result := a.GetText;
end;

class operator TStatus.Explicit(const a: TStatus): string;
begin
  Result := a.GetText;
end;

class operator TStatus.Implicit(const a: ansistring): TStatus;
begin
  if not TMessageDictionary.ReadGUID(a,Result.GUID) then begin
    raise
      EInvalidStatusGUID.Create(a);
  end;
end;

class operator TStatus.Explicit(const a: ansistring): TStatus;
begin
  if not TMessageDictionary.ReadGUID(a,Result.GUID) then begin
    raise
      EInvalidStatusGUID.Create(a);
  end;
end;

class operator TStatus.Implicit(const a: TStatus): Boolean;
begin
  Result := IsEqualGUID(cSuccess,a.GUID);
end;

class operator TStatus.Explicit(const a: TStatus): Boolean;
begin
  Result := IsEqualGUID(cSuccess,a.GUID);
end;

class operator TStatus.LogicalNot(const a: TStatus): Boolean;
begin
  Result := not IsEqualGUID(a.GUID,cSuccess);
end;

class operator TStatus.Equal(const a: TStatus; const b: TStatus): boolean;
begin
  Result := IsEqualGUID(a.GUID,b.GUID);
end;

class operator TStatus.NotEqual(const a: TStatus; const b: TStatus): boolean;
begin
  Result := not IsEqualGUID(a.GUID,b.GUID);
end;

class operator TStatus.Equal(const a: TStatus; const b: ansistring): boolean;
var
  bGUID: TGUID;
begin
  if not TMessageDictionary.ReadGUID(b,bGUID) then begin
    raise
      EInvalidStatusGUID.Create(b);
  end;
  Result := IsEqualGUID(a.GUID,bGUID);
end;

class operator TStatus.NotEqual(const a: TStatus; const b: ansistring): boolean;
var
  bGUID: TGUID;
begin
  if not TMessageDictionary.ReadGUID(b,bGUID) then begin
    raise
      EInvalidStatusGUID.Create(b);
  end;
  Result := not IsEqualGUID(a.GUID,bGUID);
end;

class operator TStatus.Equal(const a: ansistring; const b: TStatus): boolean;
var
  aGUID: TGUID;
begin
  if not TMessageDictionary.ReadGUID(a,aGUID) then begin
    raise
      EInvalidStatusGUID.Create(a);
  end;
  Result := IsEqualGUID(aGUID,b.GUID);
end;

class operator TStatus.NotEqual(const a: ansistring; const b: TStatus): boolean;
var
  aGUID: TGUID;
begin
  if not TMessageDictionary.ReadGUID(a,aGUID) then begin
    raise
      EInvalidStatusGUID.Create(a);
  end;
  Result := not IsEqualGUID(aGUID,b.GUID);
end;

class function TStatus.Unknown: TStatus;
begin
  Result.GUID := cUnknown;
end;

class function TStatus.Success: TStatus;
begin
  Result.GUID := cSuccess;
end;

procedure TStatus.ParameterizeMessage(const Parameters: array of string);
var
  S: string;
begin
  //- Get the text to be parameterized.
  Parameterized := nil;
  S := GetText;
  Parameterized := TStatusParameterizedMessage.Create;
  Parameterized.Message := S;
  Parameterized.Message := TPlaceholders.ParameterizeString(Parameterized.Message,Parameters);
end;

function TStatus.Return(const Parameters: array of string): TStatus;
begin
  ParameterizeMessage( Parameters );
  Result := Self;
end;

function TStatus.Return: TStatus;
begin
  Result := Return([]);
end;

function TStatus.GetText: string;
begin
  if assigned(Parameterized) then begin
    Result := Parameterized.Message;
    exit;
  end;
  if not TMessageDictionary.FindEntry(GUID,Result) then begin
    Result := string(GUIDToString(GUID));
  end;
end;

procedure TStatus.Raize(const Parameters: array of string);
begin
  {$hints off} if IsEqualGUID(GUID,cSuccess) then exit; {$hints on}
  if Length(Parameters)<>0 then begin
    ParameterizeMessage( Parameters );
  end;
  raise
    EStatus.Create(ansistring(GetText()));
end;

procedure TStatus.Raize;
begin
  Raize([]);
end;

class procedure TStatus.Raize(const Status: TStatus; const Parameters: array of string);
begin
  Status.Raize(Parameters);
end;

class procedure TStatus.Raize(const Status: TStatus);
begin
  Status.Raize([]);
end;

class function TStatus.Return(const Status: TStatus; const Parameters: array of string): TStatus;
begin
  Result := Status.Return(Parameters);
end;

class function TStatus.Return(const Status: TStatus): TStatus;
begin
  Result := Status.Return([]);
end;

class procedure TStatus.Register(const a: ansistring);
var
  GUID: TGUID;
  StatusText: string;
begin
  try
    if not TMessageDictionary.SplitStatusText(a,GUID,StatusText) then exit;
  except
    on E: Exception do exit;
    else exit;
  end;
  TMessageDictionary.RegisterEntry(GUID,StatusText);
end;

end.

