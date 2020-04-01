{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <summary>
///   Provides the standard implementation, conditionally selecting the
///   appropriate implementation for the target platform.
/// </summary>
unit cwDynLib.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
 cwDynLib
;

type
  TDynlib = class( TInterfacedObject, IDynlib )
  private
    fHandle: nativeuint;
  protected //- IDynlib -//
    function LoadLibrary( const filepath: string ): boolean;
    function FreeLibrary: boolean;
    function GetProcAddress( const funcName: string; out ptrProc: pointer ): boolean; overload;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils
  {$ifdef MSWINDOWS}
  {$ifndef fpc}
  , Posix.errno
  {$endif}
  {$endif}
;

{$ifdef MSWINDOWS}
  function winLoadLibrary( lpLibFileName: pointer ): nativeuint; stdcall; external 'kernel32' name 'LoadLibraryA';
  function winFreeLibrary( hLibModule: nativeuint ): boolean; stdcall; external 'kernel32' name 'FreeLibrary';
  function winGetProcAddress( hModule: nativeuint; lpProcName: pointer ): pointer; stdcall; external 'kernel32' name 'GetProcAddress';
  function winGetLastError(): uint32; stdcall; external 'kernel32' name 'GetLastError';
{$else}
  {$ifdef MACOS} //- MACOS
  const
    clibname = 'libdl.dylib';

  // MacOS x86 symbol exports have preceeding underscore.
  function dlopen( filename: pointer; flags: int32 ): pointer; cdecl; external clibname name '_dlopen';
  function dlsym( handle: pointer; symbolname: pointer ): pointer; cdecl; external clibname name '_dlsym';
  function dlclose( handle: pointer ): int32; cdecl; external clibname name '_dlclose';

  {$else} //- Posix

  const
    clibname = 'libdl.so';
    cSuccess = 0;
    cRTLD_LAZY = 1;

  function dlopen( filename: pointer; flags: int32 ): pointer; cdecl; external clibname name 'dlopen';
  function dlsym( handle: pointer; symbolname: pointer ): pointer; cdecl; external clibname name 'dlsym';
  function dlclose( handle: pointer ): int32; cdecl; external clibname name 'dlclose';

  {$endif}
{$endif}

constructor TDynlib.Create;
begin
  inherited Create;
  fHandle := 0;
end;

destructor TDynlib.Destroy;
begin
  if fHandle<>0 then begin
    FreeLibrary;
  end;
  inherited Destroy;
end;

function TDynlib.FreeLibrary: boolean;
begin
  Result := False;
  if fHandle=0 then begin
    exit;
  end;
  {$ifdef MSWINDOWS}
  if not winFreeLibrary(fHandle) then begin
    fHandle := 0;
    exit;
  end;
  {$else}
  {$hints off}
  if not (dlClose(pointer(fHandle)) = cSuccess) then begin
  {$hints on}
    fHandle := 0;
    exit;
  end;
  {$endif}
  fHandle := 0;
  Result := True;
end;

function TDynlib.GetProcAddress(const funcName: string; out ptrProc: pointer): boolean;
begin
  Result := False;
  {$ifdef MSWINDOWS}
    ptrProc := winGetProcAddress(fHandle,pAnsiChar(UTF8Encode(funcName)));
  {$else}
    {$hints off}
    ptrProc := dlSym( pointer(fHandle), pointer(UTF8Encode(funcname)) );
    {$hints on}
  {$endif}
  if not assigned(ptrProc) then begin
    exit;
  end;
  Result := True;
end;

function TDynlib.LoadLibrary(const filepath: string): boolean;
begin
  Result := False;
  {$ifdef MSWINDOWS}
  fHandle := winLoadLibrary(pAnsiChar(UTF8Encode(filepath)));
  {$else}
  {$hints off}
  fHandle := NativeUInt( dlOpen(pointer(UTF8Encode(filepath)),cRTLD_LAZY) );
  {$hints on}
  {$endif}
  if fHandle=0 then begin
    exit;
  end;
  Result := True;
end;

end.


