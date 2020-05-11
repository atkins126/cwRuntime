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
unit cwIO.TypedBuffer.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwIO
, cwIO.Buffer.Standard
;

type
  TTypedBuffer<T> = class( TInterfacedObject, ITypedBuffer<T> )
  private
    fCount: nativeuint;
    fItemSize: nativeuint;
    fBuffer: IBuffer;
  strict private //- IBuffer -//
    procedure FillMem( const value: uint8 );
    function LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    function SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    procedure Assign( const Buffer: IBuffer );
    procedure InsertData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint );
    function AppendData( const Buffer: Pointer; const Bytes: nativeuint ): pointer; overload;
    function AppendData( const Buffer: pointer ): pointer; overload;
    procedure ExtractData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint );
    function getSize: nativeuint;
    function getByte( const idx: nativeuint ): uint8;
    procedure setByte( const idx: nativeuint; const value: uint8 );
    procedure setSize( const aSize: nativeuint );
  strict private //- ITypedBuffer<T> -//
    procedure Fill( const Value: T );
    function getDataPointer: pointer;
    function getCount: nativeuint;
    procedure setCount( const value: nativeuint );
    function getValue( const Index: nativeuint ): T;
    procedure setValue( const Index: nativeuint; value: T );
  public
    constructor Create(const Items: nativeuint; const Align16: boolean = FALSE); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils
;

procedure TTypedBuffer<T>.FillMem(const value: uint8);
begin
  fBuffer.FillMem(Value);
end;

function TTypedBuffer<T>.LoadFromStream(const Stream: IStream; const Bytes: nativeuint): nativeuint;
begin
  Result := fBuffer.LoadFromStream(Stream,Bytes);
end;

function TTypedBuffer<T>.SaveToStream(const Stream: IStream; const Bytes: nativeuint): nativeuint;
begin
  Result := fBuffer.SaveToStream(Stream,Bytes);
end;

procedure TTypedBuffer<T>.Assign(const Buffer: IBuffer);
begin
  fBuffer.Assign(Buffer);
end;

procedure TTypedBuffer<T>.InsertData(const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint);
begin
  fBuffer.InsertData(Buffer,Offset,Bytes);
end;

function TTypedBuffer<T>.AppendData(const Buffer: Pointer; const Bytes: nativeuint): pointer;
begin
  Result := fBuffer.AppendData(Buffer,Bytes);
  fCount := fBuffer.Size div fItemSize;
end;

function TTypedBuffer<T>.AppendData(const Buffer: pointer): pointer;
begin
  Result := fBuffer.AppendData(Buffer);
  fCount := fBuffer.Size div fItemSize;
end;

procedure TTypedBuffer<T>.ExtractData(const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint);
begin
  fBuffer.ExtractData(Buffer,Offset,Bytes);
end;

function TTypedBuffer<T>.getSize: nativeuint;
begin
  Result := fBuffer.getSize;
end;

function TTypedBuffer<T>.getByte(const idx: nativeuint): uint8;
begin
  Result := fBuffer.getByte(idx);
end;

procedure TTypedBuffer<T>.setByte(const idx: nativeuint; const value: uint8);
begin
  fBuffer.setByte(idx,value);
end;

procedure TTypedBuffer<T>.setSize(const aSize: nativeuint);
begin
  if aSize=fBuffer.Size then begin
    exit;
  end;
  fBuffer.Size := aSize;
  fCount := fBuffer.Size div fItemSize;
end;

procedure TTypedBuffer<T>.Fill(const Value: T);
var
  idx: nativeuint;
  P: ^T;
begin
  if fCount=0 then begin
    exit;
  end;
  p := fBuffer.getDataPointer;
  for idx := 0 to pred(fCount) do begin
    p^ := Value;
    p := pointer(nativeuint(p)+fItemSize);
  end;
end;

function TTypedBuffer<T>.getDataPointer: pointer;
begin
  Result := fBuffer.getDataPointer;
end;

function TTypedBuffer<T>.getCount: nativeuint;
begin
  Result := fCount;
end;

procedure TTypedBuffer<T>.setCount(const value: nativeuint);
begin
  if fCount=value then begin
    exit;
  end;
  fCount := value;
  fBuffer.Size := fCount * fItemSize;
end;

function TTypedBuffer<T>.getValue(const Index: nativeuint): T;
var
  p: ^T;
begin
  p := fBuffer.getDataPointer;
  if Index>=fCount then begin
    raise
      Exception.Create('Index out of bounds');
  end;
  p := pointer(nativeuint(p)+fItemSize*Index);
  Result := p^;
end;

procedure TTypedBuffer<T>.setValue(const Index: nativeuint; value: T);
var
  p: ^T;
begin
  p := fBuffer.getDataPointer;
  if Index>=fCount then begin
    raise
      Exception.Create('Index out of bounds');
  end;
  p := pointer(nativeuint(p)+fItemSize*Index);
  p^ := value;
end;

constructor TTypedBuffer<T>.Create(const Items: nativeuint; const Align16: boolean);
begin
  inherited Create;
  fCount := Items;
  fItemSize := sizeof(T);
  fBuffer := TBuffer.Create( fCount*sizeof(T), Align16 );
end;

destructor TTypedBuffer<T>.Destroy;
begin
  fBuffer := nil;
  inherited Destroy;
end;

end.

