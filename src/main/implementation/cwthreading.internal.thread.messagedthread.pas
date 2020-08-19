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
unit cwThreading.Internal.Thread.MessagedThread;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwCollections
, cwThreading
, cwThreading.Internal
{$ifdef MSWINDOWS}
, cwThreading.Internal.Thread.Windows
{$else}
, cwThreading.Internal.Thread.Posix
{$endif}
;

type
  TMessagedThread = class( TThread, IThread, IMessagedThreadHandler )
  private
    fMessagedThread: IMessagedThread;
    fSleepCS: ISignaledCriticalSection;
    fMessageChannels: IList<IMessageChannelReader>;
    fMessageChannelCS: ICriticalSection;
  private
    function GetMessage(out Message: TMessage): boolean;
    procedure HandleThread( const Thread: IThread );
  strict private //- IMessagedThreadHandler -//
    function getMessagedThread: IMessagedThread;
    function IsMatch(const MessagedThread: IMessagedThread): boolean;
    function getMessageChannel: IMessageChannel;
  public
    constructor Create( const MessagedThread: IMessagedThread; const SleepCS: ISignaledCriticalSection ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  cwCollections.Standard
, cwThreading.Internal.MessageChannelReader.Standard
{$ifdef MSWINDOWS}
, cwThreading.CriticalSection.Windows
{$else}
, cwThreading.CriticalSection.Posix
{$endif}
, cwTypes
;

function TMessagedThread.GetMessage( out Message: TMessage ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  fMessageChannelCS.Acquire;
  try
    for idx := 0 to pred(fMessageChannels.Count) do begin
      if not fMessageChannels[idx].getMessagesPending then continue;
      Result := fMessageChannels[idx].getNextMessage(Message);
      if Result then exit;
    end;
  finally
    fMessageChannelCS.Release;
  end;
end;

procedure TMessagedThread.HandleThread(const Thread: IThread);
var
  Message: TMessage;
begin
  repeat
    fSleepCS.Acquire;
    try
      repeat
        if Thread.getTerminateFlag then exit;
        if not GetMessage(Message) then begin
          fSleepCS.Sleep;
        end;
        until GetMessage(Message);
    finally
      fSleepCS.Release;
    end;
    fMessagedThread.HandleMessage(Message);
  until False;
end;

function TMessagedThread.getMessagedThread: IMessagedThread;
begin
  Result := fMessagedThread;
end;

function TMessagedThread.IsMatch(const MessagedThread: IMessagedThread): boolean;
begin
  Result := fMessagedThread = MessagedThread;
end;

function TMessagedThread.getMessageChannel: IMessageChannel;
var
  NewChannel: IMessageChannelReader;
  aThreadID: TThreadID;
  idx: nativeuint;
begin
  Result := nil;
  fMessageChannelCS.Acquire;
  try
    //- First check to see if the channel already exists.
    aThreadID := GetCurrentThreadID;
    if fMessageChannels.Count>0 then begin
      for idx := 0 to pred(fMessageChannels.Count) do begin
        if fMessageChannels[idx].getPermittedThreadID=aThreadID then begin
          Result := fMessageChannels[idx] as IMessageChannel;
          exit;
        end;
      end;
    end;
    //- else
    NewChannel := TMessageChannelReader.Create( fSleepCS );
    fMessageChannels.Add(NewChannel);
    Result := NewChannel as IMessageChannel;
  finally
    fMessageChannelCS.Release;
  end;
end;

constructor TMessagedThread.Create( const MessagedThread: IMessagedThread; const SleepCS: ISignaledCriticalSection );
begin
  inherited Create( HandleThread, SleepCS );
  fSleepCS := SleepCS;
  fMessageChannels := TList<IMessageChannelReader>.Create;
  fMessageChannelCS := TCriticalSection.Create;
  fMessagedThread := MessagedThread;
end;

destructor TMessagedThread.Destroy;
begin
  fMessagedThread := nil;
  fSleepCS := nil;
  fMessageChannelCS := nil;
  fMessageChannels := nil;
  inherited Destroy;
end;

end.
