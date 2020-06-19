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
unit cwRuntime.Collections.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

(*
   Tight interaction between cwLog, cwThreading and cwCollections caused the fpc compiler
   to raise an internal compiler error (compiler bug). To work around this, all collections
   used in cwLog or cwThreading are being replaced with non-generic concrete collections.
   This unit provides the implementations for these collections.
*)

interface
uses
  cwLog
, cwThreading
, cwRuntime.Collections
;

{$region ' TInterfaceList'}

type
  TInterfaceList = class( TInterfacedObject, IInterface )
  private
    fItems: array of IInterface;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fOrdered: boolean;
    fPruned: boolean;
  protected
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IInterface;
    procedure setItem( const idx: nativeuint; const item: IInterface );
    procedure Clear;
    function Add( const item: IInterface ): nativeuint;
    procedure Remove( const Item: IInterface );
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

{$region ' TPoolThreadList'}

  TPoolThreadList = class( TInterfaceList, IPoolThreadList )
  strict private //- IPoolThreadList -//
    function getItem( const idx: nativeuint ): IPoolThread;
    procedure setItem( const idx: nativeuint; const item: IPoolThread );
    function Add( const item: IPoolThread ): nativeuint;
    procedure Remove( const Item: IPoolThread );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TMessagePipeList'}

  TMessagePipeList = class( TInterfaceList, IMessagePipeList )
  strict private //- IMessagePipeList -//
    function getItem( const idx: nativeuint ): IMessagePipe;
    procedure setItem( const idx: nativeuint; const item: IMessagePipe );
    function Add( const item: IMessagePipe ): nativeuint;
    procedure Remove( const Item: IMessagePipe );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TThreadSubsystemList'}

  TThreadSubsystemList = class( TInterfaceList, IThreadSubSystemList )
  strict private //- IThreadSubSystemList -//
    function getItem( const idx: nativeuint ): IThreadSubSystem;
    procedure setItem( const idx: nativeuint; const item: IThreadSubSystem );
    function Add( const item: IThreadSubSystem ): nativeuint;
    procedure Remove( const Item: IThreadSubSystem );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TThreadExecutorList'}

  TThreadExecutorList = class( TInterfaceList, IThreadExecutorList )
  strict private //- IThreadExecutorList -//
    function getItem( const idx: nativeuint ): IThreadExecutor;
    procedure setItem( const idx: nativeuint; const item: IThreadExecutor );
    function Add( const item: IThreadExecutor ): nativeuint;
    procedure Remove( const Item: IThreadExecutor );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TThreadLoopExecutorList'}

  TThreadLoopExecutorList = class( TInterfaceList, IThreadLoopExecutorList )
  strict private //- IThreadLoopExecutorList -//
    function getItem( const idx: nativeuint ): IThreadLoopExecutor;
    procedure setItem( const idx: nativeuint; const item: IThreadLoopExecutor );
    function Add( const item: IThreadLoopExecutor ): nativeuint;
    procedure Remove( const Item: IThreadLoopExecutor );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TLogTargetList'}

  TLogTargetList = class( TInterfaceList, ILogTargetList )
  strict private //- ILogTargetList -//
    function getItem( const idx: nativeuint ): ILogTarget;
    procedure setItem( const idx: nativeuint; const item: ILogTarget );
    function Add( const item: ILogTarget ): nativeuint;
    procedure Remove( const Item: ILogTarget );
    function RemoveItem( const idx: nativeuint ): boolean;
  end;

{$endregion}

{$region ' TMessageChannelDictionary'}

type
  TMessageChannelDictionary = class( TInterfacedObject, IMessageChannelDictionary )
  private
    fKeys: array of string;
    fItems: array of IMessageChannel;
    fCapacity: nativeuint;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fPruned: boolean;
    fOrdered: boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
    procedure Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
  private //- IMessageChannelDictionary -//
    function getCount: nativeuint;
    function getKeyByIndex( const idx: nativeuint ): string;
    function getValueByIndex( const idx: nativeuint ): IMessageChannel;
    function getKeyExists( const key: string ): boolean;
    function getValueByKey( const key: string ): IMessageChannel;
    procedure setValueByIndex( const idx: nativeuint; const value: IMessageChannel );
    procedure setValueByKey( const key: string; const value: IMessageChannel );
    procedure removeByIndex( const idx: nativeuint );
    procedure Clear;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

