{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwCollections.Stack.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  cwCollections
;

type
  TStandardStack<T> = class( TInterfacedObject, IReadOnlyStack<T>, IStack<T> )
  private
    fItems: array of T;
    fCount: nativeuint;
    fCapacity: nativeuint;
    fGranularity: nativeuint;
    fPruned: boolean;
  private //- IReadOnlyStack -//
    function Pull: T;
    function getAsReadOnly: IReadOnlyStack<T>;
  private //- IStack<T> -//
    procedure Push( const Item: T );
  public
    constructor Create( const Granularity: nativeuint = 0; const IsPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

implementation

constructor TStandardStack<T>.Create( const Granularity: nativeuint; const IsPruned: boolean );
const
  cDefaultGranularity = 32;
begin
  inherited Create;
  //- Determine memory usage granularity.
  if Granularity>0 then begin
    fGranularity := Granularity;
  end else begin
    fGranularity := cDefaultGranularity; //-default granularity
  end;
  fPruned := IsPruned;
  fCapacity := 0;
  fCount := 0;
  SetLength( fItems, fCapacity );
end;

destructor TStandardStack<T>.Destroy;
begin
  SetLength( fItems, 0 );
  inherited;
end;

function TStandardStack<T>.Pull: T;
begin
  Result := Default(T);
  if fCount>0 then begin
    Result := fItems[pred(fCount)];
    fItems[pred(fCount)] := Default(T);
    dec(fCount);
    if fPruned then begin
      if fCount<(fCapacity-fGranularity) then begin
        fCapacity := fCapacity - fGranularity;
        SetLength( fItems, fCapacity );
      end;
    end;
  end;
end;

procedure TStandardStack<T>.Push( const Item: T );
begin
  //- Test that there is sufficient memory to add the item.
  if (fCount=fCapacity) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength( fItems, fCapacity );
  end;
  //- Add the item
  fItems[fCount] := Item;
  inc(fCount);
end;

function TStandardStack<T>.getAsReadOnly: IReadOnlyStack<T>;
begin
  Result := Self as IReadOnlyStack<T>;
end;

end.

