.. _UTILITY/DelayCoveragePkg:

DelayCoveragePkg
################

.. _UTILITY/DelayCoveragePkg/Overview:

Overview
********

:vhdlcode:`DelayCoveragePkg` implements a pattern for randomizing cycle-based delays such as AXI’s Valid and Ready
signals.

Cycle based delays may be a delay between each word sent, or they may be burst like and transfer a burst of values
followed by a delay between the bursts (a burst delay). During a burst of values, there may be delay between each value
transmitted (a beat delay).

To address this, :vhdlcode:`DelayCoveragePkg` implements a singleton that has three coverage models. A separate coverage
model is used to randomize the burst length, burst delay, and beat delay. This supports complex as well as simple use
models. For example, if we want a beat delay of 0, then we tell it to select a value between 0 and 0.

For the first release, the documentation is terse. Suggestions and clarifications are welcome.

.. _UTILITY/DelayCoveragePkg/PackageInterface:

Package Interface
*****************

The interface to the package is as follows.

.. code-block:: VHDL

   package DelayCoveragePkg is

     type DelayCoverageIDType is record
         ID             : integer_max ;
         BurstLengthCov : CoverageIDType ;
         BurstDelayCov  : CoverageIDType ;
         BeatDelayCov   : CoverageIDType ;
     end record DelayCoverageIDType ;

     type DelayCoverageIDArrayType is array (integer range <>) of DelayCoverageIDType ;

     ------------------------------------------------------------
     impure function NewID (
       Name                : String ;
       ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
       ReportMode          : AlertLogReportModeType  := DISABLED ;
       Search              : NameSearchType          := PRIVATE_NAME ;
       PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
     ) return DelayCoverageIDType ;

     ------------------------------------------------------------
     impure function NewDelayCoverage (
       ID                  : Integer ;
       Name                : String ;
       ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
       ReportMode          : AlertLogReportModeType  := DISABLED ;
       Search              : NameSearchType          := PRIVATE_NAME ;
       PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
     ) return DelayCoverageIDType ;

     ------------------------------------------------------------
     impure function IsInitialized (ID : DelayCoverageIDType) return boolean ;

     impure function GetDelayCoverage(ID : integer) return DelayCoverageIDType ;
     procedure SetDelayCoverage ( ID : DelayCoverageIDType ) ;
     procedure SetBurstLength ( ID : DelayCoverageIDType ; BurstLength : integer ) ;
     impure function GetBurstLength ( ID : DelayCoverageIDType ) return integer ;

     ------------------------------------------------------------
     impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer ;
     impure function GetRandDelay ( ID : DelayCoverageIDType ) return integer_vector ;

     ------------------------------------------------------------
     procedure DeallocateBins ( ID : DelayCoverageIDType ) ;

   end package DelayCoveragePkg ;

The pattern used here is slightly different from other OSVVM singletons in that the :vhdlcode:`DelayCoverageIDType` has
the ID as well as the IDs for the coverage models.

.. _UTILITY/DelayCoveragePkg/UsageInAVerificationComponent:

Usage in a Verification Component
*********************************

:vhdlcode:`DelayCoveragePkg` is being used by the OSVVM :vhdlcode:`AxiStreamTransmitter` and
:vhdlcode:`AxiStreamReceiver`.

Step 1, declare an object of :vhdlcode:`DelayCoverageIDType`. The AxiStream VC needs an object with global scope, so a
signal is used.

.. code-block:: VHDL

   signal BurstCov : DelayCoverageIDType ;

Step 2, construct the data structure. The :vhdlcode:`wait for 0` is necessary since :vhdlcode:`ModelID` is constructed
at time 0 and is not available immediately. This is done in :vhdlcode:`TransactionDispatcher` process since there are
API commands that also update the :vhdlcode:`BurstCov` signal.

.. code-block:: VHDL

   TransactionDispatcher : process
     . . .
   begin
     wait for 0 ns ;
     BurstCov <= NewID("DelayCov", ModelID, ReportMode => DISABLED,
                        Search => NAME_AND_PARENT) ;

Step 3, implement the API in :vhdlcode:`TransactionDispatcher`.

.. code-block:: VHDL

   case TransRec.Operation is
     . . .

     when SET_USE_RANDOM_DELAYS =>
       UseCoverageDelays      <= TransRec.BoolToModel ;

     when GET_USE_RANDOM_DELAYS =>
       TransRec.BoolFromModel <= UseCoverageDelays ;

     when SET_DELAYCOV_ID =>
       BurstCov          <= GetDelayCoverage(TransRec.IntToModel) ;
       UseCoverageDelays <= TRUE ;

     when GET_DELAYCOV_ID =>
       TransRec.IntFromModel <= BurstCov.ID ;
       UseCoverageDelays <= TRUE ;

