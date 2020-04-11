# cwRuntime
Compiler agnostic and cross platform collection of utility libraries for Delphi and Freepascal.

While this library does still depend on some parts of the Delphi / Freepascal rtl libraries, 
the goal is to remove that dependency entirely. This library has been migrated from my personal 
collection to become open source under the three clause BSD license. Migration is in advanced 
stages but is not yet complete. 

Current Features:
	
	cwTest        - A light-weight unit testing framework.
	cwTypes       - A collection of type-helpers and half-precision floating point type.
	cwCollections - Generic collection classes List/Stack/Ring etc.
	cwDynLib      - Dynamic library loading.
	cwIO          - Classes for serialization/deserialzation of streams.
	cwLog         - Logging and error reporting system with language translation.
	cwThreading   - A system for organizing multi-threaded code.
	cwUnicode     - A Unicode Codec and string data type to convert between unicode formats.
	cwVectors     - A simple vector math library.

(* Half precision floating point with permission from, and thanks to Marek Mauder
   at Galfar's Lair: https://galfar.vevb.net *)
	
Supported compilers:  
    XE5, XE6, XE8, 10.0 Seattle, 10.2 Tokyo, 10.3 Rio, FPC 3.3.1-r44373 (Lazarus 2.1)
	
	Other compilers may also work - in particular the skipped Delphi compilers in the 
	above sequence. These are merely the compilers I have access to install on the 
	CI server.

Still To-Do:

	* cwLog saving/loading of translation files not yet migrated.
	* cwTypes Still heavily dependent on RTL units for string/type conversion, need to replace.
	* cwIO Still heavily dependent on RTL units, need to replace. (incl heap wrapper)
	* cwIO Unit tests are missing.
	* cwThreading unit tests are missing.
	* cwCollections - IStringList to get serialize/deserialze methods for save to file, load from file.	
	* Documentation needs work.
	
    CI Server :- Currently performs builds and runs unit tests for Windows Only, need to add targets.
	

Installation & Usage:

 There is nothing to install when using the cwRuntime (the included package comes out of legacy CI, and will likely be removed soon, it should not be installed). Instead, simply add the following two paths to your compilers search path...
 
 * cwRuntime/src/main/api
 * cwRuntime/src/main/implementation
 
Each feature may then be used by adding two units to your uses list. For example, to use cwCollections you can add both cwCollections and cwCollections.Standard to your uses list. There are some exceptions to this rule, see the api directory and associated documentation.

---  
Usage videos will be uploaded to youtube soon :- https://youtube.com/c/ChapmanWorldOnTube.



  
