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
///   Chapmanworld Logging system cwLog.
/// </summary>
unit cwLog;
{$ifdef fpc}
  {$mode delphiunicode}
  {$modeswitch nestedprocvars}
{$endif}

interface
uses
  sysutils //[RTL] for Exception
, cwTypes
;

{$region ' TStatus'}

type

  /// <summary>
  ///   Exception raised when the TStatus.ExceptOnFail method is called.
  /// </summary>
  EStatusFail = class(Exception);

type
  /// <summary>
  ///   <para>
  ///     TStatus is a data-type intended for return from
  ///     functions/procedures/methods in place of the typically used boolean
  ///     or int32 return types. <br /><br />TStatus is implemented as a
  ///     128-bit integer GUID as a member of an advanced record type with
  ///     utility functions for working with the GUID. A null guid (all zeros
  ///     {0000-000-....}) is used to represent a success status, and all
  ///     other GUID's represent an error (or partial success status). <br />
  ///     TStatus has a class functions to return unknown or success status
  ///     codes (see .Success and .Unknown). <br /><br />Operator overloads
  ///     are also available to make TStatus behave as a boolean, which
  ///     simplifies error checking for functions which use this return type.
  ///   </para>
  ///   <code lang="Delphi">function SomeFunction: TStatus;
  /// ...
  /// if not SomeFunction() then begin
  ///   ShowMessage( 'Some error occurred. '+Log.GetLastEntry );
  /// end;</code>
  ///   <para>
  ///     The logging system also uses GUID's to represent log entries when
  ///     inserted into the log, which are returned from logging methods.
  ///     It's therefore convenient to return the result of a log entry
  ///     insertion as the status of a function which failed. <br /><br />For
  ///     example, a function may return as follows... <br />
  ///   </para>
  ///   <code lang="Delphi">if Index&gt;Count then begin
  ///   Result := Log.Insert( stIndexOutOfBounds, lsError, [ Index.AsString ] );
  /// end;</code>
  /// </summary>
  /// <remarks>
  ///   It should be noted that while the status values and log entry GUIDs are
  ///   compatible, the TStatus type does not carry sufficient information to
  ///   translate a log entry which has parameters. In cases in which the
  ///   application has entered an error state, and a non success status is
  ///   returned from a function, you may call the log ILog.GetLastEntry()
  ///   method to retrieve more information about the failure state. <br /><br />
  ///   Alternatively, you may decide to provide status constants for failure
  ///   states which do not need to be inserted into the log.
  /// </remarks>
  TStatus = record
    Value: TGUID;
  public

    /// <summary>
    ///   Operator overload enabling assignment of a TStatus to a TGUID.
    /// </summary>
    /// <param name="a">
    ///   A TStatus to be returned as a TGUID
    /// </param>
    class operator Implicit(const a: TStatus): TGUID;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): TGUID;

    /// <summary>
    ///   Operator overload enabling the TStatus to be assigned to a string. <br /><br /><code lang="Delphi">ShowMessage( 'Success = '+TStatus.Success );</code>
    /// </summary>
    /// <param name="a">
    ///   A TStatus to be returned as a string.
    /// </param>
    class operator Implicit(const a: TStatus): string;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): string;

    /// <summary>
    ///   This operator overload enables TStatus to be assigned as a string. <br /><br /><code lang="Delphi">function SomeFunction: TStatus;
    /// begin
    ///   Result := '{652E9D4C-7A11-49BE-8FD7-874B0DBAD38F}';
    /// end;</code>
    /// </summary>
    /// <param name="a">
    ///   A string to be assigned to a TStatus.
    /// </param>
    /// <remarks>
    ///   This is a special use case and should only be used where absolutely
    ///   necessary. <br />GUIDS are not strings and perform slower when used
    ///   as strings than when used as GUIDs.
    /// </remarks>
    class operator Implicit(const a: string): TStatus;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: string): TStatus;

    /// <summary>
    ///   This operator allows TStatus to be assigned to a boolean where a null
    ///   GUID (all zeros) represents TRUE, and all other GUIDs represent
    ///   FALSE.
    /// </summary>
    /// <param name="a">
    ///   A TStatus to return as a boolean.
    /// </param>
    class operator Implicit(const a: TStatus): Boolean;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): Boolean;

    ///  <exclude/>  - The opposing operation for the implicit boolean.
    class operator LogicalNot(const a: TStatus): Boolean;

    ///  <exclude/> - For matching statuses
    class operator Equal( const a: TStatus; const b: TStatus ): boolean;
    ///  <exclude/> - For matching statuses
    class operator NotEqual( const a: TStatus; const b: TStatus ): boolean;

    /// <summary>
    ///   <para>
    ///     This is a convenience method to return a TStatus representing an
    ///     unknown result state. <br />Typically used to set the initial
    ///     return state of a function when the final state is indeterminate.
    ///     Should the function fail at any point, with an unexpected
    ///     condition, it's result will indicate the failure to an unknown
    ///     state..
    ///   </para>
    ///   <code lang="Delphi">function SomeFunction: TStatus;
    /// begin
    ///   Result := TStatus.Unknown; //- Incase something goes wrong.
    ///   (* Something unexpected could happen here *)
    ///   Result := TStatus.Success; //- If everything went well.
    /// end;
    /// if not SomeFunction then begin
    ///   ShowMessage('Something unexpected happened while calling SomeFunction');
    /// end;</code>
    /// </summary>
    class function Unknown: TStatus; static;

    /// <summary>
    ///   This is a convenience method to return a TStatus representing a
    ///   successful result state. <br />Returns the null GUID as a TStatus.
    /// </summary>
    /// <remarks>
    ///   The GUID for a success state is always
    ///   the'{00000000-0000-0000-0000-000000000000}' GUID.
    /// </remarks>
    class function Success: TStatus; static;

    /// <summary>
    ///   Raises an EStatusFail exception if the status is not a success code. <br />
    ///   This is a convenience method to raise exceptions for an unexpected
    ///   error status. Typically a function that returns a TStatus would be
    ///   checked to ensure that the function succeeds, however, you could
    ///   alternatively call ExceptionOnFail() to raise an exception if the
    ///   function fails.
    ///   <code lang="Delphi">function WeAssumeThisFunctionWillAlwaysSucceed: TStatus;
    /// begin
    ///   Result := TStatus.Unknown;
    ///   // Unexpected condition, perhaps divide by zero.
    /// end;
    /// begin
    ///   WeAssumeThisFunctionWillAlwaysSucceed.ExceptOnFail;
    /// end;</code>
    ///   <br />
    /// </summary>
    procedure ExceptionOnFail;

  end;

