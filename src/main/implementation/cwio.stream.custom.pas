{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwIO.Stream.Custom;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  cwLog
, cwIO
;

type
  /// <summary>
  ///   Base class for classes which implement IStream. <br />You should not
  ///   create an instance directly, but derrive from this class to provide
  ///   streams with CopyFrom() and getEndOfStream() support.
  /// </summary>
  TCustomStream = class( TInterfacedObject, IStream )
  private
    fLog: ILog;
    fName: string;
  protected //- IStream -//
    procedure Clear; virtual;
    procedure WriteBytes( const value: array of uint8 ); virtual;
    procedure WriteByte( const value: uint8 ); virtual;
    function ReadByte: uint8; virtual;
    function Read( const p: pointer; const Count: nativeuint ): nativeuint; virtual; abstract;
    function Write( const p: pointer; const Count: nativeuint ): nativeuint; virtual; abstract;
    function getSize: nativeuint; virtual; abstract;
    function getPosition: nativeuint; virtual; abstract;
    procedure setPosition( const newPosition: nativeuint ); virtual; abstract;
    function getRemainingBytes: nativeuint;
    function getName: string;
    procedure setName( const value: string );
  protected
    function CopyFrom( const Source: IStream ): nativeuint; virtual;
    function getEndOfStream: boolean; virtual;
  public
    constructor Create(const Log: ILog = nil); reintroduce;
    destructor Destroy; override;
  public
    property EndOfStream: boolean read getEndOfStream;
    property Position: nativeuint read getPosition write setPosition;
    property Size: nativeuint read getSize;
  end;

implementation
uses
  sysutils  //[RTL]
, cwRuntime.LogEntries
, cwLog.Standard
;

function TCustomStream.getRemainingBytes: nativeuint;
begin
  Result := (Self.Size - Self.Position);
end;

function TCustomStream.ReadByte: uint8;
var
  b: uint8;
begin
  Self.Read(@b,1);
  Result := B;
end;

procedure TCustomStream.setName(const value: string);
begin
  fName := value;
end;

procedure TCustomStream.WriteByte(const value: uint8);
var
  B: uint8;
begin
  B := value;
  Self.Write(@b,1);
end;

procedure TCustomStream.WriteBytes(const value: array of uint8);
begin
  Self.Write(@value[0],Length(value))
end;

procedure TCustomStream.Clear;
begin
  Log.Insert( le_StreamDoesNotSupportClear, TLogSeverity.lsFatal );
end;

function TCustomStream.CopyFrom(const Source: IStream): nativeuint;
const
  cCopyBlockSize = 1024;
var
  Buffer: array of uint8;
  ReadBytes: nativeuint;
  WrittenBytes: nativeuint;
begin
  Result := 0;
  Initialize(Buffer);
  try
    SetLength(Buffer,cCopyBlockSize);
    if not Source.getEndOfStream then begin
      repeat
        ReadBytes := Source.Read( @Buffer[0], cCopyBlockSize );
        WrittenBytes := Write( @Buffer[0], ReadBytes );
        Result := Result + WrittenBytes;
      until (ReadBytes<cCopyBlockSize) or (not WrittenBytes=ReadBytes) or (Source.getEndOfStream);
    end;
  finally
    Finalize(Buffer);
  end;
end;

constructor TCustomStream.Create(const Log: ILog = nil);
begin
  inherited Create;
  fLog := Log;
  fName := '';
end;

destructor TCustomStream.Destroy;
begin
  fLog := nil;
  inherited Destroy;
end;

function TCustomStream.getEndOfStream: boolean;
begin
  Result := getPosition()=getSize();
end;


function TCustomStream.getName: string;
begin
  Result := fName;
end;

end.


