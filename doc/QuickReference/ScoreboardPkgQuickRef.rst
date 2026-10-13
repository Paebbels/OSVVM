.. _UTILITY/ScoreboardPkgQuickRef:

ScoreboardPkg Quick Reference
#############################

.. _UTILITY/ScoreboardPkgQuickRef/GenericPackageInterface:

Generic Package Interface
*************************

.. code-block:: VHDL

   package ScoreboardGenericPkg is
   generic (
     type ExpectedType ;
     type ActualType ;
     function Match(Actual : ActualType ;
        Expected : ExpectedType)
        return boolean ;
     function expected_to_string(
        A : ExpectedType) return string ;
     function actual_to_string(
        A : ActualType) return string
   ) ;

:vhdlcode:`ExpectedType` is the input to the scoreboard. :vhdlcode:`ActualType` is the value to be checked against the
oldest :vhdlcode:`ExpectedType` value. :vhdlcode:`ExpectedType` and :vhdlcode:`ActualType` may be the same type.
:vhdlcode:`Match` is a function that compares :vhdlcode:`ExpectedType` with :vhdlcode:`ActualType`. :vhdlcode:`Match` is
often mapped to "=". :vhdlcode:`expected_to_string` converts :vhdlcode:`ExpectedType` to a string value (for reports).
:vhdlcode:`actual_to_string` converts :vhdlcode:`ActualType` to a string.

.. _UTILITY/ScoreboardPkgQuickRef/PackageInstance:

Package Instance
****************

.. code-block:: VHDL

   library ieee ;
     use ieee.std_logic_1164.all ;
     use ieee.numeric_std.all ;

   package ScoreboardPkg_slv is new
   work.ScoreboardGenericPkg
     generic map (
       ExpectedType => std_logic_vector,
       ActualType   => std_logic_vector,
       Match               => std_match,
       expected_to_string  => to_hstring,
       actual_to_string    => to_hstring
   ) ;

Note, that :vhdlcode:`ExpectedType` and :vhdlcode:`ActualType` do not need to be constrained types.

.. _UTILITY/ScoreboardPkgQuickRef/CompatibilityPackage:

Compatibility Package
*********************

:file:`ScoreboardPkg_slv_c.vhd` contains equivalent subtypes and aliases to work like the above package instance.

.. _UTILITY/ScoreboardPkgQuickRef/BasicOperations:

Basic Operations
****************

.. _UTILITY/ScoreboardPkgQuickRef/CreateAScoreboardID:

Create a ScoreboardID
=====================

A Scoreboard ID is a handle to the scoreboard object that is created internal to an instance of
:vhdlcode:`ScoreboardGenericPkg`.

.. code-block:: VHDL

   signal SB : ScoreboardIDType ;

If using more than one scoreboard package instance, disambiguate the type using a fully selected name.

.. code-block:: VHDL

   signal SB_int :
    work.ScoreboardPkg_int.ScoreboardIDType;

.. _UTILITY/ScoreboardPkgQuickRef/ConstructTheScoreboard:

Construct the Scoreboard
========================

:vhdlcode:`NewID` allocates and initializes the scoreboard data structure. It must be called before any other scoreboard
operations are used.

.. code-block:: VHDL

   SB <= NewID("UART_SB") ;

.. _UTILITY/ScoreboardPkgQuickRef/Push:

Push
====

Add expected value (:vhdlcode:`ExpectedType`) to the scoreboard.

.. code-block:: VHDL

   Push(SB, ExpectedVal) ;

.. _UTILITY/ScoreboardPkgQuickRef/Check:

Check
=====

Check a received value (:vhdlcode:`ActualType`) with value in scoreboard. Reports PASSED/ERROR via :vhdlcode:`AffirmIf`.

.. code-block:: VHDL

   Check(SB, ReceiveVal) ;

.. _UTILITY/ScoreboardPkgQuickRef/Pop:

Pop
===

Get oldest value from FIFO and remove it. Uses an out mode variable parameter of :vhdlcode:`ExpectedType`.

.. code-block:: VHDL

   Pop(SB, FifoVal) ;

Can also be called as a function:

.. code-block:: VHDL

   FifoVal := Pop(SB) ;

.. _UTILITY/ScoreboardPkgQuickRef/Peek:

Peek
====

Get oldest value from FIFO, but do not remove it. Uses an out mode variable parameter of :vhdlcode:`ExpectedType`.

.. code-block:: VHDL

   Peek(SB, FifoVal) ;

Can also be called as a function:

.. code-block:: VHDL

   FifoVal := Peek(SB) ;

.. _UTILITY/ScoreboardPkgQuickRef/GetAlertLogID:

GetAlertLogID
=============

Get the :vhdlcode:`AlertLogID` from the scoreboard internals.

.. code-block:: VHDL

   SB_ID := GetAlertLogID(SB) ;

.. _UTILITY/ScoreboardPkgQuickRef/Empty:

Empty
=====

Check if the Scoreboard is empty.

.. code-block:: VHDL
   :force:

   if not Empty(SB) then …

.. _UTILITY/ScoreboardPkgQuickRef/GetttingErrorCounts:

Getting Error Counts
====================

Errors are recorded in the :vhdlcode:`AlertLog` data structure. Retrieve the error count using the
:vhdlcode:`AlertLogID`:

.. code-block:: VHDL

   Err := GetAlertCount(GetAlertLogID(SB));

.. _UTILITY/ScoreboardPkgQuickRef/Find:

Find
====

Return the :vhdlcode:`ItemNumber` of the oldest expected value that matches the received value. :vhdlcode:`Find` +
:vhdlcode:`Flush` support systems that drop items before they are synchronized.

.. code-block:: VHDL

   ItemNum := Find(SB, ReceiveVal) ;

