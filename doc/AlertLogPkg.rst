.. _UTILITY/AlertLogPkg:

AlertLogPkg and ReportPkg
#########################

.. _UTILITY/AlertLogPkg/AlertLogPkgAndReportPkgOverview:

AlertLogPkg and ReportPkg Overview
**********************************

Error reporting and messaging is an important part of any testbench. :vhdlcode:`AlertLogPkg` adds the capabilities of
Logs, Alerts, and Affirmations.

Logs are for conditional printing. When debugging, we need messages that detail test activity. However, we do not always
want to print the messages as this would slow the simulation down. In particular for regression testing, we want to have
only minimal messages – such as pass and fail. As a result, we need to be able to enable and disable messages – and in
some cases enable messages from some sources while disabling others.

Alerts are for checking proper behavior or conditions. Use alerts to check that a response (such as ready) is not
received when a transfer is not in progress. Alerts are also used to check things like the min parameter is never
greater than the max parameter.

Affirmations are for checking that a received (actual) value matches the expected value. If they match, a log PASSED is
produced, otherwise, an alert ERROR is produced.

Both Alerts and Affirmations accumulate the number of errors they have detected during a test case. When the test
completes these are used to indicate whether the test passed or failed. If the test fails, we need additional
information – such as an indication as to which part of the test environment (such as a VC) detected the error.

VHDL assert and :vhdlcode:`TextIO` capability can certainly do some of this. Until VHDL-2019, they lack the capability
to count errors. Even with VHDL-2019, they lack the capability to indicate which part of the test environment found the
error.

OSVVM’s Alerts, Logs, and affirmations solve these issues.

.. _UTILITY/AlertLogPkg/SimpleModeBasicErrorsAndMessaging:

Simple Mode: Basic Errors and Messaging
***************************************

Simple mode tracks alerts, logs, and affirmations with a single error and affirmation counters. This is sufficient for
basic test cases.

First include OSVVM library in your testbench the OSVVM Context declaration. Context declarations are part of VHDL-2008
and allow a group of packages to be referenced as a single item.

.. code-block:: VHDL

   Library osvvm ;
   use osvvm.OsvvmContext ;

Name the test by calling :vhdlcode:`SetTestName`. When using OSVVM scripting, this name must match the test case name
provided by the scripting. For simple tests, this is the entity name of the testcase.

.. code-block:: VHDL

   SetTestName("Tb_SendGet_1") ;

Messages in OSVVM are printed using logs.

.. code-block:: VHDL

   Log("Uart Sending Data: X" & to_hstring(TxData), ALWAYS)  ;

This will print as:

.. code-block:: text

   %%      116800.0 ns  Log    ALWAYS    Uart Sending Data: X4A

Logs have levels ALWAYS, DEBUG, FINAL, INFO, and PASSED. Levels can be enabled or disabled in the test case. Log level
ALWAYS always prints. The remaining logs print when they are enabled and are disabled by default. ALWAYS is the default
if a level is not specified.

Enable a log with :vhdlcode:`SetLogEnable`.

.. code-block:: VHDL

   SetLogEnable(INFO, TRUE) ;

The following log only prints when the INFO level is enabled and can be turned off for regressions.

.. code-block:: VHDL

   Log("Uart Sending Data: X" & to_hstring(TxData), INFO)  ;

This will print as:

.. code-block:: text

   %%      116800.0 ns  Log    INFO      Uart Sending Data: X4A

The same method is used to turn DEBUG or any other message on or off. It is recommended to call :vhdlcode:`SetLogEnable`
from the top level testbench, however, it can be called from anywhere in the testbench infrastructure.

Alerts are for signaling error conditions. The following is a protocol checker that flags an error if the
:vhdlcode:`X86Lite` model receives an acknowledge when the interface is idle.

.. code-block:: VHDL

   X86_Rdy_Check: process
   begin
     wait until Rising_Edge(Clk) and nRdy = '1' ;
     AlertIf(BusIdle, "X86 Lite received ready when it was idle", ERROR) ;
   end process ;

This will print as:

.. code-block:: text

   %%       51340.0 ns  Alert  ERROR    X86 Lite received ready when it was idle

Alerts have levels FAILURE, ERROR, and WARNING. Error is the default if a level is not specified. Alerts are enabled by
default and rarely disabled (see :ref:`SetAlertEnable <UTILITY/AlertLogPkg/SetAlertEnableAlertEnableDisable>`).

Affirmations are for checking test values. When the condition is true, the affirmation prints a PASSED message (using
log), otherwise, it prints an ERROR message (using alert).

.. code-block:: VHDL

   AffirmIf(RxData = Expected, "RxData, Actual: " & to_hstring(RxData),
            "Expected: " & to_hstring(Expected)) ;

Note there are two strings associated with :vhdlcode:`AffirmIf`. The first string prints with both PASSED and ERROR. The
second string only prints with ERROR messages. When :vhdlcode:`AffirmIf` passes and log level "PASSED" is enabled, the
following message will print.

.. code-block:: text

   %%      116800.0 ns  Log    PASSED    RxData, Actual: X4A

When :vhdlcode:`AffirmIf` is FALSE, the following message will print.

.. code-block:: text

   %%      116800.0 ns  Alert  ERROR     RxData, Actual: 52  Expected: 4A

As Alerts (FAILURE, ERROR, WARNING), PASSED, and affirmations occur, a data structure inside the :vhdlcode:`AlertLogPkg`
tabulates them.

When the test is done, a text summary message can be created by calling :vhdlcode:`EndOfTestReports`.
:vhdlcode:`EndOfTestReports` also produces a number of YAML reports which OSVVM scripting converts into HTML and JUnit
XML reports.

.. code-block:: VHDL

   EndOfTestReports ;

If the test passed, a message such as the following prints. Note the message prints on a single long line that starts
with %%.

.. code-block:: text

   %%      381100.0 ns  DONE  PASSED    Tb_SendGet_1  Passed: 14  Affirmations
   Checked: 14

If the test failed, a message such as the following prints.

.. code-block:: text

   %%      381100.0 ns  DONE  FAILED  AxiLite_Uart1  Total Error(s) = 6  Failures: 0
   Errors: 6  Warnings: 0  Passed: 8  Affirmations Checked: 14

This is enough to get you started with basic testbenches. Read on when you are ready for more capability.

.. _UTILITY/AlertLogPkg/HierarchyModeTrackingErrorsAndMessagesToTheirSources:

Hierarchy Mode: Tracking Errors and Messages to their sources
*************************************************************

As testbench complexity increases, it helps to know the source of a message. Often the sources are verification
components (VCs). As a result, OSVVM calls this hierarchy mode since the sources reveal the hierarchy of the test.

Just like simple mode, reference OSVVM’s context.

.. code-block:: VHDL

   Library osvvm ;
   use osvvm.OsvvmContext ;

Then in the test architecture, set the test name.

.. code-block:: VHDL

   SetTestName("Tb_SendGet_1") ;

In hierarchy mode, an :vhdlcode:`AlertLogID` is created for each source. Often these are signals, but variables can also
be used.

.. code-block:: VHDL

   signal ModelID : AlertLogIDType ;

IDs are constructed using :vhdlcode:`NewID` before usage.

.. code-block:: VHDL

   Initialize : process
   begin
     ModelID <= NewID("UartTx_1") ;
     wait ;
   end process Initialize ;

Long term we will be able to do this in one step in a constant. While many simulators currently allow this, the VHDL LRM
seems to indicate it is illegal – but it is expected this will be allowed in the next revision of VHDL.

.. code-block:: VHDL

   constant MODEL_ID : AlertLogIDType := NewID("UartTx_1") ;

Ok. The hard part is done. On all calls to :vhdlcode:`Log`, :vhdlcode:`SetLogEnable`, :vhdlcode:`AlertIf`,
:vhdlcode:`AffirmIf`, :vhdlcode:`SetAlertEnable`, … the :vhdlcode:`AlertLogID` is specified as the first parameter to
the call.

Log levels can be enabled for specific :vhdlcode:`AlertLogIDs` as follows.

.. code-block:: VHDL

   SetLogEnable(ModelID, INFO, TRUE) ;
   SetLogEnable(TBID, PASSED, TRUE) ;

The log in the :vhdlcode:`UartTx` VC is updated as follows.

.. code-block:: VHDL

   Log(ModelID, "Uart Sending Data: X" & to_hstring(TxData), INFO)  ;

When this prints, note that it includes the source information, "In UartTx,".

.. code-block:: text

   %%      116800.0 ns  Log  INFO    In UartTx,  Uart Sending Data: X4A

The :vhdlcode:`AffirmIf` can be replaced by :vhdlcode:`AffirmIfEqual`, which internally does the equality check and
produces the same message (with less effort).

.. code-block:: VHDL

   AffirmIfEqual(TBID, RxData, Expected, "RxData, ") ;

When :vhdlcode:`AffirmIfEqual` passes, log is called to print the following message.

.. code-block:: text

   %%      116800.0 ns  Log    PASSED  In TB,   RxData, Actual: 4A

When :vhdlcode:`AffirmIfEqual` fails, the following message will print.

.. code-block:: text

   %%      116800.0 ns  Alert  ERROR   In TB,   RxData, Actual: 52  Expected: 4A

When the test is done, a text summary message can be created by calling :vhdlcode:`EndOfTestReports`.

.. code-block:: VHDL

   EndOfTestReports ;

If the test passed, we get the same simple message as for Simple Mode.

.. code-block:: text

   %%      381100.0 ns  DONE  PASSED    Tb_SendGet_1  Passed: 14  Affirmations
   Checked: 14

If the test failed, we get a summary as well as details for each source. The line starts with "%%" and prints on a
single line (here shown with line wrap to fit in the text).

.. code-block:: text

   %%      381100.0 ns  DONE  FAILED  AxiLite_Uart1  Total Error(s) = 6  Failures: 0
   Errors: 6  Warnings: 0  Passed: 8  Affirmations Checked: 14
   %%    Default        Failures: 0  Errors: 1  Warnings: 0  Passed: 0
   %%    OSVVM          Failures: 0  Errors: 0  Warnings: 0  Passed: 0
   %%    TB             Failures: 0  Errors: 1  Warnings: 0  Passed: 2
   %%    AxiManager     Failures: 0  Errors: 3  Warnings: 0  Passed: 0
   %%      Protocol     Failures: 0  Errors: 1  Warnings: 0  Passed: 0
   %%      Checker      Failures: 0  Errors: 2  Warnings: 0  Passed: 2
   %%    UartTx         Failures: 0  Errors: 0  Warnings: 0  Passed: 2
   %%    UartRx         Failures: 0  Errors: 1  Warnings: 0  Passed: 2

Note errors in the Default bin are the result of calling an alert or affirmation without an :vhdlcode:`AlertLogID`.

.. _UTILITY/AlertLogPkg/ControllingLogEnablesFromOtherLocations:

Controlling Log Enables from Other Locations
********************************************

Alerts and Logs may need to be enabled (or disabled) from a test case which is in a different entity than the VC that
defined it. To do this, the test case needs to be able to look up the :vhdlcode:`AlertLogID` for the VC. No problem.
:vhdlcode:`AlertLogIDs` can be looked up using :vhdlcode:`NewID` and the same string used in its definition. The
following code can be added to the test case.

.. code-block:: VHDL

   signal TBID, AxiManagerID, UartTxID, UartRxID : AlertLogIDType ;
   . . .
   ControlProc : process
   begin
     TBID         <= NewID("TB") ;
     wait for 0 ns ;                          -- Allow the VC to create the ID
     AxiManagerID <= NewID("AxiManager_1") ;  -- These names must match
     UartTxID     <= NewID("UartTx_1") ;      -- the names used in the VC
     UartRxID     <= NewID("UartRx_1") ;

Using this capability, we can turn on the INFO messages only for one VC, such as the :vhdlcode:`UartTx` VC. Enabling a
specific ID is important when the reporting from that VC is infrequent relative to the other VC in the system – such as
for a UART which is slow. Without this capability it is a challenge to find UART log messages among messages from faster
interfaces.

.. code-block:: VHDL

   . . .
   SetLogEnable(PASSED, TRUE) ;             -- Turn on for ALL Levels
   SetLogEnable(UartTxID, INFO, TRUE) ;     -- Turn on just UartTxID

.. _UTILITY/AlertLogPkg/ChildIDsFurtherClassificationOfIDs:

Child IDs: Further Classification of IDs
****************************************

Sometimes a VC may wish to further classify its Alerts and Logs into subclasses. This is done as follows. The
ID/:vhdlcode:`ModelID` is referred to as a parent ID and is constructed without any additional parameters. The
:vhdlcode:`ProtocolID` and :vhdlcode:`CheckerID` are referred to as child IDs (since they belong to the parent).

.. code-block:: VHDL

   signal ModelID, ProtocolID, CheckerID : AlertLogIDType ;
   . . .
   Initialize : process
     Variable ID : AlertLogIDType ;
   begin
     ID := NewID("X86Lite") ;
     ModelID <= ID ;
     ProtocolID <= NewID("Protocol", ID) ;
     CheckerID  <= NewID("Checker",  ID) ;
     wait ;
   end process Initialize ;

Using :vhdlcode:`ProtocolID`, the :vhdlcode:`X86Lite` protocol checker is updated as follows.

.. code-block:: VHDL

   X86_Rdy_Check: process
   begin
     wait until Rising_Edge(Clk) and nRdy = '1' ;
     AlertIf(ProtocolID, BusIdle, "X86 Lite received ready when it was idle") ;
   end process ;

Now the message includes both the parent ID name and child ID name.

.. code-block:: text

   %%       51340.0 ns  Alert  ERROR  in X86Lite: Protocol,   X86 Lite received ready
   when it was idle

