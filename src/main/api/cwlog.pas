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
    ///    Allows the status to be read as a GUID string
    ///  </summary>
    class operator Implicit(const a: TStatus): string;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: TStatus): string;

    ///  <summary>
    ///    Allows the status to be set as a GUID string
    ///  </summary>
    class operator Implicit(const a: string): TStatus;

    ///  <exclude/>  - for same purpose as implicit
    class operator Explicit(const a: string): TStatus;


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

{$region ' Log entry'}
type
  ///  <summary>
  ///    Represents a log entry which must be registered with the log before
  ///    it may be inserted.
  ///  </summary>
  TLogEntry = record
    Value: TGUID;
    Text: string;
  end;

{$endregion}

{$region ' Constants for pre-defined status codes which may be returned from cwRuntime'}

const
  stLogEntryNotRegistered            : TStatus = ( Value: '{59B9A72C-B7E5-46F1-9D2C-12C4B40C8F4E}');
  stDependencyNotMet                 : TStatus = ( Value: '{3E1E0236-4A9E-4646-ABCF-D380BFF9E78A}');
  stIndexOutOfBounds                 : TStatus = ( Value: '{D2A48812-D065-4DE6-9EA1-473A34B8273C}');
  stFactoryConstructException        : TStatus = ( Value: '{51FF694C-97DC-4654-B1C3-A797730B3A52}');
  stObjectNotAssigned                : TStatus = ( Value: '{EF13EE2D-65BA-4A6C-9244-B01052A018DA}');
  stStreamDoesNotSupportClear        : TStatus = ( Value: '{1FFC5715-B4A1-4E0A-8DB6-D3F6969AE372}');
  stCannotEncodeUnknownUnicodeFormat : TStatus = ( Value: '{751F423E-FE14-4E9E-8708-D4560CCE39BF}');
  stUnableToDetermineUnicodeFormat   : TStatus = ( Value: '{7507CDB2-5939-4D1D-AD22-CD890ADA718D}');
  stFailedThreadTerminate            : TStatus = ( Value: '{9798567B-E753-47EE-A51D-EB3A0A01E11B}');
  stOSAPIError                       : TStatus = ( Value: '{0155B3C1-F5AA-47A4-8C33-A606F57A9DC3}');
  stDuplicateMessageChannel          : TStatus = ( Value: '{C038923C-B2D4-400C-977C-C890C1A1D873}');
  stThreadAlreadyStarted             : TStatus = ( Value: '{A2BD6971-AEB3-4696-A149-B04FA8BD1005}');
  stFileNotFound                     : TStatus = ( Value: '{0A32412A-196B-40B2-8880-5D73DE46E3F1}');
  stModuleNotLoaded                  : TStatus = ( Value: '{F6881310-4F2E-4D5B-8A4B-8318EDF8D4AD}');
  stFailedToLoadEntryPoint           : TStatus = ( Value: '{B425D9C3-262A-425B-85BB-149E79A4C9CC}');
  stNoHighPrecisionTimer             : TStatus = ( Value: '{6EB4740F-C483-47CE-A78C-7CD2CC4D97EC}');
  stSocketError                      : TStatus = ( Value: '{704C63BE-4387-4854-BB66-4C07E1ADF709}');
  stInvalidSocket                    : TStatus = ( Value: '{3956BFFE-C229-4C90-9604-245F6624C0E3}');
  stBindNotSupportedOnDomain         : TStatus = ( Value: '{33C45B9D-4CAE-4D74-A2A1-91588E45126C}');
  stSocketBindError                  : TStatus = ( Value: '{A7F8DCD3-E122-4C07-8CF0-1AD89C0E4E79}');
  stSocketListenError                : TStatus = ( Value: '{FBF7521C-C9A9-4962-9C77-A43C9B235E37}');
  stSocketAcceptError                : TStatus = ( Value: '{A8C9CE48-133A-4495-B8B1-794A53409A7D}');
  stSocketConnectError               : TStatus = ( Value: '{99BC6926-BB39-4380-92B9-A266BBA9D8AB}');
  stSocketCloseError                 : TStatus = ( Value: '{E913A85A-070A-451C-9E86-B13BE58FA334}');
  stSocketShutdownError              : TStatus = ( Value: '{882F80C9-8D42-4BBE-B3C4-54DCD4CE3422}');
  stUnknownSocketDomain              : TStatus = ( Value: '{FB0055EC-4F5B-479C-8DA0-8E0811B5B61A}');
  stUnsupportedAddressFormat         : TStatus = ( Value: '{895F9BAC-D48E-437B-BA27-0D9321E16DDB}');
  stSocketClosed                     : TStatus = ( Value: '{2AB4A7BA-F66A-4E5A-933C-22D4FB1B7C32}');
  stFailedToConvertNetworkAddress    : TStatus = ( Value: '{E801EDB2-2BEF-4180-A6D6-E7FCBBEC325C}');
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
    ///   due to configuration or miss-use of the application. It is similar to
    ///   lsInfo, except that it may be used to flag attention to a possible
    ///   correction.
    /// </summary>
    lsHint = $02,

    /// <summary>
    ///   lsWarning is an indication that there may be an error condition, or that
    ///   the application may not be functioning as expected. <br/>
    ///   Warnings may be used to indicate miss-configuration issues, or states
    ///   which may lead to error conditions later in the application execution cycle.
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
    ///   <para>
    ///     lsFatal indicates that something has gone wrong which may cause
    ///     unexpected behavior in the application. This is a more severe
    ///     error which may cause the application to terminate.
    ///   </para>
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
  ///   ILog represents a single application-wide log into which log entries may be inserted. <br/>
  ///   Defining a log entry is done by creating a resource string which begins
  ///   with a GUID identifying the log entry, followed by the default text for
  ///   the entry. (Note, the
  ///   Log entries may also contain place holder values which are denoted
  ///   by enclosing them in brackets with percent characters around them.
  ///   For example (%value%) creates a place holder named 'value'.
  ///   Placeholders are populated using parameters passed into calls to the
  ///   Insert() method.
  /// </summary>
  ILog = interface
    ['{587FD133-6206-461F-A9F7-7D07CF60F93B}']

    ///  <summary>
    ///    Adds a log entry by UUID and default text 'MessageStr' to the log. <br/>
    ///    You should not need to call this method directly for log entries which are
    ///    declared as resourcestring. The log will automatically collect resource strings
    ///    which match the log entry format '<UUID><text>' for example:
    ///
    ///    resourcestring
    ///      le_IndexOutOfBounds = '{C55508DE-73AE-4770-B623-B864077C4177} Index out of bounds ((%index%))';
    ///
    ///    This method may be used to manually add entries to the log if required. <br/>
    ///    Returns FALSE if a log entry with the provided GUID has already been registered.
    ///  </summary>
    function RegisterLogEntry( const LogEntry: TStatus; const DefaultText: string ): boolean;

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

    ///  <summary>
    ///    When log entries are registered (currently done automatically for fpc
    ///    but manually for Delphi), this method will save those registered entries
    ///    to a json format file. The file may be translated and loaded back into
    ///    the logging system with a call to ImportTranslationFile().
    ///    (*Note File is encoded UTF8 with BOM)
    ///  </summary>
    function ExportTranslationFile( const FilePath: string ): TStatus;

    ///  <summary>
    ///    Imports log entry translations from a json format file.
    ///    (*Note: File must be encoded UTF8 with BOM)
    ///  </summary>
    function ImportTranslationFile( const FilePath: string ): TStatus;

    ///  <summary>
    ///    Returns the most recently inserted log entry for the current running thread, post translation.
    ///  </summary>
    function getLastEntry: string;

    ///  <summary>
    ///    Add a log target to the log.
    ///  </summary>
    procedure AddLogTarget( const LogTarget: ILogTarget );

    ///  <summary>
    ///    Returns the most recently inserted log entry for the current running thread, post translation.
    ///  </summary>
    property LastEntry: string read getLastEntry;

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
  Result := GuidToString(a).AsString;
end;

class operator TStatus.Explicit(const a: TStatus): string;
begin
  Result := GuidToString(a).AsString;
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

class function TStatus.Unknown: TStatus;
begin
  Result.Value := cUnknownUUID;
end;

{$endregion}


end.
