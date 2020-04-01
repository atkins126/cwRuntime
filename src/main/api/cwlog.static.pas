{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <summary>
///   Standard implementation of ILog
/// </summary>
unit cwlog.static;
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
  cwLog.Log.Static
;

var
  SingletonLog: ILog = nil;

function Log: ILog;
begin
  if not assigned(SingletonLog) then begin
    SingletonLog := TLog.Create;
  end;
  Result := SingletonLog;
end;


initialization
  SingletonLog := nil;

finalization
  SingletonLog := nil;

end.

