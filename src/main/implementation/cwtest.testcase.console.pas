{$ifdef license}
(*  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
    All Rights Reserved.
*)
{$endif}
/// <exclude/>
unit cwTest.TestCase.Console;
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
  fCurrentTestCase := TestCase;
  WriteDepth;
  Writeln('<TestCase name="',fCurrentTestCase,'">');
  inc(fCurrentDepth);
end;

procedure TStandardConsoleReport.BeginTestSuite(const TestSuite: string);
begin
  fCurrentTestSuite := TestSuite;
  fCurrentTestCase := '';
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
  Writeln('<TestCase/>');
  fCurrentTestCase := '';
  dec(fCurrentDepth);
end;

procedure TStandardConsoleReport.EndTestSuite;
begin
  WriteDepth;
  Writeln('<TestSuite/>');
  fCurrentTestSuite := '';
  fCurrentTestCase := '';
  dec(fCurrentDepth);
end;

procedure TStandardConsoleReport.RecordTestResult(const TestName: string; const TestResultState: TTestResult; const Reason: string);
var
  TestResultStr: string;
begin
  case TestResultState of
    trSucceeded: TestResultStr := 'SUCCESS';
       trFailed: TestResultStr := 'FAILED';
        trError: TestResultStr := 'ERROR';
        else begin
          TestResultStr := '';
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
