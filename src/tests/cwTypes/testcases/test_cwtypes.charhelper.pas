{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test_cwTypes.CharHelper;
{$ifdef fpc} {$mode delphiunicode} {$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
, cwTypes
;

type
  TTestCharHelper = class(TTestCase)
  private
  published
    procedure CharInArray;
  end;

implementation

procedure TTestCharHelper.CharInArray;
var
  C: char;
begin
  // Arrange:
  C := 'X';
  // Act:
  // Assert:
  TTest.Expect(FALSE ,C.CharInArray(['A','B','C']));
  TTest.Expect(TRUE  ,C.CharInArray(['X','B','C']));
  TTest.Expect(TRUE  ,C.CharInArray(['A','X','C']));
  TTest.Expect(TRUE  ,C.CharInArray(['A','B','X']));
  TTest.Expect(FALSE ,C.CharInArray(['x','B','C']));
  TTest.Expect(FALSE ,C.CharInArray(['A','x','C']));
  TTest.Expect(FALSE ,C.CharInArray(['A','B','x']));
  TTest.Expect(TRUE  ,C.CharInArray(['X']));
  TTest.Expect(FALSE ,C.CharInArray([]));
end;

initialization
  TestSuite.RegisterTestCase(TTestCharHelper);

end.
