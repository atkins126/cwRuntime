{$ifdef license}
(*  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
    All Rights Reserved.
*)
{$endif}
/// <exclude/> 
unit cwTest.TestSuite.Delphi;

interface
{$ifndef fpc}
uses
  cwTest
, cwTest.TestSuite.Custom
;

type
  TTestSuite = class( TCustomTestSuite, ITestSuite )
  private
    function RunMethod(const TestCase: TTestCase; const aMethodName: string; out Reason: string): boolean;
    function RunSetupMethod(const TestCase: TTestCase; out Reason: string): TTestResult;
    function RunTearDownMethod(const TestCase: TTestCase; out Reason: string): TTestResult;
  protected
    function GetTestMethods( const TestCaseClass: TTestCaseClass; out HasSetup: boolean; out HasTearDown: boolean ): TArrayOfMethodName; override;
    function ExecuteTestMethod( const TestCaseClass: TTestCaseClass; const aMethodName: string; const WithSetup: boolean; const WithTeardown: boolean; out Reason: string ): TTestResult; override;
  end;

{$endif}
implementation
{$ifndef fpc}
uses
  sysutils
, system.rtti
, typinfo
;

function TTestSuite.RunMethod( const TestCase: TTestCase; const aMethodName: string; out Reason: string ): boolean;
var
  utSearch: string;
  utMethodName: string;
  Context: TRTTIContext;
  rttiType: TRTTIType;
  rttiMethods: TArray<TRTTIMethod>;
  rttiMethod: TRTTIMethod;
begin
  Result := False;
  utSearch := Uppercase(Trim(aMethodName));
  Context := TRTTIContext.Create;
  rttiType := Context.GetType(TestCase.ClassType);
  rttiMethods := rttiType.GetMethods;
  for rttiMethod in rttiMethods do begin
    utMethodName := uppercase(trim(rttiMethod.Name));
    if utMethodName<>utSearch then begin
      continue;
    end;
    rttiMethod.Invoke(TestCase,[]);
    Result := True;
    exit;
  end;
  Reason := 'Method "'+aMethodName+'" not found.';
end;

function TTestSuite.RunTearDownMethod( const TestCase: TTestCase; out Reason: string ): TTestResult;
const
  cTearDown = 'TEARDOWN';
begin
  Reason := '';
  Result := TTestResult.trTearDownError;
  try
    if not RunMethod(TestCase,cTearDown,Reason) then begin
      exit;
    end;
  except
    on E: Exception do begin
      Reason := E.Message;
      exit;
    end else begin
      Reason := 'Unknown Exception';
      exit;
    end;
  end;
  Result := TTestResult.trSucceeded;
end;

function TTestSuite.RunSetupMethod( const TestCase: TTestCase; out Reason: string ): TTestResult;
const
  cSetup = 'SETUP';
var
  IgnoreStr: string;
begin
  Reason := '';
  Result := TTestResult.trSetupError;
  try
    if not RunMethod(TestCase,cSetup,Reason) then begin
      exit;
    end;
  except
    on E: Exception do begin
      Reason := E.Message;
      RunTearDownMethod(TestCase,IgnoreStr);
      exit;
    end else begin
      RunTearDownMethod(TestCase,IgnoreStr);
      exit;
    end;
  end;
  Result := TTestResult.trSucceeded;
end;

function TTestSuite.ExecuteTestMethod( const TestCaseClass: TTestCaseClass; const aMethodName: string; const WithSetup: boolean; const WithTeardown: boolean; out Reason: string ): TTestResult;
var
  TestCase: TTestCase;
  IgnoreStr: string;
begin
  Result := TTestResult.trError;
  //-
  TestCase := TestCaseClass.Create;
  try
    //- Run setup method.
    if WithSetup then begin
      Result := RunSetupMethod(TestCase,Reason);
      if Result<>TTestResult.trSucceeded then begin
        exit;
      end;
    end;

    //- Run test method.
    try
      RunMethod( TestCase, aMethodName, Reason );
    except
      on E: EFailedTest do begin
        Reason := E.Message;
        Result := TTestResult.trFailed;
        exit;
      end;
      on E: Exception do begin
        Reason := E.Message;
        exit;
      end
      else exit;
    end;
    Result := TTestResult.trSucceeded;

    //- Run TearDown method.
    if WithTearDown then begin
      if Result=TTestResult.trSucceeded then begin
        Result := RunTearDownMethod(TestCase, Reason);
      end else begin
        RunTearDownMethod(TestCase, IgnoreStr);
      end;
    end;

  finally
    TestCase.DisposeOf;
  end;
end;

function TTestSuite.GetTestMethods( const TestCaseClass: TTestCaseClass; out HasSetup: boolean; out HasTearDown: boolean ): TArrayOfMethodName;
const
  cSetup = 'SETUP';
  cTearDown = 'TEARDOWN';
var
  Context: TRTTIContext;
  rttiType: TRTTIType;
  rttiMethods: TArray<TRTTIMethod>;
  rttiMethod: TRTTIMethod;
  utMethod: string;
  count: nativeuint;
  idx: nativeuint;
begin
  HasSetup := False;
  HasTearDown := False;
  Context := TRTTIContext.Create;
  rttiType := Context.GetType(TestCaseClass);
  rttiMethods := rttiType.GetMethods;
  Count := 0;
  for rttiMethod in rttiMethods do begin
    if rttiMethod.IsConstructor then begin
      continue;
    end;
    if rttiMethod.IsDestructor then begin
      continue;
    end;
    if rttiMethod.Visibility<>TMemberVisibility.mvPublished then begin
      continue;
    end;
    utMethod := Uppercase(Trim(rttiMethod.Name));
    if utMethod=cSetup then begin
      HasSetup := True;
      continue;
    end;
    if utMethod=cTearDown then begin
      HasTearDown := True;
      continue;
    end;
    inc(Count);
  end;
  SetLength(Result,Count);
  idx := 0;
  for rttiMethod in rttiMethods do begin
    if rttiMethod.IsConstructor then begin
      continue;
    end;
    if rttiMethod.IsDestructor then begin
      continue;
    end;
    if rttiMethod.Visibility<>TMemberVisibility.mvPublished then begin
      continue;
    end;
    utMethod := Uppercase(Trim(rttiMethod.Name));
    if utMethod=cSetup then begin
      continue;
    end;
    if utMethod=cTearDown then begin
      continue;
    end;
    Result[idx] := rttiMethod.Name;
    inc(idx);
  end;
end;

{$endif}
end.
