.. _UTILITY/TbUtilPkg:

TbUtilPkg
#########

.. _UTILITY/TbUtilPkg/TbUtilPkgOverview:

TbUtilPkg Overview
******************

:vhdlcode:`TbUtilPkg` provides testbench utilities including synchronization utilities, tests for mutual exclusion,
clock creation and reset creation.

.. _UTILITY/TbUtilPkg/TestingForMutualExclusion:

Testing for Mutual Exclusion
****************************

.. _UTILITY/TbUtilPkg/OneHot:

OneHot
======

Function :vhdlcode:`OneHot` returns true when exactly one of its inputs is a one.

.. code-block:: VHDL

   function OneHot ( constant A : in std_logic_vector ) return boolean ;
   . . .
   AffirmIf(OneHot( (Sel1 & Sel2 & Sel3 & Sel4) ), . . .) ;
   . . .

.. _UTILITY/TbUtilPkg/ZeroOneHot:

ZeroOneHot
==========

Function :vhdlcode:`ZeroOneHot` returns true when either exactly one of its inputs is a one or they are all zero.

.. code-block:: VHDL

   function ZeroOneHot ( constant A : in std_logic_vector ) return boolean ;
   . . .
   AffirmIf(ZeroOneHot( (Sel1 & Sel2 & Sel3 & Sel4) ), . . .) ;
   . . .

.. _UTILITY/TbUtilPkg/VerificationComponentHandshakingForTransactionInitiation:

Verification Component Handshaking for Transaction Initiation
*************************************************************

.. _UTILITY/TbUtilPkg/RdyTypeAndAckType:

RdyType and AckType
===================

The primary types for transaction handshaking are:

.. code-block:: VHDL

   subtype RdyType is resolved_max integer range  0 to integer'high ;
   subtype AckType is resolved_max integer range -1 to integer'high ;

.. _UTILITY/TbUtilPkg/RequestTransaction:

RequestTransaction
==================

Requests a transaction from the test initiation (client) to the model (TLM or VVC).

.. code-block:: VHDL

   procedure RequestTransaction (
       signal Rdy  : Out RdyType ;
       signal Ack  : In  AckType
   ) ;
   . . .
   procedure DoTransaction( TransRec : inout TransRecType ; Parm1 : . . . ) is
   begin
     TransRec.InField1 <= Parm1 ;
     . . .
     RequestTransaction(Rdy => TransRec.Rdy, Ack => TransRec.Ack) ;
     Result1 <= TransRec.OutField1 ;
     . . .

.. _UTILITY/TbUtilPkg/WaitForTransaction:

WaitForTransaction
==================

Suspends a model until a transaction is requested via :vhdlcode:`RequestTransaction`.

.. code-block:: VHDL

     procedure WaitForTransaction (
       signal Clk  : In  std_logic ;
       signal Rdy  : In  RdyType;
       signal Ack  : Out AckType
     ) ;
   . . .
   entity Model is
     Port (
       -- Transaction connection
       TransRec : inout TransRecType ;

       -- DUT signaling interface
       . . .
     ) ;
   end entity model ;
   architecture behavior of Model is
   begin
     ModelBehavior : process
     begin
       WaitForTransaction (
          Clk  => ModelClk,
          Rdy  => TransRec.Rdy,
          Ack  => TransRec.Ack
       ) ;
       case TransRec.Operation is
         when CPU_WRITE =>
            -- do CPU Write signaling
            . . .
         when CPU_READ =>
            -- do CPU Read signaling
            . . .
         . . .
         when others =>
           Alert(ModelAlertLogID, "Unrecognized operation", FAILURE) ;
           Wait for 0 ns ;
       end case ;
     end process ModelBehavior ;

.. _UTILITY/TbUtilPkg/OverloadedVersionsOfRequestTransactionAndWaitForTransaction:

Overloaded versions of RequestTransaction and WaitForTransaction
================================================================

Overloading of :vhdlcode:`RequestTransaction` and :vhdlcode:`WaitForTransaction` also supports :vhdlcode:`std_logic` or
:vhdlcode:`bit` in place of both :vhdlcode:`RdyType` and :vhdlcode:`AckType`.

.. _UTILITY/TbUtilPkg/ToggleHandshaking:

Toggle Handshaking
******************

Toggle type handshaking is used to block one process until another process has signaled it to continue.

.. _UTILITY/TbUtilPkg/WaitForToggle:

WaitForToggle
=============

:vhdlcode:`WaitForToggle` blocks until its input signal changes. The call to :vhdlcode:`WaitForToggle` must occur before
input changes or the change will not be seen.

.. code-block:: VHDL

   procedure WaitForToggle ( signal Sig : In integer ) ;
   procedure WaitForToggle ( signal Sig : In bit ) ;
   procedure WaitForToggle ( signal Sig : In std_logic ) ;

Internally :vhdlcode:`WaitForToggle` abstracts a call to "wait on".

.. _UTILITY/TbUtilPkg/Toggle:

