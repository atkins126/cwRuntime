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
unit cwWin32.Binding;
{$ifdef fpc}{$mode delphiunicode}{$endif}

interface
{$ifdef MSWINDOWS}

type
  TSRWLOCK = record
    ptr: pointer;
  end;

  TCONDITION_VARIABLE = TSRWLOCK;

const
  cLibName = 'kernel32.dll';

const
  INFINITE = Cardinal($FFFFFFFF);
  ERROR_TIMEOUT = $5B4;

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-acquiresrwlockexclusive
///  </summary>
procedure AcquireSRWLockExclusive( var SRWLock: TSRWLock ); stdcall; external cLibName name 'AcquireSRWLockExclusive';

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-initializesrwlock
///  </summary>
procedure InitializeSRWLock( var SRWLock: TSRWLock ); stdcall; external cLibName name 'InitializeSRWLock';

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-initializeconditionvariable
///  </summary>
procedure InitializeConditionVariable( var ConditionVariable: TCONDITION_VARIABLE ); stdcall; external cLibName name 'InitializeConditionVariable';

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-releasesrwlockexclusive
///  </summary>
procedure ReleaseSRWLockExclusive( var SRWLock: TSRWLock ); stdcall; external cLibName name 'ReleaseSRWLockExclusive';

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-sleepconditionvariablesrw
///  </summary>
function SleepConditionVariableSRW( var ConditionVariable: TCONDITION_VARIABLE; var SRWLock: TSRWLock; const dwMilliseconds: uint32; const flags: uint64 ): boolean; stdcall; external cLibName name 'SleepConditionVariableSRW';

///  <summary>
///    MSDN: https://docs.microsoft.com/en-us/windows/desktop/api/synchapi/nf-synchapi-wakeconditionvariable
///  </summary>
procedure WakeConditionVariable( var ConditionVariable: TCONDITION_VARIABLE ); stdcall; external cLibName name 'WakeConditionVariable';

function QueryPerformanceFrequency( var lpFrequency: int64 ): boolean; stdcall; external cLibName name 'QueryPerformanceFrequency';

function QueryPerformanceCounter( var lpPerformanceCount: int64 ): boolean; stdcall; external cLibName name 'QueryPerformanceCounter';

function GetLastError: int32; stdcall; external cLibName name 'GetLastError';

{$endif}
implementation

end.