Note that when a child ID finds an error, it counts it and its parent also counts it.

.. _UTILITY/AlertLogPkg/MultipleLinePrinting202608:

Multiple Line Printing (2026.08)
********************************

All OSVVM printing capabilities with :vhdlcode:`Alert`, :vhdlcode:`Log`, :vhdlcode:`AffirmIf`, and :vhdlcode:`LogHeader`
as well as their variations support multiple line printing.

By default, these print their message on a single line – independent of how long that line may be.

If a message starts with LF or '<', the message will start on the next line with a small indent
(:vhdlcode:`ALERT_LOG_INDENTED_LENGTH`) and the message will WRAP if the character count exceeds the
:vhdlcode:`OSVVM_LINE_WRAP` value (currently 165 characters including the %%). The '<' at the start of the line will not
be printed. Also note that line wrap was shortened to work inside this document.

.. code-block:: text

   %%           0.0 ns  Log    ALWAYS  in Default,
   %%>                  23456789 323456789 423456789 523456789 623456789 723456789
   %%>                  3456789 323456789 423456789 523456789 623456789 723456789
   %%>                  456789 323456789 423456789 523456789 623456789 723456789

If a message starts with '>', the message will start after printing the ID. If character count exceeds the
:vhdlcode:`OSVVM_LINE_WRAP` value, a new line will be added and the next line will start aligned with the location the
message started printing. The '>' at the start of the line will not be printed.

.. code-block:: text

   %%           0.0 ns  Log    ALWAYS  in Default,   523456789 623456789 723456789
   %%>                                               23456789 623456789 723456789
   %%>                                               3456789 623456789 723456789
   %%>                                               456789 623456789 723456789

Otherwise, if the OSVVM setting :vhdlcode:`ALERT_LOG_WRAP` is true, the line will be printed in the same fashion as a
line starting with '>'.

Otherwise, if the line contains an LF character, the line will wrap at the LF. The first line of the message is printed
immediately following the ID. Additional lines are printed on following lines and are aligned with the start of the
message.

Note that when a line is wrapped, the line starts with %%> rather than %%. This allows OSVVM report handlers to know it
is a continuation and the HTML red coloring of Alert ERROR can span the entire message rather than just the first line.

As a result of all the checks above, the default printing on a single line happens when the line does not contain a LF,
does not start with either '>' or '<', and :vhdlcode:`ALERT_LOG_WRAP` is FALSE.

.. _UTILITY/AlertLogPkg/PackageReferences:

Package References
******************

The easiest way to use OSVVM is to reference its context clause.

.. code-block:: VHDL

   library osvvm ;
   context osvvm.OsvvmContext ;

While individual packages can be referenced, if the OSVVM team refactors packages, your package references will need to
be updated.

.. code-block:: VHDL

   library osvvm ;
   use osvvm.OsvvmGlobalPkg.all ; -- required to call SetAlertLogOptions
   use osvvm.AlertLogPkg.all ;
   use osvvm.ReportPkg.all ;

On the same note, calling subprograms with package selected paths (such as :vhdlcode:`osvvm.ReportPkg.EndOfTestReports`)
is not a recommended practice as it will break if the packages are refactored.

.. _UTILITY/AlertLogPkg/SettingTheTestNameAndAlertLogIDs:

Setting the Test Name and AlertLogIDs
*************************************

Tests always start in simple mode. Hierarchical mode is automatically entered when :vhdlcode:`NewID` is called.

All overloading supported for simple mode is also supported in hierarchical mode. The only difference is that in
hierarchical mode, the first parameter is the :vhdlcode:`AlertLogID`.

Also note that when in hierarchical mode, any alert, log, or affirmation that is called without an
:vhdlcode:`AlertLogID` will use the "Default" bin.

.. _UTILITY/AlertLogPkg/SetTestNameSettingTheTestName:

SetTestName: Setting the Test Name
==================================

:vhdlcode:`SetTestName` sets the name of the current test that is printed by :vhdlcode:`ReportAlerts`. Setting the test
name is a required part of the OSVVM methodology. It is recommended to set the test name at time 0. If it is not set,
the default name is :vhdlcode:`AlertLogTop`.

.. code-block:: VHDL

   procedure SetTestName(Name : string ) ;
   . . .
   SetTestName("AxiLite_Uart1") ;

.. _UTILITY/AlertLogPkg/GetTestName:

GetTestName
===========

:vhdlcode:`GetTestName` returns the string value of name associated with a Test.

.. code-block:: VHDL

   impure function GetTestName return string ;

.. _UTILITY/AlertLogPkg/GetAlertLogName:

GetAlertLogName
===============

:vhdlcode:`GetAlertLogName` returns the string value of the name associated with an :vhdlcode:`AlertLogID`. If no
:vhdlcode:`AlertLogID` is specified, it will return the name set by :vhdlcode:`SetTestName`.

.. code-block:: VHDL

   impure function GetAlertLogName(AlertLogID : AlertLogIDType:= ALERTLOG_BASE_ID)
   return string ;

.. _UTILITY/AlertLogPkg/AlertLogIDType:

AlertLogIDType
==============

:vhdlcode:`AlertLogIDType` is defined as a subtype of integer. Using a subtype here works similar to an alias and allows
it to be changed as needed.

.. code-block:: VHDL

   subtype AlertLogIDType is integer ;

.. _UTILITY/AlertLogPkg/AlertLogReportModeType:

AlertLogReportModeType
======================

.. code-block:: VHDL

   type AlertLogReportModeType is (DISABLED, ENABLED, NONZERO) ;

When :vhdlcode:`DISABLED`, an :vhdlcode:`AlertLogID` does not print in :vhdlcode:`ReportAlerts` (text reports) or
:vhdlcode:`WriteAlertYaml` (Yaml/HTML reports). When :vhdlcode:`NONZERO`, an :vhdlcode:`AlertLogID` does not print in
:vhdlcode:`ReportAlerts`, but prints in :vhdlcode:`WriteAlertYaml`. Hence, :vhdlcode:`NONZERO` shortens the text reports
to what is essential. When :vhdlcode:`ENABLED`, an :vhdlcode:`AlertLogID` prints in :vhdlcode:`ReportAlerts` and
:vhdlcode:`WriteAlertYaml`.

None of these settings impact printing in Alert or Log.

:vhdlcode:`DISABLED` is intended to be used for data structures that are not used for self-checking and may produce
errors on parameter checks. These errors are not lost as they are still accumulated in the parent ID.

.. _UTILITY/AlertLogPkg/AlertLogPrintParentType:

AlertLogPrintParentType
=======================

.. code-block:: VHDL

   type AlertLogPrintParentType is (PRINT_NAME, PRINT_NAME_AND_PARENT) ;

When :vhdlcode:`PRINT_NAME`, Alert and Log print the name of the :vhdlcode:`AlertLogID`. When
:vhdlcode:`PRINT_NAME_AND_PARENT`, Alert and Log print the parent ID name, the ID separator, and then the ID name.

.. _UTILITY/AlertLogPkg/CreatingAndFindingAlertLogIDs:

Creating and Finding AlertLogIDs
================================

Each level in a hierarchy is referenced with an :vhdlcode:`AlertLogID`. There are five functions used to create or find
:vhdlcode:`AlertLogIDs`: :vhdlcode:`NewID`, :vhdlcode:`GetID`, :vhdlcode:`FindID`, :vhdlcode:`NewReqID`, and
:vhdlcode:`GetReqID`.

Use :vhdlcode:`NewID` when the intent is to create the ID. Use :vhdlcode:`GetID` when the intent is to look up the ID –
but if it does not exist yet then create it. Use :vhdlcode:`FindID` to look up an ID that exists and if it does not,
then fail. Use :vhdlcode:`NewReqID` when the intent is to create a new requirements ID. Use :vhdlcode:`GetReqID` when
the intent is to look up the requirements ID – but if it does not exist yet then create it.

The main difference between the :vhdlcode:`NewID` and :vhdlcode:`GetID` is that :vhdlcode:`NewID` uses
:vhdlcode:`ALERTLOG_BASE_ID` as the default parent ID where as :vhdlcode:`GetID` uses
:vhdlcode:`ALERTLOG_ID_NOT_ASSIGNED`. When the parent ID is :vhdlcode:`ALERTLOG_ID_NOT_ASSIGNED`, then the next call to
:vhdlcode:`NewID` will establish the parent ID. Note though once the parent ID is assigned, it cannot be changed.

:vhdlcode:`NewID` is typically called in a verification component. :vhdlcode:`GetID` is typically called in the
testbench to look up the ID of a verification component. When using :vhdlcode:`GetID` it is typical to call it well
after time 0, so as to allow :vhdlcode:`NewID` to be called first. If it is indeed well after time 0, then calling
:vhdlcode:`FindID` will produce the same results as :vhdlcode:`GetID`.

.. _UTILITY/AlertLogPkg/NewIDCreatingANewID:

NewID: Creating a New ID
------------------------

Use :vhdlcode:`NewID` when the intent is to create the ID, such as in a verification component. If an
:vhdlcode:`AlertLogID` already exists for the specified name, :vhdlcode:`NewID` will return its :vhdlcode:`AlertLogID`.
It is recommended to use the instance label of a verification component as the Name. When creating an
:vhdlcode:`AlertLogID` in a verification component, it is recommended to call :vhdlcode:`NewID` at time 0.

The interface for :vhdlcode:`NewID` is as follows.

.. code-block:: VHDL

   impure function NewID(
     Name            : string ;
     ParentID        : AlertLogIDType          := ALERTLOG_BASE_ID ;
     ReportMode      : AlertLogReportModeType  := ENABLED ;
     PrintParent     : AlertLogPrintParentType := PRINT_NAME_AND_PARENT ;
     CreateHierarchy : boolean                 := TRUE
   ) return AlertLogIDType ;

:vhdlcode:`ParentID` allows a hierarchy of Alerts to be created with parent and child IDs. Within a verification
component it is common to create an ID for the verification component and then create Child IDs that are related to the
parent.

.. code-block:: VHDL

   signal ModelID, ProtocolID, CheckerID : AlertLogIDType ;
   . . .
   Initialize : process
     Variable ID : AlertLogIDType ;
   begin
     ID := NewID("AxiManager") ;
     ModelID <= ID ;
     ProtocolID <= NewID("Protocol", ID) ;
     CheckerID  <= NewID("Checker",  ID) ;
     wait ;
   end process Initialize ;

The :vhdlcode:`ReportMode` and :vhdlcode:`PrintParent` parameters are described in
:ref:`AlertLogReportModeType <UTILITY/AlertLogPkg/AlertLogReportModeType>` and
:ref:`AlertLogPrintParentType <UTILITY/AlertLogPkg/AlertLogPrintParentType>`.

Setting the :vhdlcode:`CreateHierarchy` parameter to FALSE allows packages to create a unique :vhdlcode:`AlertLogID`
without triggering :vhdlcode:`ReportAlerts` to print the hierarchy of the structure – unless the testbench or a
verification component also calls :vhdlcode:`NewID`. OSVVM data structures set :vhdlcode:`CreateHierarchy` to FALSE.

.. _UTILITY/AlertLogPkg/GetIDFindExistingIDOrCreateItIfItDoesNotExist:

GetID: Find Existing ID or Create it if it does not exist
---------------------------------------------------------

Use :vhdlcode:`GetID` when the intent is to look up the ID – but if it does not exist yet then create it. Typically
:vhdlcode:`GetID` is called in the testbench, well after time 0, to look up the ID of a verification component.

The interface for :vhdlcode:`GetID` is as follows:

.. code-block:: VHDL

   impure function GetID(
     Name : string ;
     ParentID : AlertLogIDType := ALERTLOG_ID_NOT_ASSIGNED ;
     CreateHierarchy : Boolean := TRUE
   ) return AlertLogIDType ;

Internally :vhdlcode:`GetID` calls :vhdlcode:`NewID`:

.. _UTILITY/AlertLogPkg/FindIDFindAnAlertLogID:

FindID: Find an AlertLogID
--------------------------

The function, :vhdlcode:`FindID`, finds an existing :vhdlcode:`AlertLogID`. If the :vhdlcode:`AlertLogID` is not found,
:vhdlcode:`ALERTLOG_ID_NOT_FOUND` is returned. Caution do not use at time 0, as :vhdlcode:`FindID` may return
:vhdlcode:`ALERTLOG_ID_NOT_FOUND` for an ID that has not been initialized by the model yet. Use :vhdlcode:`GetID` for
this situation.

The interface for :vhdlcode:`FindID` is as follows.

.. code-block:: VHDL

   impure function FindID(Name : string ; ParentID : AlertLogIDType)
       return AlertLogIDType ;
   impure function FindID(Name : string ) return AlertLogIDType ;

:vhdlcode:`FindID` with a single parameter will return the first :vhdlcode:`AlertLogID` whose name matches the
:vhdlcode:`Name` parameter, hence, only use this if that name is used once in the AlertLog data structure, such as for
top-level instance names.

.. _UTILITY/AlertLogPkg/IsInitialized:

IsInitialized
-------------

:vhdlcode:`IsInitialized` returns an indication whether an :vhdlcode:`AlertLogID` is initialized or not.

.. code-block:: VHDL

   impure function IsInitialized (ID : AlertLogIDType) return boolean ;

.. _UTILITY/AlertLogPkg/PathTailUsedToDiscoverInstanceNameOfAComponent:

PathTail - Used to Discover Instance Name of a Component
========================================================

When used in conjunction with attribute :vhdlcode:`PATH_NAME` applied to an entity name, :vhdlcode:`PathTail` returns
the instance name of component plus any for generate loop indices. For generate loop indices are added as "\_#".

