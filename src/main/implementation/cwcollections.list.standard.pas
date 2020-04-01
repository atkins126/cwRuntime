{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwCollections.List.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  cwCollections
;

type
  TStandardList<T> = class( TInterfacedObject, IReadOnlyLisT<T>, IList<T> )
  private
    fItems: array of T;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fOrdered: boolean;
    fPruned: boolean;
  private //- IReadOnlyList<T> -//
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): T;
    {$ifdef fpc}
    procedure ForEach( const Enumerate: TEnumerateGlobalHandler<T> ); overload;
    procedure ForEach( const Enumerate: TEnumerateOfObjectHandler<T> ); overload;
    {$else}
    procedure ForEach( const Enumerate: TEnumerateReferenceHandler<T> ); overload;
    {$endif}
    function getAsReadOnly: IReadOnlyList<T>;
  private //- IList<T> -/
    procedure Clear;
    function Add( const Item: T ): nativeuint;
    procedure setItem( const idx: nativeuint; const item: T );
    procedure Remove( const Item: T );
    function RemoveItem( const idx: nativeuint ): boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

implementation

function TStandardList<T>.Add( const Item: T ): nativeuint;
var
  NewSize: nativeuint;
begin
  if (fCount=Length(fItems)) then begin
    NewSize := Length(fItems);
    NewSize := NewSize + fGranularity;
    SetLength(fItems, NewSize);
  end;
  fItems[fCount] := Item;
  Result := fCount;
  inc(fCount);
end;

procedure TStandardList<T>.Clear;
begin
  fCount := 0;
  SetLength(fItems,0);
end;

constructor TStandardList<T>.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  // Set granularity control
  if Granularity>0 then begin
    fGranularity := Granularity;
  end;
  // Set granularity pruning.
  fPruned := isPruned;
  // Set order maintenance flag
  fOrdered := isOrdered;
  // Initialize the array.
  fCount := 0;
  SetLength( fItems, 0 );
end;

destructor TStandardList<T>.Destroy;
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

{$ifdef fpc}
procedure TStandardList<T>.ForEach( const Enumerate: TEnumerateOfObjectHandler<T> ); overload;
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getItem(idx));
  end;
end;
{$endif}

{$ifdef fpc}
procedure TStandardList<T>.ForEach( const Enumerate: TEnumerateGlobalHandler<T> ); overload;
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getItem(idx));
  end;
end;
{$endif}

{$ifndef fpc}
procedure TStandardList<T>.ForEach( const Enumerate: TEnumerateReferenceHandler<T> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getItem(idx));
  end;
end;
{$endif}

function TStandardList<T>.getCount: nativeuint;
begin
  Result := fCount;
end;

function TStandardList<T>.getItem( const idx: nativeuint ): T;
begin
  Result := fItems[idx];
end;

function TStandardList<T>.OrderedRemoveItem( const idx: nativeuint ): boolean;
var
  idy: nativeuint;
begin
  Result := False; // unless..
  if fCount=0 then begin
    exit;
  end;
  if idx<pred(fCount) then begin
    for idy := idx to pred(pred(fCount)) do begin
      fItems[idy] := fItems[succ(idy)];
    end;
    fItems[pred(fCount)] := Default(T);
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    fItems[idx] := Default(T);
    dec(fCount);
    Result := True;
  end;
end;

function TStandardList<T>.UnorderedRemoveItem( const idx: nativeuint ): boolean;
begin
  Result := False; // unless..
  if fCount>0 then begin
    if idx<pred(fCount) then begin
      //- Move last item into place of that being removed.
      fItems[idx] := fItems[pred(fCount)];
      //- Clear last item
      fItems[pred(fCount)] := Default(T);
      dec(fCount);
      Result := True;
    end else if idx=pred(fCount) then begin
      //- if idx=fCount then simply remove the top item and decrement
      fItems[idx] := Default(T);
      dec(fCount);
      Result := True;
    end;
  end;
end;

procedure TStandardList<T>.PruneCapacity;
var
  Blocks: nativeuint;
  Remainder: nativeuint;
  TargetSize: nativeuint;
begin
  TargetSize := 0;
  Remainder := 0;
  Blocks := fCount div fGranularity;
  Remainder := fCount - Blocks;
  if Remainder>0 then begin
    inc(Blocks);
  end;
  TargetSize := Blocks*fGranularity;
  //- Total number of required blocks has been determined.
  if Length(fItems)>TargetSize then begin
    SetLength( fItems, TargetSize );
  end;
end;

procedure TStandardList<T>.Remove(const Item: T);
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := pred(getCount) downto 0 do begin
    if getItem(idx)=Item then begin
      RemoveItem(idx);
    end;
  end;
end;

function TStandardList<T>.RemoveItem( const idx: nativeuint ): boolean;
begin
  // If the list is ordered, perform slow removal, else fast removal
  if fOrdered then begin
    Result := OrderedRemoveItem( idx );
  end else begin
    Result := UnorderedRemoveItem( idx );
  end;
  // If the list is pruning memory (to save memory space), do the prune.
  if fPruned then begin
    PruneCapacity;
  end;
end;

procedure TStandardList<T>.setItem( const idx: nativeuint; const item: T);
begin
  fItems[idx] := item;
end;

function TStandardList<T>.getAsReadOnly: IReadOnlyList<T>;
begin
  Result := Self as IReadOnlyList<T>;
end;

end.