Step 4, set default values for the coverage models.

.. code-block:: VHDL

   TransmitHandler : process
     . . .
   begin
     . . .
     wait for 0 ns ; -- Allow Cov models to initialize
     wait for 0 ns ; -- Allow Cov models to initialize
     -- BurstLength - once per BurstLength, use BurstDelay, otherwise use BeatDelay
     AddBins (BurstCov.BurstLengthCov,  80, GenBin(3,11,1)) ;    -- 80% Small Burst Len
     AddBins (BurstCov.BurstLengthCov,  20, GenBin(109,131,1));  -- 20% Large Burst Len
     -- BurstDelay - happens at BurstLength boundaries
     AddBins (BurstCov.BurstDelayCov,   80, GenBin(2,8,1)) ;   -- 80% Small delay
     AddBins (BurstCov.BurstDelayCov,   20, GenBin(108,156,1)) ; -- 20% Large delay
     -- BeatDelay - happens between each transfer if not at a BurstLength boundary
     -- These are all small
     AddBins (BurstCov.BeatDelayCov,    85, GenBin(0)) ;       -- 85% 0 delay
     AddBins (BurstCov.BeatDelayCov,    10, GenBin(1)) ;       -- 10% 1 delay
     AddBins (BurstCov.BeatDelayCov,     5, GenBin(2)) ;       --  5% 2 delay

Step 5, wait for the delay cycles.

.. code-block:: VHDL

   DelayCycles := GetRandDelay(BurstCov) ;
   WaitForClock(Clk, DelayCycles) ;

Note that whether :vhdlcode:`AddBins` or :vhdlcode:`AddCross` is used is up to the VC. :vhdlcode:`AxiStreamReceiver`
uses :vhdlcode:`AddCross` for :vhdlcode:`BurstDelayCov` and :vhdlcode:`BeatDelayCov` to also randomize the Ready Before
Valid control (0 = Ready Before Valid). To see the differences explore the code of :vhdlcode:`AxiStreamReceiver`.

Usage of Delay Coverage in an interface like

.. _UTILITY/DelayCoveragePkg/UsageInATestCase:

Usage in a test case
********************

:file:`TbStream_SendGetRandom1.vhd` was written to demonstrate the capabilities of the delay models. It is in the
directory :file:`OsvvmLibraries/AXI4/AxiStream/TestCases`.

.. _UTILITY/DelayCoveragePkg/Part1RandomizeUsingExistingVCDelayCoverage:

Part 1: Randomize using existing VC delay coverage
==================================================

Turn on Delay Coverage randomization by calling :vhdlcode:`SetUseRandomDelays`. Note that whether randomization is on
initially or not is up to a particular VC. :vhdlcode:`AxiStreamTransmitter` currently has it off to support historical
modes of operation.

.. code-block:: VHDL

   ------------------------------------------------------------
   -- AxiTransmitterProc
   --   Generate transactions for AxiTransmitter
   ------------------------------------------------------------
   TransmitterProc : process
     variable DelayCoverageID, DelayCovID_Random : DelayCoverageIDType ;
     variable BaseWord, BurstWord : std_logic_vector(31 downto 0) := X"0000_0000" ;
   begin

     wait until nReset = '1' ;
     WaitForClock(StreamTxRec, 2) ;
     -- Use Delay Coverage Defined in the VC
     SetUseRandomDelays(StreamTxRec) ;

Using the Delay Coverage settings from the VC, transfer 256 words individually and 256 words in 32 bursts of 8. Note
that the burst length of :vhdlcode:`SendBurst` (here 8) is independent from the delays set in the Delay Coverage. The
burst length of :vhdlcode:`SendBurst` says I want to transfer 8 words on the interface. The burst length of Delay
Coverage models what happens when a sequence of words is put on the interface – independent of whether the API thinks of
it as a single word or burst transfer.

.. code-block:: VHDL

   log("Transmit 256 words") ;
   BaseWord := BaseWord + X"0001_0000" ;
   for I in 1 to 256 loop
     Send( StreamTxRec, BaseWord + I ) ;
   end loop ;

   BurstWord := BaseWord ;
   log("SendBurstIncrement 8 bursts of size 8") ;
   for i in 1 to 32 loop
     BurstWord := BurstWord + X"0000_1000" ;
     SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
   end loop ;

   WaitForClock(StreamTxRec, 4) ;

