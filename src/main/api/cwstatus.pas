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
unit cwStatus;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  sysutils
;

{$region ' TStatus'}

type
  ///   <summary>
  ///     TStatus is a data-type intended for return from functions/procedures/methods in place
  ///     of the typically used boolean or int32 return types. <br/>
  ///     TStatus is implemented as a 128-bit integer GUID, which is also the return type of the
  ///     ILog.Insert() method, which returns the GUID of the log entry which was inserted. <br/>
  ///     For example, a function may return as follows...<br/>
  ///     <br/>
  ///     if Index>Count then begin <br/>
  ///       Result := Log.Insert( le_IndexOutOfBounds, lsError, [ Index.AsString ] );<br/>
  ///     end;<br/>
  ///     <br/>
  ///   </summary>
  ///   <remarks>
  ///     It should be noted that while the status values and log entry GUIDS are compatible,
  ///     the TStatus type does not carry sufficient information to translate a log entry which
  ///     has parameters. In case the status places the application into an exception state, you may
  ///     either refer the end user to the log, or alternatively call Log.GetLast() to retrieve the
  ///     most recently inserted log entry.
  ///   </remarks>
  TStatus = record
    Value: TGUID;
  public

    ///  <summary>
    ///    Allows the status record to be read as a GUID for
    ///    GUID comparison with other errors.
    ///  </summary>
    class operator Implicit(const a: TStatus): TGUID;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): TGUID;

    ///  <summary>
    ///    Returns TRUE if the status is the success (null guid) else false.
    ///    Calls .IsSuccess() internally.
    ///    This allows the return value of a function using TStatus to be
    ///    treated as a boolean for error handling purposes.
    ///  </summary>
    class operator Implicit(const a: TStatus): Boolean;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): Boolean;

     ///  <summary>
    ///    Returns TRUE if the status is the success (null guid) else false.
    ///    Calls .IsSuccess() internally.
    ///    This allows the return value of a function using TStatus to be
    ///    treated as a boolean for error handling purposes.
    ///  </summary>
    class operator LogicalNot(const a: TStatus): Boolean;

    ///  <summary>
    ///    This is a convenience method to return a TStatus representing an unknown
    ///    result state. This is typically the initialization state of a function which
    ///    returns TStatus.
    ///  </summary>
    class function Unknown: TStatus; static;

    ///  <summary>
    ///    This is a convenience method to return a TStatus representing a successful
    ///    result state. Note that the GUID for a success state is always the
    ///    '{00000000-0000-0000-0000-000000000000}' GUID. This can make debug-time
    ///    inspection of results easier, as all components of the TStatus should
    ///    be zero for Success.
    ///  </summary>
    class function Success: TStatus; static;

  end;

{$endregion}

{$region ' Constants for pre-defined status codes which may be returned from cwRuntime'}

const
  le_LogEntryNotRegistered            : TGUID = '{59B9A72C-B7E5-46F1-9D2C-12C4B40C8F4E}'; //<- This one is registered in cwLog.Log.Standard
  le_DependencyNotMet                 : TGUID = '{3E1E0236-4A9E-4646-ABCF-D380BFF9E78A}';
  le_IndexOutOfBounds                 : TGUID = '{D2A48812-D065-4DE6-9EA1-473A34B8273C}';
  le_FactoryConstructException        : TGUID = '{51FF694C-97DC-4654-B1C3-A797730B3A52}';
  le_ObjectNotAssigned                : TGUID = '{EF13EE2D-65BA-4A6C-9244-B01052A018DA}';
  le_StreamDoesNotSupportClear        : TGUID = '{1FFC5715-B4A1-4E0A-8DB6-D3F6969AE372}';
  le_CannotEncodeUnknownUnicodeFormat : TGUID = '{751F423E-FE14-4E9E-8708-D4560CCE39BF}';
  le_FailedThreadTerminate            : TGUID = '{9798567B-E753-47EE-A51D-EB3A0A01E11B}';
  le_OSAPIError                       : TGUID = '{0155B3C1-F5AA-47A4-8C33-A606F57A9DC3}';
  le_DuplicateMessageChannel          : TGUID = '{C038923C-B2D4-400C-977C-C890C1A1D873}';
  le_ThreadAlreadyStarted             : TGUID = '{A2BD6971-AEB3-4696-A149-B04FA8BD1005}';
  le_FileNotFound                     : TGUID = '{0A32412A-196B-40B2-8880-5D73DE46E3F1}';
  le_ModuleNotLoaded                  : TGUID = '{F6881310-4F2E-4D5B-8A4B-8318EDF8D4AD}';
  le_FailedToLoadEntryPoint           : TGUID = '{B425D9C3-262A-425B-85BB-149E79A4C9CC}';
  le_NoHighPrecisionTimer             : TGUID = '{6EB4740F-C483-47CE-A78C-7CD2CC4D97EC}';
  le_SocketError                      : TGUID = '{704C63BE-4387-4854-BB66-4C07E1ADF709}';
  le_InvalidSocket                    : TGUID = '{3956BFFE-C229-4C90-9604-245F6624C0E3}';
  le_BindNotSupportedOnDomain         : TGUID = '{33C45B9D-4CAE-4D74-A2A1-91588E45126C}';
  le_SocketBindError                  : TGUID = '{A7F8DCD3-E122-4C07-8CF0-1AD89C0E4E79}';
  le_SocketListenError                : TGUID = '{FBF7521C-C9A9-4962-9C77-A43C9B235E37}';
  le_SocketAcceptError                : TGUID = '{A8C9CE48-133A-4495-B8B1-794A53409A7D}';
  le_SocketConnectError               : TGUID = '{99BC6926-BB39-4380-92B9-A266BBA9D8AB}';
  le_SocketCloseError                 : TGUID = '{E913A85A-070A-451C-9E86-B13BE58FA334}';
  le_SocketShutdownError              : TGUID = '{882F80C9-8D42-4BBE-B3C4-54DCD4CE3422}';
  le_UnknownSocketDomain              : TGUID = '{FB0055EC-4F5B-479C-8DA0-8E0811B5B61A}';
  le_SocketClosed                     : TGUID = '{2AB4A7BA-F66A-4E5A-933C-22D4FB1B7C32}';
  le_FailedToConvertNetworkAddress    : TGUID = '{E801EDB2-2BEF-4180-A6D6-E7FCBBEC325C}';

