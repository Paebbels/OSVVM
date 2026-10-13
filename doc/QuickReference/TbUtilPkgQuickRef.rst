.. _UTILITY/TbUtilPkgQuickRef:

TbUtilPkg Quick Reference
#########################

.. _UTILITY/TbUtilPkgQuickRef/ZeroOneHotOneHot:

ZeroOneHot, OneHot
******************

.. code-block:: VHDL

   signal SA, SB, SC, SD : std_logic;
   signal ZOH, OH : Boolean ;

:vhdlcode:`ZeroOneHot` returns true when the :vhdlcode:`std_logic_vector` input either has a single one or is all zero.

.. code-block:: VHDL

   If ZeroOneHot((SA & SB & SC & SD)) then

:vhdlcode:`OneHot` returns true when the :vhdlcode:`std_logic_vector` input has a single one.

.. code-block:: VHDL

   if OneHot((SA & SB & SC & SD)) then

.. _UTILITY/TbUtilPkgQuickRef/TransactionHandshaking:

Transaction Handshaking
***********************

Used for handshaking between the client side of a transaction interface and the model.

.. _UTILITY/TbUtilPkgQuickRef/RequestTransaction:

RequestTransaction
==================

Request a transaction from the client side (:vhdlcode:`TestCtrl`).

.. code-block:: VHDL

   procedure DoTransaction(
     ModelRec : inout ModelRecType ;
     DataIn   : in DataType
   ) is
   begin
     ModelRec.Data <= DataIn ;
     RequestTransaction(
       Rdy => ModelRec.Rdy,
       Ack => ModelRec.Ack ) ;
   end procedure DoTransaction ;

.. _UTILITY/TbUtilPkgQuickRef/WaitForTransaction:

WaitForTransaction
==================

Model side control to wait for client side (:vhdlcode:`TestCtrl`) to request a transaction

.. code-block:: VHDL

   ExecuteTransProc : process
   begin
     WaitForTransaction(
       Clk => Clk,
       Rdy => ModelRec.Rdy,
       Ack => ModelRec.Ack
     ) ;
     -- decode and execute transaction

.. _UTILITY/TbUtilPkgQuickRef/ProcessToProcessSynchronization:

Process to Process Synchronization
**********************************

One process toggles a signal using the :vhdlcode:`toggle` procedure, the other process waits until the signal changes.

.. _UTILITY/TbUtilPkgQuickRef/Toggle:

Toggle
======

Toggle a signal between 0 and 1. Signal type can be either :vhdlcode:`bit` or :vhdlcode:`std_ulogic`.

.. code-block:: VHDL

   Toggle(Sync1) ;
   Toggle(Sync2, 2*tperiod_Clk);

.. _UTILITY/TbUtilPkgQuickRef/WaitForToggle:

WaitForToggle
=============

Wait until a signal changes. Signal type can be either :vhdlcode:`bit` or :vhdlcode:`std_ulogic`.

.. code-block:: VHDL

   WaitForToggle(Sync1) ;

.. _UTILITY/TbUtilPkgQuickRef/WaitForBarrier:

WaitForBarrier
**************

All processes stop until all processes have reached the barrier and called :vhdlcode:`WaitForBarrier`.

.. code-block:: VHDL

   WaitForBarrier(Sync1) ;
   WaitForBarrier(Sync2, 25 ms) ;

:vhdlcode:`Sync1` may be either :vhdlcode:`std_logic` or :vhdlcode:`BarrierType`.

.. code-block:: VHDL

   signal sync1 : std_logic ;
   signal sync2 : BarrierType;

.. _UTILITY/TbUtilPkgQuickRef/WakeOnBarrier:

WakeOnBarrier
*************

Stop until the barrier is released. Does not put a driver on the barrier signal. Instead waits for all the other
processes to reach the barrier, and then releases one delta cycle before :vhdlcode:`WaitForBarrier`. Allows a VC to
wakeup as the test finishes and post completion status before the test ends.

.. code-block:: VHDL

   WakeOnBarrier(TestDone) ;

.. _UTILITY/TbUtilPkgQuickRef/WaitingForClock:

Waiting for Clock
*****************

Wait for clock periods specified in either time units or an integral number of clock cycles. Is aligned to clock when
it finishes.

.. code-block:: VHDL

   WaitForClock(Clk, 5 * Tperiod_Clk);
   WaitForClock(Clk, 5) ;

.. _UTILITY/TbUtilPkgQuickRef/WaitForLevel:

Wait for Level
**************

Wait until a signal is at a level.

.. code-block:: VHDL

   WaitForLevel(A, '1') ; -- A='1'
   WaitForLevel(Bool) ;   -- TRUE