{$region ' TLogEntryDictionary'}

type
  TLogEntryDictionary = class( TInterfacedObject, ILogEntryDictionary )
  private
    fKeys: array of TGUID;
    fItems: array of string;
    fCapacity: nativeuint;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fPruned: boolean;
    fOrdered: boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
    procedure Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
  private //- ILogEntryDictionary -//
    function getCount: nativeuint;
    function getKeyByIndex( const idx: nativeuint ): TGUID;
    function getValueByIndex( const idx: nativeuint ): string;
    function getKeyExists( const key: TGUID ): boolean;
    function getValueByKey( const key: TGUID ): string;
    procedure setValueByIndex( const idx: nativeuint; const value: string );
    procedure setValueByKey( const key: TGUID; const value: string );
    procedure removeByIndex( const idx: nativeuint );
    procedure Clear;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

implementation
uses
  sysutils
;

{$region ' TInterfaceList'}

function TInterfaceList.Add( const Item: IInterface ): nativeuint;
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

procedure TInterfaceList.Clear;
begin
  fCount := 0;
  SetLength(fItems,0);
end;

constructor TInterfaceList.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
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

destructor TInterfaceList.Destroy;
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TInterfaceList.getCount: nativeuint;
begin
  Result := fCount;
end;

function TInterfaceList.getItem( const idx: nativeuint ): IInterface;
begin
  Result := fItems[idx];
end;

function TInterfaceList.OrderedRemoveItem( const idx: nativeuint ): boolean;
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
    fItems[pred(fCount)] := nil;
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    fItems[idx] := nil;
    dec(fCount);
    Result := True;
  end;
end;

function TInterfaceList.UnorderedRemoveItem( const idx: nativeuint ): boolean;
begin
  Result := False; // unless..
  if fCount>0 then begin
    if idx<pred(fCount) then begin
      //- Move last item into place of that being removed.
      fItems[idx] := fItems[pred(fCount)];
      //- Clear last item
      fItems[pred(fCount)] := nil;
      dec(fCount);
      Result := True;
    end else if idx=pred(fCount) then begin
      //- if idx=fCount then simply remove the top item and decrement
      fItems[idx] := nil;
      dec(fCount);
      Result := True;
    end;
  end;
end;

procedure TInterfaceList.PruneCapacity;
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

procedure TInterfaceList.Remove(const Item: IInterface);
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

function TInterfaceList.RemoveItem( const idx: nativeuint ): boolean;
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

procedure TInterfaceList.setItem( const idx: nativeuint; const item: IInterface );
begin
  fItems[idx] := item;
end;

{$endregion}

{$region ' TPoolThreadList'}

function TPoolThreadList.Add(const item: IPoolThread): nativeuint;
begin
  Result := inherited Add(Item);
end;


function TPoolThreadList.getItem(const idx: nativeuint): IPoolThread;
begin
  Result := inherited getItem(idx) as IPoolThread;
end;

procedure TPoolThreadList.Remove(const Item: IPoolThread);
begin
  inherited Remove(Item);
end;

function TPoolThreadList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TPoolThreadList.setItem(const idx: nativeuint; const item: IPoolThread);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TMessagePipeList'}

function TMessagePipeList.Add(const item: IMessagePipe): nativeuint;
begin
  Result := inherited Add(Item);
end;


function TMessagePipeList.getItem(const idx: nativeuint): IMessagePipe;
begin
  Result := inherited getItem(idx) as IMessagePipe;
end;

procedure TMessagePipeList.Remove(const Item: IMessagePipe);
begin
  inherited Remove(Item);
end;

function TMessagePipeList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TMessagePipeList.setItem(const idx: nativeuint; const item: IMessagePipe);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TThreadSubSystemList'}

