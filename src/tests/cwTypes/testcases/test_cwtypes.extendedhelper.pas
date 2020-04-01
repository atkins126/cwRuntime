{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.ExtendedHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestExtendedHelper = class(TTestCase)
  private
  published
    procedure AsString;
  end;

implementation

procedure TTestExtendedHelper.AsString;
var
  E: double;
  S: string;
begin
  // Arrange:
  E := 12.685;
  // Act:
  S := E.AsString;
  // Assert:
  TTest.Expect('12.685',S);
end;

initialization
  TestSuite.RegisterTestCase(TTestExtendedHelper);

end.
