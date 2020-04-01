unit cwlog.console;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
uses
  cwLog
, cwLog.Targets
;

type
  TLogTargetHelper = record helper for TLogTarget
  public
    class function Console: ILogTarget; static;
  end;

implementation
uses
  cwLog.LogTarget.Console
;

class function TLogTargetHelper.Console: ILogTarget;
begin
  Result := cwLog.LogTarget.Console.TLogTarget.Create;
end;

end.

