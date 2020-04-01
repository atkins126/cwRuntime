{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwIO.FileStream.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  Classes //[RTL]
, cwIO
, cwIO.UnicodeStream.Custom
;

type
  TFileStream = class( TCustomUnicodeStream, IStream, IUnicodeStream )
  private
    fFilePath: string;
    fSysFileStream: classes.TFileStream;
  protected
    procedure Clear; override;
    function Read( const p: pointer; const Count: nativeuint ): nativeuint; override;
    function Write( const p: pointer; const Count: nativeuint ): nativeuint; override;
    function getSize: nativeuint; override;
    function getPosition: nativeuint; override;
    procedure setPosition( const newPosition: nativeuint ); override;
  public
    constructor Create( const Filepath: string; const ReadOnly: boolean ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils //[RTL]
, cwTypes
;

procedure TFileStream.Clear;
begin
  {$ifdef fpc}
  fSysFileStream.Free;
  {$else}
  fSysFileStream.DisposeOf;
  {$endif}
  fSysFileStream := nil;
  if FileExists(fFilePath) then begin
    DeleteFile(fFilePath);
  end;
  fSysFileStream := classes.TFileStream.Create(fFilePath{$ifdef fpc}.AsAnsiString{$endif},fmCreate);
end;

constructor TFileStream.Create( const Filepath: string; const ReadOnly: boolean );
begin
  inherited Create;
  fFilepath := FilePath;
  if ReadOnly then begin
    fSysFileStream := classes.TFileStream.Create(fFilepath{$ifdef fpc}.AsAnsiString{$endif},fmOpenRead);
  end else begin
    if FileExists(FilePath) then begin
      fSysFileStream := classes.TFileStream.Create(fFilepath{$ifdef fpc}.AsAnsiString{$endif},fmOpenReadWrite);
    end else begin
      fSysFileStream := classes.TFileStream.Create(fFilepath{$ifdef fpc}.AsAnsiString{$endif},fmCreate);
    end;
  end;
end;

destructor TFileStream.Destroy;
begin
  {$ifdef fpc}
  fSysFileStream.Free;
  {$else}
  fSysFileStream.DisposeOf;
  {$endif}
  inherited;
end;

function TFileStream.getPosition: nativeuint;
begin
  Result := fSysFileStream.Position;
end;

function TFileStream.getSize: nativeuint;
begin
  Result := fSysFileStream.Size;
end;

function TFileStream.Read(const p: pointer; const Count: nativeuint): nativeuint;
begin
  Result := fSysfileStream.Read(p^,Count);
end;

procedure TFileStream.setPosition(const newPosition: nativeuint);
begin
  fSysFileStream.Position := newPosition;
end;

function TFileStream.Write(const p: pointer; const Count: nativeuint): nativeuint;
begin
  Result := fSysFileStream.Write(p^,Count);
end;

end.
