{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit test_cwtest.sampletest;
{$ifdef fpc}{$mode delphiunicode}{$M+}{$endif}

interface
uses
  cwTest
, cwTest.Standard
;

type
  TSampleTest = class( TTestCase )
  published
    procedure SucceedSample;
    procedure FailSample;
    procedure ErrorSample;
  end;

implementation

procedure TSampleTest.ErrorSample;
var
  R: single;
begin
  //- Attempt to divide by zero to raise an exception.
  R := 3;
  R := R / 0;
end;

procedure TSampleTest.FailSample;
begin
  TTest.Fail('Sample method "FailSample" failed.');
end;

procedure TSampleTest.SucceedSample;
begin
  //- Do nothing and this test succeeds.
end;

initialization
  TestSuite.RegisterTestCase( TSampleTest );

end.


