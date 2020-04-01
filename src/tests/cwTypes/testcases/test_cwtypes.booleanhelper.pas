{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.BooleanHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestBooleanHelper = class(TTestCase)
  private
  published
    procedure AsString;
  end;

implementation

procedure TTestBooleanHelper.AsString;
var
  B1: boolean;
  B2: boolean;
  B3: boolean;
  B4: boolean;
  B5: boolean;
  B6: boolean;
begin
  // Arrange:
  B1 := True;
  B2 := False;
  // Act:
  {$warnings off} B3.AsString := 'True'; {$warnings on} // Warns that B3 is not initialized, this is initialization
  {$warnings off} B4.AsString := 'False';{$warnings on} // Warns that B4 is not initialized, this is initialization
  {$warnings off} B5.AsString := 'TRUE'; {$warnings on} // Warns that B5 is not initialized, this is initialization
  {$warnings off} B6.AsString := 'XYZ';  {$warnings on} // Warns that B6 is not initialized, this is initialization
  // Assert:
  TTest.Expect('TRUE',B1.AsString);
  TTest.Expect('FALSE',B2.AsString);
  TTest.Expect(TRUE,B3);
  TTest.Expect(FALSE,B4);
  TTest.Expect(TRUE,B5);
  TTest.Expect(FALSE,B6);
end;

initialization
  TestSuite.RegisterTestCase(TTestBooleanHelper);

end.
