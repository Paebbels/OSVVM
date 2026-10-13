.. _UTILITY/TranscriptPkg:

Transcript Package
##################

.. _UTILITY/TranscriptPkg/TranscriptPkgAndTranscriptBasePkgOverview:

TranscriptPkg and TranscriptBasePkg Overview
********************************************

:vhdlcode:`TranscriptPkg` allows different parts of a testbench to use a common transcript file. As such, it provides
means to open (:vhdlcode:`TranscriptOpen`) and close (:vhdlcode:`TranscriptClose`) the transcript file. In addition, it
provides a variety of printing capabilities.

.. _UTILITY/TranscriptPkg/TranscriptPkgUseModels:

TranscriptPkg Use Models
************************

All OSVVM printing uses the transcript capability. If the :vhdlcode:`TranscriptFile` is open, all OSVVM printing will go
to it. If the :vhdlcode:`TranscriptFile` is not open all OSVVM printing will go to OUTPUT (stdout). If the
:vhdlcode:`TranscriptFile` is open and transcript mirroring is enabled, printing will go to both the
:vhdlcode:`TranscriptFile` and to OUTPUT.

The following shows the basic use model. Set the test name (using :vhdlcode:`SetTestName`). Open the transcript file
(using :vhdlcode:`TranscriptOpen`). Mirror the transcript file to OUTPUT (:vhdlcode:`SetTranscriptMirror`). Print using
the transcripting capability. Close the transcript file (:vhdlcode:`TranscriptClose`) just before the end of the test.
Generate reports (using :vhdlcode:`EndOfTestReports`). Stop the test case (using :vhdlcode:`std.env.stop`).

.. code-block:: VHDL

   library osvvm ;
   context osvvm.OsvvmContext ;
   . . .

   architecture Test1 of TestCtrl is
   begin
     ControlProc : process
     begin
       SetTestName("Tb_SendGet_1") ;
       TranscriptOpen ;           -- Print to Tb_SendGet_1.log
       SetTranscriptMirror ;      -- Also print to OUTPUT
       PrintLine("Print 1") ;
       swrite(buf, "Write 1") ;
       writeline(buf) ;
       . . .
       TranscriptClose ;
       EndOfTestReports ;
       std.env.stop ;
     end process ControlProc ;

.. _UTILITY/TranscriptPkg/MethodReference:

Method Reference
****************

.. _UTILITY/TranscriptPkg/PackageReference:

Package Reference
=================

The entire OSVVM utility library, including :vhdlcode:`TranscriptPkg` can be referenced as follows:

.. code-block:: VHDL

   library osvvm ;
   context osvvm.OsvvmContext ;

.. _UTILITY/TranscriptPkg/TranscriptFile:

Transcript File
===============

:vhdlcode:`TranscriptFile` is declared in :vhdlcode:`TranscriptBasePkg` and is not visible to user programs.

.. code-block:: VHDL

   file TranscriptFile : text ;

.. _UTILITY/TranscriptPkg/SetTestName:

SetTestName
===========

Formally this method is in :vhdlcode:`AlertLogPkg`. It gives the test case a name.

.. _UTILITY/TranscriptPkg/TranscriptOpenAndTranscriptClose:

TranscriptOpen and TranscriptClose
==================================

:vhdlcode:`TranscriptOpen` opens the :vhdlcode:`TranscriptFile`. There are a number of variations (overloaded versions)
of :vhdlcode:`TranscriptOpen`, however, the simplest is the following. It opens a file named :file:`TestCaseName.log`,
where :vhdlcode:`TestCaseName` is the name used in :vhdlcode:`SetTestName`.

.. code-block:: VHDL

   procedure TranscriptOpen ;

:vhdlcode:`TranscriptClose` closes the :vhdlcode:`TranscriptFile`.

.. code-block:: VHDL

   procedure TranscriptClose ;

When :vhdlcode:`FILE_OPEN_KIND` is not specified in the call, the first call to :vhdlcode:`TranscriptOpen` will open the
file in :vhdlcode:`WRITE_MODE`. If the transcript is closed (with :vhdlcode:`TranscriptClose`) and then reopened, it
will be opened with :vhdlcode:`APPEND_MODE`.

