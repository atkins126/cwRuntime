{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.Uint8Helper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestUint8Helper = class(TTestCase)
  private
  published
    procedure AsString;
    procedure AsHex;
  end;

implementation

procedure TTestUint8Helper.AsHex;
var
  I: uint8;
  S: string;
begin
  // Arrange:
  I := 12;
  // Act:
  S := I.AsHex(2);
  // Assert:
  TTest.Expect('0C',S);
end;

procedure TTestUint8Helper.AsString;
var
  I: uint8;
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
  TestSuite.RegisterTestCase(TTestUint8Helper);

end.
