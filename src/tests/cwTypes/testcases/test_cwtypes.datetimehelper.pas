{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.DateTimeHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestDateTimeHelper = class(TTestCase)
  private
  published
    procedure AsString;
  end;

implementation

procedure TTestDateTimeHelper.AsString;
var
  DateTime: TDateTime;
  S: string;
begin
  // Arrange:
  {$warnings off} DateTime.Encode( 2019, 04, 11, 21, 26, 15, 00 ); {$warnings on} // warns that DateTime is not initialized, this is initialization
  // Act:
  S := DateTime.AsString;
  // Assert:
  TTest.Expect('2019-04-11 21:26:15',S);
end;

initialization
  TestSuite.RegisterTestCase(TTestDateTimeHelper);

end.