function TThreadSubSystemList.Add(const item: IThreadSubSystem): nativeuint;
begin
  Result := inherited Add(Item);
end;

function TThreadSubSystemList.getItem(const idx: nativeuint): IThreadSubSystem;
begin
  Result := inherited getItem(idx) as IThreadSubSystem;
end;

procedure TThreadSubSystemList.Remove(const Item: IThreadSubSystem);
begin
  inherited Remove(Item);
end;

function TThreadSubSystemList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TThreadSubSystemList.setItem(const idx: nativeuint; const item: IThreadSubSystem);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TThreadExecutorList'}

function TThreadExecutorList.Add(const item: IThreadExecutor): nativeuint;
begin
  Result := inherited Add(Item);
end;

function TThreadExecutorList.getItem(const idx: nativeuint): IThreadExecutor;
begin
  Result := inherited getItem(idx) as IThreadExecutor;
end;

procedure TThreadExecutorList.Remove(const Item: IThreadExecutor);
begin
  inherited Remove(Item);
end;

function TThreadExecutorList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TThreadExecutorList.setItem(const idx: nativeuint; const item: IThreadExecutor);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TThreadLoopExecutorList'}

function TThreadLoopExecutorList.Add(const item: IThreadLoopExecutor): nativeuint;
begin
  Result := inherited Add(Item);
end;

function TThreadLoopExecutorList.getItem(const idx: nativeuint): IThreadLoopExecutor;
begin
  Result := inherited getItem(idx) as IThreadLoopExecutor;
end;

procedure TThreadLoopExecutorList.Remove(const Item: IThreadLoopExecutor);
begin
  inherited Remove(Item);
end;

function TThreadLoopExecutorList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TThreadLoopExecutorList.setItem(const idx: nativeuint; const item: IThreadLoopExecutor);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TLogTargetList'}

function TLogTargetList.Add(const item: ILogTarget): nativeuint;
begin
  Result := inherited Add(Item);
end;

function TLogTargetList.getItem(const idx: nativeuint): ILogTarget;
begin
  Result := inherited getItem(idx) as ILogTarget;
end;

procedure TLogTargetList.Remove(const Item: ILogTarget);
begin
  inherited Remove(Item);
end;

function TLogTargetList.RemoveItem(const idx: nativeuint): boolean;
begin
  Result := inherited RemoveItem(idx);
end;

procedure TLogTargetList.setItem(const idx: nativeuint; const item: ILogTarget);
begin
  inherited setItem(idx,item);
end;

{$endregion}

{$region ' TMessageChannelDictionary'}

procedure TMessageChannelDictionary.Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
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

constructor TMessageChannelDictionary.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  Initialize(Granularity,isOrdered,isPruned);
end;

destructor TMessageChannelDictionary.Destroy;
begin
  SetLength( fKeys, 0 );
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TMessageChannelDictionary.getCount: nativeuint;
begin
  Result := fCount;
end;

function TMessageChannelDictionary.getKeyByIndex( const idx: nativeuint ): string;
begin
  Result := '';
  if idx<getCount then begin
    Result := fKeys[idx];
  end;
end;

