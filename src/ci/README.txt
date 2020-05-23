
IMPORTANT: 
	There are no installable packages for cwRuntime!
	
The cwRuntime may be included into your project by including the following two paths:
	<cwRuntime>/src/main/api
	<cwRuntime>/src/main/implementation
	
The packages found in this directory are used only for development purposes,
and are therefore not required in order to use the cwRuntime library.

-------------------------------------------
 What are the contents of this directory?
-------------------------------------------

The Delphi package (cwRuntime.dpk) is used to build the .chm documentation for cwRuntime.
This project uses Documentation Insight from DevJet Software to generate the help files.
Documentation Insight was selected (over pasdoc and fpdoc) because of it's compatibility 
with Help Insight (the documentation system built into the Delphi IDE), which offers live 
documentation while editing code.
The package is built using which-ever is the latest available IDE to me, currently Rio, and
will be updated as new versions are available with the an available Document Insight tool.

The Lazarus package in this directory is one that I use when adding new features to the 
code, or during refactoring. It does not "Install" into the IDE and can therefore be used
to provide code navigation. It too uses the latest IDE available to me, which in the case
of lazarus is the trunk - updated as frequently as I find necessary.

