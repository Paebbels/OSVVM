.. _UTILITY/TextUtilPkg:

TextUtilPkg
###########

.. _UTILITY/TextUtilPkg/TextUtilPkgOverview:

TextUtilPkg Overview
********************

:vhdlcode:`TextUtilPkg` provides basic string handling and reading utilities.

.. _UTILITY/TextUtilPkg/CharacterTests:

Character Tests
***************

:vhdlcode:`TextUtilPkg` provides the following character test functions:

.. code-block:: VHDL

   function IsUpper  (constant Char : character ) return boolean ;
   function IsLower  (constant Char : character ) return boolean ;
   function IsWhiteSpace (constant Char : character ) return boolean ;
   function IsHex (constant Char : character ) return boolean ;
   function IsHexOrStdLogic (constant Char : character ) return boolean ;
   function IsNumber (constant Char : character ) return boolean ;
   function IsNumber (Name : string ) return boolean ;
   function isstd_logic (constant Char : character ) return boolean ;

.. _UTILITY/TextUtilPkg/TextCaseConversions:

Text Case Conversions
*********************

:vhdlcode:`TextUtilPkg` provides the following text conversion functions:

.. code-block:: VHDL

   function to_lower (constant Char : character ) return character ;
   function to_lower (constant Str : string ) return string ;
   function to_upper (constant Char : character ) return character ;
   function to_upper (constant Str : string ) return string ;

.. _UTILITY/TextUtilPkg/SpaceAndCRLFHandling:

Space and CRLF handling
***********************

:vhdlcode:`TextUtilPkg` provides the following functions that remove Space or CRLF:

.. code-block:: VHDL

   procedure RemoveSpace (variable S : inout string ; variable Len : InOut integer) ;
   -- Only needed for non-compliant simulators -- X
   procedure RemoveCrLf (S : string ; variable Len : out integer) ;
   function  RemoveCrLf( S : string ) return string ;

.. _UTILITY/TextUtilPkg/ArrayOfStdLogicToHex:

Array of Std_logic to Hex
*************************

:vhdlcode:`TextUtilPkg` provides the following functions that convert from an array of :vhdlcode:`std_logic` to hex. A
string of 4 Meta characters, such as U, X, Z, W, and - print as that character. If there is a mixture of Meta characters
and other characters a ? is printed.

.. code-block:: VHDL

   function to_hxstring ( A : std_ulogic_vector) return string ;
   function to_hxstring ( A : unsigned) return string ;
   function to_hxstring ( A : signed) return string ;

.. _UTILITY/TextUtilPkg/FindCharacterHasCharacter:

FindCharacter, HasCharacter
***************************

:vhdlcode:`FindCharacter` finds a character in a string. Start at :vhdlcode:`StartIndex`. End at :vhdlcode:`EndIndex`.
Return index of the character location or 0 if not found.

.. code-block:: VHDL

   function FindCharacter (S : in string ; C : in character ; StartIndex, EndIndex :
   in integer) return integer ;

:vhdlcode:`HasCharacter` returns true if a character is found in a string.

.. code-block:: VHDL

   function HasCharacter  (S : in string; C : in character) return boolean ;

.. _UTILITY/TextUtilPkg/Format:

Format
******

:vhdlcode:`Format` is alternatives to :vhdlcode:`to_string` for integer, real, and time.

:vhdlcode:`Format` with integer prints :vhdlcode:`integer'high` if :vhdlcode:`integer'high`, :vhdlcode:`integer'low` if
:vhdlcode:`integer'low`, otherwise the integer value.

.. code-block:: VHDL

   function format ( I : integer ) return string ;

:vhdlcode:`Format` with real prints :vhdlcode:`real'high` if :vhdlcode:`real'high`, :vhdlcode:`real'low` if
:vhdlcode:`real'low`. If the value fits in fixed point, print as fixed point, otherwise, print in exponential notation.

.. code-block:: VHDL

   function format (
     R                   : Real ;
     FractionDigits      : natural := OSVVM_DIGITS_FOR_REAL_FRACTION ;
     MaxFixedPointDigits : natural := OSVVM_MAX_DIGITS_FOR_FIXED_POINT_REAL
   ) return string ;