.. _UTILITY/TranscriptPkg/AdditionalOverloadingForTranscriptOpen:

Additional overloading for TranscriptOpen
=========================================

The following versions of :vhdlcode:`TranscriptOpen` use the :file:`TestCaseName.log` as the file name.

.. code-block:: VHDL

   procedure TranscriptOpen (OpenKind: WRITE_APPEND_OPEN_KIND) ;
   procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS) ;
   procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS;
                               OpenKind: WRITE_APPEND_OPEN_KIND) ;

The following versions of :vhdlcode:`TranscriptOpen` allow the file name to be specified.

.. code-block:: VHDL

   procedure TranscriptOpen (ExternalName: STRING) ;
   procedure TranscriptOpen (ExternalName: STRING; OpenKind: WRITE_APPEND_OPEN_KIND);
   procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING) ;
   procedure TranscriptOpen (Status: InOut FILE_OPEN_STATUS; ExternalName: STRING;
                               OpenKind: WRITE_APPEND_OPEN_KIND) ;

.. _UTILITY/TranscriptPkg/SetTranscriptMirror:

SetTranscriptMirror
===================

:vhdlcode:`SetTranscriptMirror` sets mirror mode in which case all OSVVM printing goes to both the
:vhdlcode:`TranscriptFile` and :vhdlcode:`std.textio.OUTPUT`.

.. code-block:: VHDL

   procedure SetTranscriptMirror (A : boolean := TRUE) ;
   . . .
   SetTranscriptMirror ;

.. _UTILITY/TranscriptPkg/IsTranscriptOpen:

IsTranscriptOpen
================

:vhdlcode:`IsTranscriptOpen` returns true when the :vhdlcode:`TranscriptFile` is open.

.. code-block:: VHDL

   impure function IsTranscriptOpen return boolean ;
   . . .
   if IsTranscriptOpen then
     swrite(buf, "Write 1 - transcript open") ;
     writeline(TranscriptFile, buf) ;
   end if;

.. _UTILITY/TranscriptPkg/IsTranscriptMirrored:

IsTranscriptMirrored
====================

:vhdlcode:`IsTranscriptMirrored` returns true when the transcript is mirrored.

.. code-block:: VHDL

   impure function  IsTranscriptMirrored return boolean ;
   . . .
   if IsTranscriptMirrored then
     . . .

.. _UTILITY/TranscriptPkg/WriteLine:

WriteLine
=========

:vhdlcode:`WriteLine` writes the buffer using the transcript capability.

.. code-block:: VHDL

   procedure WriteLine(buf : inout line)  ;
   . . .
   swrite(buf, "A Message") ;
   WriteLine(buf) ;

.. _UTILITY/TranscriptPkg/Print:

Print
=====

:vhdlcode:`Print` writes a string using the transcript capability.

.. code-block:: VHDL

   procedure Print(s : string) ;
   . . .
   Print("Another Message") ;

.. _UTILITY/TranscriptPkg/Blank:

Blank
=====

:vhdlcode:`Blank` puts a variable number of blank lines in the output.

.. code-block:: VHDL

   procedure Blank (count : natural := 1) ;
   . . .
   Blank(5) ; -- prints 5 blank lines

.. _UTILITY/TranscriptPkg/PrintLine:

PrintLine
=========

:vhdlcode:`PrintLine` prints the string using the transcript capability. Like :vhdlcode:`Alert` and :vhdlcode:`Log`,
:vhdlcode:`PrintLine` prefixes the line with :vhdlcode:`OSVVM_PRINT_PREFIX`. In addition, like :vhdlcode:`Log`,
:vhdlcode:`PrintLine` allows message filtering using :vhdlcode:`Level` and :vhdlcode:`AlertLogID`. Unlike
:vhdlcode:`Log`, :vhdlcode:`PrintLine` does not print the time, "log", or the Log level.

.. code-block:: VHDL

   procedure PrintLine (s : string) ;
   procedure PrintLine (s : string ; Level : LogType) ;
   procedure PrintLine (AlertLogID : AlertLogIDType ; s : string ; Level : LogType);

