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
unit cwRuntime.Collections;
{$ifdef fpc}{$mode delphiunicode}{$endif}

(*
   Tight interaction between cwLog, cwThreading and cwCollections caused the fpc compiler
   to raise an internal compiler error (compiler bug). To work around this, all collections
   used in cwLog or cwThreading are being replaced with non-generic concrete collections.
   This unit provides the required interfaces for these collections.
*)

interface
uses
  cwLog
, cwThreading
;

type
  IPoolThreadList = interface
  ['{864FB50C-DCA7-4C28-B164-314DA7B135EE}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IPoolThread;
    procedure setItem( const idx: nativeuint; const item: IPoolThread );
    procedure Clear;
    function Add( const item: IPoolThread ): nativeuint;
    procedure Remove( const Item: IPoolThread );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: IPoolThread read getItem write setItem; default;
  end;

  IMessagePipeList = interface
  ['{1596DAA8-C93C-48F7-BB85-CA8BEC210AC3}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IMessagePipe;
    procedure setItem( const idx: nativeuint; const item: IMessagePipe );
    procedure Clear;
    function Add( const item: IMessagePipe ): nativeuint;
    procedure Remove( const Item: IMessagePipe );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: IMessagePipe read getItem write setItem; default;
  end;

  IThreadSubSystemList = interface
  ['{F47F439B-5E58-4806-B1F7-3D7C1AE4E1DE}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IThreadSubSystem;
    procedure setItem( const idx: nativeuint; const item: IThreadSubSystem );
    procedure Clear;
    function Add( const item: IThreadSubSystem ): nativeuint;
    procedure Remove( const Item: IThreadSubSystem );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: IThreadSubSystem read getItem write setItem; default;
  end;

  IThreadExecutor = interface
    ['{62101CBD-F657-42F0-A46B-4D22FF453FAE}']
    function isDedicated: boolean;
    procedure setDedicated;
    function getSubSystemCount: uint32;
    function InstallSubSystem( aSubSystem: IThreadSubSystem ): boolean;
  end;

  IThreadExecutorList = interface
  ['{9801CF5B-FA6F-4C30-9D56-07004220E1A9}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IThreadExecutor;
    procedure setItem( const idx: nativeuint; const item: IThreadExecutor );
    procedure Clear;
    function Add( const item: IThreadExecutor ): nativeuint;
    procedure Remove( const Item: IThreadExecutor );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: IThreadExecutor read getItem write setItem; default;
  end;

  IThreadLoopExecutor = interface
    ['{28C414FF-79E1-4243-916C-59BC1F8442DD}']
    function Status: TStatus;
    function IsJobRunning: boolean;
    function getWorkOffset: nativeuint;
    function getWorkTop: nativeuint;
    procedure SetWorkDimensions( const Offset: nativeuint; const Top: nativeuint; const Total: nativeuint; const UserOffset: nativeuint );
    procedure TerminateExecutor;
    procedure Execute( const Method: TThreadedLoopMethod ); overload;
    procedure Execute( const Method: TThreadedLoopMethodOfObject ); overload;
  end;

  IThreadLoopExecutorList = interface
  ['{F4A6AB83-3B40-4D3E-8AD5-6F76C50338BD}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): IThreadLoopExecutor;
    procedure setItem( const idx: nativeuint; const item: IThreadLoopExecutor );
    procedure Clear;
    function Add( const item: IThreadLoopExecutor ): nativeuint;
    procedure Remove( const Item: IThreadLoopExecutor );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: IThreadLoopExecutor read getItem write setItem; default;
  end;

  ILogTargetList = interface
  ['{AA987F0B-6AEB-40E9-B3D3-054756E7BB7B}']
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): ILogTarget;
    procedure setItem( const idx: nativeuint; const item: ILogTarget );
    procedure Clear;
    function Add( const item: ILogTarget ): nativeuint;
    procedure Remove( const Item: ILogTarget );
    function RemoveItem( const idx: nativeuint ): boolean;

    property Count: nativeuint read getCount;
    property Items[ const idx: nativeuint ]: ILogTarget read getItem write setItem; default;
  end;

  IMessageChannelDictionary = interface
    ['{29F34EB5-C0AF-4BDF-9C73-08B9C257A11D}']
    function getCount: nativeuint;
    function getKeyByIndex( const idx: nativeuint ): String;
    function getValueByIndex( const idx: nativeuint ): IMessageChannel;
    function getKeyExists( const key: String ): boolean;
    function getValueByKey( const key: String ): IMessageChannel;
    procedure setValueByKey( const key: String; const value: IMessageChannel );
    procedure setValueByIndex( const idx: nativeuint; const value: IMessageChannel );
    procedure removeByIndex( const idx: nativeuint );
    procedure Clear;

    property Count: nativeuint read getCount;
    property KeyExists[ const key: String ]: boolean read getKeyExists;
    property ValueByKey[ const key: String ]: IMessageChannel read getValueByKey; default;
    property ValueByIndex[ const idx: nativeuint ]: IMessageChannel read getValueByIndex;
    property KeyByIndex[ const idx: nativeuint ]: String read getKeyByIndex;
  end;

  ILogEntryDictionary = interface
    ['{A025EB2F-F9EA-4A12-84E1-F3644E793C6B}']
    function getCount: nativeuint;
    function getKeyByIndex( const idx: nativeuint ): TGUID;
    function getValueByIndex( const idx: nativeuint ): string;
    function getKeyExists( const key: TGUID ): boolean;
    function getValueByKey( const key: TGUID ): string;
    procedure setValueByKey( const key: TGUID; const value: string );
    procedure setValueByIndex( const idx: nativeuint; const value: string );
    procedure removeByIndex( const idx: nativeuint );
    procedure Clear;

    property Count: nativeuint read getCount;
    property KeyExists[ const key: TGUID ]: boolean read getKeyExists;
    property ValueByKey[ const key: TGUID ]: string read getValueByKey; default;
    property ValueByIndex[ const idx: nativeuint ]: string read getValueByIndex;
    property KeyByIndex[ const idx: nativeuint ]: TGUID read getKeyByIndex;
  end;

implementation

end.

