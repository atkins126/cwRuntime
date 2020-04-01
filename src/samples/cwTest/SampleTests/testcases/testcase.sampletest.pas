{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit TestCase.SampleTest;
{$ifdef fpc}{$mode delphiunicode}{$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
;

type
  TSampleTest = class( TTestCase )
  published

    /// <summary>
    ///   This sample test succeeds. <br />The method executes and completes
    ///   without raising a failure or error state.
    /// </summary>
    procedure SucceedSample;

    /// <summary>
    ///   This test fails. <br />The method raises a fail state resembling a
    ///   failure to meet test criteria.
    /// </summary>
    procedure FailSample;

    /// <summary>
    ///   This sample test enters an error state (throws exception).
    /// </summary>
    procedure ErrorSample;
  end;

implementation

{$hints off}
procedure TSampleTest.ErrorSample;
var
  R: single;
begin
  //- Attempt to divide by zero to raise an exception.
  R := 3;
  R := R / 0;
end;
{$hints on}

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
