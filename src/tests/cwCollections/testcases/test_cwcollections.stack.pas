{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwCollections.Stack;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwCollections
, cwCollections.standard
;

type
  TTest_cwCollectionsStack = class(TTestCase)
  private
    procedure internal_Push( vCUT: ICollection );
    procedure internal_Pull( vCUT: ICollection );

  published
    procedure Push;
    procedure Pull;
  end;

implementation
uses
  cwTest.Standard
;

//------------------------------------------------------------------------------
// A simple collection item for testing the stack.
//------------------------------------------------------------------------------
type
  ICollectionItem = interface
    function getValue: uint32;
    procedure setValue( value: uint32 );
    property Value: uint32 read getValue write setValue;
  end;
  TCollectionItem = class( TInterfacedObject, ICollectionItem )
  private
    fValue: uint32;
  private
    function getValue: uint32;
    procedure setValue( value: uint32 );
  public
    constructor create( value: uint32 = 0 ); reintroduce;
  end;

constructor TCollectionItem.create(value: uint32);
begin
  inherited create;
  fValue := Value;
end;

function TCollectionItem.getValue: uint32;
begin
  Result := fValue;
end;

procedure TCollectionItem.setValue(value: uint32);
begin
  fValue := Value;
end;
//------------------------------------------------------------------------------

procedure TTest_cwCollectionsStack.internal_Pull( vCUT: ICollection );
var
  CUT: IStack<ICollectionItem>;
begin
  CUT := (vCUT as IStack<ICollectionItem>);
  CUT.Push(TCollectionItem.create(0));
  CUT.Push(TCollectionItem.create(1));
  CUT.Push(TCollectionItem.create(2));
  TTest.Expect(True,CUT.Pull.Value=2);
  TTest.Expect(True,CUT.Pull.Value=1);
  TTest.Expect(True,CUT.Pull.Value=0);
  TTest.Expect(False,assigned(CUT.Pull));
end;

procedure TTest_cwCollectionsStack.internal_Push( vCUT: ICollection );
begin
  internal_Pull( vCUT ); //- Same test as Pull!
end;

procedure TTest_cwCollectionsStack.Push;
var
  CUT: IStack<ICollectionItem>;
begin
  CUT := TStack<ICollectionItem>.Create(2,FALSE);
  internal_Push(CUT);
  CUT := TStack<ICollectionItem>.Create(2,TRUE);
  internal_Push(CUT);
  CUT := TStack<ICollectionItem>.Create(32,FALSE);
  internal_Push(CUT);
  CUT := TStack<ICollectionItem>.Create(32,TRUE);
  internal_Push(CUT);
end;

procedure TTest_cwCollectionsStack.Pull;
var
  CUT: IStack<ICollectionItem>;
begin
  CUT := TStack<ICollectionItem>.Create(2,FALSE);
  internal_Pull(CUT);
  CUT := TStack<ICollectionItem>.Create(2,TRUE);
  internal_Pull(CUT);
  CUT := TStack<ICollectionItem>.Create(32,FALSE);
  internal_Pull(CUT);
  CUT := TStack<ICollectionItem>.Create(32,TRUE);
  internal_Pull(CUT);
end;


initialization
  TestSuite.RegisterTestCase(TTest_cwCollectionsStack)

end.