If you run the simulation, you can tell when it changes from transferring individual words to transferring bursts by
checking for :vhdlcode:`TLast = 1`.

.. _UTILITY/DelayCoveragePkg/Part2ReplaceTheOldDelayCoverageWithNewDelayCoverage:

Part 2: Replace the old delay coverage with new delay coverage
==============================================================

Get the :vhdlcode:`DelayCoverageID` from the VC using :vhdlcode:`GetDelayCoverageID`. Note that the
:vhdlcode:`DelayCoverageID` variable has both the singleton ID as well as copy of the :vhdlcode:`CoverageIDs` that are
also in the :vhdlcode:`DelayCoveragePkg` singleton.

.. code-block:: VHDL

   GetDelayCoverageID(StreamTxRec, DelayCoverageID) ;

Remove all existing bins Delay Coverage bins referenced by the :vhdlcode:`DelayCoverageID` variable using
:vhdlcode:`DeallocateBins`. Since :vhdlcode:`DelayCoverageID` has the same :vhdlcode:`CoverageIDs` as the singleton,
this effectively removes the Delay Coverage bins from the singleton (and the VC).

.. code-block:: VHDL

   DeallocateBins(DelayCoverageID) ;

Create new Delay Coverage bins using :vhdlcode:`AddBins`. In this case, use a constant burst length of 4, a burst delay
of 4, and a beat delay of 1.

.. code-block:: VHDL

   AddBins(DelayCoverageID.BurstLengthCov, GenBin(4)) ;
   AddBins(DelayCoverageID.BurstDelayCov, GenBin(4)) ;
   AddBins(DelayCoverageID.BeatDelayCov,  GenBin(1)) ;

Using these settings, transfer 32 words individually and transfer 64 words in bursts of 8.

.. code-block:: VHDL

   log("Transmit 32 words") ;
   BaseWord := BaseWord + X"0001_0000" ;
   for i in 1 to 32 loop
     Send( StreamTxRec, BaseWord + I ) ;
   end loop ;

   log("SendBurstIncrement 8 bursts of size 8") ;
   BurstWord := BaseWord ;
   for i in 1 to 8 loop
     BurstWord := BurstWord + X"0000_1000" ;
     SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
   end loop ;

   WaitForClock(StreamTxRec, 4) ;

.. _UTILITY/DelayCoveragePkg/Part3CreateNewDelayCoverageAndSwapItInForTheExistingOne:

Part 3: Create new Delay Coverage and Swap it in for the Existing One
=====================================================================

Create Delay Coverage information in variable :vhdlcode:`DelayCovID_Random` using :vhdlcode:`NewDelayCoverage`. Note
that these :vhdlcode:`CoverageIDs` are only in the variable and not in the :vhdlcode:`DelayCoveragePkg` singleton. Also
note that :vhdlcode:`DelayCovID_Random.ID` is set to the same singleton ID used by :vhdlcode:`DelayCoverageID`.

.. code-block:: VHDL

   DelayCovID_Random := NewDelayCoverage(DelayCoverageID.ID, "TxRandom", TbID);

Add bins to the :vhdlcode:`CoverageIDs` referenced in :vhdlcode:`DelayCovID_Random` using :vhdlcode:`AddBins`.

.. code-block:: VHDL

   -- BurstLength - once per BurstLength, use BurstDelay, otherwise use BeatDelay
   AddBins (DelayCovID_Random.BurstLengthCov, 80, GenBin(3,11,1)) ;   -- 80% Small
   AddBins (DelayCovID_Random.BurstLengthCov, 20, GenBin(109,131,1)); -- 20% Large
   -- BurstDelay - happens at BurstLength boundaries
   AddBins (DelayCovID_Random.BurstDelayCov,  80, GenBin(2,8,1)) ; -- 80% Small
   AddBins (DelayCovID_Random.BurstDelayCov,  20, GenBin(108,156,1)) ; -- 20% Large
   -- BeatDelay - happens between each transfer if not at a BurstLength boundary
   AddBins (DelayCovID_Random.BeatDelayCov,    85, GenBin(0)) ; -- 85% no delay
   AddBins (DelayCovID_Random.BeatDelayCov,    10, GenBin(1)) ; -- 10% 1 cycle delay
   AddBins (DelayCovID_Random.BeatDelayCov,     5, GenBin(2)) ; --  5% 2 cycle delay