.. code-block:: VHDL

   constant CPU_ALERT_ID : AlertLogIDType :=
       --            Name (string value),         Parent AlertLogID
       NewID(PathTail(CpuModel'PATH_NAME), ALERTLOG_BASE_ID) ;

.. _UTILITY/AlertLogPkg/GetAlertLogParentID:

GetAlertLogParentID
===================

Get the :vhdlcode:`AlertLogID` of the parent of a specified :vhdlcode:`AlertLogID`.

.. code-block:: VHDL

   impure function GetAlertLogParentID(AlertLogID : AlertLogIDType) return
   AlertLogIDType ;

.. _UTILITY/AlertLogPkg/LogMethodReference:

Log Method Reference
********************

.. _UTILITY/AlertLogPkg/LogType:

LogType
=======

Log levels can be ALWAYS, DEBUG, PASSED, or INFO.

.. code-block:: VHDL

   type LogType is (ALWAYS, DEBUG, FINAL, INFO, PASSED) ;

.. _UTILITY/AlertLogPkg/Log:

Log
===

If the log level is enabled, then the log message will print. The :vhdlcode:`Enable` parameter indicates to print the
message even if the log level is not enabled. This is useful to enable printing for a single transaction.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure log(
     AlertLogID   : AlertLogIDType ;
     Message      : string ;
     Level        : LogType := ALWAYS ; -- Log if LogType is enabled
     Enable       : boolean := FALSE    -- also log if Enable is TRUE
   ) ;

   -- without an AlertLogID
   procedure log(
     Message   : string ;
     Level     : LogType := ALWAYS ; -- Log if LogType is enabled
     Enable    : boolean := FALSE    -- also log if Enable is TRUE
   ) ;

Usage:

.. code-block:: VHDL

   Log(UartID, "Uart Parity Received", DEBUG) ;
   . . .
   Log("Received UART word", DEBUG) ;

.. _UTILITY/AlertLogPkg/LogHeader:

LogHeader
=========

:vhdlcode:`LogHeader` is a log message plus prefix and suffix lines to frame the message and make it stand out. Square
brackets below indicate the parameter is optional.

.. code-block:: VHDL

   procedure LogHeader (
     [ AlertLogID   : AlertLogIDType ; ]
     Message      : string ;
     Prefix       : string ;
     Suffix       : string ;
     Level        : LogType := ALWAYS ;
     Enable       : boolean := FALSE
   ) ;

Each character in the prefix and suffix indicates a line to print. Each line printed is prefixed by
:vhdlcode:`OSVVM_PRINT_PREFIX`. If the character is a space, then print a blank line, otherwise, repeat that character
:vhdlcode:`OSVVM_LINE_LENGTH` times.

There is also a short form that uses :vhdlcode:`OSVVM_HEADER_PREFIX` (default " ") and :vhdlcode:`OSVVM_HEADER_SUFFIX`
(default "\*") instead of having a :vhdlcode:`Prefix` and :vhdlcode:`Suffix` parameter.

.. code-block:: VHDL

   procedure LogHeader (
     [ AlertLogID   : AlertLogIDType ; ]
     Message      : string ;
     Level        : LogType := ALWAYS ;
     Enable       : boolean := FALSE    -- override internal enable
   ) ;

Usage:

.. code-block:: VHDL

   LogHeader(TB, "Start Of UART1 Test", " *", "* ") ;

Prints as (line length shortened to fit page width):

.. code-block:: text

   %%
   %% ****************************************************************************
   %%           0.0 ns  Log    ALWAYS  in TB,      Start of UART1 Test
   %% ****************************************************************************
   %%

.. _UTILITY/AlertLogPkg/AlertMethodReference:

Alert Method Reference
**********************

Alert is intended for parameter error checking. For self-checking see
:ref:`affirmations <UTILITY/AlertLogPkg/AffirmationReference>`.

.. _UTILITY/AlertLogPkg/AlertType:

AlertType
=========

Alert levels can be FAILURE, ERROR, or WARNING.

.. code-block:: VHDL

   type AlertType is (FAILURE, ERROR, WARNING) ;

.. _UTILITY/AlertLogPkg/Alert:

Alert
=====

:vhdlcode:`Alert` generates an alert. The following overloading is supported.

.. code-block:: VHDL

   procedure alert(
     AlertLogID   : AlertLogIDType ;
     Message   : string ;
     Level     : AlertType := ERROR
   ) ;

   procedure Alert( Message : string ; Level : AlertType := ERROR ) ;

Usage of alert:

.. code-block:: VHDL

   . . .
   Alert(UartID, "Uart Parity", ERROR) ;

   Alert("Uart Parity") ;  -- ERROR by default

.. _UTILITY/AlertLogPkg/AlertIfAndAlertIfNot:

AlertIf and AlertIfNot
======================

:vhdlcode:`Alert` has two conditional forms, :vhdlcode:`AlertIf` and :vhdlcode:`AlertIfNot`. The following is their
overloading.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIf( AlertLogID : AlertLogIDType ; condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) ;
   impure function  AlertIf( AlertLogID : AlertLogIDType ; condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) return boolean ;
   procedure AlertIfNot( AlertLogID : AlertLogIDType ; condition : boolean ;
       Message : string ; Level : AlertType := ERROR )  ;
   impure function  AlertIfNot( AlertLogID : AlertLogIDType ; condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) return boolean ;

   -- without an AlertLogID
   procedure AlertIf( condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) ;
   impure function  AlertIf( condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) return boolean ;
   procedure AlertIfNot( condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) ;
   impure function  AlertIfNot( condition : boolean ;
       Message : string ; Level : AlertType := ERROR ) return boolean ;

Usage of conditional alerts:

.. code-block:: VHDL

   -- with an AlertLogID
   AlertIf(UartID, Break='1', "Uart Break", ERROR) ;
   AlertIfNot(UartID, ReadValid, "Read", FAILURE);

   -- without an AlertLogID
   AlertIf(Break='1', "Uart Break", ERROR) ;
   AlertIfNot(ReadValid, "Read Failed", FAILURE) ;

The function form is convenient for use for conditional exit of a loop.

.. code-block:: VHDL
   :force:

   exit AlertIfNot(UartID, ReadValid, "in ReadCovDb while reading …", FAILURE) ;

.. _UTILITY/AlertLogPkg/AlertIfEqualAndAlertIfNotEqual:

AlertIfEqual and AlertIfNotEqual
================================

:vhdlcode:`AlertIfEqual` and :vhdlcode:`AlertIfNotEqual` checks two values and produces an Alert if the check fails. In
the following, :vhdlcode:`AType` can be :vhdlcode:`std_logic`, :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned`,
:vhdlcode:`signed`, :vhdlcode:`integer`, :vhdlcode:`integer_vector`, :vhdlcode:`real`, :vhdlcode:`character`,
:vhdlcode:`string`, or :vhdlcode:`time`.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIfEqual( AlertLogID : AlertLogIDType ;  L, R : AType ;
       Message : string ; Level : AlertType := ERROR )  ;
   procedure AlertIfNotEqual( AlertLogID : AlertLogIDType ;  L, R : AType ;
       Message : string ; Level : AlertType := ERROR )  ;

   -- without an AlertLogID
   procedure AlertIfEqual( L, R : AType ; Message : string ;
       Level : AlertType := ERROR )  ;
   procedure AlertIfNotEqual( L, R : AType ; Message : string ;
       Level : AlertType := ERROR )  ;

.. _UTILITY/AlertLogPkg/AlertIfFilesNotMatch:

AlertIfFilesNotMatch
====================

Alert form :vhdlcode:`AlertIfFilesNotMatch` is for comparing two files.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AlertIfFilesNotMatch (AlertLogID : AlertLogIDType ;
     Name1, Name2 : string;    Message : string := "" ; Level : AlertType := ERROR ;
     IgnoreSpaces : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;
   procedure AlertIfFilesNotMatch (AlertLogID : AlertLogIDType ;
     file File1, File2 : text; Message : string := "" ; Level : AlertType := ERROR ;
     IgnoreSpaces : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;

   -- without an AlertLogID
   procedure AlertIfFilesNotMatch (
     Name1, Name2 : string;    Message : string := "" ; Level : AlertType := ERROR ;
     IgnoreSpaces : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;
   procedure AlertIfFilesNotMatch (
     file File1, File2 : text; Message : string := "" ; Level : AlertType := ERROR ;
     IgnoreSpaces : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;

.. _UTILITY/AlertLogPkg/IncrementAlertCount:

IncrementAlertCount
===================

Intended as a silent alert. Used by :vhdlcode:`CoveragePkg`.

.. code-block:: VHDL

   -- Hierarchy
   procedure IncAlertCount(   -- A silent form of alert
     AlertLogID   : AlertLogIDType ;
     Level        : AlertType := ERROR
   ) ;
   -- Global Alert Counters
   procedure IncAlertCount( Level : AlertType := ERROR ) ;

.. _UTILITY/AlertLogPkg/AffirmationReference:

Affirmation Reference
*********************

Affirmations are a combination of Alerts and Logs. If the Affirmation is true, then a log is generated. If an
Affirmation is false, then an alert is generated.

Affirmations are intended to be used for self-checking of a test. Each call to :vhdlcode:`AffirmIf` is counted and
reported during :vhdlcode:`ReportAlerts`. This provides feedback on the amount of self-checking added by a test and is
used as a quality metric.

.. _UTILITY/AlertLogPkg/AffirmIfAffirmIfNot:

AffirmIf / AffirmIfNot
======================

:vhdlcode:`AffirmIf` has two forms of overloading. The first has a separate :vhdlcode:`ReceivedMessage` and
:vhdlcode:`ExpectedMessage`. When the affirmation passes, log is called with just the Received Message. When an
affirmation fails, alert is called with the :vhdlcode:`ExpectedMessage` concatenated to the end of the
:vhdlcode:`ReceivedMessage`.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     AlertLogID       : AlertLogIDType ;
     condition        : boolean ;
     ReceivedMessage  : string ;
     ExpectedMessage  : string ;
     Enable           : boolean := FALSE
   ) ;

   -- without an AlertLogID
   procedure AffirmIf(
     condition        : boolean ;
     ReceivedMessage  : string ;
     ExpectedMessage  : string ;
     Enable           : boolean := FALSE
   ) ;

The second overloading of :vhdlcode:`AffirmIf` has a single :vhdlcode:`Message` parameter. Hence, both alert and log
print the same message.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     AlertLogID       : AlertLogIDType ;
     condition        : boolean ;
     Message          : string ;
     Enable           : boolean := FALSE
   ) ;

   -- without an AlertLogID
   procedure AffirmIf(
     condition        : boolean ;
     Message          : string ;
     Enable           : boolean := FALSE
   ) ;

:vhdlcode:`AffirmIfNot` supports the same parameters as :vhdlcode:`AffirmIf`.

.. _UTILITY/AlertLogPkg/AffirmIfEqualAndAffirmIfNotEqual:

AffirmIfEqual and AffirmIfNotEqual
==================================

Affirmation form :vhdlcode:`AffirmIfEqual` checks if two values are equal. It greatly simplifies the message printing
since it differentiates between the Received and Expected values. In the following, :vhdlcode:`AType` can be
:vhdlcode:`std_logic`, :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned`, :vhdlcode:`signed`, :vhdlcode:`integer`,
:vhdlcode:`integer_vector`, :vhdlcode:`real`, :vhdlcode:`character`, :vhdlcode:`string` or :vhdlcode:`time`.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfEqual(
     AlertLogID          : AlertLogIDType ;
     Received, Expected  : AType ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

   -- without an AlertLogID
   procedure AffirmIfEqual(
     Received, Expected  : AType ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

:vhdlcode:`AffirmIfNotEqual` supports the same parameters as :vhdlcode:`AffirmIfEqual`.

:vhdlcode:`AffirmIfEqual` is effectively an abbreviation for,

.. code-block:: VHDL

   AffirmIf (AlertLogID, Received = Expected,
     Message & " Received: " & to_string(Received),
     " /= Expected: " & to_string(Expected),
     Enable) ;

.. _UTILITY/AlertLogPkg/AffirmIfInRange:

AffirmIfInRange
===============

:vhdlcode:`AffirmIfInRange` checks if the received value is between the specified min and max values (inclusive). In the
following, :vhdlcode:`AType` can be :vhdlcode:`std_logic`, :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned`,
:vhdlcode:`signed`, :vhdlcode:`integer`, :vhdlcode:`real`, :vhdlcode:`character`, or :vhdlcode:`time`.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfInRange (
     AlertLogID          : AlertLogIDType ;
     Received, Min, Max  : AType ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

   -- without an AlertLogID
   procedure AffirmIfInRange (
     Received, Min, Max  : AType ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

:vhdlcode:`AffirmIfInRange` is an abbreviation for,

.. code-block:: VHDL

   AffirmIf(AlertLogID, (Min <= Received) and (Received <= Max),
     AddSpaceIfNotEmpty(Message) &
     "Check " & to_string(Min) & " <= " &
     "Received (" & to_string(Received) & ") <= " & to_string(Max),
      Enable) ;

.. _UTILITY/AlertLogPkg/AffirmIfFilesMatch:

AffirmIfFilesMatch
==================

Affirmation form :vhdlcode:`AffirmIfFilesMatch` is for comparing two files.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfFilesMatch (
     AlertLogID       : AlertLogIDType ;
     Name1, Name2     : string;
     Message          : string := "" ;
     Enable           : boolean := FALSE ;
     IgnoreSpaces     : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;
   procedure AffirmIfFilesMatch (
     AlertLogID        : AlertLogIDType ;
     file File1, File2 : text;
     Message           : string := "" ;
     Enable            : boolean := FALSE ;
     IgnoreSpaces      : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines  : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;
   -- without an AlertLogID
   procedure AffirmIfFilesMatch (
     Name1, Name2     : string;
     Message          : string := "" ;
     Enable           : boolean := FALSE ;
     IgnoreSpaces     : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;
   procedure AffirmIfFilesMatch (
     file File1, File2 : text;
     Message           : string := "" ;
     Enable            : boolean := FALSE ;
     IgnoreSpaces      : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines  : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;

.. _UTILITY/AlertLogPkg/AffirmIfTranscriptsMatch:

AffirmIfTranscriptsMatch
========================

:vhdlcode:`AffirmIfTranscriptsMatch` compares the current transcript file (defined by :vhdlcode:`GetTranscriptName`)
with the same named file in the directory specified by the :vhdlcode:`PathToValidatedResults` parameter.

.. code-block:: VHDL

   procedure AffirmIfTranscriptsMatch (
     AlertLogID             : AlertLogIDType ;
     PathToValidatedResults : string;
     Message                : string := "" ;
     Enable                 : boolean := FALSE ;
     IgnoreSpaces           : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines       : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;

   procedure AffirmIfTranscriptsMatch (
     PathToValidatedResults : string;
     Message                : string := "" ;
     Enable                 : boolean := FALSE ;
     IgnoreSpaces           : boolean := ALERT_LOG_IGNORE_SPACES ;
     IgnoreEmptyLines       : boolean := ALERT_LOG_IGNORE_EMPTY_LINES ) ;

.. _UTILITY/AlertLogPkg/AffirmIfStableAffirmIfNotStable:

AffirmIfStable, AffirmIfNotStable
=================================

:vhdlcode:`AffirmIfStable` checks if the :vhdlcode:`LastChange` is greater than or equal to the Stable requirement.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIfStable(
     AlertLogID          : AlertLogIDType ;
     LastChange, Stable  : time ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

   -- without an AlertLogID
   procedure AffirmIfStable(
     LastChange, Stable  : time ;
     Message             : string := "";
     Enable              : boolean := FALSE
   ) ;

:vhdlcode:`AffirmIfStable` is an abbreviation for,

.. code-block:: VHDL

   AffirmIf(AlertLogID, LastChange >= Stable,
     Message & "Check Stable:  LastChange: " & format(LastChange) &
     " >  Stable Requirement: " & format(Stable),
     Enable) ;

:vhdlcode:`AffirmIfNotStable` has the same parameters and checks that :vhdlcode:`LastChange` is less than the Stable
requirement.

.. _UTILITY/AlertLogPkg/GetAffirmCount:

GetAffirmCount
==============

Returns the current affirmation check count.

.. code-block:: VHDL

   impure function GetAffirmCount return natural ;

.. _UTILITY/AlertLogPkg/IncAffirmCount:

IncAffirmCount
==============

Increments the affirmation check count. Intended to be used only in special situations, such as packages that have
additional considerations when using affirmations.

.. code-block:: VHDL

   procedure IncAffirmCount ;

.. _UTILITY/AlertLogPkg/HTMLTestReports:

HTML Test Reports
*****************

.. _UTILITY/AlertLogPkg/RequiredStepsForReportGeneration:

Required Steps for Report Generation
====================================

Reports are created as a partnership of VHDL code and OSVVM scripts.

The VHDL code creates the YAML files by doing:

* Set the test name by calling :vhdlcode:`SetTestName` (:vhdlcode:`AlertLogPkg`),
* Do Alerts and Affirmations during the test (:vhdlcode:`AlertLogPkg`),
* At the end of the test, call :vhdlcode:`EndOfTestReports`

Within OSVVM scripting:

* Run each test case with OSVVM script API command :tclcode:`simulate` or :tclcode:`RunTest`.
* Run the entire test suite with OSVVM script API command :tclcode:`build`.

Details of the reports are shown in the ":ref:`OSVVM Test Writer's User Guide <FRAMEWORK/TestWriters>`" in the
Documentation repository.

.. _UTILITY/AlertLogPkg/EndOfTestReportsInReportPkg:

EndOfTestReports (in ReportPkg)
===============================

:vhdlcode:`EndOfTestReports` creates YAML files that OSVVM scripts use to create the reports.

The call interface to :vhdlcode:`EndOfTestReports` is:

.. code-block:: VHDL

   procedure EndOfTestReports (
     ReportAll      : boolean        := FALSE ;
     ExternalErrors : AlertCountType := (0,0,0) ;
     Stop           : boolean        := FALSE ;
     TimeOut        : boolean        := FALSE
   ) ;

If :vhdlcode:`ReportAll` is true, the text based test report prints details during pass (otherwise it only prints
details during an error).

Test pass/fail is determined by :vhdlcode:`AlertErrors` + :vhdlcode:`ExternalErrors` – :vhdlcode:`ExpectedErrors`. If
the count of FAILURE, ERROR, or WARNING is non-zero the test case fails. :vhdlcode:`AlertErrors` are those tabulated by
Alerts and Affirmations as the test is running. :vhdlcode:`ExternalErrors` is the parameter of
:vhdlcode:`EndOfTestReports` – and may be negative also to indicate expected errors. :vhdlcode:`ExpectedErrors` is the
value set by :vhdlcode:`SetExpectedAlertCount` (next section) or :vhdlcode:`IncrementExpectedAlertCount`.

If the :vhdlcode:`Stop` parameter is true (not recommended), :vhdlcode:`std.env.stop` is called.

If :vhdlcode:`TimeOut` is true, the test case reports TIMEOUT for status. This is treated as an error in the reports.

.. _UTILITY/AlertLogPkg/SetExpectedAlertCount:

SetExpectedAlertCount
=====================

:vhdlcode:`SetExpectedAlertCount` sets the internal :vhdlcode:`ExpectedErrors` variable and is used when the test
completes to calculate total errors. The call interface to :vhdlcode:`SetExpectedAlertCount` is:

.. code-block:: VHDL

   procedure SetExpectedAlertCount (Count : AlertCountType) ;
   procedure SetExpectedAlertCount (Level : AlertType ; Count : integer) ;

These allow errors (FAILURE, ERROR, WARNING) to be specified either as a group or individually.

.. _UTILITY/AlertLogPkg/IncrementExpectedAlertCount:

IncrementExpectedAlertCount
===========================

:vhdlcode:`IncrementExpectedAlertCount` increments the internal :vhdlcode:`ExpectedErrors` variable. The call interface
to :vhdlcode:`IncrementExpectedAlertCount` is:

.. code-block:: VHDL

   procedure IncrementExpectedAlertCount (Level : AlertType ; Count : integer := 1) ;

.. _UTILITY/AlertLogPkg/GetExpectedAlertCount:

GetExpectedAlertCount
=====================

:vhdlcode:`GetExpectedAlertCount` returns the value of the internal :vhdlcode:`ExpectedErrors` variable. The call
interface to :vhdlcode:`GetExpectedAlertCount` is:

.. code-block:: VHDL

   impure function GetExpectedAlertCount return AlertCountType ;

Note that if a single level is needed, the result value can be indexed.

.. code-block:: VHDL

   ExpectedErrors := GetExpectedAlertCount(ERROR) ;

.. _UTILITY/AlertLogPkg/RequirementsTracking:

Requirements Tracking
*********************

OSVVM can track requirements either as an Alert or as Coverage. As an Alert, a requirement is nothing more than an
:vhdlcode:`AlertLogID` that has a PASSED goal associated with it. As Coverage, a requirement is a :vhdlcode:`CoverageID`
that has a goal. Requirements pass if the goal is reached. By default, the goal is 1.

Requirement IDs are created with :vhdlcode:`NewReqID`. A group of requirements can be read in with
:vhdlcode:`ReadSpecification`. Then the ID can be looked up using :vhdlcode:`GetReqID`.

Requirements can be checked by using any affirmation and the :vhdlcode:`AlertLogID` that is associated with that
requirement. Requirements can also be checked using a special form of :vhdlcode:`AffirmIf` that takes the requirement
name (as a string).

When a test case completes and calls :vhdlcode:`EndOfTestReports`, a YAML requirements report is automatically
generated. When a test suite completes, OSVVM scripts merge the YAML requirements for that test suite. When the build
completes, OSVVM scripts merge the YAML requirements for each test suite that was run during the build and produces an
HTML and CSV merged requirements report.

.. _UTILITY/AlertLogPkg/NewReqID:

NewReqID
========

Use :vhdlcode:`NewReqID` when the intent is to create an :vhdlcode:`AlertLogID` that is used for requirements tracking.
The interface for :vhdlcode:`NewReqID` is as follows.

.. code-block:: VHDL

   impure function NewReqID(
     Name            : string ;
     Goal            : natural ;
     ParentID        : AlertLogIDType          := REQUIREMENT_ALERTLOG_ID ;
     ReportMode      : AlertLogReportModeType  := ENABLED ;
     PrintParent     : AlertLogPrintParentType := PRINT_NAME_AND_PARENT ;
     CreateHierarchy : boolean                 := TRUE
   ) return AlertLogIDType ;

Call :vhdlcode:`NewReqID` with the name of the requirement and the :vhdlcode:`PassedGoal`.

.. code-block:: VHDL

   signal Uart1ReqID : AlertLogIDType ;
   . . .
   Uart1ReqID <= NewReqID("UART_REQ_1", 2);

.. _UTILITY/AlertLogPkg/GetReqID:

GetReqID
========

:vhdlcode:`GetReqID` returns an :vhdlcode:`AlertLogID` for a requirement. If an :vhdlcode:`AlertLogID` already exists
for the requirement, :vhdlcode:`GetReqID` will return its :vhdlcode:`AlertLogID`. Use :vhdlcode:`GetReqID` when the
intent is to look up the ID – but if it does not exist yet then create it. Typically :vhdlcode:`GetReqID` is called in
the testbench, well after time 0, to look up an ID.

The interface for :vhdlcode:`GetReqID` is as follows.

.. code-block:: VHDL

   impure function GetReqID (
     Name            : string ;
     PassedGoal      : integer := -1 ;  -- If -1, use DefaultPassedGoalVar
     ParentID        : AlertLogIDType := ALERTLOG_ID_NOT_ASSIGNED;
     CreateHierarchy : Boolean := TRUE
   ) return AlertLogIDType ;

When the :vhdlcode:`ParentID` defaults to :vhdlcode:`ALERTLOG_ID_NOT_ASSIGNED`, internally :vhdlcode:`GetReqID` changes
this to :vhdlcode:`REQUIREMENT_ALERTLOG_ID`.

Creating :vhdlcode:`AlertLogIDs` for requirements is as follows. Since :vhdlcode:`PassedGoal` is not set in the call,
the :vhdlcode:`DefaultPassedGoalVar` is used (default is 1). Change with
:vhdlcode:`SetAlertLogOptions(DefaultPassedGoal => 2)`.

.. code-block:: VHDL

   signal Uart1ReqID : AlertLogIDType ;
   signal Uart2ReqID : AlertLogIDType ;

   . . .
   InitializeProc: process
   begin
     Uart1ReqID <= GetReqID("UART_REQ_1");
     Uart2ReqID <= GetReqID("UART_REQ_2", 2);

.. _UTILITY/AlertLogPkg/ReadSpecification:

ReadSpecification
=================

:vhdlcode:`ReadSpecification` reads files in the following format. In the following items enclosed in "[]" are optional
and are ignored.

.. code-block:: text

   <requirement1 ID Name> [, Requirement1 Description] [, Requirement1 PASSED Goal]
   <requirement2 ID Name> [, Requirement2 Description] [, Requirement2 PASSED Goal]
   . . .
   <requirementN ID Name> [, RequirementN Description] [, RequirementN PASSED Goal]

The interface for :vhdlcode:`ReadSpecification` is as follows.

.. code-block:: VHDL

   procedure ReadSpecification (FileName : string  ; PassedGoal : integer := -1) ;

A call to :vhdlcode:`ReadSpecification`:

.. code-block:: VHDL

   ReadSpecification("Uart_Specification.txt") ;

If a requirement is not set, by default it will be 1. The default can be changed using
:vhdlcode:`SetAlertLogOptions(DefaultPassedGoal => 2)`. Alternately all requirements can be changed to the
:vhdlcode:`PassedGoal` specified in the call to :vhdlcode:`ReadSpecification` (here 2):

.. code-block:: VHDL

   ReadSpecification("Uart_Specification.txt", 2) ;

.. _UTILITY/AlertLogPkg/SetPassedGoal:

SetPassedGoal
=============

The :vhdlcode:`PassedGoal` of an :vhdlcode:`AlertLogID` can be replaced by calling :vhdlcode:`SetPassedGoal`.

.. code-block:: VHDL

   procedure SetPassedGoal(AlertLogID : AlertLogIDType ; PassedGoal : integer ) ;
   . . .
   SetPassedGoal(Req1ID, 2) ;

.. _UTILITY/AlertLogPkg/AffirmIfForRequirements:

AffirmIf for Requirements
=========================

For requirements, an additional form of :vhdlcode:`AffirmIf` that uses the requirements ID name is provided. It has two
forms of overloading. The first has a separate :vhdlcode:`ReceivedMessage` and :vhdlcode:`ExpectedMessage`. When the
affirmation passes, log is called with just the Received Message. When an affirmation fails, alert is called with the
:vhdlcode:`ExpectedMessage` concatenated to the end of the :vhdlcode:`ReceivedMessage`.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     RequirementsIDName : string ;
     condition          : boolean ;
     ReceivedMessage    : string ;
     ExpectedMessage    : string ;
     Enable             : boolean := FALSE
   ) ;

The second overloading of :vhdlcode:`AffirmIf` has a single :vhdlcode:`Message` parameter. Hence, both alert and log
print the same message.

.. code-block:: VHDL

   -- with an AlertLogID
   procedure AffirmIf(
     RequirementsIDName : string ;
     condition          : boolean ;
     Message            : string ;
     Enable             : boolean := FALSE
   ) ;

A call to :vhdlcode:`AffirmIf` with two parameters is as follows.

.. code-block:: VHDL

   AffirmIf("T1.1", A > B, "Test 1.1 A (" & to_string(A) & ")",
                            "> B (" & to_string(B) & ")" ) ;

Note that the :vhdlcode:`RequirementsIDName` is case insensitive.

.. _UTILITY/AlertLogPkg/UsingOtherFormsOfAffirmIFWithRequirements:

Using Other Forms of AffirmIf with Requirements
===============================================

To use other forms of :vhdlcode:`AffirmIf`, either the ID needs to be known (:vhdlcode:`NewReqID` or
:vhdlcode:`GetReqID`) or looked up using :vhdlcode:`FindID`.

.. code-block:: VHDL

   AffirmIfEqual( Uart1ReqID, TestValue1, ExpectedValue1, "Message") ;
   AffirmIfEqual( FindID("Axi4Req1"), TestValue2, ExpectedValue2, "Message") ;

.. _UTILITY/AlertLogPkg/WriteRequirementsYamlCalledByEndOfTestReports:

WriteRequirementsYaml (Called by EndOfTestReports)
==================================================

For information only. :vhdlcode:`WriteRequirementsYaml` is called by :vhdlcode:`EndOfTestReports`.
:vhdlcode:`WriteRequirementsYaml` creates a YAML report that contains all requirements information for a test case. The
file, :file:`./reports/<TestSuite>/<TestName>_req.yml`, holds the requirements results for a given test case.

The call interface to :vhdlcode:`WriteRequirementsYaml` is:

.. code-block:: VHDL

   procedure WriteRequirementsYaml (
     FileName    : string ;
     AlertLogID  : AlertLogIDType := REQUIREMENT_ALERTLOG_ID ;
     OpenKind    : File_Open_Kind := WRITE_MODE
   ) ;

.. _UTILITY/AlertLogPkg/TestFailureDueToMissedRequirements:

Test Failure Due to Missed Requirements
=======================================

When a test has requirements, a test will fail if requirements are not met and :vhdlcode:`FailOnRequirementErrors` is
true (default is TRUE). Disable using :vhdlcode:`SetAlertLogOptions(FailOnRequirementErrors => FALSE)`.

A test failing due to :vhdlcode:`FailOnRequirementErrors` will result in a :vhdlcode:`ReportAlerts` such as the
following.

.. code-block:: text

   %%  381100.0 ns  DONE  FAILED  req_test1  Total Error(s) = 2  Failures: 0  Errors:
   0  Warnings: 0  Passed: 20  Affirmations Checked: 20  Requirements Passed: 2 of 4
   %%    Default       Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 0
   %%    OSVVM         Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 0
   %%    Requirements  Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 0
   %%      T1.1        Failures: 0  Errors: 0  Warnings: 0  Passed: 1 of 1
   %%      T1.2        Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 2
   %%      T1.3        Failures: 0  Errors: 0  Warnings: 0  Passed: 2 of 3
   %%      T1.4        Failures: 0  Errors: 0  Warnings: 0  Passed: 4 of 4

.. _UTILITY/AlertLogPkg/ReportAlertsAndRequirements:

ReportAlerts and Requirements
=============================

:vhdlcode:`ReportAlerts` prints requirements in both the summary and the detailed report when a test fails.

In the summary report (first line) of :vhdlcode:`ReportAlerts`, a requirements summary (# met of # total) will be
printed if either :vhdlcode:`PrintRequirements` is TRUE (default is FALSE) or both the test has requirements and
:vhdlcode:`PrintIfHaveRequirements` is TRUE (default is TRUE).

.. code-block:: text

   %%  381100.0 ns  DONE  PASSED  req_test2  Total Error(s) = 0  Failures: 0  Errors:
   0  Warnings: 0  Passed: 20  Affirmations Checked: 20  Requirements Passed: 4 of 4

For a test that fails, detailed printing of requirements will be printed in :vhdlcode:`ReportAlerts` if
:vhdlcode:`PrintRequirements` is TRUE (default is FALSE).

.. code-block:: text

   %%  381100.0 ns  DONE  FAILED  req_test1  Total Error(s) = 6  Failures: 0  Errors:
   4  Warnings: 0  Passed: 20  Affirmations Checked: 20  Requirements Passed: 2 of 4
   %%    Default       Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 0
   %%    OSVVM         Failures: 0  Errors: 0  Warnings: 0  Passed: 0 of 0
   %%    Requirements  Failures: 0  Errors: 4  Warnings: 0  Passed: 0 of 0
   %%      T1.1        Failures: 0  Errors: 0  Warnings: 0  Passed: 1 of 1
   %%      T1.2        Failures: 0  Errors: 2  Warnings: 0  Passed: 0 of 2
   %%      T1.3        Failures: 0  Errors: 2  Warnings: 0  Passed: 1 of 3
   %%      T1.4        Failures: 0  Errors: 0  Warnings: 0  Passed: 4 of 4

Both :vhdlcode:`PrintRequirements` and :vhdlcode:`PrintIfHaveRequirements` can be changed using
:vhdlcode:`SetAlertLogOptions`.

.. _UTILITY/AlertLogPkg/EnablingAndDisablingLogsAndAlerts:

Enabling and Disabling Logs and Alerts
**************************************

.. _UTILITY/AlertLogPkg/SetLogEnableEnableDisableLogging:

SetLogEnable: Enable / Disable Logging
======================================

Excepting ALWAYS, log enables are disabled by default. :vhdlcode:`SetLogEnable` allows log levels to be individually
enabled. When used without :vhdlcode:`AlertLogID`, :vhdlcode:`SetLogEnable` sets a value for all
:vhdlcode:`AlertLogIDs`.

.. code-block:: VHDL

   procedure SetLogEnable(Level : LogType ;  Enable : boolean) ;
   . . .
   SetLogEnable(PASSED, TRUE) ;

When an :vhdlcode:`AlertLogID` is used, :vhdlcode:`SetLogEnable` sets a value for that :vhdlcode:`AlertLogID`, and if
Hierarchy is true, the :vhdlcode:`AlertLogIDs` of its children.

.. code-block:: VHDL

   procedure SetLogEnable(AlertLogID : AlertLogIDType ;
       Level : LogType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) ;
   . . .
   --       AlertLogID,  Level,   Enable,  DescendHierarchy
   SetLogEnable(UartID,  INFO,    TRUE,    TRUE) ;

.. _UTILITY/AlertLogPkg/ReadingLogEnablesFromAFILE:

Reading Log Enables from a FILE
===============================

:vhdlcode:`ReadLogEnables` reads enables from a file.

.. code-block:: VHDL

   procedure ReadLogEnables (FileName : string) ;
   procedure ReadLogEnables (file AlertLogInitFile : text) ;

The preferred file format is:

.. code-block:: text

   U_CpuModel DEBUG
   U_UART_TX DEBUG INFO
   U_UART_RX PASSED INFO DEBUG

   ReadLogEnables will also read a file of the format:

   U_CpuModel
   DEBUG
   U_UART_TX
   DEBUG
   U_UART_TX
   INFO
   . . .

.. _UTILITY/AlertLogPkg/IsLogEnabledGetLogEnable:

IsLogEnabled /GetLogEnable
==========================

:vhdlcode:`IsLoggingEnabled` returns true when logging is enabled for a particular :vhdlcode:`AlertLogID`.

.. code-block:: VHDL

   impure function IsLogEnabled(Level : LogType) return boolean ;
   impure function IsLogEnabled(AlertLogID : AlertLogIDType ; Level : LogType)
       return boolean ;
   . . .
   if IsLogEnabled(UartID, DEBUG) then
   . . .

:vhdlcode:`GetLogEnable` is a synonym for :vhdlcode:`IsLogEnabled`.

.. code-block:: VHDL

   impure function GetLogEnable(AlertLogID : AlertLogIDType ;  Level : LogType)
   return boolean ;
   impure function GetLogEnable(Level : LogType) return boolean ;

.. _UTILITY/AlertLogPkg/SetAlertEnableAlertEnableDisable:

SetAlertEnable: Alert Enable / Disable
======================================

Alerts are enabled by default. :vhdlcode:`SetAlertEnable` allows alert levels to be individually enabled or disabled.
When used without :vhdlcode:`AlertLogID`, :vhdlcode:`SetAlertEnable` sets a value for all :vhdlcode:`AlertLogIDs`.

.. code-block:: VHDL

   procedure SetAlertEnable(Level : AlertType ;  Enable : boolean) ;
   . . .
   --                       Level,      Enable
   SetAlertEnable(WARNING, FALSE) ;

When an :vhdlcode:`AlertLogID` is used, :vhdlcode:`SetAlertEnable` sets a value for that :vhdlcode:`AlertLogID`, and if
:vhdlcode:`DescendHierarchy` is TRUE, the :vhdlcode:`AlertLogIDs` of its children.

.. code-block:: VHDL

   procedure SetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType ;
   Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

.. _UTILITY/AlertLogPkg/GetAlertEnable:

GetAlertEnable
==============

Get the value of the current alert enable for either a specific :vhdlcode:`AlertLogId` or for the global alert counter.

.. code-block:: VHDL

   -- Hierarchy
   impure function GetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType)
   return boolean ;
   -- Global Alert Counter
   impure function GetAlertEnable(Level : AlertType) return boolean ;

.. _UTILITY/AlertLogPkg/ClearAlertsResetAlertCounts:

ClearAlerts: Reset Alert Counts
===============================

:vhdlcode:`ClearAlerts` resets alert counts to 0. Recommended as an alternative to :vhdlcode:`SetGlobalAlertEnable` –
just after the design enters reset, call :vhdlcode:`ClearAlerts`.

.. code-block:: VHDL

   procedure ClearAlerts ;

.. _UTILITY/AlertLogPkg/ClearAlertCountsResetAlertAndAlertStopCounts:

ClearAlertCounts: Reset Alert and Alert Stop Counts
===================================================

:vhdlcode:`ClearAlertCounts` resets alert counts to 0 and alert stop counts back to their default.

.. code-block:: VHDL

   procedure ClearAlertCounts ;

.. _UTILITY/AlertLogPkg/SetGlobalAlertEnableAlertGlobalEnableDisable:

SetGlobalAlertEnable: Alert Global Enable / Disable
===================================================

:vhdlcode:`SetGlobalAlertEnable` allows Alerts to be globally enabled and disabled. The Global Alert Enable is enabled
by default.

.. code-block:: VHDL

   procedure SetGlobalAlertEnable (A : boolean := TRUE) ;
   impure function SetGlobalAlertEnable (A : boolean := TRUE) return boolean ;

Originally intended to be used to disable alerts during startup, as shown below. Instead, for most applications we
recommend using :vhdlcode:`ClearAlerts` just after reset.

.. code-block:: VHDL

   InitAlerts : process
     constant DisableAlerts : boolean := SetGlobalAlertEnable(FALSE);
   begin
     wait until nReset = '1' ; --  Deassertion of reset
     SetGlobalAlertEnable(TRUE)  ;  -- enable alerts

.. _UTILITY/AlertLogPkg/GetGlobalAlertEnable:

GetGlobalAlertEnable
====================

Get the current value of the global alert enable

.. code-block:: VHDL

   impure function GetGlobalAlertEnable return boolean ;

.. _UTILITY/AlertLogPkg/StopCountAndPrintCount:

Stop Count and Print Count
**************************

.. _UTILITY/AlertLogPkg/SetAlertStopCountAlertStopCounts:

SetAlertStopCount: Alert Stop Counts
====================================

:vhdlcode:`SetAlertStopCount` stops a simulation after a specified number of alerts have occurred. For tests that have
numerous errors, this allows the test case to stop sooner and debugging to start.

If an alert stop count is reached, the simulation stops with status STOPLIMIT. When used without :vhdlcode:`AlertLogID`,
:vhdlcode:`SetAlertStopCount` sets the alert stop count for the top level to the specified value.

.. code-block:: VHDL

   procedure SetAlertStopCount(Level : AlertType ;  Count : integer) ;
   . . .
   --                Level,     Count
   SetAlertStopCount(ERROR,      20) ;  -- Stop if 20 errors occur

When used with an :vhdlcode:`AlertLogID`, :vhdlcode:`SetAlertStopCount` sets the value for the specified
:vhdlcode:`AlertLogID` and adjusts the :vhdlcode:`AlertStopCount` at each parent by that amount.

.. code-block:: VHDL

   procedure SetAlertStopCount(AlertLogID : AlertLogIDType ;
       Level : AlertType ;  Count : integer) ;
   . . .
   --                AlertLogID,  Level,      Count
   SetAlertStopCount(UartID,      ERROR,      20) ;

By default, the :vhdlcode:`AlertStopCount` for WARNING and ERROR are :vhdlcode:`integer'right`, and FAILURE is 0.

.. _UTILITY/AlertLogPkg/GetAlertStopCount:

GetAlertStopCount
=================

Get the value of the current alert stop count for either a specific :vhdlcode:`AlertLogId` or for the global alert
counter.

.. code-block:: VHDL

   -- Hierarchy
   impure function GetAlertStopCount(
     AlertLogID : AlertLogIDType ;
     Level : AlertType
   ) return integer ;
   -- Global Alert Stop Count
   impure function GetAlertStopCount(Level : AlertType) return integer ;

.. _UTILITY/AlertLogPkg/ClearAlertStopCountsResetAlertStopCounts:

ClearAlertStopCounts: Reset Alert Stop Counts
=============================================

:vhdlcode:`ClearAlertStopCounts` resets alert stop counts back to their default.

.. code-block:: VHDL

   procedure ClearAlertStopCounts ;

.. _UTILITY/AlertLogPkg/SetAlertPrintCount:

SetAlertPrintCount
==================

Sets a maximum number of times to print an Alert level for an :vhdlcode:`AlertLogID`. The :vhdlcode:`AlertPrintCount` is
specified either as an integer value for a particular level or as an :vhdlcode:`AlertCountType` value that specifies a
count for each Alert level. Applies only to that ID, hence, if a child ID does not exceed its count, it prints,
independent of the :vhdlcode:`AlertPrintCount` of its parent. When an ID is not specified, the ID of the default bin is
used (:vhdlcode:`ALERTLOG_DEFAULT_ID`).

.. code-block:: VHDL

   procedure SetAlertPrintCount(
       AlertLogID : AlertLogIDType ;  Level : AlertType ;  Count : integer) ;
   procedure SetAlertPrintCount(Level : AlertType ;  Count : integer) ;
   procedure SetAlertPrintCount(
       AlertLogID : AlertLogIDType ;  Count : AlertCountType) ;
   procedure SetAlertPrintCount(Count : AlertCountType) ;

.. _UTILITY/AlertLogPkg/GetAlertPrintCount:

GetAlertPrintCount
==================

Returns the :vhdlcode:`AlertPrintCount` for an ID – either as an integer value for a particular level or as an
:vhdlcode:`AlertCountType` value that contains a count for each Alert level. When an ID is not specified, the ID of the
default bin is used (:vhdlcode:`ALERTLOG_DEFAULT_ID`).

.. code-block:: VHDL

   impure function GetAlertPrintCount(AlertLogID : AlertLogIDType ;  Level :
   AlertType) return integer ;
     impure function GetAlertPrintCount(Level : AlertType) return integer ;
     impure function GetAlertPrintCount(AlertLogID : AlertLogIDType) return
   AlertCountType ;
     impure function GetAlertPrintCount return AlertCountType ;

.. _UTILITY/AlertLogPkg/GettingCounts:

Getting Counts
**************

.. _UTILITY/AlertLogPkg/AlertCountType:

AlertCountType
==============

Alerts are stored as a value of :vhdlcode:`AlertCountType`.

.. code-block:: VHDL

   subtype AlertIndexType is AlertType range FAILURE to WARNING ;
   type    AlertCountType is array (AlertIndexType) of integer ;

CAUTION: When working with values of :vhdlcode:`AlertCountType`, be sure to use named association as the type ordering
may change in the future.

.. code-block:: VHDL

   variable ExternalErrors : AlertCountType ;
   . . .
   ExternalErrors := (FAILURE => 0, ERROR => 6, WARNING => 0) ;

.. _UTILITY/AlertLogPkg/GetAlertCount:

GetAlertCount
=============

:vhdlcode:`GetAlertCount` returns the :vhdlcode:`AlertCount` value at :vhdlcode:`AlertLogID`. :vhdlcode:`GetAlertCount`
is overloaded to return either :vhdlcode:`AlertCountType` or integer.

.. code-block:: VHDL

   impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID)
       return AlertCountType ;
   impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID)
       return integer ;
   . . .
   TopTotalErrors  := GetAlertCount ;          -- AlertCount for Top of hierarchy
   UartTotalErrors := GetAlertCount(UartID) ;  -- AlertCount for UartID

.. _UTILITY/AlertLogPkg/GetEnabledAlertCount:

GetEnabledAlertCount
====================

:vhdlcode:`GetEnabledAlertCount` is similar to :vhdlcode:`GetAlertCount` except it returns 0 for disabled alert levels.
:vhdlcode:`GetEnabledAlertCount` is overloaded to return either :vhdlcode:`AlertCountType` or integer.

.. code-block:: VHDL

   impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType :=
       ALERTLOG_BASE_ID) return AlertCountType ;
   impure function GetEnabledAlertCount (AlertLogID : AlertLogIDType :=
       ALERTLOG_BASE_ID) return integer ;
   . . .
   TopTotalErrors  := GetEnabledAlertCount ;           -- Top of hierarchy
   UartTotalErrors := GetEnabledAlertCount(UartID) ;   -- UartID

