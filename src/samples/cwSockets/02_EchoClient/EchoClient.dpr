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

program EchoClient;
{$ifdef fpc}{$mode delphiunicode}{$else}{$APPTYPE CONSOLE}{$endif}
uses
  cwIO
, cwIO.Standard
, cwSockets
, cwSockets.Standard
;

const
  cIPv6Loopback = '0000:0000:0000:0000:0000:0000:0000:0001';
  cPort = 55443;
  cMaxBuffer = 511;

var
  ClientSocket: ISocket;
  MessageText: string;
  RecvBuffer: IUnicodeBuffer;
  SendBuffer: IUnicodeBuffer;

begin
  //- Start by creating a new socket for our client to connect through.
  //- Because this sample is intended to run on multiple target platforms, we
  //- select IPv6 (because some platforms have depricated IPv4).
  ClientSocket := TSocket.Create( sdIPv6 );
  try
    //- Connect our client to the server.
    if not ClientSocket.Connect( TNetworkAddress.Create(cIPv6Loopback,cPort) ).IsSuccess then begin
      Writeln('Unable to connect to server.');
      exit;
    end;

    repeat
      //- Wait for something to send to the server.
      Write('Message: ');
      Readln(MessageText);
      if Length(MessageText)>cMaxBuffer then begin
        Writeln('Keep it short please!');
        continue;
      end;
      //- Create a buffer to send our message
      SendBuffer := TBuffer.Create;
      SendBuffer.WriteString(MessageText,TUnicodeFormat.utf8,True);
      if not ClientSocket.Send(SendBuffer).IsSuccess then begin
        Writeln('Connection to server lost.');
        break;
      end;

    until False;

  finally
    ClientSocket := nil;
  end;
end.