function TMessageChannelDictionary.getKeyExists( const key: string ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if fKeys[idx]=key then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TMessageChannelDictionary.getValueByIndex( const idx: nativeuint ): IMessageChannel;
begin
  Result := nil;
  if idx<getCount then begin
    Result := fItems[idx];
  end;
end;

procedure TMessageChannelDictionary.setValueByIndex( const idx: nativeuint; const value: IMessageChannel );
begin
  fItems[idx] := value;
end;

function TMessageChannelDictionary.getValueByKey( const key: string ): IMessageChannel;
var
  idx: nativeuint;
begin
  Result := nil;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if fKeys[idx]=key then begin
      Result := fItems[idx];
      Exit;
    end;
  end;
end;

function TMessageChannelDictionary.OrderedRemoveItem( const idx: nativeuint ): boolean;
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
    fItems[pred(fCount)] := nil;
    fKeys[pred(fCount)] := '';
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- Item is last on list, no need to move-down items above it.
    fItems[idx] := nil;
    fKeys[idx] := '';
    dec(fCount);
    Result := True;
  end;
end;

function TMessageChannelDictionary.UnorderedRemoveItem( const idx: nativeuint ): boolean;
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
    fItems[pred(fCount)] := nil;
    fKeys[pred(fCount)] := '';
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- if idx=fCount then simply remove the top item and decrement
    fItems[idx] := nil;
    fKeys[idx] := '';
    dec(fCount);
    Result := True;
  end;
end;

procedure TMessageChannelDictionary.PruneCapacity;
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

procedure TMessageChannelDictionary.removeByIndex( const idx: nativeuint );
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

procedure TMessageChannelDictionary.Clear;
begin
  fCount := 0;
  if fPruned then begin
    fCapacity := 0;
    SetLength( fKeys, fCapacity );
    SetLength( fItems, fCapacity );
  end;
end;

procedure TMessageChannelDictionary.setValueByKey( const key: string; const value: IMessageChannel );
var
  idx: nativeuint;
begin
  if getCount>0 then begin //- Craig! Don't change this!
    for idx := pred(getCount) downto 0 do begin
      if fKeys[idx]=key then begin
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

{$endregion}

{$region ' TLogEntryDictionary'}

procedure TLogEntryDictionary.Initialize(const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false);
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

constructor TLogEntryDictionary.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  Initialize(Granularity,isOrdered,isPruned);
end;

destructor TLogEntryDictionary.Destroy;
begin
  SetLength( fKeys, 0 );
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TLogEntryDictionary.getCount: nativeuint;
begin
  Result := fCount;
end;

function TLogEntryDictionary.getKeyByIndex( const idx: nativeuint ): TGUID;
begin
  Result := Default(TGUID);
  if idx<getCount then begin
    Result := fKeys[idx];
  end;
end;

function TLogEntryDictionary.getKeyExists( const key: TGUID ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if IsEqualGUID(fKeys[idx],key) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TLogEntryDictionary.getValueByIndex( const idx: nativeuint ): string;
begin
  Result := '';
  if idx<getCount then begin
    Result := fItems[idx];
  end;
end;

procedure TLogEntryDictionary.setValueByIndex( const idx: nativeuint; const value: string );
begin
  fItems[idx] := value;
end;

function TLogEntryDictionary.getValueByKey( const key: TGUID ): string;
var
  idx: nativeuint;
begin
  Result := '';
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if IsEqualGUID(fKeys[idx],key) then begin
      Result := fItems[idx];
      Exit;
    end;
  end;
end;

function TLogEntryDictionary.OrderedRemoveItem( const idx: nativeuint ): boolean;
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
    fItems[pred(fCount)] := '';
    fKeys[pred(fCount)] := Default(TGUID);
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- Item is last on list, no need to move-down items above it.
    fItems[idx] := '';
    fKeys[idx] := Default(TGUID);
    dec(fCount);
    Result := True;
  end;
end;

function TLogEntryDictionary.UnorderedRemoveItem( const idx: nativeuint ): boolean;
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
    fItems[pred(fCount)] := '';
    fKeys[pred(fCount)] := Default(TGUID);
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- if idx=fCount then simply remove the top item and decrement
    fItems[idx] := '';
    fKeys[idx] := Default(TGUID);
    dec(fCount);
    Result := True;
  end;
end;

procedure TLogEntryDictionary.PruneCapacity;
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

procedure TLogEntryDictionary.removeByIndex( const idx: nativeuint );
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

procedure TLogEntryDictionary.Clear;
begin
  fCount := 0;
  if fPruned then begin
    fCapacity := 0;
    SetLength( fKeys, fCapacity );
    SetLength( fItems, fCapacity );
  end;
end;

procedure TLogEntryDictionary.setValueByKey( const key: TGUID; const value: string );
var
  idx: nativeuint;
begin
  if getCount>0 then begin //- Craig! Don't change this!
    for idx := pred(getCount) downto 0 do begin
      if IsEqualGUID(fKeys[idx],key) then begin
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

{$endregion}

end.

