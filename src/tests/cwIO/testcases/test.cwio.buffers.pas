{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit test.coio.buffers;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  deTest
;

type
  TTest_IUnicodeBuffer_Standard = class(TTestCase)
  private
  published
    procedure NoTestsYet;
  end;

implementation

procedure deIO_Buffers.NoTestsYet;
begin

end;

initialization
  TestSuite.RegisterTestCase(TTest_IUnicodeBuffer_Standard);

end.


