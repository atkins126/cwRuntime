{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.DoubleHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestDoubleHelper = class(TTestCase)
  private
  published
    procedure AsString;
  end;

implementation

procedure TTestDoubleHelper.AsString;
var
  D: double;
  S: string;
begin
  // Arrange:
  D := 12.685;
  // Act:
  S := D.AsString;
  // Assert:
  TTest.Expect('12.685',S);
end;

initialization
  TestSuite.RegisterTestCase(TTestDoubleHelper);

end.
