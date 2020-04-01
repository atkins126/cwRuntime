{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.PointerHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestPointerHelper = class(TTestCase)
  private
  published
    procedure AsNativeUint;
    procedure PCharLen;
  end;

implementation

procedure TTestPointerHelper.AsNativeUint;
var
  P: pointer;
begin
  // Arrange:
  P := Self;
  // Act:
  // Assert:
  TTest.Expect(TRUE,P.AsNativeUint=nativeuint(Self));
end;

procedure TTestPointerHelper.PCharLen;
var
  Data: array[0..17] of uint8;
  P: pointer;
begin
  // Arrange:
  Data[00] := ord('h');
  Data[01] := ord('e');
  Data[02] := ord('l');
  Data[03] := ord('l');
  Data[04] := ord('o');
  Data[05] := ord(' ');
  Data[06] := ord('c');
  Data[07] := ord('r');
  Data[08] := ord('u');
  Data[09] := ord('e');
  Data[10] := ord('l');
  Data[11] := ord(' ');
  Data[12] := ord('w');
  Data[13] := ord('o');
  Data[14] := ord('r');
  Data[15] := ord('l');
  Data[16] := ord('d');
  Data[17] := 0;
  P := @Data[0];
  // Act:
  // Assert:
  TTest.Expect(TRUE,P.PCharLen=Pred(Length(Data)));
end;

initialization
  TestSuite.RegisterTestCase(TTestPointerHelper);

end.
