.. _UTILITY/AlertLogPkgQuickRef:

AlertLogPkg and ReportPkg Quick Reference
#########################################

.. _UTILITY/AlertLogPkgQuickRef/SimpleModeBasicErrorsAndMessages:

Simple Mode: Basic Errors and Messages
**************************************

Simple mode tracks alerts, logs, and affirmations with a single error and affirmation counters. This is sufficient for
basic test cases.

.. _UTILITY/AlertLogPkgQuickRef/PackageReferences:

Package References
==================

.. code-block:: VHDL

   library osvvm ;
   context osvvm.OsvvmContext ;

.. _UTILITY/AlertLogPkgQuickRef/SetTestName:

SetTestName
===========

Sets the test name. Printed by :vhdlcode:`ReportAlerts`.

.. code-block:: VHDL

   SetTestName("Tb_SendGet_1") ;

.. _UTILITY/AlertLogPkgQuickRef/LogLevels:

Log Levels
==========

Logs have the levels ALWAYS, DEBUG, FINAL, INFO, and PASSED. Logs are disabled by default – except for ALWAYS.
:vhdlcode:`SetLogEnable` enables logs.

.. _UTILITY/AlertLogPkgQuickRef/Logs:

Logs
====

Logs are for conditional printing. Logs allow printing of lots of messages when debugging and very few when running
regressions. Log prints when the :vhdlcode:`LogLevel` is enabled or the optional enable (last parameter) is TRUE.

.. code-block:: VHDL

   Log("Uart Parity Received", INFO) ;
   --                                    Enable
   Log("Received read response", DEBUG, TRUE) ;

.. _UTILITY/AlertLogPkgQuickRef/SimpleModeBasicErrorsAndMessages/LogEnableDisable:

Log Enable / Disable
====================

Enable all logs of a particular log level:

.. code-block:: VHDL

   --           Level, Enable
   SetLogEnable(INFO,  TRUE) ;

.. _UTILITY/AlertLogPkgQuickRef/AlertLevels:

Alert Levels
============

Alerts have levels FAILURE, ERROR, and WARNING.

.. _UTILITY/AlertLogPkgQuickRef/Alerts:

Alerts
======

Alerts are for checking for proper behavior – generate an error when a response is unexpected. :vhdlcode:`AlertLevel`
ERROR is the default. Alerts are enabled by default (and rarely disabled).

.. code-block:: VHDL

   Alert("Uart Parity") ;
   AlertIf(Break='1', "Uart Break", ERROR) ;
   AlertIfNot(ReadValid, "Read", FAILURE);
   AlertIfDiff("FileA.txt","FileB.txt");

.. _UTILITY/AlertLogPkgQuickRef/AlertEnableDisable:

Alert Enable / Disable
======================

Alerts can be enabled or disabled in a similar fashion to logs, however, this is rarely done. When it is done, errors
are still tracked and reported as disabled alerts.

.. _UTILITY/AlertLogPkgQuickRef/Affirmations:

Affirmations
============

Affirmations are for checking the received (actual) value against an expected value – the heart of self-checking
tests. If the check matches, a log PASSED is produced, otherwise, an alert ERROR is produced.

.. code-block:: VHDL

   AffirmIf(Data = Expected, "Data: " & to_string(Data),
     " /= Expected: " & to_string(Expected)) ;
   AffirmIfNot(ReadValid, "Reading Test.txt") ;
   AffirmIfEqual(ReceivedData, ExpectedData, "Data") ;
   AffirmIfFilesMatch("Uart1.txt", "validated/Uart1.txt") ;

.. _UTILITY/AlertLogPkgQuickRef/EndOfTestReports:

EndOfTestReports
================

Write out text report and YAML based alert reports.

.. code-block:: VHDL

   EndOfTestReports ;

See :ref:`UTILITY/AlertLogPkg` for additional parameters.

.. _UTILITY/AlertLogPkgQuickRef/HierarchyMode:

Hierarchy Mode
**************

Hierarchy mode tracks alerts, logs, and affirmations from different sources separately. An :vhdlcode:`AlertLogID` is
used to identify each source.

All alerts, logs, and affirmations support both simple and hierarchy mode. When used the :vhdlcode:`AlertLogID` is
always specified as the first parameter of the call.

Hierarchy mode requires the following additional steps or modified steps.

.. _UTILITY/AlertLogPkgQuickRef/NewIDCreateHierarchy:

NewID: Create Hierarchy
=======================

Create an :vhdlcode:`AlertLogID` and associate it with the name.

.. code-block:: VHDL

   signal ModelID, ProtocolID : AlertLogIDType ;
   . . .
   ModelID <= NewID("Uart_1") ;
   wait for 0 ns ;
   --                  Name,       Parent AlertLogID
   ProtocolID <= NewID("Protocol", ModelID);

If an ID is not specified, its parent is the top ID, :vhdlcode:`ALERTLOG_BASE_ID`.

.. _UTILITY/AlertLogPkgQuickRef/PathTail:

PathTail
========

:vhdlcode:`PathTail` is used in conjunction with :vhdlcode:`PATH_NAME` to determine an instance name for an entity.

.. code-block:: VHDL

   ModelID <= NewID(PathTail(UART'PATH_NAME));

.. _UTILITY/AlertLogPkgQuickRef/IDsAndAlertsLogsAffirmations:

IDs and Alerts, Logs, Affirmations
==================================

When using an :vhdlcode:`AlertLogID`, it is the first parameter of the procedure being called.

.. code-block:: VHDL

   AlertIf(ModelID, Break='1', "Uart Break", ERROR) ;
   Log(ModelID, "Uart Parity Received", INFO) ;
   AffirmIfEqual(ModelID, ReceivedData, ExpectedData) ;

.. _UTILITY/AlertLogPkgQuickRef/HierarchyMode/LogEnableDisable:

Log Enable / Disable
====================

:vhdlcode:`SetLogEnable` will also enable the children of an :vhdlcode:`AlertLogID` if the :vhdlcode:`DescendHierarchy`
is TRUE.

.. code-block:: VHDL

   --           AlertLogID, Level, Enable, DescendHierarchy
   SetLogEnable(ModelID,    INFO,  TRUE,   TRUE) ;

.. _UTILITY/AlertLogPkgQuickRef/ReadLogEnables:

Read Log Enables
================

Log enables can also be read from a file using:

.. code-block:: VHDL

   ReadLogEnables("InitEnables.txt") ;

.. _UTILITY/AlertLogPkgQuickRef/MultilineMessages:

Multiline Messages
******************

By default, the message is printed on the same line as the alert or log – independent of how long the line is.

If a line starts with either LF or '<', the message will be printed on the next line with a short indent. If the message
exceeds :vhdlcode:`OSVVM_LINE_WRAP` characters, additional lines will be produced at the wrap point and will be indented
to match the preceding line.

If a line starts with '>', the message will be printed on the same line as the Alert or Log. If the message exceeds the
:vhdlcode:`OSVVM_LINE_WRAP` characters, additional lines will be produced at the wrap point and will be indented to
match the preceding line.

Otherwise if the line contains an LF character, the line will wrap at the LF.

.. _UTILITY/AlertLogPkgQuickRef/LogHeader:

LogHeader
*********

:vhdlcode:`LogHeader` is a log message plus additional blank lines or repeated characters to make the line more
visible. Each character in the prefix and suffix strings indicates a line to print. If the character is a space, a blank
line is printed, otherwise, a line of that character is printed.

.. code-block:: VHDL

   LogHeader("UART1 Test", " *", "* ") ;

Prints as:

.. code-block:: text

   %%
   %% ***************************************************
   %%       50.0 ns Log ALWAYS      UART1 Test
   %% ***************************************************
   %%

Calling :vhdlcode:`LogHeader` without :vhdlcode:`Prefix` and :vhdlcode:`Suffix` is equivalent to the following:

.. code-block:: VHDL

   LogHeader("UART1 Test", " ", "*") ;

.. _UTILITY/AlertLogPkgQuickRef/ClearAlerts:

ClearAlerts
***********

Reset alert counts to 0. Used in an environment where a VC is erroneously signaling an error at the start of the test.

.. code-block:: VHDL

   ClearAlerts ;

.. _UTILITY/AlertLogPkgQuickRef/OptionsForReports:

Options for Reports
*******************

Options for :vhdlcode:`AlertLogPkg` are determined by deferred constants in :vhdlcode:`OsvvmSettingsPkg`. See
:ref:`OSVVM Settings User Guide <UTILITY/OsvvmSettings>` for details. The defaults are intended to help you get started.

.. _UTILITY/AlertLogPkgQuickRef/ControllingIDsFromOtherLocations:

Controlling IDs from Other Locations
************************************

Alerts and Logs may need to be enabled (or disabled) from a test case which is in a different entity than the VC that
defined it. To do this, the test case needs to be able to look up the :vhdlcode:`AlertLogID` for the VC. No problem.
:vhdlcode:`AlertLogIDs` can be looked up using :vhdlcode:`GetID` and the same string used in its definition as done in
the following code.

.. code-block:: VHDL

   signal TBID, AxiManagerID, UartTxID, UartRxID :
   AlertLogIDType ;
   . . .
   ControlProc : process
   begin
     TBID         <= NewID("TB") ;
     wait for 0 ns ; -- Allow the VC to create the ID
     AxiManagerID <= GetID("AxiManager_1") ;
     UartTxID     <= GetID("UartTx_1") ;
     UartRxID     <= GetID("UartRx_1") ;

The following code turns on PASSED for all IDs and INFO for the :vhdlcode:`UartTxID`. This capability facilitates
finding infrequent messages (such as from a slow UART) hidden among messages from faster interfaces.

.. code-block:: VHDL

     . . .
   SetLogEnable(PASSED, TRUE) ;
   SetLogEnable(UartTxID, INFO, TRUE) ;

.. _UTILITY/AlertLogPkgQuickRef/FileIOTranscriptFiles:

File IO / Transcript Files
**************************

Alert, Log, and Affirmations all print using OSVVM's transcript capability, giving the test case full control of where
the output goes (:vhdlcode:`std.textio.OUTPUT`, :vhdlcode:`TranscriptFile`, or both).

.. _UTILITY/AlertLogPkgQuickRef/AlertStopCounts:

Alert Stop Counts
*****************

:vhdlcode:`SetAlertStopCount` stops a simulation after a specified number of alerts have occurred. This allows debug to
start sooner.

Use :vhdlcode:`SetAlertStopCount` without an :vhdlcode:`AlertLogID` to set the stop count for accumulated alerts across
the entire test case.

.. code-block:: VHDL

   --                Level,      Count
   SetAlertStopCount(ERROR,      20) ;

Use :vhdlcode:`SetAlertStopCount` with an :vhdlcode:`AlertLogID` to control the stop count for a particular
verification component.

.. code-block:: VHDL

   --                AlertLogID,  Level,      Count
   SetAlertStopCount(UartID,      ERROR,      20) ;

.. _UTILITY/AlertLogPkgQuickRef/AlertPrintCounts:

Alert Print Counts
******************

:vhdlcode:`AlertPrintCount` stops printing an alert after a specified number of alerts have occurred. This allows
acknowledging an issue, but stops its output from overwhelming the simulation output.

:vhdlcode:`SetAlertPrintCount` can be used with or without an ID.

.. code-block:: VHDL

   --                 Level,      Count
   SetAlertPrintCount(ERROR,      20) ;

   --                 AlertLogID,  Level,      Count
   SetAlertPrintCount(UartTxID,    ERROR,      20) ;