.. _UTILITY/AlertLogPkg/GetDisabledAlertCount:

GetDisabledAlertCount
=====================

:vhdlcode:`GetDisabledAlertCount` returns the count of disabled errors for either the entire design hierarchy or a
particular :vhdlcode:`AlertLogID`. :vhdlcode:`GetDisabledAlertCount` is relevant since a "clean" passing design will not
have any disabled alert counts.

.. code-block:: VHDL

   impure function GetDisabledAlertCount return AlertCountType ;
   impure function GetDisabledAlertCount return integer ;
   impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType)
       return AlertCountType ;
   impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return integer ;

Note that disabled errors are not added to higher levels in the hierarchy. Hence, often :vhdlcode:`GetAlertCount` /=
:vhdlcode:`GetEnabledAlertCount` + :vhdlcode:`GetDisabledAlertCount`.

.. _UTILITY/AlertLogPkg/MathOnAlertCountType:

Math on AlertCountType
======================

.. code-block:: VHDL

   function "+" (L, R : AlertCountType) return AlertCountType ;
   function "-" (L, R : AlertCountType) return AlertCountType ;
   function "-" (R : AlertCountType) return AlertCountType ;
   . . .
   TotalAlertCount := Phase1Count + Phase2Count ;
   TotalErrors := GetAlertCount - ExpectedErrors ;
   NegateErrors := -ExpectedErrors ;