{$endregion}

implementation
uses
  cwLog.Standard
;

{$region ' TStatus implementation'}

const
  cSuccessUUID: TGUID = '{00000000-0000-0000-0000-000000000000}';
  cUnknownUUID: TGUID = '{A334E3A7-D11E-4106-B021-C737523CB51B}';

class function TStatus.Success: TStatus;
begin
  Result.Value := cSuccessUUID;
end;

class operator TStatus.Implicit(const a: TStatus): TGUID;
begin
  Result := a.Value;
end;

class operator TStatus.Explicit(const a: TStatus): TGUID;
begin
  Result := a.Value;
end;

class operator TStatus.Implicit(const a: TStatus): Boolean;
begin
  Result := IsEqualGUID(a.Value,cSuccessUUID);
end;

class operator TStatus.Explicit(const a: TStatus): Boolean;
begin
  Result := IsEqualGUID(a.Value,cSuccessUUID);
end;

class operator TStatus.LogicalNot(const a: TStatus): Boolean;
begin
  Result := not IsEqualGUID(a.Value,cSuccessUUID);
end;

class function TStatus.Unknown: TStatus;
begin
  Result.Value := cUnknownUUID;
end;

{$endregion}

initialization

{$region ' Register these status codes as log entries with the logging system.'}

  Log.RegisterLogEntry(le_DependencyNotMet,                 'An error occured while constructing a required dependency.');
  Log.RegisterLogEntry(le_IndexOutOfBounds,                 'Index out of bounds "(%index%)".');
  Log.RegisterLogEntry(le_FactoryConstructException,        'An exception occurred while attempting to construct an object, with message "(%message%)"');
  Log.RegisterLogEntry(le_ObjectNotAssigned,                'Object "(%object%)" is not assigned.');
  Log.RegisterLogEntry(le_StreamDoesNotSupportClear,        'Stream does not support the Clear() method.');
  Log.RegisterLogEntry(le_CannotEncodeUnknownUnicodeFormat, 'Cannot encode to unicode format utfUnknown.');
  Log.RegisterLogEntry(le_FailedThreadTerminate,            'Thread (%index%) failed to terminate gracefully.');
  Log.RegisterLogEntry(le_OSAPIError,                       'An Operating System error occurred on (%call%) value (%value%).');
  Log.RegisterLogEntry(le_DuplicateMessageChannel,          'Message channel name must be unique. (%channel%) is already in use.');
  Log.RegisterLogEntry(le_ThreadAlreadyStarted,             'Thread is already started.');
  Log.RegisterLogEntry(le_FileNotFound,                     'File not found "(%filename%)"');
  Log.RegisterLogEntry(le_ModuleNotLoaded,                  'DynLib failed to load module "(%module%)"');
  Log.RegisterLogEntry(le_FailedToLoadEntryPoint,           'Failed to locate entrypoint "(%entrypoint%)" in library "(%library%)"');
  Log.RegisterLogEntry(le_NoHighPrecisionTimer,             'Unable to access high-precision timer device.');
  Log.RegisterLogEntry(le_SocketError,                      'A socket API error occurred (%apierrno%)');
  Log.RegisterLogEntry(le_InvalidSocket,                    'Attempt to "(%operation%)" on invalid socket.');
  Log.RegisterLogEntry(le_BindNotSupportedOnDomain,         'The bind operation is not yet supported for this domain / address family.');
  Log.RegisterLogEntry(le_SocketBindError,                  'The socket library failed to bind with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_SocketListenError,                'The socket library failed to listen with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_SocketAcceptError,                'The socket library failed to accept with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_SocketConnectError,               'The socket library failed to connect with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_SocketCloseError,                 'The socket library failed to close with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_SocketShutdownError,              'The socket library failed to shutdown with return code "(%returncode%)"');
  Log.RegisterLogEntry(le_UnknownSocketDomain,              'Unknown socket domain / address family.');
  Log.RegisterLogEntry(le_SocketClosed,                     'Socket closed on Recv().');
  Log.RegisterLogEntry(le_FailedToConvertNetworkAddress,    'Failed to convert network address "(%IPAddress%)" on port "(%port%)"');

{$endregion}

finalization
end.

