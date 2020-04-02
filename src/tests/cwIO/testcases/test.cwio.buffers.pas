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
unit test.cwIO.Buffers;
{$ifdef fpc} {$mode delphiunicode} {$M+} {$endif}

interface
uses
  cwTest
;

type
  TTest_IUnicodeBuffer_Standard = class(TTestCase)
  private
  published
    procedure FillMem;
    procedure LoadFromStream;
    procedure SaveToStream;
    procedure Assign;
    procedure InsertData;
    procedure AppendData;
    procedure AppendDataASCIIZ;
    procedure ExtractData;
    procedure getDataPointer;
    procedure getSize;
    procedure getByte;
    procedure setByte;
    procedure setSize;
  end;

implementation
uses
  cwTest.Standard
, cwIO
, cwIO.Standard
;

const
  cTestBufferSize = 512;

procedure TTest_IUnicodeBuffer_Standard.FillMem;
var
  idx: nativeuint;
  CUT: IBuffer;
begin
  // Arrange:
  CUT := TBuffer.Create( cTestBufferSize );
  // Act:
  CUT.FillMem($FF);
  // Assert:
  for idx := 0 to pred( cTestBufferSize ) do begin
    TTest.Expect( CUT.getByte(idx), $FF );
  end;
end;

procedure TTest_IUnicodeBuffer_Standard.LoadFromStream;
var
  MS: IStream;
  CUT: IBuffer;
  B: uint8;
  idx: nativeuint;
begin
  // Arrange:
  B := $FE;
  MS := TMemoryStream.Create;
  for idx := 0 to pred(cTestBufferSize) do begin
    MS.Write(@B,1);
  end;
  MS.Position := 0;
  CUT := TBuffer.Create(cTestBufferSize);
  // Act:
  CUT.LoadFromStream(MS,MS.Size);
  // Assert:
  for idx := 0 to pred( cTestBufferSize ) do begin
    TTest.Expect( CUT.getByte(idx), $FE );
  end;
end;

procedure TTest_IUnicodeBuffer_Standard.SaveToStream;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.Assign;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.InsertData;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.AppendData;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.AppendDataASCIIZ;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.ExtractData;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.getDataPointer;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.getSize;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.getByte;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.setByte;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

procedure TTest_IUnicodeBuffer_Standard.setSize;
begin
  // Arrange:
  // Act:
  // Assert:
  TTest.Fail('Test not yet implemented');
end;

initialization
  TestSuite.RegisterTestCase(TTest_IUnicodeBuffer_Standard);

end.