.. _UTILITY/AlertLogPkg/SumAlertCountAlertCountTypeToIntegerErrorCount:

SumAlertCount: AlertCountType to Integer Error Count
====================================================

:vhdlcode:`SumAlertCount` sums up the FAILURE, ERROR, and WARNING values into a single integer value.

.. code-block:: VHDL

   impure function SumAlertCount(AlertCount: AlertCountType) return integer ;
   . . .
   ErrorCountInt := SumAlertCount(AlertCount) ;

.. _UTILITY/AlertLogPkg/AlertAndLogPrefixAndSuffixToMessage:

Alert and Log Prefix and Suffix to Message
******************************************

A prefix and suffix can be added to a message that is printed with Alert or Log. These are set on an
:vhdlcode:`AlertLogID` basis using the following operations.

.. code-block:: VHDL

   procedure SetAlertLogPrefix(AlertLogID : AlertLogIDType; Name : string ) ;
   procedure UnSetAlertLogPrefix(AlertLogID : AlertLogIDType) ;
   impure function GetAlertLogPrefix(AlertLogID : AlertLogIDType) return string ;
   procedure SetAlertLogSuffix(AlertLogID : AlertLogIDType; Name : string ) ;
   procedure UnSetAlertLogSuffix(AlertLogID : AlertLogIDType) ;
   impure function GetAlertLogSuffix(AlertLogID : AlertLogIDType) return string ;

