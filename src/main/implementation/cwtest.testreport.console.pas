{$ifdef license}
(*  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
    All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwtest.testreport.console;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwTest
;

type
 TStandardConsoleReport = class( TInterfacedObject, ITestReport )
 private
   fCurrentTestSuite: string;
   fCurrentTestCase: string;
   fCurrentDepth: nativeuint;
   fCaseSuccesses: nativeuint;
   fCaseFailures: nativeuint;
   fCaseErrors: nativeuint;
   fSuiteSuccesses: nativeuint;
   fSuiteFailures: nativeuint;
   fSuiteErrors: nativeuint;
 private
   procedure WriteDepth;
 strict private //- ITestReport -//
   procedure BeginTestSuite( const TestSuite: string );
   procedure EndTestSuite;
   procedure BeginTestCase( const TestCase: string );
   procedure EndTestCase;
   procedure RecordTestResult( const TestName: string; const TestResultState: TTestResult; const Reason: string );
 public
   constructor Create; reintroduce;
 end;

implementation

procedure TStandardConsoleReport.BeginTestCase(const TestCase: string);
begin
  fCaseSuccesses := 0;
  fCaseFailures := 0;
  fCaseErrors := 0;
  fCurrentTestCase := TestCase;
  WriteDepth;
  Writeln('<TestCase name="',fCurrentTestCase,'">');
  inc(fCurrentDepth);
end;

procedure TStandardConsoleReport.BeginTestSuite(const TestSuite: string);
begin
  fCurrentTestSuite := TestSuite;
  fCurrentTestCase := '';
  fCaseSuccesses := 0;
  fCaseFailures := 0;
  fCaseErrors := 0;
  fSuiteSuccesses := 0;
  fSuiteFailures := 0;
  fSuiteErrors := 0;
  WriteDepth;
  Writeln('<TestSuite name="',fCurrentTestSuite,'">');
  inc(fCurrentDepth);
end;

constructor TStandardConsoleReport.Create;
begin
  inherited Create;
  fCurrentTestCase := '';
  fCurrentTestSuite := '';
  fCurrentDepth := 0;
end;

procedure TStandardConsoleReport.EndTestCase;
begin
  WriteDepth;
  Writeln('<summary tests=',fCaseSuccesses+fCaseFailures+fCaseErrors,' success=',fCaseSuccesses,' failures=',fCaseFailures,' errors=',fCaseErrors,'/>');
  fCurrentTestCase := '';
  dec(fCurrentDepth);
  WriteDepth;
  Writeln('<TestCase/>');
end;

procedure TStandardConsoleReport.EndTestSuite;
begin
  WriteDepth;
  Writeln('<summary tests=',fSuiteSuccesses+fSuiteFailures+fSuiteErrors,' success=',fSuiteSuccesses,' failures=',fSuiteFailures,' errors=',fSuiteErrors,'/>');
  fCurrentTestSuite := '';
  fCurrentTestCase := '';
  dec(fCurrentDepth);
  WriteDepth;
  Writeln('<TestSuite/>');
end;

procedure TStandardConsoleReport.RecordTestResult(const TestName: string; const TestResultState: TTestResult; const Reason: string);
var
  TestResultStr: string;
begin
  case TestResultState of
    trSucceeded: begin
      TestResultStr := 'SUCCESS';
      inc(fCaseSuccesses);
      inc(fSuiteSuccesses);
    end;
    trFailed: begin
      TestResultStr := 'FAILED';
      inc(fCaseFailures);
      inc(fSuiteFailures);
    end;
    trError: begin
      TestResultStr := 'ERROR';
      inc(fCaseErrors);
      inc(fSuiteErrors);
    end;
    trSetupError: begin
      TestResultStr := 'Setup Failed.';
      inc(fCaseErrors);
      inc(fSuiteErrors);
    end;
    trTearDownError: begin
      TestResultStr := 'TearDown Failed.';
      inc(fCaseErrors);
      inc(fSuiteErrors);
    end;
  end;
  WriteDepth;
  if TestResultState<>trSucceeded then begin
    Writeln('<Test name="',TestName,'" Result="',TestResultStr,'" Reason="'+Reason+'"/>');
  end else begin
    Writeln('<Test name="',TestName,'" Result="',TestResultStr,'"/>');
  end;
end;

procedure TStandardConsoleReport.WriteDepth;
var
  idx: nativeuint;
begin
  if fCurrentDepth=0 then begin
    exit;
  end;
  for idx := 0 to pred(fCurrentDepth) do begin
    Write(chr($09));
  end;
end;

end.
