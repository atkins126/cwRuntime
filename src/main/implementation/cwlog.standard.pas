{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <summary>
///   Standard implementation of ILog
/// </summary>
unit cwLog.Standard;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
;

///  <summary>
///    Returns the singleton instance of ILog.
///  </summary>
function Log: ILog;

implementation
uses
  sysutils //[RTL] for FileExists
, cwLog.Log.Static
, cwLog.Log.Dynamic
;

var
  LocalSingletonLog: ILog = nil;

function Log: ILog;
begin
  if not assigned(LocalSingletonLog) then begin
    Result := cwLog.Log.Dynamic.Log();
  end;
  if not assigned(LocalSingletonLog) then begin
    Result := cwLog.Log.Static.Log();
  end;
  Result := LocalSingletonLog;
end;

initialization
  LocalSingletonLog := nil;

finalization
  LocalSingletonLog := nil;

end.