.. _UTILITY/AlertLogPkg/TextBasedTestCaseReportsViaReportAlerts:

Text Based Test Case Reports via ReportAlerts
*********************************************

For most purposes calling :vhdlcode:`EndOfTestReports` and using the default text based reports is sufficient –
particularly if you are using OSVVM scripting which also produces an HTML test case report that provides a superset of
the information in the text based test case reports.

On the other hand, if you are using your own scripts to run the test cases, you may wish to use additional options
and/or settings with :vhdlcode:`ReportAlerts`.

.. _UTILITY/AlertLogPkg/ReportSummary:

Report Summary
==============

The report summary is the first line printed by :vhdlcode:`ReportAlerts`/:vhdlcode:`ReportNonZeroAlerts`

.. code-block:: text

   %%      381100.0 ns  DONE  FAILED  t17_print_ctrl  Total Error(s) = 2  Failures: 0
   Errors: 0  Warnings: 0   Total Disabled Error(s) = 2  Failures: 0  Errors: 2
   Warnings: 0  Passed: 0  Affirmations Checked: 2

Note in the above message, two affirmations were done and they both resulted in an error, however, the error was
disabled (see :ref:`SetAlertEnable <UTILITY/AlertLogPkg/SetAlertEnableAlertEnableDisable>`) so it reported as a Disabled
Error.

Options can be enabled or disabled using :vhdlcode:`SetAlertLogOptions`. Let's look at the report piece by piece.

If Total Errors /= 0, then the following part of the message prints. In this case, Total Errors is nonzero since
:vhdlcode:`FailOnDisabledErrors` is enabled (default) and the disabled errors count as test errors. Hence, Failures,
Errors, and Warnings are all 0.

.. code-block:: text

   Total Error(s) = 2  Failures: 0  Errors: 0  Warnings: 0

If :vhdlcode:`FailOnDisabledErrors` is disabled, then the same test will PASS as shown below.

.. code-block:: text

   %%      381100.0 ns  DONE  PASSED  t17_print_ctrl  Total Disabled Error(s) = 2
   Passed: 0  Affirmations Checked: 2

Next is the Total Disabled Errors summary. It will print if the :vhdlcode:`DisabledAlerts` /= 0 or if
:vhdlcode:`PrintDisabledAlerts` is enabled (default is disabled).

.. code-block:: text

   Total Disabled Error(s) = 2

Next is the details of the Disabled Errors. These will print if :vhdlcode:`FailOnDisabledErrors` is enabled and
:vhdlcode:`DisabledAlerts` /= 0 or if :vhdlcode:`PrintDisabledAlerts` is enabled.

.. code-block:: text

   Total Disabled Error(s) = 2  Failures: 0  Errors: 2  Warnings: 0

Next is the printing of the pass and affirmation counts. If :vhdlcode:`PrintPassed` is enabled (default), the passed
count will be printed. If :vhdlcode:`PrintAffirmations` is enabled (default is disabled) or Affirmation Count /= 0 then
the passed and affirmation counts will be printed.

.. code-block:: text

   Passed: 0  Affirmations Checked: 2

.. _UTILITY/AlertLogPkg/ReportDetails:

Report Details
==============

When in hierarchy mode, a summary for each :vhdlcode:`AlertLogID` will be printed. This can include the following
details. Each line summary starts with "%%".

.. code-block:: text

   %%    Default   Failures: 0  Errors: 2  Warnings: 0  Disabled Failures: 0  Errors:
   0  Warnings: 0  Passed: 2  Affirmations: 4
   %%    OSVVM     Failures: 0  Errors: 0  Warnings: 0  Disabled Failures: 0  Errors:
   0  Warnings: 0  Passed: 0  Affirmations: 0
   %%    Cpu1      Failures: 0  Errors: 2  Warnings: 0  Disabled Failures: 0  Errors:
   0  Warnings: 0  Passed: 2  Affirmations: 4
   %%    UartTx    Failures: 0  Errors: 0  Warnings: 0  Disabled Failures: 0  Errors:
   2  Warnings: 0  Passed: 2  Affirmations: 4
   %%    UartRx    Failures: 0  Errors: 2  Warnings: 0  Disabled Failures: 0  Errors:
   0  Warnings: 0  Passed: 2  Affirmations: 4

The Failures, Errors, and Warnings always prints.

Disabled Failures, Errors, and Warnings only print if :vhdlcode:`PrintDisabledAlerts` is enabled (default is disabled).

Passed only prints if :vhdlcode:`PrintPassed` is enabled (default).

Affirmations only prints if :vhdlcode:`PrintAffirmations` is enabled (default is disabled).

With :vhdlcode:`PrintDisabledAlerts` disabled (default), :vhdlcode:`PrintPassed` enabled (default), and
:vhdlcode:`PrintAffirmations` disabled (default), and :vhdlcode:`DisabledAlerts` = 0, the report will be simplified to
the following.

.. code-block:: text

   %%    Default   Failures: 0  Errors: 2  Warnings: 0  Passed: 2
   %%    OSVVM     Failures: 0  Errors: 0  Warnings: 0  Passed: 0
   %%    Cpu1      Failures: 0  Errors: 2  Warnings: 0  Passed: 2
   %%    UartTx    Failures: 0  Errors: 0  Warnings: 0  Passed: 2
   %%    UartRx    Failures: 0  Errors: 2  Warnings: 0  Passed: 2

.. _UTILITY/AlertLogPkg/ReportAlertsReportingAlerts:

ReportAlerts: Reporting Alerts
==============================

At test completion call :vhdlcode:`ReportAlerts` to generate a simple text based report. If you call
:vhdlcode:`EndOfTestReports`, it calls :vhdlcode:`ReportAlerts`, so you don’t have to.

.. code-block:: VHDL

   procedure ReportAlerts (
       Name            : string := "" ;
       AlertLogID      : AlertLogIDType := ALERTLOG_BASE_ID ;
       ExternalErrors  : AlertCountType := (others => 0) ;
       ReportAll       : Boolean         := FALSE
   ) ;

:vhdlcode:`ReportAlerts` has 4 optional parameters: :vhdlcode:`Name`, :vhdlcode:`AlertLogID`,
:vhdlcode:`ExternalErrors`, and :vhdlcode:`ReportAll`. :vhdlcode:`Name` overrides the name specified by
:vhdlcode:`SetTestName`. :vhdlcode:`AlertLogID` allows reporting alerts for a specific :vhdlcode:`AlertLogID` and its
children (if any). :vhdlcode:`ExternalErrors` allows separately detected errors to be reported.
:vhdlcode:`ExternalErrors` is type :vhdlcode:`AlertCountType` and the value
:vhdlcode:`(FAILURE => 0, ERROR => 5, WARNING => 1)` indicates detection logic separate from :vhdlcode:`AlertLogPkg` saw
0 Failures, 5 Errors, and 1 Warning. See notes under :ref:`AlertCountType <UTILITY/AlertLogPkg/AlertCountType>`. When
:vhdlcode:`ReportAll` is true, :vhdlcode:`ReportAlerts` reports a summary as well as details for each source – whether
the test failed or passed.

