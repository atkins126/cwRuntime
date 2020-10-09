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
program ScheduledTasks_Lazarus;
uses
  sysutils
, crt
, cwTypes
, cwThreading
, cwThreading.Standard
;

type
  TClockTickSchedule = class( TInterfacedObject, IScheduledTask )
  private
    fInterval: nativeuint;
  strict private //- IScheduledTask -//
    function getIntervalSeconds: nativeuint;
    procedure setIntervalSeconds( const Interval: nativeuint );
    procedure Execute( const DeltaSeconds: nativeuint );
  public
    constructor Create( const InitialInterval: uint32 );
  end;

function TClockTickSchedule.getIntervalSeconds: nativeuint;
begin
  Result := fInterval;
end;

procedure TClockTickSchedule.setIntervalSeconds(const Interval: nativeuint);
begin
  fInterval := Interval;
end;

procedure TClockTickSchedule.Execute(const DeltaSeconds: nativeuint);
begin
  Writeln( DeltaSeconds.AsString, ' second tick - (press [esc] to exit.)' );
end;

constructor TClockTickSchedule.Create(const InitialInterval: uint32);
begin
  inherited Create;
  fInterval := InitialInterval;
end;

const
  cTwo = 2;

begin
  //- Create a scheduled task to fire every 2 seconds.
  ThreadSystem.Execute( TClockTickSchedule.Create( cTwo ) );

  //- Repeat readln to block main thread while schedule executes.
  repeat
    if ReadKey = #27 then exit;
  until False;

end.

