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
///   Provides pre-defined log targets.
/// </summary>
unit cwlog.targets;
{$ifdef fpc}
  {$mode delphiunicode}
  {$modeswitch nestedprocvars}
{$endif}

interface
uses
  cwLog
, cwIO
;

type
  ///  <summary>
  ///    A namespace for instancing log targets.
  ///  </summary>
  TLogTarget = record
    class function Stream( const TargetStream: IUnicodeStream; const Format: TUnicodeFormat ): ILogTarget; static;
    {$ifdef fpc}
      class function Event( const anEvent: TOnLogInsertEventGlobal ): ILogTarget; overload; static;
      class function Event( const anEvent: TOnLogInsertEventOfObject ): ILogTarget; overload; static;
      class function Event( const anEvent: TOnLogInsertEventNested ): ILogTarget; overload; static;
    {$else}
      class function Event( const anEvent: TOnLogInsertEvent ): ILogTarget; static;
    {$endif}
  end;

implementation
uses
  cwLog.LogTarget.Stream
, cwLog.LogTarget.Event
;

class function TLogTarget.Stream( const TargetStream: IUnicodeStream; const Format: TUnicodeFormat ): ILogTarget;
begin
  Result := TStreamLogTarget.Create( TargetStream, Format );
end;

{$ifdef fpc}
class function TLogTarget.Event(const anEvent: TOnLogInsertEventGlobal): ILogTarget;
begin
  Result := TEventLogTarget.Create( anEvent );
end;
{$endif}

{$ifdef fpc}
class function TLogTarget.Event(const anEvent: TOnLogInsertEventOfObject): ILogTarget;
begin
  Result := TEventLogTarget.Create( anEvent );
end;
{$endif}

{$ifdef fpc}
class function TLogTarget.Event(const anEvent: TOnLogInsertEventNested): ILogTarget;
begin
  Result := TEventLogTarget.Create( anEvent );
end;
{$endif}

{$ifndef fpc}
class function TLogTarget.Event(const anEvent: TOnLogInsertEvent): ILogTarget;
begin
  Result := TEventLogTarget.Create( anEvent );
end;
{$endif}


end.