.. code-block:: VHDL

   --            Name,   AlertLogID,  ExternalErrors
   ReportAlerts("Uart1", UartID,      (FAILURE => 0, ERROR => 5, WARNING => 1) ) ;

.. _UTILITY/AlertLogPkg/ReportNonZeroAlerts:

ReportNonZeroAlerts
===================

When in hierarchy mode, a summary for each :vhdlcode:`AlertLogID` will be printed. This can include the following
details. Each summary starts with "%%".

Within the hierarchy, if a level has no alerts set, then that level will not be printed.

.. code-block:: VHDL

   procedure ReportNonZeroAlerts (
       Name             : string := OSVVM_STRING_INIT_PARM_DETECT ;
       AlertLogID       : AlertLogIDType := ALERTLOG_BASE_ID ;
       ExternalErrors   : AlertCountType := (others => 0)
   ) ;

.. _UTILITY/AlertLogPkg/OverloadedReportAlertsForReportingAlertCounts:

Overloaded ReportAlerts for Reporting AlertCounts
=================================================

:vhdlcode:`ReportAlerts` can also be used to print a passed/failed message for an :vhdlcode:`AlertCount` that is passed
into the procedure call. This will not use any of the internal settings or information.

.. code-block:: VHDL

   procedure ReportAlerts ( Name : String ; AlertCount : AlertCountType) ;

This is useful to accumulate values returned by different phases of a test that need to be reported separately.

.. code-block:: VHDL

   ReportAlerts("Test1: Final", Phase1AlertCount + Phase2AlertCount) ;

.. _UTILITY/AlertLogPkg/AlertAndLogOutputControlOptions:

Alert and Log Output Control Options
************************************

All OSVVM Alert and Log output controls get their initial value from a setting in :file:`OsvvmSettingsPkg_default.vhd`.

For most projects setting them in the :vhdlcode:`OsvvmSettingsPkg` for the entire project should be sufficient. These
values can be customized for a project as described in the :ref:`OSVVM Settings User Guide <UTILITY/OsvvmSettings>`.
This is the recommended approach.

.. _UTILITY/AlertLogPkg/SettingsInOsvvmSettingsPkgDefaultVhd:

Settings In OsvvmSettingsPkg_default.vhd
========================================

See :ref:`OSVVM Settings User Guide <UTILITY/OsvvmSettings>` for details on these and how to change them. This is the
recommended approach to change these values. Note that there are additional values that do not have a setting.

.. _UTILITY/AlertLogPkg/SetAlertLogJustify:

SetAlertLogJustify
==================

:vhdlcode:`SetAlertLogJustify` sets the justify variable. When the justify variable is true, the message of Alerts and
Logs are justified so they align. Default value is determined by the setting :vhdlcode:`ALERT_LOG_JUSTIFY_ENABLE`.

.. code-block:: VHDL

   procedure SetAlertLogJustify(Enable : boolean := TRUE) ;

.. _UTILITY/AlertLogPkg/OsvvmOptionsType:

OsvvmOptionsType
================

:vhdlcode:`OsvvmOptionsType` defines the values for options. User values are: :vhdlcode:`OPT_USE_DEFAULT`,
:vhdlcode:`DISABLED`, :vhdlcode:`FALSE`, :vhdlcode:`ENABLED`, :vhdlcode:`TRUE`. The values :vhdlcode:`DISABLED` and
:vhdlcode:`FALSE` are handled the same. The values :vhdlcode:`ENABLED` and :vhdlcode:`TRUE` are treated the same. The
value :vhdlcode:`OPT_USE_DEFAULT` causes the variable to use its default value. :vhdlcode:`OsvvmOptionsType` is defined
in :vhdlcode:`OsvvmGlobalPkg`.

.. code-block:: VHDL

   type OsvvmOptionsType is (OPT_INIT_PARM_DETECT, OPT_USE_DEFAULT, DISABLED, FALSE,
   ENABLED, TRUE) ;

.. _UTILITY/AlertLogPkg/DeprecatedSetAlertLogOptions:

Deprecated: SetAlertLogOptions
==============================

:vhdlcode:`SetAlertLogOptions` allows individual settings to be made at run time. For most of these this is not
recommended. This may be removed entirely in the future or selected parameters removed.

The call interface for :vhdlcode:`SetAlertLogOptions` is shown below. Note that parameters that have already been
deprecated and have no impact are not shown.

.. code-block:: VHDL

   procedure SetAlertLogOptions (
     FailOnWarning           : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     FailOnDisabledErrors    : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     FailOnRequirementErrors : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     ReportHierarchy         : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertErrorCount    : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertLevel         : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertName          : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteAlertTime          : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogErrorCount      : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogLevel           : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogName            : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     WriteLogTime            : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintPassed             : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintAffirmations       : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintDisabledAlerts     : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintRequirements       : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     PrintIfHaveRequirements : OsvvmOptionsType := OPT_INIT_PARM_DETECT;
     DefaultPassedGoal       : integer             := integer'left ;
     WriteTimeLast           : OsvvmOptionsType    := OPT_INIT_PARM_DETECT ;
     TimeJustifyAmount       : integer             := integer'left
   ) ;

:vhdlcode:`SetAlertLogOptions` will change as :vhdlcode:`AlertLogPkg` evolves. Use of named association is required to
ensure future compatibility. Only specify the values that need to change. Values not specified in the call will not
change (hence the peculiar initial values on the parameters).

.. code-block:: VHDL

   SetAlertLogOptions (
       FailOnWarning            => FALSE,
       FailOnDisabledErrors     => FALSE
   ) ;

The following tables explain the options, their initial value and the corresponding constant in
:vhdlcode:`OsvvmSettingsPkg`.

Options that impact what causes a test to fail:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`FailOnWarning`
       | :vhdlcode:`ALERT_LOG_FAIL_ON_WARNING`
     - Count warnings as test errors.
     - TRUE
   * - | :vhdlcode:`FailOnDisabledErrors`
       | :vhdlcode:`ALERT_LOG_FAIL_ON_DISABLED_ERRORS`
     - If :vhdlcode:`FailOnDisabledErrors` is enabled and :vhdlcode:`DisabledAlerts` /= 0, then

       #. Test Fails
       #. :vhdlcode:`DisabledAlerts` are printed in the report summary.
       #. :vhdlcode:`DisabledAlerts` print for each :vhdlcode:`AlertLogID`
     - TRUE
   * - | :vhdlcode:`FailOnRequirementErrors`
       | :vhdlcode:`ALERT_LOG_FAIL_ON_REQUIREMENT_ERRORS`
     - If :vhdlcode:`FailOnRequirementErrors` is enabled, a Test fails if it does not reach its requirements (PASSED
       goals).
     - TRUE

Options that impact requirements:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`DefaultPassedGoal`
       | :vhdlcode:`ALERT_LOG_DEFAULT_PASSED_GOAL`
     - Set the Default Passed Goal for :vhdlcode:`ReadSpecification` and :vhdlcode:`GetReqID`
     - 1

Options that impact information printed by both Alert and Log:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`WriteTimeLast`
       | :vhdlcode:`ALERT_LOG_WRITE_TIME_FIRST`
     - Write time last when TRUE or first when FALSE.
     - FALSE
   * - | :vhdlcode:`TimeJustifyAmount`
       | :vhdlcode:`ALERT_LOG_TIME_JUSTIFY_AMOUNT`
     - Print level.
     - 9

Options that impact information printed by Alert:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`WriteAlertErrorCount`
       | :vhdlcode:`ALERT_LOG_WRITE_ERRORCOUNT`
     - Print Error Count immediately after %% Alert
     - FALSE
   * - | :vhdlcode:`WriteAlertLevel`
       | :vhdlcode:`ALERT_LOG_WRITE_LEVEL`
     - Print level.
     - TRUE
   * - | :vhdlcode:`WriteAlertName`
       | :vhdlcode:`ALERT_LOG_WRITE_NAME`
     - Print :vhdlcode:`AlertLogID` name.
     - TRUE
   * - | :vhdlcode:`WriteAlertTime`
       | :vhdlcode:`ALERT_LOG_WRITE_TIME`
     - Alerts print time.
     - TRUE

Options that impact information printed by Log:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`WriteLogErrorCount`
       | :vhdlcode:`ALERT_LOG_WRITE_ERRORCOUNT`
     - Print Error Count immediately after %% Log
     - FALSE
   * - | :vhdlcode:`WriteLogLevel`
       | :vhdlcode:`ALERT_LOG_WRITE_LEVEL`
     - Print level.
     - TRUE
   * - | :vhdlcode:`WriteLogName`
       | :vhdlcode:`ALERT_LOG_WRITE_NAME`
     - Print :vhdlcode:`AlertLogID` name.
     - TRUE
   * - | :vhdlcode:`WriteLogTime`
       | :vhdlcode:`ALERT_LOG_WRITE_TIME`
     - Logs print time.
     - TRUE

Options that impact the text report printed by :vhdlcode:`ReportAlerts`:

