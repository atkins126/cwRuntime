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
/// <summary>
///   Standard implementation of ILog
/// </summary>
unit cwlog.standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  sysutils // for Exception
, cwLog
, cwLog.Common
;

/// <summary>
///   TLoggedException will insert an entry into the log with severity
///   lsFatal, and then raise an exception using the log entry text.
///   Using TLoggedException enables translation of exception messages
///   through the log translation functionality.
/// <summary>
{$region ' TException'}
type  
  TLoggedException = class(Exception)
  private
    fStatus: TStatus;
  public
    constructor Create( const Status: TStatus ); reintroduce; overload;
    constructor Create( const Status: TStatus; const Parameters: array of string ); reintroduce; overload;
    property Status: TStatus read fStatus;
  end;  
{$endregion}

///  <summary>
///    Returns the singleton instance of ILog.
///  </summary>
function Log: ILog;

implementation
uses
  cwLog.Log.Standard
{$ifdef fpc}
, cwTypes
{$endif}
;

function Log: ILog;
begin
  Result := cwLog.Log.Standard.Log();
end;

{$region ' TException'}
constructor TLoggedException.Create(const Status: TStatus);
var
  aStatus: TStatus;
begin
  aStatus := Log.Insert(Status,lsFatal);
  {$ifdef fpc}
  inherited Create( Log.LastEntry.AsAnsiString );
  {$else}
  inherited Create( Log.LastEntry );
  {$endif}
  fStatus := aStatus;
end;

constructor TLoggedException.Create(const Status: TStatus; const Parameters: array of string);
var
  aStatus: TStatus;
begin
  aStatus := Log.Insert(Status,lsFatal,Parameters);
  {$ifdef fpc}
  inherited Create( Log.LastEntry.AsAnsiString );
  {$else}
  inherited Create( Log.LastEntry );
  {$endif}
  fStatus := aStatus;
end;
{$endregion}

initialization
{$region ' Register these status codes as log entries with the logging system.'}

  Log.RegisterEntry(stDependencyNotMet,                 'An error occured while constructing a required dependency.');
  Log.RegisterEntry(stIndexOutOfBounds,                 'Index out of bounds "(%index%)".');
  Log.RegisterEntry(stFactoryConstructException,        'An exception occurred while attempting to construct an object, with message "(%message%)"');
  Log.RegisterEntry(stObjectNotAssigned,                'Object "(%object%)" is not assigned.');
  Log.RegisterEntry(stStreamDoesNotSupportClear,        'Stream does not support the Clear() method.');
  Log.RegisterEntry(stCannotEncodeUnknownUnicodeFormat, 'Cannot encode to unicode format utfUnknown.');
  Log.RegisterEntry(stUnableToDetermineUnicodeFormat,   'Unable to determine the unicode format.');
  Log.RegisterEntry(stFailedThreadTerminate,            'Thread (%index%) failed to terminate gracefully.');
  Log.RegisterEntry(stOSAPIError,                       'An Operating System error occurred on (%call%) value (%value%).');
  Log.RegisterEntry(stDuplicateMessageChannel,          'Message channel name must be unique. (%channel%) is already in use.');
  Log.RegisterEntry(stThreadAlreadyStarted,             'Thread is already started.');
  Log.RegisterEntry(stFileNotFound,                     'File not found "(%filename%)"');
  Log.RegisterEntry(stModuleNotLoaded,                  'DynLib failed to load module "(%module%)"');
  Log.RegisterEntry(stFailedToLoadEntryPoint,           'Failed to locate entrypoint "(%entrypoint%)" in library "(%library%)"');
  Log.RegisterEntry(stNoHighPrecisionTimer,             'Unable to access high-precision timer device.');
  Log.RegisterEntry(stSocketError,                      'A socket API error occurred (%apierrno%)');
  Log.RegisterEntry(stInvalidSocket,                    'Attempt to "(%operation%)" on invalid socket.');
  Log.RegisterEntry(stBindNotSupportedOnDomain,         'The bind operation is not yet supported for this domain / address family.');
  Log.RegisterEntry(stSocketBindError,                  'The socket library failed to bind with return code "(%returncode%)"');
  Log.RegisterEntry(stSocketListenError,                'The socket library failed to listen with return code "(%returncode%)"');
  Log.RegisterEntry(stSocketAcceptError,                'The socket library failed to accept with return code "(%returncode%)"');
  Log.RegisterEntry(stSocketConnectError,               'The socket library failed to connect with return code "(%returncode%)"');
  Log.RegisterEntry(stSocketCloseError,                 'The socket library failed to close with return code "(%returncode%)"');
  Log.RegisterEntry(stSocketShutdownError,              'The socket library failed to shutdown with return code "(%returncode%)"');
  Log.RegisterEntry(stUnknownSocketDomain,              'Unknown socket domain / address family.');
  Log.RegisterEntry(stUnsupportedAddressFormat,         'The socket library does not support this address format');
  Log.RegisterEntry(stSocketClosed,                     'Socket closed on Recv().');
  Log.RegisterEntry(stFailedToConvertNetworkAddress,    'Failed to convert network address "(%IPAddress%)" on port "(%port%)"');
  Log.RegisterEntry(stInvalidArrayForVector,            'Array passed to vector has incorrect length.');

{$endregion}

finalization
end.

