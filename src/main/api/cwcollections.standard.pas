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
///   Standard implementation for cwCollections.
/// </summary>
unit cwCollections.Standard;
{$ifdef fpc}
  {$mode delphiunicode}
  {$modeswitch nestedprocvars}
{$endif}
interface
uses
  cwCollections
, cwIO
;

{$region ' TList<T>'}

type
  TList<T> = class( TInterfacedObject, IReadOnlyLisT<T>, IList<T> )
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
    procedure ForEach( const Enumerate: TEnumerateMethodGlobal<T> ); overload;
    procedure ForEach( const Enumerate: TEnumerateMethodOfObject<T> ); overload;
    procedure ForEach( const Enumerate: TEnumerateMethodIsNested<T> ); overload;
    {$else}
    procedure ForEach( const Enumerate: TEnumerateMethod<T> ); overload;
    {$endif}
    function getAsReadOnly: IReadOnlyList<T>;
  private //- IList<T> -/
    procedure Clear;
    function Add( const Item: T ): nativeuint;
    procedure setItem( const idx: nativeuint; const item: T );
    {$ifdef fpc}
    procedure Remove( const Item: T );
    {$else}
    procedure Remove( const Item: T; const Compare: TCompare<T> );
    {$endif}
    function RemoveItem( const idx: nativeuint ): boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

{$region ' TDictionary<K,V>'}

