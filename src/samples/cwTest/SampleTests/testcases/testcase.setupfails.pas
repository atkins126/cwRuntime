{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit TestCase.SetupFails;
{$ifdef fpc}{$mode delphiunicode}{$endif}
{$M+}

interface
uses
  cwTest
, cwTest.Standard
;

type
  TSetupFailTest = class( TTestCase )
  published
    ///  <summary>
    ///    Setup method will fail by raising exception.
    ///  </summary>
    procedure Setup;

    ///  <summary>
    ///    No issue with this tear-down, but it should be called regardless of failing setup.
    ///  </summary>
    procedure TearDown;

    /// <summary>
    ///   This test would succeed if it weren't for the setup method failing.
    /// </summary>
    procedure Sample;
  end;

implementation
uses
  sysutils
;

procedure TSetupFailTest.Setup;
begin
  raise
    Exception.Create('Oh no! Setup failed!');
end;

procedure TSetupFailTest.TearDown;
begin
  //-
end;

procedure TSetupFailTest.Sample;
begin
end;

initialization
  TestSuite.RegisterTestCase( TSetupFailTest );

end.