.. list-table::
   :header-rows: 1
   :widths: 313 335 65

   * - Parameter / Constant Name
     - Description
     - Value
   * - | :vhdlcode:`ReportHierarchy`
       | :vhdlcode:`ALERT_LOG_REPORT_HIERARCHY`
     - When multiple :vhdlcode:`AlertLogIDs` exist, print an error summary for each level.
     - TRUE
   * - | :vhdlcode:`PrintPassed`
       | :vhdlcode:`ALERT_LOG_PRINT_PASSED`
     - If :vhdlcode:`PrintPassed` is enabled, print number of passed logs in the report summary and for each
       :vhdlcode:`AlertLogID`
     - TRUE
   * - | :vhdlcode:`PrintAffirmations`
       | :vhdlcode:`ALERT_LOG_PRINT_AFFIRMATIONS`
     - If :vhdlcode:`PrintAffirmations` is enabled, print the number of affirmations in the report summary and for each
       :vhdlcode:`AlertLogID`
     - FALSE
   * - | :vhdlcode:`PrintDisabledAlerts`
       | :vhdlcode:`ALERT_LOG_PRINT_DISABLED_ALERTS`
     - If :vhdlcode:`PrintDisabledAlerts` is Enabled, print :vhdlcode:`DisabledAlerts` in the report summary and for
       each :vhdlcode:`AlertLogID`
     - FALSE
   * - | :vhdlcode:`PrintRequirements`
       | :vhdlcode:`ALERT_LOG_PRINT_REQUIREMENTS`
     - If :vhdlcode:`PrintRequirements` is enabled, then

       #. In the summary of :vhdlcode:`ReportAlerts`, print a requirements summary (# met of # total).
       #. In the detailed report, print a requirements :vhdlcode:`ReportAlerts`, print a requirements summary
          (# met of # total).
     - FALSE
   * - | :vhdlcode:`PrintIfHaveRequirements`
       | :vhdlcode:`ALERT_LOG_PRINT_IF_HAVE_REQUIREMENTS`
     - If :vhdlcode:`PrintIfHaveRequirements` is enabled and the test has requirements, then in the summary of
       :vhdlcode:`ReportAlerts`, print a requirements summary (# met of # total).
     - TRUE

In the event you missed the earlier notice, :vhdlcode:`SetAlertLogOptions` is deprecated. It is recommended to use
:vhdlcode:`OsvvmSettingsPkg` instead. See :ref:`Osvvm Settings User Guide <UTILITY/OsvvmSettings>`.

.. _UTILITY/AlertLogPkg/DeprecatedReportAlertLogOptionsPrintReportOptions:

Deprecated: ReportAlertLogOptions: Print Report Options
=======================================================

Prints out :vhdlcode:`AlertLogPkg` Report Options.

.. _UTILITY/AlertLogPkg/DeprecatedGettingAlertLogReportOptions:

Deprecated: Getting AlertLog Report Options
===========================================

Report options can be retrieved with one of the Get functions below.

.. code-block:: VHDL

   function GetAlertLogFailOnWarning        return OsvvmOptionsType ;
   function GetAlertLogFailOnDisabledErrors return OsvvmOptionsType ;
   function GetAlertLogReportHierarchy      return OsvvmOptionsType ;
   function GetAlertLogHierarchyInUse       return OsvvmOptionsType ;
   function GetAlertLogWriteAlertLevel      return OsvvmOptionsType ;
   function GetAlertLogWriteAlertName       return OsvvmOptionsType ;
   function GetAlertLogWriteAlertTime       return OsvvmOptionsType ;
   function GetAlertLogWriteLogLevel        return OsvvmOptionsType ;
   function GetAlertLogWriteLogName         return OsvvmOptionsType ;
   function GetAlertLogWriteLogTime         return OsvvmOptionsType ;

Note while the following are still supported, they just return the constant from :file:`OsvvmSettingsPkg_default.vhd`
identified in :vhdlcode:`SetAlertLogOptions`

.. code-block:: VHDL

   function GetAlertLogAlertPrefix          return string ;
   function GetAlertLogLogPrefix            return string ;
   function GetAlertLogReportPrefix         return string ;
   function GetAlertLogDoneName             return string ;
   function GetAlertLogPassName             return string ;
   function GetAlertLogFailName             return string ;

.. _UTILITY/AlertLogPkg/DeallocatingAndReInitializingTheDataStructure:

Deallocating and Re-initializing the Data structure
***************************************************

.. _UTILITY/AlertLogPkg/DeallocateAlertLogStruct:

DeallocateAlertLogStruct
========================

:vhdlcode:`DeallocateAlertLogStruct` deallocates all temporary storage allocated by :vhdlcode:`AlertLogPkg`. Also see
:vhdlcode:`ClearAlerts`.

.. _UTILITY/AlertLogPkg/InitializeAlertLogStruct:

InitializeAlertLogStruct
========================

:vhdlcode:`InitializeAlertLogStruct` is used after :vhdlcode:`DeallocateAlertLogStruct` to create and initialize
internal storage.

.. _UTILITY/AlertLogPkg/DeprecatedOlderCSVTypeReporting:

Deprecated: Older CSV Type Reporting
************************************

OSVVM can also create Test Completion and Requirements reports as CSV files. The approach using CSV files requires
considerable effort on your part.

These have been deprecated in favor of the VHDL (YAML) + Scripting (HTML, JUnit, CSV) approach that happen mostly
autonomously with OSVVM VHDL + OSVVM Scripting.

.. _UTILITY/AlertLogPkg/DeprecatedReportingTestCompletionCSVReports:

Deprecated Reporting Test Completion: CSV Reports
=================================================

As an alternative to creating YAML reports (from VHDL) and HTML and Junit reports (from OSVVM Scripting), OSVVM has an
older CSV based approach.

This approach requires a significant amount of work that is specific to your test suite. As a result, it is deprecated.

The process for CSV based test tracking involves the following steps:

* :vhdlcode:`WriteTestSummary` – write out a one-line test summary. Each test in a test suite writes to the same results
  file.
* :vhdlcode:`ReadTestSummaries` – read in a set of test summaries written out by :vhdlcode:`WriteTestSummary`.
* :vhdlcode:`ReportTestSummaries` – Print a summary for each test that was read by :vhdlcode:`ReadTestSummaries`

In addition, :vhdlcode:`WriteAlerts` produces a CSV based detailed alert report.

CSV was explored as an initial methodology to write out reports for consumption by other tools. Unfortunately, CSV does
not do an adequate job in conveying hierarchical relationships and it has been set aside in preference of YAML reports.

.. _UTILITY/AlertLogPkg/DeprecatedWriteAlerts:

Deprecated: WriteAlerts
-----------------------

:vhdlcode:`WriteAlerts` prints all the information in :vhdlcode:`ReportAlerts` in a CSV format.

.. code-block:: VHDL

   procedure WriteAlerts (
     FileName    : string ;
     AlertLogID  : AlertLogIDType := ALERTLOG_BASE_ID ;
     OpenKind    : File_Open_Kind := WRITE_MODE
   ) ;

The first line of :vhdlcode:`WriteAlerts` prints the report summary in a CSV format (see
:ref:`WriteTestSummary <UTILITY/AlertLogPkg/DeprecatedWriteTestSummary>`). The format of :vhdlcode:`WriteAlerts` is as
follows:

.. code-block:: text

   <Name>,<PassedGoal>,<PassedCount>,<TotalErrors>,<Failures>,<Errors>,<Warnings>,<Af
   firmCount>

.. _UTILITY/AlertLogPkg/DeprecatedWriteTestSummary:

Deprecated: WriteTestSummary
----------------------------

:vhdlcode:`WriteTestSummary` creates a one line print of the information that is in the report summary (the first line
of :vhdlcode:`ReportAlerts`) as a CSV. :vhdlcode:`WriteTestSummary` is intended to be used by each separate test in the
test suite.

.. code-block:: VHDL

   procedure WriteTestSummary(
     FileName : string ;
     OpenKind : File_Open_Kind := APPEND_MODE ) ;

The following :vhdlcode:`WriteTestSummary` adds a test summary for the current test to the :file:`OsvvmTestSummary.txt`
file. The default ":vhdlcode:`APPEND_MODE`" is used by all tests except maybe the first test. If the regression manager
does not delete the :file:`OsvvmTestSummary.txt`, then the first test will use ":vhdlcode:`WRITE_MODE`".

.. code-block:: VHDL

   WriteTestSummary("./results/OsvvmTestSummary.txt") ;

:vhdlcode:`WriteTestSummary` prints in the following format. :vhdlcode:`ReqGoal` is the count of the number of
requirements that have :vhdlcode:`PassedGoals`. :vhdlcode:`ReqCount` is the count of the number of requirements whose
:vhdlcode:`PassedCount` is greater or equal to the :vhdlcode:`PassedGoal`.

.. code-block:: text

   <Name>,<ReqGoal>,<ReqCount>,<TotalErrors>,<Failures>,<Errors>,<Warnings>,<AffirmCo
   unt>,<PassedCount>

.. _UTILITY/AlertLogPkg/DeprecatedReadTestSummaries:

Deprecated: ReadTestSummaries
-----------------------------

:vhdlcode:`ReadTestSummaries` reads in the file created by :vhdlcode:`WriteTestSummary` and records each separate test
results as a requirement.

.. code-block:: VHDL

   procedure ReadTestSummaries (FileName : string) ;

Calling :vhdlcode:`ReadTestSummaries`:

.. code-block:: VHDL

   ReadTestSummaries("./results/OsvvmTestSummary.txt") ;

.. _UTILITY/AlertLogPkg/DeprecatedReportTestSummaries:

Deprecated: ReportTestSummaries
-------------------------------

:vhdlcode:`ReportTestSummaries` produces a report of the results from the test summary file.
:vhdlcode:`ReportTestSummaries` has no input parameters and is called as follows.

.. code-block:: VHDL

   ReportTestSummaries ;

:vhdlcode:`ReportTestSummaries` produces a report such as the following. Note each line starts with %%. The
"Affirmations …" printed on a separate line is a line wrap in the text below.

.. code-block:: text

   %%  PASSED test_1    Total Error(s) = 0  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 11 of 11  Requirements Passed: 2 of 2
   %%  FAILED test_2    Total Error(s) = 2  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 22 of 22  Requirements Passed: 2 of 4
   %%  PASSED test_3    Total Error(s) = 0  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 33 of 33  Requirements Passed: 6 of 6
   %%  FAILED test_4    Total Error(s) = 2  Failures: 0  Errors: 2  Warnings: 0
   Affirmations Passed: 44 of 44  Requirements Passed: 6 of 8
   %%  PASSED test_5    Total Error(s) = 0  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 55 of 55  Requirements Passed: 10 of 10
   %%  PASSED test_6    Total Error(s) = 0  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 66 of 66  Requirements Passed: 10 of 12

If a test does not run, it will fail if (:vhdlcode:`AffirmCount` <= 0) and (:vhdlcode:`RequirementsGoal` >
:vhdlcode:`RequirementsPassed`) and (:vhdlcode:`FailOnRequirementErrorsVar` = TRUE). :vhdlcode:`FailOnRequirementErrors`
is set by :vhdlcode:`SetAlertLogOptions` and TRUE is the default. These will print as follows:

.. code-block:: text

   %%  FAILED test_7    Total Error(s) = 1  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 0 of 0  Requirements Passed: 0 of 1
   %%  FAILED test_8    Total Error(s) = 1  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 0 of 0  Requirements Passed: 0 of 1

If (:vhdlcode:`AffirmCount` = 0) and either (:vhdlcode:`RequirementsGoal` = 0) or :vhdlcode:`FailOnRequirementErrors` is
FALSE, the test results are indeterminate. These will print as follows:

.. code-block:: text

   %%  ????? test_7    Total Error(s) = 1  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 0 of 0  Requirements Passed: 0 of 1
   %%  ????? test_8    Total Error(s) = 1  Failures: 0  Errors: 0  Warnings: 0
   Affirmations Passed: 0 of 0  Requirements Passed: 0 of 1

.. _UTILITY/AlertLogPkg/DeprecatedWriteTestSummaries:

Deprecated: WriteTestSummaries
------------------------------

:vhdlcode:`WriteTestSummaries` produces a csv file of the same information that is printed by
:vhdlcode:`ReportTestSummaries`.

.. code-block:: VHDL

   procedure WriteTestSummaries ( FileName : string ; OpenKind : File_Open_Kind ) ;

.. _UTILITY/AlertLogPkg/DeprecatedUseModel:

Deprecated: Use Model
---------------------

One potential use model is to just get a report of what passed and failed. This would involve the following.

.. code-block:: VHDL

   -- In Test1.vhd
   WriteTestSummary("./results/OsvvmTestSummary.txt", WRITE_MODE) ;
   . . .
   -- In Test2.vhd
   WriteTestSummary("./results/OsvvmTestSummary.txt") ;
   . . .
   -- In TestN.vhd
   WriteTestSummary("./results/OsvvmTestSummary.txt") ;

   . . .
   -- In OsvvmTestSummary.vhd
   ReadTestSummaries ("./results/OsvvmTestSummary.txt") ;
   ReportTestSummaries ;
   -- WriteTestSummaries("PointLess_IsSameAs_OsvvmTestSummary.txt") ;

However, the above approach fails to find tests that for some reason did not run and did not produce any output. Note
also that using, :vhdlcode:`WriteTestSummaries` in the above example would produce the same information that is already
in :file:`OsvvmTestSummary.txt` after all of the tests have finished. So there is no reason to do
:vhdlcode:`WriteTestSummaries` above.

First, remember that test summaries are recorded as requirements. To find what tests did not run and to make the order
of printing match a predefined order, let's define the tests that we wanted to run as a list of test names. Then read
the name of tests in as a specification. Hence, we will modify :file:`OsvvmTestSummary.vhd` as follows:

.. code-block:: VHDL

   -- In OsvvmTestSummary.vhd
   ReadSpecification ("./OsvvmTestsToRun.txt") ;
   ReadTestSummaries ("./results/OsvvmTestSummary.txt") ;
   ReportTestSummaries ;
   WriteTestSummaries("OsvvmAllTestResults.txt") ;

In this case, tests that did not run will show up as having an :vhdlcode:`AffirmCount` of 0 and a
:vhdlcode:`RequirementsGoal` of 1, hence, by defaults of :vhdlcode:`ReportTestSummaries`, the test will fail.

.. _UTILITY/AlertLogPkg/DeprecatedRequirementsReportingCSVReports:

Deprecated: Requirements Reporting: CSV Reports
===============================================

:vhdlcode:`ReportRequirements` produces a test summary as well as a tabulation of each requirement.
:vhdlcode:`WriteRequirements` prints the same information in a CSV format. :vhdlcode:`ReadRequirements` reads multiple
files produced by :vhdlcode:`WriteRequirements` and merges them.

Caution: :vhdlcode:`ReportRequirements` and :vhdlcode:`WriteRequirements` only report/write requirements that are in the
hierarchy under the :vhdlcode:`REQUIREMENT_ALERTLOG_ID`. The current implementation allows requirements to be anywhere
in the AlertLog hierarchy.

.. _UTILITY/AlertLogPkg/DeprecatedReportRequirements:

Deprecated: ReportRequirements
------------------------------

:vhdlcode:`ReportRequirements` produces a report that has the test summary of the :vhdlcode:`ReportAlerts` and then just
the IDs that are under the Requirements bin (via :vhdlcode:`GetReqID` or :vhdlcode:`ReadSpecification`). A
:vhdlcode:`ReportRequirements` for the previous :vhdlcode:`ReportAlerts` is as follows.

.. code-block:: text

   ReportRequirements ;
   . . .
   %%  381100.0 ns  DONE  FAILED  req_test1  Total Error(s) = 6  Failures: 0  Errors:
   4  Warnings: 0  Passed: 20  Affirmations Checked: 20  Requirements Passed: 2 of 4
   %%    T1.1    Failures: 0  Errors: 0  Warnings: 0  Passed: 1 of 1
   %%    T1.2    Failures: 0  Errors: 2  Warnings: 0  Passed: 0 of 2
   %%    T1.3    Failures: 0  Errors: 2  Warnings: 0  Passed: 1 of 3
   %%    T1.4    Failures: 0  Errors: 0  Warnings: 0  Passed: 4 of 4

.. _UTILITY/AlertLogPkg/DeprecatedWriteRequirements:

Deprecated: WriteRequirements
-----------------------------

:vhdlcode:`WriteRequirements` creates a CSV file that has the same information as :vhdlcode:`ReportRequirements`. The
format is identical to :vhdlcode:`WriteAlerts`.

.. code-block:: VHDL

   procedure WriteRequirements (
     FileName        : string ;
     AlertLogID      : AlertLogIDType := REQUIREMENT_ALERTLOG_ID ;
     OpenKind        : File_Open_Kind := WRITE_MODE
   ) ;

.. _UTILITY/AlertLogPkg/DeprecatedReadRequirements:

Deprecated: ReadRequirements
----------------------------

:vhdlcode:`ReadRequirements` reads a file that is in the format of :vhdlcode:`WriteRequirements`. The intent of
:vhdlcode:`ReadRequirements` is to read and merge the :vhdlcode:`WriteRequirements` information from multiple separate
tests.

.. code-block:: VHDL

   procedure ReadRequirements (
     FileName        : string ;
     ThresholdPassed : boolean := FALSE
   ) ;

If the :vhdlcode:`ThresholdPassed` parameter is true and if the read :vhdlcode:`PassedCount` exceeds the read
:vhdlcode:`PassedGoal`, the :vhdlcode:`PassedCount` is replaced by the :vhdlcode:`PassedGoal`.

.. _UTILITY/AlertLogPkg/DeprecatedNamesAndTheirReplacementName:

Deprecated Names and their Replacement name
*******************************************

From time to time, names must change to keep consistency across a large set of packages. Where possible OSVVM uses a
soft deprecation methodology where the subprogram takes on the new name and the original name is supported via an alias.
For example :vhdlcode:`SetTestName` was originally named :vhdlcode:`SetAlertLogName` and :vhdlcode:`FindID` was
originally named :vhdlcode:`FindAlertLogID`. As a result, you will find aliases in :vhdlcode:`AlertLogPkg` as follows:

.. code-block:: VHDL

   alias SetAlertLogName is SetTestName [string] ;
   alias FindAlertLogID is FindID [string return AlertLogIDType] ;

.. _UTILITY/AlertLogPkg/CompilingAndUsingOSVVMUtilityLibrary:

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
