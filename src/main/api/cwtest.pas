{$ifdef license}
(*  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
    All Rights Reserved.
*)
{$endif}
/// <summary>
///   cwTest unit testing framework from ChapmanWorld LLC.
/// </summary>
unit cwTest;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  sysutils
;

type 
  /// <summary>
  ///   This type of exception is raised within a test to indicate that the
  ///   test failed. <br/>
  ///   You need not raise this exception directly, instead, call one of the methods
  ///   of TTest from cwTest.Standard
  /// </summary>
  EFailedTest = class(Exception);

  ///  <summary>
  ///    A simple base class from which to derive test cases. <br/>
  ///    Descendants of TTestCase may be registered with the singleton
  ///    TestSuite using ITestSuite.RegisterTestCase() to be run as part
  ///    of a test suite. <br/> Add parameter-less published methods to TTestCase
  ///    to have them executed as tests. <br/>
  ///    If the test case has a method named <b>'Setup'</b> it will be called before
  ///    each test method. Similarly, if the test case has a method named
  ///    <b>'TearDown'</b> it will be called after each test method.
  ///  </summary>
  TTestCase = class end;

  ///  <summary>
  ///    Class type for passing into RegisterTestCase.
  ///  </summary>
  TTestCaseClass = class of TTestCase;

  ///  <summary>
  ///    Represents the three possible result states of running a test.
  ///  </summary>
  TTestResult = (
    /// <summary>
    ///   The test succeeded.
    /// </summary>
    trSucceeded,
    /// <summary>
    ///   The test failed (did not meet test criteria).
    /// </summary>
    trFailed,
    /// <summary>
    ///   An error occurred while running the test (exception was raised).
    /// </summary>
    trError,
    /// <summary>
    ///   An error occurred while running the case Setup() method.
    /// </summary>
    trSetupError,
    /// <summary>
    ///   An error occurred while running the case TearDown() method.
    /// </summary>
    trTearDownError
  );

  ///  <summary>
  ///    An instance of ITestReport is passed to the singleton TestSuite
  ///    to receive the results of executing its test cases.
  ///  </summary>
  ITestReport = interface
    ['{CFDD6581-644F-4DF0-898D-C6AAF89E4B0F}']

    ///  <summary>
    ///    Called by the ITestSuite implementation when the run of tests
    ///    begins. A subsequent call to EndTestSuite indicates that this
    ///    suite has completed its run.
    ///  </summary>
    procedure BeginTestSuite( const TestSuite: string );

    /// <summary>
    ///   Called when the test suite has completed a run to test cases.
    /// </summary>
    procedure EndTestSuite;

    /// <summary>
    ///   Called by the ITestSuite implementation for each test case before it
    ///   begins. A subsequent call to EndTestCase will be made to inciate the
    ///   completion of a test case.
    /// </summary>
    procedure BeginTestCase( const TestCase: string );

    /// <summary>
    ///   Called by the ITestSuite implementation when a test case has
    ///   completed its run.
    /// </summary>
    procedure EndTestCase;

    /// <summary>
    ///   Called by the ITestSuite implementation for each test which is run as
    ///   part of a test case.
    /// </summary>
    procedure RecordTestResult( const TestName: string; const TestResultState: TTestResult; const Reason: string );
  end;

  ///  <summary>
  ///    This is an interface for working with the singleton instance
  ///    TestSuite, which behaves as a collection of test cases.
  ///  </summary>
  ITestSuite = interface
    ['{B8E90890-4587-461E-A6DA-71F1C45147DB}']

    ///  <summary>
    ///    Called to register a test case with the test suite.
    ///  </summary>
    procedure RegisterTestCase( const TestCase: TTestCaseClass );

    /// <summary>
    ///   Runs all test cases that have been registered with the suite.
    /// </summary>
    /// <returns>
    ///   The total number of errors or failures.
    /// </returns>
    function Run( const SuiteName: string; const TestReports: array of ITestReport ): nativeuint;
  end;

implementation

end.