Toggle
======

:vhdlcode:`Toggle` causes a signal to change either after a delta cycle or a specified amount of time.

.. code-block:: VHDL

   procedure Toggle(signal Sig : InOut std_logic ; constant DelayVal : delay_length);
   procedure Toggle(signal Sig : InOut std_logic ) ;
   procedure Toggle(signal Sig : InOut bit ; constant DelayVal : delay_length) ;
   procedure Toggle(signal Sig : InOut bit ) ;

Internally :vhdlcode:`Toggle` abstracts an assignment to :vhdlcode:`Sig`.

.. _UTILITY/TbUtilPkg/Increment:

Increment
=========

:vhdlcode:`Increment` adds 1 to the integer signal.

.. code-block:: VHDL

   procedure Increment (
     signal Sig             : InOut integer ;
     constant RollOverValue : in integer := 0) ;

.. _UTILITY/TbUtilPkg/UsageOfIncrementAndWaitForToggle:

Usage of Increment and WaitForToggle
====================================

Using FIFOs to communicate requires an event. OSVVM FIFOs do not generate events. Instead, :vhdlcode:`Increment` and
:vhdlcode:`WaitForToggle` are used. This is shown below.

.. code-block:: VHDL

   TransactionDispatcher : process
   Begin
      . . .
      Push(FIFO, TransRec.Data) ;
      Increment(RequestCount) ;
      . . .

   DataHandler : process
     variable Data : std_logic_vector(15 downto 0) ;
   begin
     if IsEmpty(FIFO) then
       WaitForToggle(RequestCount) ;
     end if ;
     Data := Pop(FIFO) ;
     . . .

.. _UTILITY/TbUtilPkg/BarrierSynchronization:

Barrier Synchronization
***********************

Barrier synchronization allows two or more processes to stop until all have arrived at a designated synchronization
point.

.. _UTILITY/TbUtilPkg/WaitForBarrier:

WaitForBarrier
==============

:vhdlcode:`WaitForBarrier` causes a process to stop until all processes that call :vhdlcode:`WaitForBarrier` with that
signal have reached the same point.

.. code-block:: VHDL

   procedure WaitForBarrier (signal Sig : InOut BarrierType) ;
   procedure WaitForBarrier (
     signal   Sig     : InOut BarrierType;
     constant TimeOut : delay_length) ;
   procedure WaitForBarrier (signal Sig : InOut std_logic ) ;
   procedure WaitForBarrier (
     signal   Sig     : InOut std_logic;
     constant TimeOut : delay_length);

.. _UTILITY/TbUtilPkg/WakeOnBarrier:

WakeOnBarrier
=============

Stop until the barrier is released. Does not put a driver on the barrier signal. Instead waits for all the other
processes to reach the barrier, and then releases one delta cycle before :vhdlcode:`WaitForBarrier`. Allows a VC to
wakeup one cycle before the test finishes and post completion status before the test ends.

.. code-block:: VHDL

   WakeOnBarrier(TestDone) ;

.. _UTILITY/TbUtilPkg/TypesAndResolutionFunctions:

Types and resolution functions
==============================

The type :vhdlcode:`BarrierType` is designed to simplify barrier synchronization.

.. code-block:: VHDL

   function resolved_barrier ( s : integer_vector ) return integer ;
   subtype  BarrierType is resolved_barrier integer range
       integer'low+1 to integer'high ;

The range on :vhdlcode:`BarrierType` is only needed to work around bugs in Xilinx XSim.

.. _UTILITY/TbUtilPkg/Declarations:

Declarations
============

Usage of integer barriers requires usage of :vhdlcode:`resolved_barrier`. Usage of :vhdlcode:`BarrierType` is
recommended.

.. code-block:: VHDL

   signal TestDone : BarrierType ;                    -- Preferred
   signal Sync1    : resolved_barrier integer := 1 ;  -- Supported

With :vhdlcode:`std_logic`, initialization to '0' is preferred, but not required. Do not initialize to 'H'.

.. code-block:: VHDL

   signal Sync2 : std_logic := '0' ; -- Initialization preferred

.. _UTILITY/TbUtilPkg/Usage:

Usage
=====

.. code-block:: VHDL

   ControlProc : process
   begin
     -- initialize test
     SetTestName("Uart1_Rx") ;
     . . .
     WaitForBarrier(TestDone, 5 ms) ; -- control process uses timeout
     AlertIf(now >= 5 ms, "Test finished due to Time Out") ;
     ReportAlerts ;
     Std.env.stop ;
   End process ControlProc ;

   CpuProc : process
   begin
      InitDut(. . . ) ;
      Toggle(CpuReady) ;
      -- run numerous Cpu test transactions
      . . .
      WaitForBarrier(TestDone) ;
      wait ;
   end process CpuProc ;

   UartTxProc : process
   Begin
     WaitForToggle(CpuReady) ;
      -- run numerous Uart Transmit test transactions
      . . .
      WaitForBarrier(TestDone) ;
      wait ;
   end process UartTxProc ;
   . . .

