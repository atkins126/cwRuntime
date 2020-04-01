{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwCollections.RingBuffer;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwCollections
, cwCollections.Standard
;

type
  TTest_cwCollectionsRingBuffer = class(TTestCase)
  private
    procedure internal_Push( vCUT: ICollection );
    procedure internal_Peek( vCUT: ICollection );
    procedure internal_Pull( vCUT: ICollection );
  published
    procedure Push;
    procedure Peek;
    procedure Pull;
  end;

implementation
uses
  cwTest.Standard
;

procedure TTest_cwCollectionsRingBuffer.internal_Peek( vCUT: ICollection );
var
  CUT: IRingBuffer<uint32>;
  x: uint32;
begin
  CUT := (vCUT as IRingBuffer<uint32>);
  TTest.Expect(True,CUT.IsEmpty);
  CUT.Push(3);
  TTest.Expect(False,CUT.IsEmpty);
  CUT.Push(2);
  TTest.Expect(False,CUT.IsEmpty);
  CUT.Pull(x);
  TTest.Expect(False,CUT.IsEmpty);
  CUT.Pull(x);
  TTest.Expect(True,CUT.IsEmpty);
end;

procedure TTest_cwCollectionsRingBuffer.internal_Pull( vCUT: ICollection );
var
  CUT: IRingBuffer<uint32>;
  x: uint32;
begin
  CUT := (vCUT as IRingBuffer<uint32>);
  CUT.Push(3);
  CUT.Push(2);
  TTest.Expect(True,CUT.Pull(x));
  TTest.Expect(True,CUT.Pull(x));
  TTest.Expect(False,CUT.Pull(x));
end;

procedure TTest_cwCollectionsRingBuffer.internal_Push( vCUT: ICollection );
var
  CUT: IRingBuffer<uint32>;
begin
  CUT := (vCUT as IRingBuffer<uint32>);
  TTest.Expect(True,CUT.Push(3));
  TTest.Expect(True,CUT.Push(2));
  TTest.Expect(False,CUT.Push(5));
end;

procedure TTest_cwCollectionsRingBuffer.Push;
var
  CUT: IRingBuffer<uint32>;
begin
  CUT := TRingBuffer<uint32>.Create(3);
  internal_Push(CUT);
end;

procedure TTest_cwCollectionsRingBuffer.Peek;
var
  CUT: IRingBuffer<uint32>;
begin
  CUT := TRingBuffer<uint32>.Create(3);
  internal_Peek(CUT);
end;

procedure TTest_cwCollectionsRingBuffer.Pull;
var
  CUT: IRingBuffer<uint32>;
begin
  CUT := TRingBuffer<uint32>.Create(3);
  internal_Pull(CUT);
end;


initialization
  TestSuite.RegisterTestCase(TTest_cwCollectionsRingBuffer)

end.


