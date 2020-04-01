{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
unit cwLog.LogTarget.Console;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
;

type
  TLogTarget = class( TInterfacedObject, ILogTarget )
  strict private //- ILogTarget -//
    {$hints off} procedure Insert( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string ); {$hints on}
  end;

implementation

{$hints off}
procedure TLogTarget.Insert(const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string );
begin
  Writeln(TranslatedText);
end;
{$hints on}

end.