:vhdlcode:`Format` with time prints the time value in the specified time units with :vhdlcode:`FractionDigits` number of
fraction digits. If time units is not specified, use the largest time units possible.

.. code-block:: VHDL

   function GetMaxWholeTimeUnits(T : time) return time ;
   function GetTimeUnits(T : time) return string ;
   function format (
     T              : time ;
     TimeUnits      : time ;
     FractionDigits : natural := OSVVM_DIGITS_FOR_TIME_FRACTION ;
     RightJustify   : natural := 0
   ) return string ;

   function format (
     T              : time ;
     FractionDigits : natural := OSVVM_DIGITS_FOR_TIME_FRACTION ;
     RightJustify   : natural := 0
   ) return string ;

   alias to_string_max is format[integer return string] ;
   function to_string_max ( I :
   integer) return string ;

.. _UTILITY/TextUtilPkg/Justify:

Justify
*******

Justify a string value. If :vhdlcode:`Fill` character specified use that as the fill character, otherwise, use space.

.. code-block:: VHDL

   type AlignType is (RIGHT, LEFT, CENTER) ;

   function Justify (
     S       : string ;
     Amount  : natural ;
     Align   : AlignType := LEFT
   ) return string ;

   function Justify (
     S       : string ;
     Fill    : character ;
     Amount  : natural ;
     Align   : AlignType := LEFT
   ) return string ;

.. _UTILITY/TextUtilPkg/WrapToBuf:

WrapToBuf
*********

:vhdlcode:`WrapToBuf` wraps a string based message into a line variable using the :vhdlcode:`InitialPrefix` for the
first line and :vhdlcode:`SubsequentPrefix` for additional lines. Wrap at :vhdlcode:`WrapLength` characters.

.. code-block:: VHDL

   procedure WrapToBuf(
     buf              : inout line ;
     s                : in string ;
     InitialPrefix    : in string ;
     SubsequentPrefix : in string ;
     WrapLength       : in integer := OSVVM_LINE_WRAP
   ) ;

For :vhdlcode:`WrapToBuf` without the :vhdlcode:`InitialPrefix` has the :vhdlcode:`InitialPrefix` already in
:vhdlcode:`buf`.

.. code-block:: VHDL

   procedure WrapToBuf(
     buf              : inout line ;
     s                : in string ;
     SubsequentPrefix : in string ;
     WrapLength       : in integer := OSVVM_LINE_WRAP
   ) ;

:vhdlcode:`WrapOneLine` finds the wrap point using the string :vhdlcode:`s`.

.. code-block:: VHDL

   procedure WrapOneLine(
     s               : in string ;
     NextStartIndex  : inout integer ;
     FoundIndex      : inout integer ;
     WrapLength      : in integer := OSVVM_LINE_WRAP
   ) ;

.. _UTILITY/TextUtilPkg/HeaderToBuf:

HeaderToBuf
***********

For each character in the string indicates a line to print. If the character is a space, then print a blank line,
otherwise, repeat that character :vhdlcode:`OSVVM_LINE_LENGTH` times. Each line is prefixed with
:vhdlcode:`OSVVM_PRINT_PREFIX`.

.. code-block:: VHDL

   procedure HeaderToBuf (buf : inout line ; S : string) ;

.. _UTILITY/TextUtilPkg/FileExists:

File Exists
***********

:vhdlcode:`FileExists` returns true if a file exists.

.. code-block:: VHDL

   impure function FileExists(FileName : string) return boolean ;

.. _UTILITY/TextUtilPkg/ReadUtilities:

Read Utilities
**************

.. _UTILITY/TextUtilPkg/GetLine:

GetLine
=======

:vhdlcode:`GetLine` reads lines from a file. Optionally will skip over empty lines. Returns :vhdlcode:`EndOfFile` as
true if there are no more lines in the file.

.. code-block:: VHDL

   procedure GetLine(
     File     FileId           :       text ;
     variable Buf              : inout line ;
     variable LineCount        : inout integer ;
     variable EndOfFile        : out   boolean ;
     constant IgnoreEmptyLines : in    boolean
   ) ;

.. _UTILITY/TextUtilPkg/SkipWhiteSpace:

Skip White Space
================

:vhdlcode:`SkipWhiteSpace` discards leading whitespace characters by reading them.

