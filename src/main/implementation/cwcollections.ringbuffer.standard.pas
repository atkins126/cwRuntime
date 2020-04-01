{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwCollections.RingBuffer.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  cwCollections
;

type
  TStandardRingBuffer<T> = class( TInterfacedObject, IReadOnlyRingBuffer<T>, IRingBuffer<T> )
  private
    fPushIndex: nativeuint;
    fPullIndex: nativeuint;
    fItems: array of T;
  strict private //- IReadOnlyRingBuffer<T> -//
    function Pull( out item: T ): boolean;
    function IsEmpty: boolean;
    function getAsReadOnly: IReadOnlyRingBuffer<T>;
  strict private //- IRingBuffer<T> -//
    function Push( const item: T ): boolean;
  public
    constructor Create( ItemCount: nativeuint = 128 ); reintroduce;
  end;

implementation

constructor TStandardRingBuffer<T>.Create( ItemCount: nativeuint );
begin
  inherited Create;
  fPushIndex := 0;
  fPullIndex := 0;
  SetLength(fItems,ItemCount);
end;

function TStandardRingBuffer<T>.IsEmpty: boolean;
begin
  Result := True;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Result := False;
end;

function TStandardRingBuffer<T>.Pull(out item: T): boolean;
var
  NewIndex: nativeuint;
begin
  Result := False;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Item := Default(T);
  Move( fItems[fPullIndex], item, sizeof(T) );
  NewIndex := succ(fPullIndex);
  if NewIndex>=Length(fItems) then begin
    NewIndex := 0;
  end;
  fPullIndex := NewIndex;
  Result := True;
end;

function TStandardRingBuffer<T>.Push(const item: T): boolean;
var
  NewIndex: nativeuint;
begin
  Result := False;
  NewIndex := succ(fPushIndex);
  if (NewIndex>=Length(fItems)) then begin
    NewIndex := 0;
  end;
  if NewIndex=fPullIndex then begin
    Exit;
  end;
  Move( item, fItems[fPushIndex], sizeof(T) );
  fPushIndex := NewIndex;
  Result := True;
end;

function TStandardRingBuffer<T>.getAsReadOnly: IReadOnlyRingBuffer<T>;
begin
  Result := self as IReadOnlyRingBuffer<T>;
end;

end.