type
  TDictionary<K,V> = class( TInterfacedObject, ICollection, IReadOnlyDictionary<K,V>, IDictionary<K,V> )
  private
    {$ifdef fpc}
    const rfGlobal = 1;
    const rfObject = 2;
    const rfNested = 3;
    {$endif}
  private
    {$ifdef fpc}
    fKeyCompare: pointer;
    fKeyCompareType: uint8;
    {$else}
    fKeyCompare: TCompare<K>;
    {$endif}
    fKeys: array of K;
    fItems: array of V;
    fCapacity: nativeuint;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fPruned: boolean;
    fOrdered: boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
    function CompareKeys( const KeyA: K; const KeyB: K ): TComparisonResult;
    procedure Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
  private //- IReadOnlyDictionary<K,V> -//
    function getCount: nativeuint;
    function getKeyByIndex( const idx: nativeuint ): K;
    function getValueByIndex( const idx: nativeuint ): V;
    function getKeyExists( const key: K ): boolean;
    function getValueByKey( const key: K ): V;
    procedure setValueByIndex( const idx: nativeuint; const value: V );
    {$ifdef fpc}
    procedure ForEach( const Enumerate: TEnumeratePairGlobal<K,V> ); overload;
    procedure ForEach( const Enumerate: TEnumeratePairOfObject<K,V> ); overload;
    procedure ForEach( const Enumerate: TEnumeratePairIsNested<K,V> ); overload;
    {$else}
    procedure ForEach( const Enumerate: TEnumeratePair<K,V> ); overload;
    {$endif}
    function getAsReadOnly: IReadOnlyDictionary<K,V>;
  strict private //- IDictionary<K,V> -//
    procedure setValueByKey( const key: K; const value: V );
    procedure removeByIndex( const idx: nativeuint );
    procedure Clear;
  public
    {$ifdef fpc}
    constructor Create( const KeyCompare: TCompareGlobal<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce; overload;
    constructor Create( const KeyCompare: TCompareOfObject<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce; overload;
    constructor Create( const KeyCompare: TCompareNested<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce; overload;
    {$else}
    constructor Create( const KeyCompare: TCompare<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce; overload;
    {$endif}
    destructor Destroy; override;
  end;

{$endregion}

{$region ' TRingBuffer<T>'}

type
  TRingBuffer<T> = class( TInterfacedObject, IReadOnlyRingBuffer<T>, IRingBuffer<T> )
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

{$endregion}

{$region ' TStack<T>'}

type
  TStack<T> = class( TInterfacedObject, IReadOnlyStack<T>, IStack<T> )
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

{$endregion}

{$region ' TStringList'}

type
  TStringList = class( TInterfacedObject, IReadOnlyStringList, IStringList )
  private
    fStrings: IList<string>;
  strict private //- IReadOnlyStringList -//
    {$ifdef fpc}
    procedure ForEach( const Enumerate: TEnumerateMethodGlobal<string> ); overload;
    procedure ForEach( const Enumerate: TEnumerateMethodOfObject<string> ); overload;
    procedure ForEach( const Enumerate: TEnumerateMethodIsNested<string> ); overload;
    {$else}
    procedure ForEach( const Enumerate: TEnumerateMethod<string> ); overload;
    {$endif}
    function getCount: nativeuint;
    function getString( const idx: nativeuint ): string;
    function getAsReadOnly: IReadOnlyStringList;
    function Contains( const Search: string; const CaseInsensitive: boolean = FALSE ): boolean;
    procedure SaveToStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat );
    procedure LoadFromStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat );

  strict private //- IStringList -//
    procedure Clear;
    procedure Add( const value: string );
    procedure setString( const idx: nativeuint; const value: string );
    function RemoveString( const idx: nativeuint ): boolean;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;


{$endregion}

{$region ' TCompare'}

type
  ///  <summary>
  ///    Namespace of pre-defined comparison functions for use
  ///    with dictionary / list.remove().
  ///  </summary>
  TCompare = record
    class function ComparePointers( const AValue: pointer; const BValue: pointer ): TComparisonResult; static;
    class function CompareStrings( const AValue: string; const BValue: string ): TComparisonResult; static;
  end;

{$endregion}

implementation
uses
  sysutils
, cwTypes
, cwLog
, cwLog.Standard
;

{$region ' TList<T>'}

function TList<T>.Add( const Item: T ): nativeuint;
var
  NewSize: nativeuint;
  L: nativeuint;
begin
  L := Length(fItems);
  if (fCount=L) then begin
    NewSize := Length(fItems);
    NewSize := NewSize + fGranularity;
    SetLength(fItems, NewSize);
  end;
  fItems[fCount] := Item;
  Result := fCount;
  inc(fCount);
end;

procedure TList<T>.Clear;
begin
  fCount := 0;
  SetLength(fItems,0);
end;

constructor TList<T>.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
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

destructor TList<T>.Destroy;
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

{$ifdef fpc}
procedure TList<T>.ForEach( const Enumerate: TEnumerateMethodOfObject<T> ); overload;
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
procedure TList<T>.ForEach( const Enumerate: TEnumerateMethodGlobal<T> ); overload;
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
procedure TList<T>.ForEach( const Enumerate: TEnumerateMethodIsNested<T> ); overload;
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
procedure TList<T>.ForEach( const Enumerate: TEnumerateMethod<T> );
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

function TList<T>.getCount: nativeuint;
begin
  Result := fCount;
end;

function TList<T>.getItem( const idx: nativeuint ): T;
begin
  Result := fItems[idx];
end;

function TList<T>.OrderedRemoveItem( const idx: nativeuint ): boolean;
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

function TList<T>.UnorderedRemoveItem( const idx: nativeuint ): boolean;
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

procedure TList<T>.PruneCapacity;
var
  Blocks: nativeuint;
  Remainder: nativeuint;
  TargetSize: nativeuint;
  L: nativeuint;
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
  L := Length(fItems);
  if L>TargetSize then begin
    SetLength( fItems, TargetSize );
  end;
end;

{$ifdef fpc}
procedure TList<T>.Remove(const Item: T);
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
{$endif}

{$ifndef fpc}
procedure TList<T>.Remove( const Item: T; const Compare: TCompare<T> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := pred(getCount) downto 0 do begin
    if Compare(getItem(idx),Item)=crAEqualToB then begin
      RemoveItem(idx);
    end;
  end;
end;
{$endif}

function TList<T>.RemoveItem( const idx: nativeuint ): boolean;
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

procedure TList<T>.setItem( const idx: nativeuint; const item: T);
begin
  fItems[idx] := item;
end;

function TList<T>.getAsReadOnly: IReadOnlyList<T>;
begin
  Result := Self as IReadOnlyList<T>;
end;

{$endregion}

{$region ' TStringList'}

constructor TStringList.Create(const Granularity: nativeuint; const isOrdered: boolean; const isPruned: boolean);
begin
  inherited Create;
  fStrings := TList<string>.Create( Granularity, isOrdered, isPruned );
end;

procedure TStringList.Add(const value: string);
var
  Exploded: TArrayOfString;
  idx: nativeuint;
begin
  if Value.Trim='' then begin
    fStrings.Add(CR+LF);
    exit;
  end;
  Exploded := Value.Explode(LF);
  if Length(Exploded)>0 then begin
    for idx := 0 to pred(Length(Exploded)) do begin
      fStrings.Add(Exploded[idx]);
    end;
  end else begin
    fStrings.Add(value);
  end;
end;

procedure TStringList.Clear;
begin
  fStrings.Clear;
end;

function TStringList.Contains(const Search: string; const CaseInsensitive: boolean): boolean;
var
  idx: nativeuint;
  SearchTerm: string;
  TestItem: string;
begin
  Result := False;
  if fStrings.Count=0 then begin
    exit;
  end;
  SearchTerm := Search;
  if CaseInsensitive then begin
    SearchTerm := Uppercase(SearchTerm);
  end;
  for idx := 0 to pred(fStrings.Count) do begin
     TestItem := fStrings[idx];
     if CaseInsensitive then begin
       TestItem := Uppercase(TestItem);
     end;
     if TestItem = SearchTerm then begin
       Result := True;
       exit;
     end;
  end;
end;

procedure TStringList.SaveToStream(const Stream: IUnicodeStream; const Format: TUnicodeFormat);
var
  idx: nativeuint;
begin
  if Format=TUnicodeFormat.utfUnknown then begin
    raise
      TLoggedException.Create(stCannotEncodeUnknownUnicodeFormat);
  end;
  Stream.WriteBOM(Format);
  if getCount()=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount()) do begin
    Stream.WriteString( fStrings[idx]+LF, Format );
  end;
end;

procedure TStringList.LoadFromStream(const Stream: IUnicodeStream; const Format: TUnicodeFormat);
var
  ActualFormat: TUnicodeFormat;
  Exploded: TArrayOfString;
  idx: nativeuint;
  S: string;
begin
  ActualFormat := Format;
  if ActualFormat=TUnicodeFormat.utfUnknown then begin
    ActualFormat := Stream.DetermineUnicodeFormat;
  end;
  if ActualFormat=TUnicodeFormat.utfUnknown then begin
    raise
      TLoggedException.Create(stUnableToDetermineUnicodeFormat);
  end;
  Self.Clear;
  while not Stream.getEndOfStream do begin
    S := Stream.ReadString(ActualFormat,True);
    if S.Trim='' then continue;
    Exploded := S.Explode(LF);
    try
      if Length(Exploded)>0 then begin
        for idx := 0 to pred(Length(Exploded)) do begin
          Self.Add(Exploded[idx]);
        end;
      end else begin
        Self.Add(S);
      end;
    finally
      SetLength(Exploded,0);
    end;
  end;
end;

destructor TStringList.Destroy;
begin
  fStrings := nil;
  inherited Destroy;
end;

{$ifdef fpc}
procedure TStringList.ForEach(const Enumerate: TEnumerateMethodGlobal<string>);
begin
  fStrings.ForEach(Enumerate);
end;
{$endif}

{$ifdef fpc}
procedure TStringList.ForEach(const Enumerate: TEnumerateMethodOfObject<string>);
begin
  fStrings.ForEach(Enumerate);
end;
{$endif}

{$ifdef fpc}
procedure TStringList.ForEach(const Enumerate: TEnumerateMethodIsNested<string>);
begin
  fStrings.ForEach(Enumerate);
end;
{$endif}

{$ifndef fpc}
procedure TStringList.ForEach(const Enumerate: TEnumerateMethod<string>);
begin
  fStrings.ForEach(Enumerate);
end;
{$endif}

function TStringList.getAsReadOnly: IReadOnlyStringList;
begin
  Result := Self as IReadOnlyStringList;
end;

function TStringList.getCount: nativeuint;
begin
  Result := fStrings.Count;
end;

function TStringList.getString(const idx: nativeuint): string;
begin
  Result := fStrings[idx];
end;

function TStringList.RemoveString(const idx: nativeuint): boolean;
begin
  Result := fStrings.RemoveItem(idx);
end;

procedure TStringList.setString(const idx: nativeuint; const value: string);
begin
  fStrings[idx] := Value;
end;

{$endregion}

{$region ' TDictionary<K,V>'}

procedure TDictionary<K,V>.Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
begin
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
  fCapacity := 0;
  SetLength( fKeys, fCapacity );
  SetLength( fItems, fCapacity );
end;

{$ifdef fpc}
constructor TDictionary<K,V>.Create( const KeyCompare: TCompareGlobal<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  Move(KeyCompare,fKeyCompare,Sizeof(pointer));
  fKeyCompareType := rfGlobal;
  Initialize(Granularity,isOrdered,isPruned);
end;
{$endif}

{$ifdef fpc}
constructor TDictionary<K,V>.Create( const KeyCompare: TCompareOfObject<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  Move(KeyCompare,fKeyCompare,Sizeof(pointer));
  fKeyCompareType := rfObject;
  Initialize(Granularity,isOrdered,isPruned);
end;
{$endif}

{$ifdef fpc}
constructor TDictionary<K,V>.Create( const KeyCompare: TCompareNested<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  Move(KeyCompare,fKeyCompare,Sizeof(pointer));
  fKeyCompareType := rfNested;
  Initialize(Granularity,isOrdered,isPruned);
end;
{$endif}

{$ifndef fpc}
constructor TDictionary<K,V>.Create( const KeyCompare: TCompare<K>; const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  fKeyCompare := KeyCompare;
  Initialize(Granularity,isOrdered,isPruned);
end;
{$endif}

destructor TDictionary<K,V>.Destroy;
begin
  SetLength( fKeys, 0 );
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TDictionary<K,V>.getCount: nativeuint;
begin
  Result := fCount;
end;

{$ifdef fpc}
procedure TDictionary<K,V>.ForEach( const Enumerate: TEnumeratePairGlobal<K,V> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getKeyByIndex(idx),getValueByIndex(idx));
  end;
end;
{$endif}

{$ifdef fpc}
procedure TDictionary<K,V>.ForEach( const Enumerate: TEnumeratePairOfObject<K,V> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getKeyByIndex(idx),getValueByIndex(idx));
  end;
end;
{$endif}

{$ifdef fpc}
procedure TDictionary<K,V>.ForEach( const Enumerate: TEnumeratePairIsNested<K,V> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getKeyByIndex(idx),getValueByIndex(idx));
  end;
end;
{$endif}

{$ifndef fpc}
procedure TDictionary<K,V>.ForEach( const Enumerate: TEnumeratePair<K,V> );
var
  idx: nativeuint;
begin
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    Enumerate(getKeyByIndex(idx),getValueByIndex(idx));
  end;
end;
{$endif}

function TDictionary<K,V>.getKeyByIndex( const idx: nativeuint ): K;
begin
  {$warnings off} Result := Default(K); {$warnings on}
  if idx<getCount then begin
    Result := fKeys[idx];
  end;
end;

function TDictionary<K,V>.CompareKeys( const KeyA: K; const KeyB: K ): TComparisonResult;
{$ifdef fpc}
var
  Glob: TCompareGlobal<K>;
  Obj: TCompareOfObject<K>;
  Nested: TCompareNested<K>;
{$endif}
begin
  {$ifdef fpc}
  Result := TComparisonResult.crErrorNotCompared;
  if not assigned(fKeyCompare) then begin
    exit;
  end;
  case fKeyCompareType of
    rfGlobal: begin
      Glob := nil;
      Move(fKeyCompare,Glob,sizeof(pointer));
      Result := Glob( KeyA, keyB );
    end;
    rfObject: begin
      Obj := nil;
      Move(fKeyCompare,Obj,sizeof(pointer));
      Result := Obj( KeyA, keyB );
    end;
    rfNested: begin
      Nested := nil;
      Move(fKeyCompare,Nested,sizeof(pointer));
      Result := Nested( KeyA, keyB );
    end;
  end;
  {$else}
    Result := fKeyCompare( KeyA, keyB );
  {$endif}
end;

function TDictionary<K,V>.getKeyExists( const key: K ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if CompareKeys(fKeys[idx],key)=crAEqualToB then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TDictionary<K,V>.getValueByIndex( const idx: nativeuint ): V;
begin
  Result := Default(V);
  if idx<getCount then begin
    Result := fItems[idx];
  end;
end;

procedure TDictionary<K,V>.setValueByIndex( const idx: nativeuint; const value: V );
begin
  fItems[idx] := value;
end;

function TDictionary<K,V>.getValueByKey( const key: K ): V;
var
  idx: nativeuint;
begin
  Result := Default(V);
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if CompareKeys(fKeys[idx],key)=crAEqualToB then begin
      Result := fItems[idx];
      Exit;
    end;
  end;
end;

function TDictionary<K,V>.OrderedRemoveItem( const idx: nativeuint ): boolean;
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
      fKeys[idy] := fKeys[succ(idy)];
    end;
    fItems[pred(fCount)] := Default(V);
    fKeys[pred(fCount)] := Default(K);
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- Item is last on list, no need to move-down items above it.
    fItems[idx] := Default(V);
    fKeys[idx] := Default(K);
    dec(fCount);
    Result := True;
  end;
end;

function TDictionary<K,V>.UnorderedRemoveItem( const idx: nativeuint ): boolean;
begin
  Result := False; // unless..
  if fCount=0 then begin
    exit;
  end;
  if idx<pred(fCount) then begin
    //- Move last item into place of that being removed.
    fItems[idx] := fItems[pred(fCount)];
    fKeys[idx] := fKeys[pred(fCount)];
    //- Clear last item
    fItems[pred(fCount)] := Default(V);
    {$warnings off} fKeys[pred(fCount)] := Default(K); {$warnings on}
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- if idx=fCount then simply remove the top item and decrement
    fItems[idx] := Default(V);
    {$warnings off} fKeys[idx] := Default(K); {$warnings on}
    dec(fCount);
    Result := True;
  end;
end;

procedure TDictionary<K,V>.PruneCapacity;
var
  Blocks: nativeuint;
  Remainder: nativeuint;
  TargetSize: nativeuint;
begin
  Blocks := fCount div fGranularity;
  Remainder := fCount - Blocks;
  if Remainder>0 then begin
    inc(Blocks);
  end;
  TargetSize := Blocks*fGranularity;
  //- Total number of required blocks has been determined.
  if fCapacity>TargetSize then begin
    fCapacity := TargetSize;
    SetLength( fItems, fCapacity );
    SetLength( fKeys, fCapacity );
  end;
end;

procedure TDictionary<K,V>.removeByIndex( const idx: nativeuint );
begin
  // If the list is ordered, perform slow removal, else fast removal
  if fOrdered then begin
    OrderedRemoveItem( idx );
  end else begin
    UnorderedRemoveItem( idx );
  end;
  // If the list is pruning memory (to save memory space), do the prune.
  if fPruned then begin
    PruneCapacity;
  end;
end;

procedure TDictionary<K,V>.Clear;
begin
  fCount := 0;
  if fPruned then begin
    fCapacity := 0;
    SetLength( fKeys, fCapacity );
    SetLength( fItems, fCapacity );
  end;
end;

procedure TDictionary<K,V>.setValueByKey( const key: K; const value: V );
var
  idx: nativeuint;
begin
  if getCount>0 then begin //- Craig! Don't change this!
    for idx := pred(getCount) downto 0 do begin
      if CompareKeys(fKeys[idx],key)=crAEqualToB then begin
        fItems[idx] := value;
        exit;
      end;
    end;
  end;
  //- If we made it here, add the item.
  if (fCount=fCapacity) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength(fKeys,fCapacity);
    SetLength(fItems,fCapacity);
  end;
  fKeys[fCount] := key;
  fItems[fCount] := value;
  inc(fCount);
end;

function TDictionary<K,V>.getAsReadOnly: IReadOnlyDictionary<K,V>;
begin
  Result := Self as IReadOnlyDictionary<K,V>;
end;

{$endregion}

{$region ' TRingBuffer<T>'}

constructor TRingBuffer<T>.Create( ItemCount: nativeuint );
begin
  inherited Create;
  fPushIndex := 0;
  fPullIndex := 0;
  SetLength(fItems,ItemCount);
end;

function TRingBuffer<T>.IsEmpty: boolean;
begin
  Result := True;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Result := False;
end;

function TRingBuffer<T>.Pull(out item: T): boolean;
var
  NewIndex: nativeuint;
  L: nativeuint;
begin
  Result := False;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Item := Default(T);
  Move( fItems[fPullIndex], item, sizeof(T) );
  NewIndex := succ(fPullIndex);
  L := Length(fItems);
  if NewIndex>=L then begin
    NewIndex := 0;
  end;
  fPullIndex := NewIndex;
  Result := True;
end;

function TRingBuffer<T>.Push(const item: T): boolean;
var
  NewIndex: nativeuint;
  L: nativeuint;
begin
  Result := False;
  NewIndex := succ(fPushIndex);
  L := Length(fItems);
  if (NewIndex>=L) then begin
    NewIndex := 0;
  end;
  if NewIndex=fPullIndex then begin
    Exit;
  end;
  Move( item, fItems[fPushIndex], sizeof(T) );
  fPushIndex := NewIndex;
  Result := True;
end;

function TRingBuffer<T>.getAsReadOnly: IReadOnlyRingBuffer<T>;
begin
  Result := self as IReadOnlyRingBuffer<T>;
end;

{$endregion}

{$region ' TStack<T>'}

constructor TStack<T>.Create( const Granularity: nativeuint; const IsPruned: boolean );
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

destructor TStack<T>.Destroy;
begin
  SetLength( fItems, 0 );
  inherited;
end;

function TStack<T>.Pull: T;
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

procedure TStack<T>.Push( const Item: T );
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

function TStack<T>.getAsReadOnly: IReadOnlyStack<T>;
begin
  Result := Self as IReadOnlyStack<T>;
end;

{$endregion}

{$region ' TCompare'}

class function TCompare.ComparePointers(const AValue: pointer; const BValue: pointer): TComparisonResult;
begin
  if AValue=BValue then begin
    Result := TComparisonResult.crAEqualToB;
  {$hints off} end else if nativeuint(AValue)>nativeuint(BValue) then begin {$hints on} // fpc warns not portable, actually it is.
    Result := TComparisonResult.crAGreaterThanB;
  end else begin
    Result := TComparisonResult.crBGreaterThanA;
  end;
end;

class function TCompare.CompareStrings(const AValue: string; const BValue: string): TComparisonResult;
begin
  if AValue=BValue then begin
    Result := TComparisonResult.crAEqualToB;
  end else if AValue>BValue then begin
    Result := TComparisonResult.crAGreaterThanB;
  end else begin
    Result := TComparisonResult.crBGreaterThanA;
  end;
end;


{$endregion}

end.