.. code-block:: VHDL

   procedure SkipWhiteSpace (
     variable L     : InOut line ;
     variable Empty : out   boolean
   ) ;
   procedure SkipWhiteSpace (variable L : InOut line) ;

.. _UTILITY/TextUtilPkg/EmptyLineChecks:

Empty Line Checks
=================

:vhdlcode:`IsWhiteSpaceOrEmpty` returns :vhdlcode:`Empty` as true if the line is empty or only contains white space. Is
a procedure due to VHDL limitations (before 2019).

.. code-block:: VHDL

   procedure IsWhiteSpaceOrEmpty (
     variable L                : InOut  line ;
     variable Empty            : Out    boolean
   ) ;

:vhdlcode:`EmptyOrCommentLine` indicates whether a line is empty or whether the read process is currently in the middle
of a multiple line comment.

.. code-block:: VHDL

   procedure EmptyOrCommentLine (
     variable L                : InOut  line ;
     variable Empty            : InOut  boolean ;
     variable MultiLineComment : inout  boolean
   ) ;

.. _UTILITY/TextUtilPkg/FindingADelimiter:

Finding a Delimiter
===================

:vhdlcode:`ReadUntilDelimiterOrEOL` reads a :vhdlcode:`Name` until a delimiter or EOL is found.

.. code-block:: VHDL

   procedure ReadUntilDelimiterOrEOL(
     variable L         : InOut line ;
     variable Name      : InOut line ;
     constant Delimiter : In    character ;
     variable ReadValid : Out   boolean
   ) ;

:vhdlcode:`FindDelimiter` reads the next character. If it is the specified delimiter, return :vhdlcode:`Found` as TRUE.
If the delimiter is not SPACE, then :vhdlcode:`SkipWhiteSpace` before searching for the delimiter.

.. code-block:: VHDL

   procedure FindDelimiter(
     variable L                : InOut line ;
     constant Delimiter        : In    character ;
     variable Found            : Out   boolean
   ) ;

.. _UTILITY/TextUtilPkg/ReadHexToken:

ReadHexToken
============

:vhdlcode:`ReadHexToken` reads hex values up to :vhdlcode:`Result'length`. Less is OK. Does not skip white space.

.. code-block:: VHDL

   procedure ReadHexToken (
     variable L      : InOut line ;
     variable Result : Out   std_logic_vector ;
     variable StrLen : Out   integer
   ) ;

.. _UTILITY/TextUtilPkg/ReadBinaryToken:

ReadBinaryToken
===============

:vhdlcode:`ReadBinaryToken` reads binary values up to :vhdlcode:`Result'length`. Less is OK. Does not skip white space.

.. code-block:: VHDL

   procedure ReadBinaryToken (
     variable L      : InOut line ;
     variable Result : Out   std_logic_vector ;
     variable StrLen : Out   integer
   ) ;

.. _UTILITY/TextUtilPkg/SreadC:

Sread_C
=======

:vhdlcode:`Sread_c` is an :vhdlcode:`sread` procedure for Xilinx tools.

.. code-block:: VHDL

   procedure sread_c (
     variable L          : InOut line ;
     variable Name       : Out   string ;
     variable NameLength : Out   integer
   ) ;

.. _UTILITY/TextUtilPkg/CompilingTextUtilPkgAndFriends:

Compiling TextUtilPkg and Friends
*********************************

Compilation order for OSVVM Utility Library is in :file:`CHANGELOG.md` and :file:`osvvm.pro`. To run :file:`osvvm.pro`
see the :ref:`Script User Guide <UG>`.

OSVVM Utility library is released under the Apache open source license. It is free (both to download and use - there are
no license fees). You can download it from osvvm.org or from our development area on GitHub
(https://github.com/OSVVM/OSVVM).

If you add features to the package, please donate them back under the same license as candidates to be added to the
standard version of the package. If you need features, be sure to contact us.

We also support the OSVVM user community and blogs through http://www.osvvm.org. Interested in sharing about your
experience using OSVVM? Let us know, you can blog about it at osvvm.org.

.. _UTILITY/TextUtilPkg/FutureWork:

Future Work
***********

:file:`TextUtilPkg.vhd` is a work in progress and will be updated from time to time.

Caution, undocumented items are experimental and may be removed in a future version.