{$endregion}

{$region ' Log entry'}
type
  /// <summary>
  ///   A log entry must be registered with the log before it may be inserted
  ///   into the log. <br />This type may be used to define constants for the
  ///   log entries to be inserted...
  ///   <code lang="Delphi">const
  ///   stIndexOutOfBounds: TStatus = (Value: '{D2A48812-D065-4DE6-9EA1-473A34B8273C}');
  /// initialization
  ///   Log.RegisterEntry( stIndexOutOfBounds, 'Index out of bounds (%index%)' );
  /// finalization
  /// end.</code>
  /// </summary>
  TLogEntry = record
    Value: TGUID;
    Text: string;
  end;

{$endregion}

{$region ' Constants for pre-defined status codes which may be returned from cwRuntime'}

const
  /// <summary>
  ///   When an attempt is made to insert an entry into the log which has not
  ///   been registered with the log, the stLogEntryNotRegistered entry will be
  ///   inserted in it's place.
  /// </summary>
  stLogEntryNotRegistered            : TStatus = ( Value: '{59B9A72C-B7E5-46F1-9D2C-12C4B40C8F4E}');

  /// <summary>
  ///   stIndexOutOfBounds is inserted into the log when attempting to address
  ///   members of an array style property which fall outside the bounds of the
  ///   array.
  /// </summary>
  stIndexOutOfBounds                 : TStatus = ( Value: '{D2A48812-D065-4DE6-9EA1-473A34B8273C}');

  /// <summary>
  ///   This entry is inserted into the log by cwRuntime methods which attempt
  ///   to reference a missing dependency.
  /// </summary>
  stObjectNotAssigned                : TStatus = ( Value: '{EF13EE2D-65BA-4A6C-9244-B01052A018DA}');

  /// <summary>
  ///   This is inserted into the log when attempting to call the .Clear()
  ///   method on an IStream / IUnicodeStream which does not support the clear
  ///   method (i.e. Read-Only streams).
  /// </summary>
  stStreamDoesNotSupportClear        : TStatus = ( Value: '{1FFC5715-B4A1-4E0A-8DB6-D3F6969AE372}');

  /// <summary>
  ///   This entry is inserted into the log while attempting to use the unicode
  ///   codec to encode TUnicodeFormat.utfUnknown.
  /// </summary>
  stCannotEncodeUnknownUnicodeFormat : TStatus = ( Value: '{751F423E-FE14-4E9E-8708-D4560CCE39BF}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to automatically
  ///   determine the format of unicode data in a stream fails.
  /// </summary>
  stUnableToDetermineUnicodeFormat   : TStatus = ( Value: '{7507CDB2-5939-4D1D-AD22-CD890ADA718D}');

  /// <summary>
  ///   This entry is inserted into the log by cwRuntime when a thread pool is
  ///   asked to terminate, but one or more of the threads in the pool does not
  ///   cooperatively terminate it's self.
  /// </summary>
  stFailedThreadTerminate            : TStatus = ( Value: '{9798567B-E753-47EE-A51D-EB3A0A01E11B}');

  /// <summary>
  ///   This entry is inserted into the log by the cwRuntime when a call to an
  ///   Operating System API ( cLib or Win32 f.x ) fails unexpectedly. ( Likely
  ///   to originate from the cwThreading system )
  /// </summary>
  stOSAPIError                       : TStatus = ( Value: '{0155B3C1-F5AA-47A4-8C33-A606F57A9DC3}');

  /// <summary>
  ///   This entry is inserted into the log by the messaging system which is
  ///   part of the cwThreading system, when an attempt is made to create two
  ///   messaging channels with the same name.
  /// </summary>
  stDuplicateMessageChannel          : TStatus = ( Value: '{C038923C-B2D4-400C-977C-C890C1A1D873}');

  /// <summary>
  ///   This entry is inserted into the log when an attempt is made to start a
  ///   thread or thread pool which is already running.
  /// </summary>
  stThreadAlreadyStarted             : TStatus = ( Value: '{A2BD6971-AEB3-4696-A149-B04FA8BD1005}');

  /// <summary>
  ///   This entry is inserted into the log when an attempt is made to open a
  ///   file which is either non existent, or for permissions reasons cannot be
  ///   opened.
  /// </summary>
  stFileNotFound                     : TStatus = ( Value: '{0A32412A-196B-40B2-8880-5D73DE46E3F1}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to use a dynamic
  ///   library (using cwDynlib) that has not been loaded.
  /// </summary>
  stModuleNotLoaded                  : TStatus = ( Value: '{F6881310-4F2E-4D5B-8A4B-8318EDF8D4AD}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to locate an export
  ///   from a dynamic library fails.
  /// </summary>
  stFailedToLoadEntryPoint           : TStatus = ( Value: '{B425D9C3-262A-425B-85BB-149E79A4C9CC}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to use a high
  ///   precision timer on a target platform that does not have high-precision
  ///   timer support. (Unlikely on any modern hardware, but included as a
  ///   potential error state)
  /// </summary>
  stNoHighPrecisionTimer             : TStatus = ( Value: '{6EB4740F-C483-47CE-A78C-7CD2CC4D97EC}');

  /// <summary>
  ///   This entry is inserted into the log when an error occurs in either
  ///   WinSock or BSD Sockets API's while making a call to the cwSockets
  ///   implementation. The error message will carry the API error number to be
  ///   examined on a per-platform basis.
  /// </summary>
  stSocketError                      : TStatus = ( Value: '{704C63BE-4387-4854-BB66-4C07E1ADF709}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to make a call to a
  ///   socket function on a socket that has not yet been initialized. Check
  ///   the ISocket.Initialize method has been called.
  /// </summary>
  stInvalidSocket                    : TStatus = ( Value: '{3956BFFE-C229-4C90-9604-245F6624C0E3}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to call Bind() on a
  ///   socket for which the domain (address family) is not supported by
  ///   cwSockets. (There are currently only two supported domains, IPv4 and
  ///   IPv6)
  /// </summary>
  stBindNotSupportedOnDomain         : TStatus = ( Value: '{33C45B9D-4CAE-4D74-A2A1-91588E45126C}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Bind(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketBindError                  : TStatus = ( Value: '{A7F8DCD3-E122-4C07-8CF0-1AD89C0E4E79}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Listen(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketListenError                : TStatus = ( Value: '{FBF7521C-C9A9-4962-9C77-A43C9B235E37}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Accept(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketAcceptError                : TStatus = ( Value: '{A8C9CE48-133A-4495-B8B1-794A53409A7D}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Connect(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketConnectError               : TStatus = ( Value: '{99BC6926-BB39-4380-92B9-A266BBA9D8AB}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Close(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketCloseError                 : TStatus = ( Value: '{E913A85A-070A-451C-9E86-B13BE58FA334}');

  /// <summary>
  ///   This entry is inserted into the log when the underlying sockets API (
  ///   Winsock or BSD Sockets ) returns an error status while attempting to
  ///   call Shutdown(). The API-level error number will be included in the log
  ///   entry text.
  /// </summary>
  stSocketShutdownError              : TStatus = ( Value: '{882F80C9-8D42-4BBE-B3C4-54DCD4CE3422}');

  /// <summary>
  ///   This entry is inserted into the log when cwSockets attempts to decode a
  ///   socket domain (address family) which it does not know about. There are
  ///   many socket domains which vary across platforms, attempts have been
  ///   made to include as many as possible.
  /// </summary>
  stUnknownSocketDomain              : TStatus = ( Value: '{FB0055EC-4F5B-479C-8DA0-8E0811B5B61A}');

  /// <summary>
  ///   This entry is inserted into the log when cwSockets attempts to decode
  ///   an address format that it does not yet support. (Currently only IPv4
  ///   and IPv6 addresses are supported).
  /// </summary>
  stUnsupportedAddressFormat         : TStatus = ( Value: '{895F9BAC-D48E-437B-BA27-0D9321E16DDB}');

  /// <summary>
  ///   This log entry is inserted when cwSockets attempts to perform an
  ///   operation on a socket which is closed.
  /// </summary>
  stSocketClosed                     : TStatus = ( Value: '{2AB4A7BA-F66A-4E5A-933C-22D4FB1B7C32}');

  /// <summary>
  ///   This log entry is inserted when cwSockets attempts to convert a network
  ///   address (IPv4 or IPv6) from a string and the conversion fails. Check
  ///   that the provided address is valid.
  /// </summary>
  stFailedToConvertNetworkAddress    : TStatus = ( Value: '{E801EDB2-2BEF-4180-A6D6-E7FCBBEC325C}');

  /// <summary>
  ///   This entry is inserted into the log when attempting to assign an array
  ///   to a vector type in cwVectors, but the array does not contain the
  ///   correct number of elements for the target vector type.
  /// </summary>
  stInvalidArrayForVector            : TStatus = ( Value: '{EEE6AC48-4BBE-4A94-944B-BE2705B0708E}');

{$endregion}

{$region ' TLogSeverity'}
type
  /// <summary>
  ///   An enumerated type used to indicate the severity of a log entry upon insertion
  ///   into the log. <br />
  /// </summary>
  {$Z4}
  TLogSeverity = (

    /// <summary>
    ///   lsInfo is used to convey a simple piece of information to the end
    ///   user. This is useful for simple state reporting to file for example.
    /// </summary>
    lsInfo = $01,

    /// <summary>
    ///   lsHint is used to indicate potential performance or stability issues
    ///   due to configuration or miss-use of the application or sub-system.
    /// </summary>
    lsHint = $02,

    /// <summary>
    ///   lsWarning is an indication that there may be an error condition, or
    ///   that the application may not be functioning as expected. Warnings may
    ///   be used to indicate miss-configuration issues, or states which may
    ///   lead to error conditions later in the execution cycle.
    /// </summary>
    lsWarning = $03,

    /// <summary>
    ///   lsError indicates that something has gone wrong which may cause
    ///   unexpected behavior in the application. It may be possible for the application
    ///   to proceed despite the error, or not, the end user should be made aware
    ///   of such a condition.
    /// </summary>
    lsError = $04,

    /// <summary>
    ///   lsFatal indicates that something has gone wrong which may cause
    ///   unexpected behavior in the application. This is a more severe version
    ///   of lsError, the application should either terminate, or at least
    ///   terminate the sub-system which inserted this log entry.
    /// </summary>
    lsFatal = $05
  );

{$endregion}

{$region ' TOnLogInsertEvent'}
type
  {$ifdef fpc}
  TOnLogInsertEventGlobal   = procedure( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string );
  TOnLogInsertEventOfObject = procedure( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string ) of object;
  TOnLogInsertEventNested   = procedure( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string ) is nested;
  {$else}
  /// <exclude/> - Documented where used on event log target.
  TOnLogInsertEvent         = reference to procedure( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string );
  {$endif}
{$endregion}

{$region ' ILogTarget'}

  ///  <summary>
  ///    Implementations of ILogTarget will receive log entries as they
  ///    are inserted into the log.
  ///  </summary>
  ILogTarget = interface
    ['{4658C7FB-1AA5-4177-A74D-4F85AEF87564}']

    ///  <summary>
    ///    This method is called for each entry inserted into the log.
    ///  </summary>
    procedure Insert( const LogEntry: TGUID; const TranslatedText: string; const TS: TDateTime; const Severity: TLogSeverity; const Parameters: array of string );
  end;

{$endregion}

{$region ' ILog'}

  /// <summary>
  ///   ILog represents a single application-wide language translatable log,
  ///   into which log entries may be inserted. <br /><br />The standard
  ///   implementation of ILog returns a thread-local singleton, meaning that
  ///   each thread gets it's own instance of ILog, however, ultimately these
  ///   are merely interfaces to a SINGLE log implementation which is shared
  ///   between threads. The reason for the thread independent implementations
  ///   is both to lighten locking on the log, and to provide the ability for
  ///   any thread to look up the last inserted entry, without it being
  ///   overwritten by another thread. <br /><br />Log entries must be
  ///   registered with the log before they may be inserted. This is typically
  ///   done in two parts. <br /><list type="number">
  ///     <item>
  ///       Define a TStatus constant to supply the status code for the log
  ///       entry.
  ///     </item>
  ///     <item>
  ///       Call Log.RegisterEntry() to bind the status code with a
  ///       'default text'.
  ///     </item>
  ///   </list>
  ///   The first step can be seen exampled in the cwLog unit, where a number
  ///   of status codes are declared for the cwRutime library to return. i.e.
  ///   see stIndexOutOfBounds <br /><br /><code lang="Delphi">const
  ///   stIndexOutOfBounds: TStatus = (Value: '{D2A48812-D065-4DE6-9EA1-473A34B8273C}');</code>
  ///   The second step, log entry registration, is typically done in the
  ///   initialization section of the unit where the status is declared, with a
  ///   call that looks like this... <br /><br /><code lang="Delphi">initialization
  ///   Log.RegisterEntry( stIndexOutOfBounds, 'Index out of bounds (%index%).' );
  /// end.</code>
  ///   The call to register the log entry binds a piece of default text to the
  ///   status code "Index out of bounds (%index%)." which may be saved to a
  ///   translation file by the logging system. The translation file (json
  ///   format) may then be edited to provide alternative language translations
  ///   and re-loaded into the log at runtime. <br /><br />Note that the
  ///   default text contains a placeholder "(%index%)", this placeholder will
  ///   be replaced upon insertion of the log entry with a value supplied at
  ///   runtime. In this example, the index which fell outside of bounds may be
  ///   provided, and will be inserted into the message text. Note: These
  ///   placeholders must also appear in translation files.<br />Multiple
  ///   place-holders may be used, including the reuse of the same place
  ///   holder. Parameters will be supplied in order of the placeholders <b>
  ///   first-use</b> in the string, meaning that translations must use the
  ///   place holders in the same order, though they do not need to use the
  ///   same place holder more than once, even if this is done in the original
  ///   text. <br />
  /// </summary>
  ILog = interface
    ['{587FD133-6206-461F-A9F7-7D07CF60F93B}']

    /// <summary>
    ///   Registers a status code and it's default text with the log. <br />See
    ///   ILog() for information on log entry registration.
    /// </summary>
    /// <param name="LogEntry">
    ///   The status code to register as a log entry.
    /// </param>
    /// <param name="DefaultText">
    ///   The default text to be inserted into the log.
    /// </param>
    procedure RegisterEntry( const LogEntry: TStatus; const DefaultText: string );

    ///  <summary>
    ///    Inserts a log entry into the log. <br/>
    ///    Note: For log entries which do not require parameters, see the overloaded Insert method.
    ///  </summary>
    function Insert( const LogEntry: TStatus; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;

    ///  <summary>
    ///    Inserts a log entry into the log, just like the overload by the same name, however
    ///    this overload does not require parameters to be provided. This method may be convenient
    ///    for inserting log entries which do not require parameters.
    ///  </summary>
    function Insert( const LogEntry: TStatus; const Severity: TLogSeverity ): TStatus; overload;

    /// <exclude/> - Allows insertion of a GUID as a TStatus so long as it's registered.
    function Insert( const LogEntry: TGUID; const Severity: TLogSeverity ): TStatus; overload;

    /// <exclude/> - Allows insertion of a GUID as a TStatus so long as it's registered.
    function Insert( const LogEntry: TGUID; const Severity: TLogSeverity; const Parameters: array of string ): TStatus; overload;

    /// <summary>
    ///   When log entries are registered, this method will save those
    ///   registered entries to a json format file. <br />The file may be
    ///   translated and loaded back into the logging system with a call to
    ///   ImportTranslationFile(). (*Note: File is encoded UTF8 with BOM)
    /// </summary>
    function ExportTranslationFile( const FilePath: string ): TStatus;

    /// <summary>
    ///   Imports log entry translations from a json format file. <br />(*Note:
    ///   File must be encoded UTF8 with BOM)
    /// </summary>
    function ImportTranslationFile( const FilePath: string ): TStatus;

    /// <summary>
    ///   Returns the most recently inserted log entry for the current running
    ///   thread.
    /// </summary>
    function getLastEntry: string;

    /// <summary>
    ///   <para>
    ///     Add a log target to the log.
    ///   </para>
    ///   <para>
    ///     Some pre-build implementations of ILogTarget may be instanced
    ///     from the TLogTarget factory in cwLog.Standard / cwLog.Console.
    ///     Otherwise you may supply your own implementation of ILogTarget()
    ///     to receive log entries as they are inserted.
    ///   </para>
    /// </summary>
    procedure AddTarget( const LogTarget: ILogTarget );

    /// <summary>
    ///   Returns the most recently inserted log entry for the current running
    ///   thread.
    /// </summary>
    property LastEntry: string read getLastEntry;

  end;

{$endregion}

{$region ' Chain Log'}
type

  /// <summary>
  ///   <para>
  ///     Regardless of the threading model, ultimately there is only one log
  ///     in an application.
  ///   </para>
  ///   <para>
  ///     Each thread gets an instance of ILog and is able to use that
  ///     instance operate the thread-global singleton logging system. With
  ///     the exception of LastEntry which is per instance, and therefore per
  ///     thread.
  ///   </para>
  ///   <para>
  ///     When using logging within a dynamic library however, things are
  ///     different. <br />The compiler builds one instance of the runtime
  ///     into the calling executable, and another instance of the runtime
  ///     into the dynamic library. This means that Log entries inserted
  ///     within the library are retained within the library and never make
  ///     it back to the main application.
  ///   </para>
  ///   <para>
  ///     IChainLog is an experimental feature to resolve this problem. <br />
  ///     Your library would need to provide an exported procedure which
  ///     accepts a pointer in order to chain logs together.
  ///   </para>
  ///   <para>
  ///     For example, inside the library you could code:
  ///   </para>
  ///   <code lang="Delphi">procedure ChainLog( const Chain: pointer ); export;
  /// begin
  ///   IChainLog(Log).setChainLog(Chain);
  /// end;</code>
  ///   <para>
  ///     This code would tell the log inside the library to simply foward
  ///     all logging activity to the chained log passed as a parameter.
  ///   </para>
  ///   <para>
  ///     From the calling executable you can then do this:
  ///   </para>
  ///   <code lang="Delphi">MyLibraryBinding.ChainLog( Log.getChainLog );</code>
  ///   <para>
  ///     At the time that the log chain is formed, the log within the
  ///     library will call to register it's known log entries with the log
  ///     in the main application. Duplicate entries in the library would
  ///     cause the entries in the main application to be overwritten with
  ///     new message text. <br /><br />Because Log Chaining may cause the
  ///     default text for some messages in the main application to be
  ///     overwritten, you must also reload any translation file after
  ///     chaining log.
  ///   </para>
  ///   <para>
  ///     Similarly, the export of a translation file will be incomplete if
  ///     it is exported before all log-enabled libraries are loaded.
  ///   </para>
  /// </summary>
  IChainLog = interface
    ['{8A305076-5FFB-4BB8-878D-AC4B9ABEB4FA}']

    /// <summary>
    ///   Tells the log to forward all logging activity to another instance for
    ///   crossing the module boundary. <br />Pass as a parameter the value
    ///   obtained by calling getChainLog on the target log.
    /// </summary>
    /// <param name="ChainLog">
    ///   The result of calling getChainLog() on the target log.
    /// </param>
    procedure setChainLog( const ChainLog: pointer );

    ///  <summary>
    ///    Returns a pointer which represents the log as a target for
    ///    chaining.
    ///  </summary>
    function getChainLog: pointer;
  end;

{$endregion}

implementation

{$region ' TStatus implementation'}

const
  cSuccessUUID: TGUID = '{00000000-0000-0000-0000-000000000000}';
  cUnknownUUID: TGUID = '{A334E3A7-D11E-4106-B021-C737523CB51B}';

class function TStatus.Success: TStatus;
begin
  Result.Value := cSuccessUUID;
end;

procedure TStatus.ExceptionOnFail;
begin
  if IsEqualGUID(Value,cSuccessUUID) then begin
    exit;
  end;
  raise
    EStatusFail.Create( GUIDToString(Value) );
end;

class operator TStatus.Implicit(const a: TStatus): TGUID;
begin
  Result := a.Value;
end;

class operator TStatus.Explicit(const a: TStatus): TGUID;
begin
  Result := a.Value;
end;

class operator TStatus.Implicit(const a: TStatus): string;
begin
  Result := GuidToString(a){$ifdef fpc}.AsString{$endif};
end;

class operator TStatus.Explicit(const a: TStatus): string;
begin
  Result := GuidToString(a){$ifdef fpc}.AsString{$endif};
end;

class operator TStatus.Implicit(const a: string): TStatus;
begin
  Result.Value := StringToGUID(a{$ifdef fpc}.AsAnsiString{$endif});
end;

class operator TStatus.Explicit(const a: string): TStatus;
begin
  Result.Value := StringToGUID(a{$ifdef fpc}.AsAnsiString{$endif});
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

class operator TStatus.Equal(const a: TStatus; const b: TStatus): boolean;
begin
  Result := isEqualGUID(a,b);
end;

class operator TStatus.NotEqual(const a: TStatus; const b: TStatus): boolean;
begin
  Result := not isEqualGUID(a,b);
end;

class function TStatus.Unknown: TStatus;
begin
  Result.Value := cUnknownUUID;
end;

{$endregion}


end.