.. _UTILITY/TbUtilPkg/PredefinedOSVVMBarriers:

Predefined OSVVM Barriers
=========================

:vhdlcode:`TbUtilPkg` provides the following predefined barrier signals.

.. code-block:: VHDL

   type PredefinedBarrierType is record
     ResetStarted   : BarrierType ;
     ResetDone      : BarrierType ;
     TestInit       : BarrierType ;
     TestDone       : BarrierType ;
     VcInit         : BarrierType ;
   end record PredefinedBarrierType ;
   signal Barrier : PredefinedBarrierType ;

   alias OsvvmResetStarted  : BarrierType is Barrier.ResetStarted ;
   alias OsvvmResetDone     : BarrierType is Barrier.ResetDone ;
   alias OsvvmTestInit      : BarrierType is Barrier.TestInit ;
   alias OsvvmTestDone      : BarrierType is Barrier.TestDone ;
   alias TestDone           : BarrierType is Barrier.TestDone ;
   alias OsvvmVcInit        : BarrierType is Barrier.VcInit ;

.. _UTILITY/TbUtilPkg/FindingClockChanging:

Finding Clock Changing
**********************

:vhdlcode:`EdgeRose` checks if the signal rose during this time step. :vhdlcode:`EdgeFell` checks if the signal fell
during this time step. :vhdlcode:`EdgeActive` checks if the signal changed to the value specified by :vhdlcode:`A` in
this time step.

.. code-block:: VHDL

   function  EdgeRose ( signal C : in std_logic ) return boolean ;
   function  EdgeFell ( signal C : in std_logic ) return boolean ;
   function  EdgeActive ( signal C : in std_logic; A : std_logic ) return boolean ;
   function  ChangingEdge ( signal C : in std_logic; A : std_logic ) return boolean ;
   alias changing_edge is ChangingEdge [std_logic, std_logic return boolean] ;

:vhdlcode:`EdgeRose` is similar to :vhdlcode:`rising_edge` except :vhdlcode:`EdgeRose` checks if clock changed on a time
step (by checking :vhdlcode:`C'last_event=0 sec`), whereas, :vhdlcode:`rising_edge` checks if a clock changed during
this delta cycle (by checking :vhdlcode:`C'event`). :vhdlcode:`EdgeRose` does the following check.

.. code-block:: VHDL

   to_x01(C)='1' and to_x01(C'last_value)='0' and C'last_event= 0 sec

.. _UTILITY/TbUtilPkg/WaitingForClock:

Waiting for Clock
*****************

Wait for the number of clocks specified in either time or an integer number of clock cycles. Active edge of clock is
defined by the :vhdlcode:`ClkActive` parameter (which is set to '1').

.. code-block:: VHDL

   procedure WaitForClock (
     signal Clk              : in std_logic ;
     constant Delay          : in delay_length ;
     constant ClkActive      : in std_logic := CLK_ACTIVE) ;
   procedure WaitForClock (
     signal Clk              : in std_logic ;
     constant NumberOfClocks : in natural := 1 ;
     constant ClkActive      : in std_logic := CLK_ACTIVE) ;
   procedure WaitForClock (
     signal Clk            : in std_logic ;
     signal Enable         : in boolean ;
     constant ClkActive    : in std_logic := CLK_ACTIVE) ;
   procedure WaitForClock (
     signal Clk            : in std_logic ;
     signal Enable         : in std_logic ;
     constant EnableActive : std_logic := '1' ;
     constant ClkActive    : in std_logic := CLK_ACTIVE) ;

.. _UTILITY/TbUtilPkg/WaitingForLevel:

Waiting For Level
*****************

Wait for a signal to become a level.

.. code-block:: VHDL

   procedure WaitForLevel ( signal A : boolean ) ;
   procedure WaitForLevel ( signal A : std_logic ; Level : std_logic := '1' ) ;

   procedure WaitForLevel (
     signal   A       : in boolean;
     constant TimeOut : delay_length);
   procedure WaitForLevel (
     signal   A       : in std_logic;
     constant TimeOut : delay_length;
     constant Level   : std_logic := '1');

   procedure WaitForLevel (
     signal   A              : in boolean;
     constant TimeOut        : delay_length;
     variable TimeOutReached : out boolean);
   procedure WaitForLevel (
     signal   A              : in std_logic;
     constant TimeOut        : delay_length;
     variable TimeOutReached : out boolean;
     constant Level          : std_logic := '1');

.. _UTILITY/TbUtilPkg/CreateClockAndCreateResetMovedToClockResetPkg:

CreateClock and CreateReset Moved to ClockResetPkg
**************************************************

:vhdlcode:`CreateClock` and :vhdlcode:`CreateReset` were moved to :vhdlcode:`ClockResetPkg`.

.. _UTILITY/TbUtilPkg/CompilingAndUsingOSVVMUtilityLibrary:

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
