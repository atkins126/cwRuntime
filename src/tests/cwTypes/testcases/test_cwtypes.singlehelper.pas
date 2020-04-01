{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.SingleHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestSingleHelper = class(TTestCase)
  private
  published
    procedure AsString;
  end;

implementation

procedure TTestSingleHelper.AsString;
var
  F: single;
  S: string;
begin
  // Arrange:
  F := 12.685;
  // Act:
  S := F.AsString;
  // Assert:
  TTest.Expect('12.685',S.LeftStr(6));
end;

initialization
  TestSuite.RegisterTestCase(TTestSingleHelper);

end.
