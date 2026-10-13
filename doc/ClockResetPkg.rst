.. _UTILITY/ClockResetPkg:

ClockResetPkg
#############

.. _UTILITY/ClockResetPkg/ClockResetPkgOverview:

ClockResetPkg Overview
**********************

:vhdlcode:`ClockResetPkg` provides testbench utilities for creating clock and reset.

.. _UTILITY/ClockResetPkg/CreateClock:

CreateClock
***********

Create a clock with a specified period and specified duty cycle. :vhdlcode:`ClkActive` is the active edge value.
:vhdlcode:`Offset` is the delay from time 0 at which the active edge value happens. Designed so that after the first
clock transition that Clock always transitions on delta cycle 0. Designed so that the resulting clock period will match
the :vhdlcode:`Period` parameter and that any rounding due to :vhdlcode:`DutyCycle` and simulator resolution will only
impact the effective :vhdlcode:`DutyCycle`.

.. code-block:: VHDL

   procedure CreateClock (
     signal   Clk             : inout std_logic ;
     constant Period          : in    time ;
     constant DutyCycle       : in    real := 0.5 ;
     constant Offset          : in    time := 0 sec ;
     constant ClkActive       : in    std_logic := CLK_ACTIVE
   ) ;

   procedure CreateClock (
     signal   Clk             : inout std_logic ;
     signal   Enable          : in    boolean ;
     constant Period          : in    time ;
     constant DutyCycle       : in    real := 0.5 ;
     constant Offset          : in    time := 0 sec ;
     constant ClkActive       : in    std_logic := CLK_ACTIVE
   ) ;

.. _UTILITY/ClockResetPkg/CreateJitterClock:

CreateJitterClock
*****************

Create a clock in a similar fashion to :vhdlcode:`CreateClock`, but have a 10% jitter in the clock period. The Jitter is
controlled by :vhdlcode:`CoverID` and the bins in :vhdlcode:`CoverID` can be changed after time 0 sim cycle 1.

.. code-block:: VHDL

   procedure CreateJitterClock (
     signal   Clk             : inout std_logic ;
     signal   CoverID         : inout CoverageIdType ;
     constant Name            : in    string ;
     constant Period          : in    time ;
     constant DutyCycle       : in    real := 0.5 ;
     constant Offset          : in    time := 0 sec ;
     constant ClkActive       : in    std_logic := CLK_ACTIVE
   ) ;

.. _UTILITY/ClockResetPkg/CreatingReset:

Creating Reset
**************

Create reset that is asserted :vhdlcode:`tpd` after the first active edge of clock and deasserts :vhdlcode:`tpd` after
the clock edge that is :vhdlcode:`Period` in time from the first active edge of clock. :vhdlcode:`ClkActive` is the
active edge value – its default is '1' (rising edge).

.. code-block:: VHDL

   procedure CreateReset (
     signal   Reset       : out std_logic ;
     constant ResetActive : in  std_logic ;
     signal   Clk         : in  std_logic ;
     constant Period      :     time ;
     constant tpd         :     time ;
     constant ClkActive   : in  std_logic := CLK_ACTIVE
   ) is   . . .

.. _UTILITY/ClockResetPkg/CheckingTheClockPeriod:

Checking the Clock Period
*************************

The procedure :vhdlcode:`CheckClockPeriod` checks that the clock period matches the :vhdlcode:`Period` parameter. It
checks the first :vhdlcode:`HowMany` clocks.

.. code-block:: VHDL

   procedure CheckClockPeriod (
       constant AlertLogID : in  AlertLogIDType ;
       signal   Clk        : in  std_logic ;
       constant Period     : in  time ;
       constant ClkName    : in  string := "Clock" ;
       constant HowMany    : in  integer := 5 ;
       constant ClkActive  : in  std_logic := CLK_ACTIVE
     ) ;

     procedure CheckClockPeriod (
       signal   Clk        : in  std_logic ;
       constant Period     : in  time ;
       constant ClkName    : in  string := "Clock" ;
       constant HowMany    : in  integer := 5 ;
       constant ClkActive  : in  std_logic := CLK_ACTIVE
     ) ;

.. _UTILITY/ClockResetPkg/CheckingTheReset:

Checking the Reset
******************

:vhdlcode:`LogReset` creates logs when the :vhdlcode:`Reset` signal changes.

.. code-block:: VHDL

   procedure LogReset (
     constant AlertLogID  : in  AlertLogIDType ;
     signal   Reset       : in  std_logic ;
     constant ResetActive : in  std_logic ;
     constant ResetName   : in  string := "Reset" ;
     constant LogLevel    : in  LogType := ALWAYS
   ) ;

   procedure LogReset (
     signal   Reset       : in  std_logic ;
     constant ResetActive : in  std_logic ;
     constant ResetName   : in  string := "Reset" ;
     constant LogLevel    : in  LogType := ALWAYS
   ) ;

.. _UTILITY/ClockResetPkg/CompilingAndUsingOSVVMUtilityLibrary:

Compiling and Using OSVVM Utility Library
*****************************************

Reference all packages in the OSVVM Utility library by using the context declaration:

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;

Compilation order for OSVVM Utility Library is in :osvvmdoc:`OSVVM_release_notes.pdf <osvvm_release_notes>`. Rather than
learning this, we recommend using the OSVVM compilation scripts.

OSVVM Utility library is released under the Apache open source license. It is free (both to download and use - there are
no license fees). You can download it from osvvm.org or from our development area on GitHub
(https://github.com/OSVVM/OSVVM).

If you add features to the package, please donate them back under the same license as candidates to be added to the
standard version of the package. If you need features, be sure to contact us.

We also support the OSVVM user community and blogs through http://www.osvvm.org. Interested in sharing about your
experience using OSVVM? Let us know, you can blog about it at osvvm.org.
