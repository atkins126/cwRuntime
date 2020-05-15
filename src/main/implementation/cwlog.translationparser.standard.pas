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
unit cwlog.translationparser.standard;
{$ifdef fpc}
  {$mode delphiunicode}
{$endif}

interface
uses
  cwIO
, sysutils
, cwTypes
;

type
  TTranslationParser = record
   private
     AHeadChar: Char;
   private
      function Poke(const Translations: IUnicodeStream): boolean;
      function Match(const Ch: char): boolean;
      function MatchAndPoke(const Translations: IUnicodeStream; const Ch: char): boolean;
      function GetUUID(const Translations: IUnicodeStream; out UUID: string): boolean;
      function ExpectIdentifier(const Translations: IUnicodeStream; const Identifier: string): boolean;
      function SkipWhiteSpace(const Translations: IUnicodeStream): boolean;
      function GetMessage(const Translations: IUnicodeStream; out Message: string): boolean;
      function ParseEntry(const Translations: IUnicodeStream): boolean;
    public
      GUIDS: array of TGUID;
      Texts: array of string;
      EntryCount: nativeuint;

    /// <summary>
    ///   Parses a json formatted translation file and registers the entries
    ///   with the log.  Note, all translations are parsed first to ensure that
    ///   translation of the entire file is successful, before log registry
    ///   begins.
    /// </summary>
    function ParseTranslations( const Translations: IUnicodeStream ): boolean;
  end;

implementation

const
  cEntryGranularity = 32;
  cGUIDChars: array[0..22] of char = ('-','A','B','C','D','E','F','a','b','c','d','e','f','0','1','2','3','4','5','6','7','8','9');


function TTranslationParser.SkipWhiteSpace(const Translations: IUnicodeStream): boolean;
begin
  Result := False;
  while (AHeadChar.CharInArray([' ',TAB,CR,LF])) do begin
    if not Poke(Translations) then begin
      exit;
    end;
  end;
  Result := True;
end;

function TTranslationParser.Poke(const Translations: IUnicodeStream): boolean;
begin
  Result := False;
  if Translations.Position=Translations.Size then begin
    exit;
  end;
  AHeadChar := Translations.ReadChar( TUnicodeFormat.utf8 );
  Result := True;
end;

function TTranslationParser.Match(const Ch: char ): boolean;
begin
  Result := AHeadChar=CH;
end;

function TTranslationParser.MatchAndPoke(const Translations: IUnicodeStream; const Ch: char): boolean;
begin
  Result := False;
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  if not Match(CH) then begin
    exit;
  end;
  if not Poke(Translations) then begin
    exit;
  end;
  Result := True;
end;

function TTranslationParser.GetUUID(const Translations: IUnicodeStream; out UUID: string): boolean;
begin
  Result := False;
  UUID := '';
  if not MatchAndPoke(Translations,'{') then begin
    exit;
  end;
  while AHeadChar.CharInArray(cGUIDChars) do begin
    UUID := UUID + AHeadChar;
    if not Poke(Translations) then begin
      exit;
    end;
  end;
  if not MatchAndPoke(Translations,'}') then begin
    exit;
  end;
  Result := True;
end;

function TTranslationParser.GetMessage(const Translations: IUnicodeStream; out Message: string): boolean;
var
  SkippingChar: Boolean;
begin
  Result := False;
  Message := '';
  SkippingChar := False;
  while (not Match('"')) and (not SkippingChar) do begin
    if not SkippingChar then begin
      if AHeadChar='\' then begin
        SkippingChar := True;
        Continue;
      end;
    end else begin
      if AHeadChar='"' then begin
        Message := Message + '"';
      end else begin
        Message := Message + '\'+AHeadChar;
      end;
      SkippingChar := False;
    end;
    Message := Message + AHeadChar;
    if not Poke(Translations) then begin
      exit;
    end;
  end;
  Result := True;
end;

function TTranslationParser.ExpectIdentifier( const Translations: IUnicodeStream; const Identifier: string ): boolean;
var
  Collected: string;
begin
  Result := False;
  Collected := '';
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  while not Match('"') do begin
    Collected := Collected + AHeadChar;
    if not Poke(Translations) then begin
      exit;
    end;
  end;
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  Result := Collected.Uppercase.Trim=Identifier.Uppercase.Trim;
end;

function TTranslationParser.ParseEntry(const Translations: IUnicodeStream): boolean;
var
  UUID: string;
  MessageText: string;
  S: string;
  L: nativeuint;
begin
  Result := False;
  //- Remove opening bra
  if not MatchAndPoke(Translations,'{') then begin
    exit;
  end;
  //- Expect Identifier
  if not ExpectIdentifier(Translations,'EntryID') then begin
    exit;
  end;
  //- Match colon
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  if not MatchAndPoke(Translations,':') then begin
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  //- Match a quoted value string as a GUID
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  //- Collect the string
  UUID := '';
  if not GetUUID( Translations, UUID ) then begin
    exit;
  end;
  //- Remove trailing quote
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  //- Expect a comma
  if not MatchAndPoke(Translations,',') then begin
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  //- Expect Identifier
  if not ExpectIdentifier(Translations,'EntryText') then begin
    exit;
  end;
  //- Match colon
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  if not MatchAndPoke(Translations,':') then begin
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    exit;
  end;
  //- Expect a quoted message
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  if not GetMessage( Translations, MessageText ) then begin
    exit;
  end;
  if not MatchAndPoke(Translations,'"') then begin
    exit;
  end;
  //- Expect closing ket
  if not MatchAndPoke(Translations,'}') then begin
    exit;
  end;
  //- Add the entry.
  L := Length(GUIDS);
  if EntryCount>=L then begin
    SetLength(GUIDS,Length(GUIDS)+cEntryGranularity);
    SetLength(Texts,Length(Texts)+cEntryGranularity);
  end;
  S := '{'+UUID+'}';
  GUIDS[EntryCount] := StringToGUID(S{$ifdef fpc}.AsAnsiString{$endif});
  Texts[EntryCount] := MessageText;
  inc(EntryCount);
  Result := True;
end;

function TTranslationParser.ParseTranslations(const Translations: IUnicodeStream): boolean;
  procedure BailOut;
  begin
    SetLength(GUIDS,0);
    SetLength(Texts,0);
  end;
begin
  Result := False;
  EntryCount := 0;
  SetLength(GUIDS,cEntryGranularity);
  SetLength(Texts,cEntryGranularity);
  Translations.ReadBOM(TUnicodeFormat.utf8);
  if not Poke(Translations) then begin
    BailOut;
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    BailOut;
    exit;
  end;
  if not MatchAndPoke(Translations,'[') then begin
    BailOut;
    exit;
  end;
  if not SkipWhiteSpace(Translations) then begin
    BailOut;
    exit;
  end;
  while ParseEntry( Translations ) do begin
    if not SkipWhiteSpace(Translations) then begin
      BailOut;
      exit;
    end;
    if Match(',') then begin
      if not Poke(Translations) then begin
        BailOut;
        exit;
      end;
    end else begin
      break;
    end;
  end;
  if not SkipWhiteSpace(Translations) then begin
    BailOut;
    exit;
  end;
  if not Match(']') then begin
    BailOut;
    exit;
  end;
  Result := True;
end;

end.

