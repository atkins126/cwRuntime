{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.

  3. Neither the name of the copyright holder nor the names of its contributors may be
     used to endorse or promote products derived from this software without specific prior
     written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
{$endif}
unit test_cwlog.inserts.static;
{$ifdef fpc}{$mode delphiunicode}{$endif}
{$M+}

interface
uses
  cwTest
;

type
  TTest_cwLog_Insert = class( TTestCase )
  private
  published

    //- Tests that a log entry is inserted with 'info' level severity.
    procedure Test_InsertLogEntry_Info;

    //- Tests that a log entry is inserted with 'hint' level severity.
    procedure Test_InsertLogEntry_Hint;

    //- Tests that a log entry is inserted with 'warning' level severity.
    procedure Test_InsertLogEntry_Warning;

    //- Tests that a log entry is inserted with 'error' level severity.
    procedure Test_InsertLogEntry_Error;

    //- Tests that a log entry is inserted with 'fata' level severity, and that an exception is
    //- raised to reflect the fatal severity level.
    procedure Test_InsertLogEntry_Fatal;

    //- Tests that many placeholders are correctly replaced in the log string when inserting
    //- an 'info' level severity entry. Also checks that placeholders need be provided only
    //- once, but that substitutions may be re-used in the entry.
    procedure Test_InsertLogEntry_Info_Substitution;

    //- Tests that many placeholders are correctly replaced in the log string when inserting
    //- an 'hint' level severity entry. Also checks that placeholders need be provided only
    //- once, but that substitutions may be re-used in the entry.
    procedure Test_InsertLogEntry_Hint_Substitution;

    //- Tests that many placeholders are correctly replaced in the log string when inserting
    //- an 'warning' level severity entry. Also checks that placeholders need be provided only
    //- once, but that substitutions may be re-used in the entry.
    procedure Test_InsertLogEntry_Warning_Substitution;

    //- Tests that many placeholders are correctly replaced in the log string when inserting
    //- an 'error' level severity entry. Also checks that placeholders need be provided only
    //- once, but that substitutions may be re-used in the entry.
    procedure Test_InsertLogEntry_Error_Substitution;

    //- Tests that many placeholders are correctly replaced in the log string when inserting
    //- an 'fatal' level severity entry. Also checks that placeholders need be provided only
    //- once, but that substitutions may be re-used in the entry. Also tests for exception
    //- being raised to reflect fatal severity.
    procedure Test_InsertLogEntry_Fatal_Substitution;
  end;

implementation
uses
  sysutils
, cwTest.Standard
, cwLog
, cwLog.Standard
;

const
  stTestLogEntry: TStatus = ( Value: '{68D3D83C-4109-4EB5-AB8E-F5F9EDE5E540}');
  stAlphabet: TStatus = ( Value: '{4CAC6378-7500-4BAB-B0C8-8F15BB051B1A}');

const
  cstTestLogEntryGUID = '{68D3D83C-4109-4EB5-AB8E-F5F9EDE5E540}';
  cstTestLogEntryText = 'This is a test log entry.';
  cstAlphabetGUID = '{4CAC6378-7500-4BAB-B0C8-8F15BB051B1A}';
  cstAlphabetText = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z A B C.';


procedure TTest_cwLog_Insert.Test_InsertLogEntry_Info;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stTestLogEntry,lsInfo);
  // Assert
  TTest.Expect( cstTestLogEntryGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[INFO] '+cstTestLogEntryText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Hint;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stTestLogEntry,lsHint);
  // Assert
  TTest.Expect( cstTestLogEntryGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[HINT] '+cstTestLogEntryText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Warning;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stTestLogEntry,lsWarning);
  // Assert
  TTest.Expect( cstTestLogEntryGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[WARNING] '+cstTestLogEntryText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Error;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stTestLogEntry,lsError);
  // Assert
  TTest.Expect( cstTestLogEntryGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[ERROR] '+cstTestLogEntryText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Fatal;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stTestLogEntry,lsFatal);
  // Assert
  TTest.Expect( cstTestLogEntryGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[FATAL] '+cstTestLogEntryText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Info_Substitution;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stAlphabet,lsInfo,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
  // Assert
  TTest.Expect( cstAlphabetGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[INFO] '+cstAlphabetText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Hint_Substitution;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stAlphabet,lsHint,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
  // Assert
  TTest.Expect( cstAlphabetGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[HINT] '+cstAlphabetText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Warning_Substitution;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stAlphabet,lsWarning,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
  // Assert
  TTest.Expect( cstAlphabetGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[WARNING] '+cstAlphabetText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Error_Substitution;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stAlphabet,lsError,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
  // Assert
  TTest.Expect( cstAlphabetGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[ERROR] '+cstAlphabetText, Log.getLastEntry );
end;

procedure TTest_cwLog_Insert.Test_InsertLogEntry_Fatal_Substitution;
var
  R: TStatus;
begin
  // Act
  R := Log.Insert(stAlphabet,lsFatal,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
  // Assert
  TTest.Expect( cstAlphabetGUID, string(GUIDToString(R.Value)) );
  TTest.Expect( '[FATAL] '+cstAlphabetText, Log.getLastEntry );
end;

initialization
  TestSuite.RegisterTestCase( TTest_cwLog_Insert );
  Log.RegisterEntry(stTestLogEntry,'This is a test log entry.');
  Log.RegisterEntry(stAlphabet,'(%a%) (%b%) (%c%) (%d%) (%e%) (%f%) (%g%) (%h%) (%i%) (%j%) (%k%) (%l%) (%m%) (%n%) (%o%) (%p%) (%q%) (%r%) (%s%) (%t%) (%u%) (%v%) (%w%) (%x%) (%y%) (%z%) (%a%) (%b%) (%c%).');

end.