.. _UTILITY/ScoreboardPkgQuickRef/Flush:

Flush
=====

Quietly drop all values whose item number is less than the specified item number. :vhdlcode:`Find` + :vhdlcode:`Flush`
support systems that drop items before they are synchronized.

.. code-block:: VHDL

   Flush(SB, ItemNum) ;

.. _UTILITY/ScoreboardPkgQuickRef/GetPushCount:

GetPushCount
============

Get number of items pushed into the scoreboard.

.. code-block:: VHDL
   :force:

   print("…" & to_string(GetItemCount(SB)));

.. _UTILITY/ScoreboardPkgQuickRef/GetCheckCount:

GetCheckCount
=============

Get number of items checked by the scoreboard.

.. code-block:: VHDL

   print(to_string(GetCheckCount(SB)));

.. _UTILITY/ScoreboardPkgQuickRef/GetPopCount:

GetPopCount
===========

Get number of items popped out of the scoreboard.

.. code-block:: VHDL
   :force:

   print("…" & to_string(GetPopCount(SB)));

.. _UTILITY/ScoreboardPkgQuickRef/GetDropCount:

GetDropCount
============

Get number of items dropped by the scoreboard.

.. code-block:: VHDL
   :force:

   print("…" & to_string(GetDropCount(SB)));

.. _UTILITY/ScoreboardPkgQuickRef/GetFifoCount:

GetFifoCount
============

Get number of items in the FIFO inside the scoreboard.

.. code-block:: VHDL
   :force:

   print("…" & to_string(GetFifoCount(SB)));

.. _UTILITY/ScoreboardPkgQuickRef/TaggedScoreboards:

Tagged Scoreboards
******************

Tagged Scoreboards are used for systems that allow transactions to execute out of order.

Tags are represented as string values (since most types convert to string using :vhdlcode:`to_string`). A tag value is
specified as the first value in the calls to push, check, and pop, such as shown below. In all examples,
:vhdlcode:`ExpectedVal` has the type :vhdlcode:`ExpectedType`, and :vhdlcode:`ReceiveVal` has the type
:vhdlcode:`ActualType`.

.. code-block:: VHDL
   :force:

   Push(SB, "WriteOp", ExpectedVal) ;
   Check(SB, "WriteOp", ReceiveVal) ;
   Pop(SB, "WriteOp", ExpectedVal) ;

   if Empty(SB, "MyTag")  then   …

For :vhdlcode:`Check` (and :vhdlcode:`Pop`), the item checked (or returned) is the oldest item with the matching tag.

.. code-block:: VHDL

   ItemNum := Find(SB, "ReadOp", ReceiveVal);
   Flush(SB, "ReadOp", ItemNum) ;

For :vhdlcode:`Flush`, only items matching the tag are removed. In some systems, it may be appropriate to do the
:vhdlcode:`Find` with the tag and the flush without the tag.

.. _UTILITY/ScoreboardPkgQuickRef/IndexedScoreboards:

Indexed Scoreboards
*******************

Indexed scoreboards are for systems, such as a network switch that have multiple scoreboards that are most conveniently
represented as an array.

:vhdlcode:`ScoreboardIDType` is an ordinary type, so normal VHDL methods can be used to create arrays of it.

.. _UTILITY/ScoreboardPkgQuickRef/1DAnd2DArrayTypes:

1D and 2D Array Types
=====================

:vhdlcode:`ScoreboardGenericPkg` defines the following types:

.. code-block:: VHDL

   -- 1D array type
   type ScoreboardIdArrayType  is array (integer
   range <>) of ScoreboardIdType ;

   -- 2D array type
   type ScoreboardIdMatrixType is array (integer
   range <>, integer range <>)
       of ScoreboardIdType ;

.. _UTILITY/ScoreboardPkgQuickRef/1DArraysOfScoreboards:

1D Arrays of Scoreboards
========================

The following operations are appropriate for any array of scoreboards. Procedures and functions not documented here are
from :vhdlcode:`AlertLogPkg`.

.. code-block:: VHDL

   signal SB :
     ScoreboardIDArrayType(1 to 3);
   . . .

   -- Create 3 indexed scoreboards
   SB <= NewID("SB", 3);
   wait for 0 ns ;

   -- Push values into scoreboards
   Push(SB(1), X"11") ;
   Push(SB(2), X"2222") ;
   Push(SB(3), X"3") ;

   -- Check values using scoreboards
   Check(SB(3), X"3") ;
   Check(SB(2), X"2222") ;
   Check(SB(1), X"01") ;

   -- Includes Scoreboard errors
   ReportAlerts ;

.. _UTILITY/ScoreboardPkgQuickRef/1DArraysOfScoreboardsAgain:

1D Arrays of Scoreboards Again
==============================

The previous example used a simple form of :vhdlcode:`NewID` since the left array index is 1. If it is not 1, such as
below, the second form of :vhdlcode:`NewID` is needed. This is shown below.

.. code-block:: VHDL

   signal SB :
     ScoreboardIDArrayType(5 to 7);
   . . .

   SB <= NewID("SB", (5, 7));

.. _UTILITY/ScoreboardPkgQuickRef/2DArraysOfScoreboards:

2D Arrays of Scoreboards
========================

The following demonstrates the creation of 2D arrays of scoreboards. Note in :vhdlcode:`SB1`, the left array indices are
1 and a simpler form of :vhdlcode:`NewID` can be used.

.. code-block:: VHDL

   signal SB1 :
     ScoreboardIdMatrixType(1 to 3, 1 to 5);
   signal SB2 :
     ScoreboardIdMatrixType(1 to 3, 5 to 7);. . .

   SB1 <= NewID("SB1", 3, 5 );
   SB2 <= NewID("SB", (1, 3), (5,7) );