Copy the :vhdlcode:`CoverageIDs` in variable :vhdlcode:`DelayCovID_Random` to the :vhdlcode:`DelayCoveragePkg`
singleton. Since :vhdlcode:`DelayCovID_Random.ID = DelayCoverageID.ID`, this copies over the original
:vhdlcode:`CoverageIDs` in the singleton (and used by VC) – don’t despair we still have a reference to the original
:vhdlcode:`CoverageIDs` in the :vhdlcode:`DelayCoverageID` variable.

.. code-block:: VHDL

   SetDelayCoverage(DelayCovID_Random) ;

Using these settings, transfer 256 words individually and 256 words in 32 bursts of 8.

.. code-block:: VHDL

   -- Send
   log("Transmit 256 words") ;
   BaseWord := BaseWord + X"0001_0000" ;
   for I in 1 to 256 loop
     Send( StreamTxRec, BaseWord + I ) ;
   end loop ;

   BurstWord := BaseWord ;
   log("SendBurstIncrement 8 bursts of size 8") ;
   for i in 1 to 32 loop
     BurstWord := BurstWord + X"0000_1000" ;
     SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
   end loop ;

   WaitForClock(StreamTxRec, 4) ;

.. _UTILITY/DelayCoveragePkg/Part4SwapInTheDelayModelFromPart2:

Part 4: Swap in the Delay Model from Part 2
===========================================

The Delay Coverage from :ref:`part 2 <UTILITY/DelayCoveragePkg/Part2ReplaceTheOldDelayCoverageWithNewDelayCoverage>` is
still in the variable :vhdlcode:`DelayCoverageID`. Copy the :vhdlcode:`CoverageIDs` in :vhdlcode:`DelayCoverageID` to
the :vhdlcode:`DelayCoveragePkg` singleton. This will use a constant burst length of 4, a burst delay of 4, and a beat
delay of 1.

.. code-block:: VHDL

   SetDelayCoverage(DelayCoverageID) ;

Using these settings, transfer 32 words individually and transfer 64 words in bursts of 8.

.. code-block:: VHDL

     log("Transmit 32 words") ;
     BaseWord := BaseWord + X"0001_0000" ;
     for i in 1 to 32 loop
       Send( StreamTxRec, BaseWord + I ) ;
     end loop ;

     log("SendBurstIncrement 8 bursts of size 8") ;
     BurstWord := BaseWord ;
     for i in 1 to 8 loop
       BurstWord := BurstWord + X"0000_1000" ;
       SendBurstIncrement(StreamTxRec, BurstWord, 8) ;
     end loop ;

     -- Wait for outputs to propagate and signal TestDone
     WaitForClock(StreamTxRec, 2) ;
     WaitForBarrier(TestDone) ;
     wait ;
   end process TransmitterProc ;

.. _UTILITY/DelayCoveragePkg/SettingBurstLengthAtStartUp:

Setting BurstLength at Start up
*******************************

Nominally the default :vhdlcode:`BurstLength` is 0. This means the first call to :vhdlcode:`GetRandDelay` in a VC will
use a burst delay. If :vhdlcode:`RandomSalt` is set, then the :vhdlcode:`BurstLength` will be a random value between 0
and 5. A VC or test case can set the first value to be a particular value using :vhdlcode:`SetBurstLength`.

.. code-block:: VHDL

   -- Get Delay Coverage ID
   GetDelayCoverageID(StreamTxRec, DelayCoverageID) ;
   -- Set the BurstLength so that the next 5 delays use Beat Delays
   SetBurstLength(DelayCoverageID, 5) ;

.. _UTILITY/DelayCoveragePkg/RunningTbStreamSendGetRandom1Vhd:

Running TbStream_SendGetRandom1.vhd
***********************************

Build the OsvvmLibraries per the directions in the :ref:`Script User Guide <UG>`. Change :file:`RunDemoTests.pro` that
is in the directory :file:`OsvvmLibraries/AXI4/AxiStream` so that it reads as follows:

.. code-block:: tcl

   TestSuite AxiStream
   library   osvvm_TbAxiStream
   include ./testbench
   RunTest ./TestCases/TbStream_SendGetRandom1.vhd

Now run this test case using:

.. code-block:: tcl

   build <Path-To-OsvvmLibraries>/OsvvmLibraries/AXI4/AxiStream/RunDemoTests.pro

Note that you can tell when it changes from transferring individual words to transferring bursts by checking for
:vhdlcode:`TLast = 1`.

.. _UTILITY/DelayCoveragePkg/CompilingAndUsingOSVVMUtilityLibrary:

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
