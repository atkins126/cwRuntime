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
unit cwlog.logtarget.event;
{$ifdef fpc}
  {$mode delphiunicode}
  {$modeswitch nestedprocvars}
{$endif}

interface
uses
  cwLog
;

type
  TEventLogTarget = class( TInterfacedObject, ILogTarget )
  private
  {$ifdef fpc}
    fEventHandler: pointer;
    fEventHandlerType: uint8;
	{$else}
  	fEventHandler: TOnLogInsertEvent;
	{$endif}
  strict private //- ILogTarget -//
    {$hints off} procedure Insert( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string ); {$hints on}
  public

  {$ifdef fpc}
    constructor Create( const Event: TOnLogInsertEventGlobal ); overload;
    constructor Create( const Event: TOnLogInsertEventOfObject ); overload;
    constructor Create( const Event: TOnLogInsertEventNested ); overload;
  {$else}
    constructor Create( const Event: TOnLogInsertEvent ); overload;
  {$endif}

  end;

implementation

{$ifdef fpc}
const
  rfGlobal = 1;
  rfObject = 2;
  rfNested = 3;
{$endif}

procedure TEventLogTarget.Insert(const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string);
{$ifdef fpc}
var
  Global: TOnLogInsertEventGlobal;
  Obj: TOnLogInsertEventOfObject;
  Nested: TOnLogInsertEventNested;
{$endif}
begin
  {$ifdef fpc}
  if not assigned(fEventHandler) then begin
    exit;
  end;
  case fEventHandlerType of    
    rfGlobal: begin
      Global := nil;
      Move(fEventHandler,Global,sizeof(pointer));
      Global(LogEntry,TranslatedText,TS,Severity,Parameters);
    end;
    rfObject: begin
      Obj := nil;
      Move(fEventHandler,Obj,sizeof(pointer));
      Obj(LogEntry,TranslatedText,TS,Severity,Parameters);
    end;
    rfNested: begin
      Nested := nil;
      Move(fEventHandler,Nested,sizeof(pointer));
      Nested(LogEntry,TranslatedText,TS,Severity,Parameters);
    end;    
  end;
  {$else}
  fEventHandler(LogEntry,TranslatedText,TS,Severity,Parameters);
  {$endif}
end;

{$ifndef fpc}
constructor TEventLogTarget.Create(const Event: TOnLogInsertEvent);
begin
  inherited Create;
  fEventHandler := Event;  
end;
{$endif}

{$ifdef fpc}
constructor TEventLogTarget.Create(const Event: TOnLogInsertEventGlobal);
begin
  inherited Create;
  fEventHandlerType := rfGlobal;
  Move(Event,fEventHandler,sizeof(pointer));
end;
{$endif}

{$ifdef fpc}
constructor TEventLogTarget.Create(const Event: TOnLogInsertEventOfObject);
begin
  inherited Create;
  fEventHandlerType := rfGlobal;
  Move(Event,fEventHandler,sizeof(pointer));
end;
{$endif}

{$ifdef fpc}
constructor TEventLogTarget.Create(const Event: TOnLogInsertEventNested);
begin
  inherited Create;
  fEventHandlerType := rfNested;
  Move(Event,fEventHandler,sizeof(pointer));
end;
{$endif}


end.

