{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <summary>
///   Standard implementation of ILog
/// </summary>
unit cwlog.dynamic;
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
  cwLog.Log.Dynamic
;

function Log: ILog;
begin
  Result := cwLog.Log.Dynamic.Log;
end;


end.

