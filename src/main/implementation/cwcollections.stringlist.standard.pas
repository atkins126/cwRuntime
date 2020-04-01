{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwCollections.StringList.Standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  cwCollections
;

type
  TStandardStringList = class( TInterfacedObject, IReadOnlyStringList, IStringList )
  private
    fStrings: IList<string>;
  strict private //- IReadOnlyStringList -//
    procedure ForEach( const Enumerate: TEnumerate<string> ); overload;
    function getCount: nativeuint;
    function getString( const idx: nativeuint ): string;
    function getAsReadOnly: IReadOnlyStringList;
    function Contains( const Search: string; const CaseInsensitive: boolean = FALSE ): boolean;
  strict private //- IStringList -//
    procedure Clear;
    function Add( const value: string ): nativeuint;
    procedure setString( const idx: nativeuint; const value: string );
    function RemoveString( const idx: nativeuint ): boolean;
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils
, cwCollections.List.Standard
;

constructor TStandardStringList.Create(const Granularity: nativeuint; const isOrdered: boolean; const isPruned: boolean);
begin
  inherited Create;
  fStrings := TStandardList<string>.Create( Granularity, isOrdered, isPruned );
end;

function TStandardStringList.Add(const value: string): nativeuint;
begin
  Result := fStrings.Add(value);
end;

procedure TStandardStringList.Clear;
begin
  fStrings.Clear;
end;

function TStandardStringList.Contains(const Search: string; const CaseInsensitive: boolean): boolean;
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

destructor TStandardStringList.Destroy;
begin
  fStrings := nil;
  inherited Destroy;
end;

procedure TStandardStringList.ForEach(const Enumerate: TEnumerate<string>);
begin
  fStrings.ForEach(Enumerate);
end;

function TStandardStringList.getAsReadOnly: IReadOnlyStringList;
begin
  Result := Self as IReadOnlyStringList;
end;

function TStandardStringList.getCount: nativeuint;
begin
  Result := fStrings.Count;
end;

function TStandardStringList.getString(const idx: nativeuint): string;
begin
  Result := fStrings[idx];
end;

function TStandardStringList.RemoveString(const idx: nativeuint): boolean;
begin
  Result := fStrings.RemoveItem(idx);
end;

procedure TStandardStringList.setString(const idx: nativeuint; const value: string);
begin
  fStrings[idx] := Value;
end;

end.

