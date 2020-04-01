{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.Int8Helper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestInt8Helper = class(TTestCase)
  private
  published
    procedure AsString;
    procedure AsHex;
  end;

implementation

procedure TTestInt8Helper.AsHex;
var
  I: int8;
  S: string;
begin
  // Arrange:
  I := 12;
  // Act:
  S := I.AsHex(2);
  // Assert:
  TTest.Expect('0C',S);
end;

procedure TTestInt8Helper.AsString;
var
  I: int8;
  S: string;
begin
  // Arrange:
  I := 12;
  // Act:
  S := I.AsString;
  // Assert:
  TTest.Expect('12',S);
end;

initialization
  TestSuite.RegisterTestCase(TTestInt8Helper);

end.
