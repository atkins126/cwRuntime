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
unit cwRuntime.LogEntries;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface

resourcestring
  le_IndexOutOfBounds                 = '{CA1B1695-17C4-49A9-8460-908ED702F5AA} Index out of bounds "(%index%)".';
  le_ObjectNotAssigned                = '{EF13EE2D-65BA-4A6C-9244-B01052A018DA} Object "(%object%)" is not assigned.';
  le_StreamDoesNotSupportClear        = '{1FFC5715-B4A1-4E0A-8DB6-D3F6969AE372} Stream does not support the Clear() method.';
  le_CannotEncodeUnknownUnicodeFormat = '{751F423E-FE14-4E9E-8708-D4560CCE39BF} Cannot encode to unicode format utfUnknown.';
  le_FailedThreadTerminate            = '{9798567B-E753-47EE-A51D-EB3A0A01E11B} Thread (%index%) failed to terminate gracefully.';
  le_OSAPIError                       = '{0155B3C1-F5AA-47A4-8C33-A606F57A9DC3} An Operating System error occurred on (%call%) value (%value%).';
  le_DuplicateMessageChannel          = '{C038923C-B2D4-400C-977C-C890C1A1D873} Message channel name must be unique. (%channel%) is already in use.';
  le_ThreadAlreadyStarted             = '{A2BD6971-AEB3-4696-A149-B04FA8BD1005} Thread is already started.';
  le_FileNotFound                     = '{0A32412A-196B-40B2-8880-5D73DE46E3F1} File not found "(%filename%)"';
  le_ModuleNotLoaded                  = '{F6881310-4F2E-4D5B-8A4B-8318EDF8D4AD} DynLib failed to load module "(%module%)"';
  le_FailedToLoadEntryPoint           = '{B425D9C3-262A-425B-85BB-149E79A4C9CC} Failed to locate entrypoint "(%entrypoint%)" in library "(%library%)"';
  le_NoHighPrecisionTimer             = '{6EB4740F-C483-47CE-A78C-7CD2CC4D97EC} Unable to access high-precision timer device.';
  le_SocketError                      = '{704C63BE-4387-4854-BB66-4C07E1ADF709} A socket API error occurred (%apierrno%)';
  le_InvalidSocket                    = '{3956BFFE-C229-4C90-9604-245F6624C0E3} Attempt to "(%operation%)" on invalid socket.';
  le_BindNotSupportedOnDomain         = '{33C45B9D-4CAE-4D74-A2A1-91588E45126C} The bind operation is not yet supported for this domain / address family.';
  le_SocketBindError                  = '{A7F8DCD3-E122-4C07-8CF0-1AD89C0E4E79} The socket library failed to bind with return code "(%returncode%)"';
  le_SocketListenError                = '{FBF7521C-C9A9-4962-9C77-A43C9B235E37} The socket library failed to listen with return code "(%returncode%)"';
  le_SocketAcceptError                = '{A8C9CE48-133A-4495-B8B1-794A53409A7D} The socket library failed to accept with return code "(%returncode%)"';
  le_SocketConnectError               = '{99BC6926-BB39-4380-92B9-A266BBA9D8AB} The socket library failed to connect with return code "(%returncode%)"';
  le_SocketCloseError                 = '{E913A85A-070A-451C-9E86-B13BE58FA334} The socket library failed to close with return code "(%returncode%)"';
  le_SocketShutdownError              = '{882F80C9-8D42-4BBE-B3C4-54DCD4CE3422} The socket library failed to shutdown with return code "(%returncode%)"';
  le_UnknownSocketDomain              = '{FB0055EC-4F5B-479C-8DA0-8E0811B5B61A} Unknown socket domain / address family.';
  le_SocketClosed                     = '{2AB4A7BA-F66A-4E5A-933C-22D4FB1B7C32} Socket closed on Recv().';
  le_FailedToConvertNetworkAddress    = '{E801EDB2-2BEF-4180-A6D6-E7FCBBEC325C} Failed to convert network address "(%IPAddress%)" on port "(%port%)"';

implementation
{$ifndef fpc}
uses
  cwLog.Standard
;
{$endif}

initialization
  {$ifndef fpc}
  Log.RegisterLogEntry(le_IndexOutOfBounds);
  Log.RegisterLogEntry(le_ObjectNotAssigned);
  Log.RegisterLogEntry(le_StreamDoesNotSupportClear);
  Log.RegisterLogEntry(le_CannotEncodeUnknownUnicodeFormat);
  Log.RegisterLogEntry(le_FailedThreadTerminate);
  Log.RegisterLogEntry(le_OSAPIError);
  Log.RegisterLogEntry(le_DuplicateMessageChannel);
  Log.RegisterLogEntry(le_ThreadAlreadyStarted);
  Log.RegisterLogEntry(le_NoHighPrecisionTimer);
  Log.RegisterLogEntry(le_SocketError);
  Log.RegisterLogEntry(le_InvalidSocket);
  Log.RegisterLogEntry(le_BindNotSupportedOnDomain);
  Log.RegisterLogEntry(le_SocketBindError);
  Log.RegisterLogEntry(le_SocketListenError);
  Log.RegisterLogEntry(le_SocketAcceptError);
  Log.RegisterLogEntry(le_SocketConnectError);
  Log.RegisterLogEntry(le_SocketCloseError);
  Log.RegisterLogEntry(le_FailedToConvertNetworkAddress);
  Log.RegisterLogEntry(le_UnknownSocketDomain);
  Log.RegisterLogEntry(le_SocketClosed);
  {$endif}

finalization

end.