.. _UTILITY/TranscriptPkg/PrintHeader:

PrintHeader
===========

:vhdlcode:`PrintHeader` prints the string plus prefix and suffix lines to frame the message and make it stand out. Each
character in the prefix and suffix indicates a line to print. Each line printed is prefixed by
:vhdlcode:`OSVVM_PRINT_PREFIX`. If the character is a space, then print a blank line, otherwise, repeat that character
:vhdlcode:`OSVVM_LINE_LENGTH` times. In addition, like :vhdlcode:`Log`, :vhdlcode:`PrintHeader` supports message
filtering using :vhdlcode:`Level` and :vhdlcode:`AlertLogID`.

.. code-block:: VHDL

   procedure PrintHeader (s, Prefix, Suffix : string) ;
   procedure PrintHeader (s, Prefix, Suffix : string ; Level : LogType ) ;
   procedure PrintHeader (AlertLogID : AlertLogIDType ; s, Prefix, Suffix : string ;
   Level : LogType ) ;

There is also a short form that uses :vhdlcode:`OSVVM_HEADER_PREFIX` (default " ") and :vhdlcode:`OSVVM_HEADER_SUFFIX`
(default "\*") instead of having a :vhdlcode:`Prefix` and :vhdlcode:`Suffix` parameter.

.. code-block:: VHDL

   procedure PrintHeader (s : string) ;
   procedure PrintHeader (s : string ; Level : LogType ) ;
   procedure PrintHeader (AlertLogID : AlertLogIDType; s : string; Level : LogType);

.. _UTILITY/TranscriptPkg/HeaderLine:

HeaderLine
==========

:vhdlcode:`HeaderLine` prints a string of characters that indicate a line to print. Each line printed is prefixed by
:vhdlcode:`OSVVM_PRINT_PREFIX`. If the character is a space, then print a blank line, otherwise, repeat that character
:vhdlcode:`OSVVM_LINE_LENGTH` times. In addition, like :vhdlcode:`Log`, :vhdlcode:`HeaderLine` supports message
filtering using :vhdlcode:`Level` and :vhdlcode:`AlertLogID`.

.. code-block:: VHDL

   procedure HeaderLine (S : string) ;
   procedure HeaderLine (S : string; Level : LogType; Enable : boolean := FALSE ) ;
   procedure HeaderLine (AlertLogID : AlertLogIDType; S : string;
                         Level : LogType := ALWAYS; Enable : boolean := FALSE) ;

.. _UTILITY/TranscriptPkg/BlankLine:

BlankLine
=========

:vhdlcode:`BlankLine` puts a variable number of blank lines in the output. Each line is prefixed by
:vhdlcode:`OSVVM_PRINT_PREFIX`. Blank lines can also be filtered with Log levels and :vhdlcode:`AlertLogID`.

.. code-block:: VHDL

   procedure BlankLine (count : natural := 1) ;
   procedure BlankLine (count : natural; Level : LogType; Enable : boolean := FALSE);
   procedure BlankLine (AlertLogID : AlertLogIDType ; count : natural;
                        Level : LogType := ALWAYS; Enable : boolean := FALSE);

.. _UTILITY/TranscriptPkg/CompilingAndUsingOSVVMUtilityLibrary:

Compiling and Using OSVVM Utility Library
*****************************************

Compilation order for OSVVM Utility Library is in :file:`CHANGELOG.md` and :file:`osvvm.pro`. To run :file:`osvvm.pro`
see the :ref:`Script User Guide <UG>`.

OSVVM Utility library is released under the Apache open source license. It is free (both to download and use - there are
no license fees). You can download it from osvvm.org or from our development area on GitHub
(https://github.com/OSVVM/OSVVM).

If you add features to the package, please donate them back under the same license as candidates to be added to the
standard version of the package. If you need features, be sure to contact us.

We also support the OSVVM user community and blogs through http://www.osvvm.org. Interested in sharing about your
experience using OSVVM? Let us know, you can blog about it at osvvm.org.
