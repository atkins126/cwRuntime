{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.Uint64Helper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestUint64Helper = class(TTestCase)
  private
  published
    procedure AsString;
    procedure AsHex;
  end;

implementation

procedure TTestUint64Helper.AsHex;
var
  I: uint64;
  S: string;
begin
  // Arrange:
  I := 12;
  // Act:
  S := I.AsHex(2);
  // Assert:
  TTest.Expect('0C',S);
end;

procedure TTestUint64Helper.AsString;
var
  I: uint64;
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
  TestSuite.RegisterTestCase(TTestUint64Helper);

end.
