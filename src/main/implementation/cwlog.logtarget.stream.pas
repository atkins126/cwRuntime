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
unit cwLog.LogTarget.Stream;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
, cwIO
;

type
  TStreamLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fIncludeCRLF: boolean;
    fStream: IUnicodeStream;
    fFormat: TUnicodeFormat;
  strict private //- ILogTarget -//
    {$hints off} procedure Insert( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string ); {$hints on}
  public
    constructor Create( const TargetStream: IUnicodeStream; const Format: TUnicodeFormat; const IncludeCRLF: boolean = TRUE ); reintroduce;
  end;

implementation
uses
  cwTypes
;

constructor TStreamLogTarget.Create(const TargetStream: IUnicodeStream; const Format: TUnicodeFormat; const IncludeCRLF: boolean = TRUE);
begin
  inherited Create;
  fStream := TargetStream;
  fFormat := Format;
  fIncludeCRLF := IncludeCRLF;
end;

{$hints off}
procedure TStreamLogTarget.Insert(const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string );
begin
  if fIncludeCRLF then begin
    fStream.WriteString( TranslatedText+CR+LF, fFormat );
  end else begin
    fStream.WriteString( TranslatedText, fFormat );
  end;
end;
{$hints on}

end.

