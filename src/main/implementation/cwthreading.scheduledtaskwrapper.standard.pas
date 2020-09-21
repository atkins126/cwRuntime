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
unit cwThreading.ScheduledTaskWrapper.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}


interface
uses
  cwThreading
, cwThreading.Internal
;

type
  TScheduledThreadState = ( tsRunning, tsTerminating, tsTerminated );

  TScheduledTaskWrapper = class( TInterfacedObject, IScheduledTaskWrapper )
  private
    fThread: IThread;
    fThreadCS: ISignaledCriticalSection;
    fScheduledTask: IScheduledTask;
    fLastExecuted: nativeuint;
    fDeltaSeconds: nativeuint;
    fTerminated: boolean;
    fThreadState: TScheduledThreadState;
  private
    procedure ExecuteThread( const Thread: IThread );
  strict private //- IScheduledTaskWrapper -//
    function getScheduledTask: IScheduledTask;
    function getLastExecuted: nativeuint;
    procedure setLastExecuted( const value: nativeuint );
    procedure RunTask( const DeltaSeconds: nativeuint );
  public
    constructor Create( const ScheduledTask: IScheduledTask; const DeltaSeconds: nativeuint );
    destructor Destroy; override;
  end;

implementation
uses
{$ifdef MSWINDOWS}
  cwThreading.SignaledCriticalSection.Windows
, cwThreading.Internal.Thread.Windows
{$else}
  cwThreading.SignaledCriticalSection.Posix
, cwThreading.Internal.Thread.Posix
{$endif}
;

procedure TScheduledTaskWrapper.ExecuteThread(const Thread: IThread);
begin
  try
    repeat
      Thread.Acquire;
      try
        Thread.Sleep;
        try
          if fThreadState<>tsRunning then exit;
          fLastExecuted := fDeltaSeconds;
          fScheduledTask.Execute(fDeltaSeconds);
        finally
        end;
      finally
        Thread.Release;
      end;
    until fThreadState<>tsRunning;
  finally
    fThreadState := tsTerminated;
  end;
end;

function TScheduledTaskWrapper.getScheduledTask: IScheduledTask;
begin
  Result := fScheduledTask;
end;

function TScheduledTaskWrapper.getLastExecuted: nativeuint;
begin
  Result := fLastExecuted;
end;

procedure TScheduledTaskWrapper.setLastExecuted( const value: nativeuint );
begin
  fLastExecuted := Value;
end;

procedure TScheduledTaskWrapper.RunTask(const DeltaSeconds: nativeuint);
begin
  fDeltaSeconds := DeltaSeconds;
  if (fScheduledTask.IntervalSeconds=0) then exit;
  if (fDeltaSeconds>=fLastExecuted+fScheduledTask.IntervalSeconds) then begin
    fThread.Wake;
  end;
end;

constructor TScheduledTaskWrapper.Create(const ScheduledTask: IScheduledTask; const DeltaSeconds: nativeuint );
begin
  inherited Create;
  fThreadState := tsRunning;
  fLastExecuted := DeltaSeconds;
  fDeltaSeconds := 0;
  fScheduledTask := ScheduledTask;
  fThreadCS := TSignaledCriticalSection.Create;
  fThread := TThread.Create(ExecuteThread,fThreadCS);
end;

destructor TScheduledTaskWrapper.Destroy;
begin
  fThreadState := tsTerminating;
  while fThreadState<>tsTerminated do fThread.Wake;
  fThreadCS := nil;
  fThread := nil;
  fScheduledTask := nil;
  inherited Destroy;
end;

end.

