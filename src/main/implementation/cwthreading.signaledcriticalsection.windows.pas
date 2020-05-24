﻿{$ifdef license}
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
unit cwThreading.SignaledCriticalSection.Windows;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
{$ifdef MSWINDOWS}
uses
  cwLog
, cwThreading
, cwWin32.Binding
;


type
  TSignaledCriticalSection = class( TInterfacedObject, ISignaledCriticalSection )
  private
    fMutex: TSRWLOCK;
    fCondition: TCONDITION_VARIABLE;
  private //- ISignaledCriticalSection -//
    procedure Acquire;
    procedure Release;
    procedure Sleep;
    procedure Wake;
  public
    constructor Create; reintroduce;
  end;

{$endif}
implementation
{$ifdef MSWINDOWS}
uses
  cwTypes
, cwLog.Standard
;

procedure TSignaledCriticalSection.Acquire;
begin
  AcquireSRWLockExclusive(fMutex);
end;

constructor TSignaledCriticalSection.Create;
begin
  inherited Create;
  InitializeSRWLock(fMutex);
  InitializeConditionVariable(fCondition);
end;

procedure TSignaledCriticalSection.Release;
begin
  ReleaseSRWLockExclusive(fMutex);
end;

procedure TSignaledCriticalSection.Sleep;
var
  Error: uint32;
begin
  if not SleepConditionVariableSRW(fCondition, fMutex, INFINITE, 0) then begin
    Error:=GetLastError;
    if Error<>ERROR_TIMEOUT then begin
      Log.Insert(stOSAPIError,lsFatal,['SleepConditionVariableSRW',Error.AsString]);
    end;
  end;
end;

procedure TSignaledCriticalSection.Wake;
begin
  WakeConditionVariable(fCondition);
end;

{$endif}
end.
