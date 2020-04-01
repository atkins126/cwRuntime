{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.NativeUintHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestNativeUintHelper = class(TTestCase)
  private
  published
    procedure AsPointer;
  end;

implementation

procedure TTestNativeUintHelper.AsPointer;
var
  N: nativeuint;
begin
  // Arrange:
  // Act:
  N := NativeUInt(self);
  // Assert:
  TTest.Expect(TRUE,Self=N.AsPointer);
end;

initialization
  TestSuite.RegisterTestCase(TTestNativeUintHelper);

end.
