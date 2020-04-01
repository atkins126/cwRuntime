{$ifdef license}
(*
  Copyright 2020 ChapmanWorld LLC ( https://chapmanworld.com )
  All Rights Reserved.
*)
{$endif}
/// <summary>
///   Cross platform dynamic library loader.
/// </summary>
unit cwDynLib;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface

type
  /// <summary>
  ///   An instance of IDynlib represents a dynamic library, such as a .dll or
  ///   .so file.
  /// </summary>
  IDynlib = interface
    ['{AA731CC2-8779-4F83-8117-F481DDD2B48D}']

    /// <summary>
    ///   Loads a library from disk into memory.
    /// </summary>
    /// <param name="filepath">
    ///   Specifies the full path and filename of the library to be loaded.
    ///   (Relative paths permitted based on target implementation).
    /// </param>
    /// <returns>
    /// </returns>
    function LoadLibrary( const filepath: string ): boolean;

    /// <summary>
    ///   Unloads the library (previously loaded using the LoadLibrary()
    ///   method) from memory.
    /// </summary>
    /// <returns>
    /// </returns>
    function FreeLibrary: boolean;

    /// <summary>
    ///   Locates a symbol within a library (previously loaded using the
    ///   LoadLibrary() method), and returns a pointer to it.
    /// </summary>
    /// <param name="funcName">
    ///   The name of the function or symbol to locate.
    /// </param>
    /// <returns>
    ///   If successful, returns a pointer to the requested symbol. Otherwise
    ///   returns false. Typically a failure is caused either by not having
    ///   first loaded the library using the LoadLibrary() method, or because
    ///   of an incorrect symbol name specified in the funcName parameter.
    ///   Symbol names may be case sensitive, depending upon the implementation
    ///   and target.
    /// </returns>
    function GetProcAddress( const funcName: string; out ptrProc: pointer ): boolean; overload;
  end;


implementation

end.

