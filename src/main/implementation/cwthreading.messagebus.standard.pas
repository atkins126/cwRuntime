﻿{$ifdef license}
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
unit cwThreading.MessageBus.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
, cwThreading
, cwRuntime.Collections
;

type
  TMessageBus = class( TInterfacedObject, IMessageBus )
  private
    fEnabled: boolean;
    fMessageChannels: IMessageChannelDictionary;
  private //- IMessageBus -//
    function getEnabled: boolean;
    procedure setEnabled( value: boolean );
    function CreateChannel( ChannelName: string ): IMessageChannel;
    function GetMessagePipe( ChannelName: string ): IMessagePipe;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils
, cwRuntime.Collections.Standard
, cwThreading.messagechannel.standard
, cwLog.Standard
;

{ TMessageBus }

constructor TMessageBus.Create;
begin
  inherited Create;
  fEnabled := True;
  fMessageChannels := TMessageChannelDictionary(16);
end;

function TMessageBus.CreateChannel(ChannelName: string): IMessageChannel;
var
  NewChannel: IMessageChannel;
  utChannelName: string;
begin
  Result := nil;
  utChannelName := uppercase(trim(ChannelName));
  if fMessageChannels.KeyExists[utChannelName] then begin
    Log.Insert(stDuplicateMessageChannel,lsFatal,[ChannelName]);
  end;
  NewChannel := TMessageChannel.Create;
  fMessageChannels.setValueByKey(utChannelName,NewChannel);
  Result := NewChannel;
end;

destructor TMessageBus.Destroy;
begin
  fMessageChannels := nil;
  inherited;
end;

function TMessageBus.getEnabled: boolean;
begin
  Result := fEnabled;
end;

function TMessageBus.GetMessagePipe(ChannelName: string): IMessagePipe;
var
  utChannelName: string;
begin
  Result := nil;
  utChannelName := uppercase(trim(ChannelName));
  if not fMessageChannels.KeyExists[utChannelName] then begin
    exit;
  end;
  Result := fMessageChannels.ValueByKey[utChannelName].GetMessagePipe;
end;

procedure TMessageBus.setEnabled(value: boolean);
var
  idx: nativeuint;
begin
  if fEnabled=value then begin
    exit;
  end;
  fEnabled := Value;
  if fMessageChannels.Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(fMessageChannels.Count) do begin
    fMessageChannels.ValueByIndex[idx].Enabled := fEnabled;
  end;
end;

end.
