{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit TestCase.TearDownFails;
{$ifdef fpc}{$mode delphiunicode}{$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
;

type
  TTearDownFailTest = class( TTestCase )
  published
    ///  <summary>
    ///    TearDown method will fail by raising exception.
    ///  </summary>
    procedure TearDown;

    /// <summary>
    ///   This test would succeed if it weren't for the TearDown method failing.
    /// </summary>
    procedure Sample;
  end;

implementation
uses
  sysutils
;

procedure TTearDownFailTest.TearDown;
begin
  raise
    Exception.Create('Oh no! TearDown failed!');
end;

procedure TTearDownFailTest.Sample;
begin
end;


initialization
  TestSuite.RegisterTestCase( TTearDownFailTest );

end.
