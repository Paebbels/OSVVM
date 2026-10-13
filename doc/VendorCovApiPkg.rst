.. _UTILITY/VendorCovApiPkg:

VendorCovApiPkg
###############

.. _UTILITY/VendorCovApiPkg/VendorCovApiPkgOverview:

VendorCovApiPkg Overview
************************

:vhdlcode:`VendorCovApiPkg` provides an interface between the creation of coverage and recording of coverage in OSVVM
:vhdlcode:`CoveragePkg` and a simulator.

.. _UTILITY/VendorCovApiPkg/TypeDefinitions:

Type Definitions
****************

.. _UTILITY/VendorCovApiPkg/VendorCovHandleType:

VendorCovHandleType
===================

:vhdlcode:`VendorCovHandleType` is the type for the handle that OSVVM uses to identify the coverage object to the tool.
The tool will set the value for the handle with a call to either function :vhdlcode:`VendorCovPointCreate` or
:vhdlcode:`VendorCovCrossCreate`.

.. code-block:: VHDL

   subtype VendorCovHandleType is integer;

The type may be changed to any valid VHDL type.

.. _UTILITY/VendorCovApiPkg/CoverageBins:

Coverage Bins
=============

A coverage bin value is represented by an integer range stored in a record. The type used for the interface is
:vhdlcode:`VendorCovRangeArrayType` which is an array of the :vhdlcode:`VendorCovRangeType`.

.. code-block:: VHDL

   type VendorCovRangeType is record
     min: integer;
     max: integer;
   end record;

   type VendorCovRangeArrayType is array ( integer range <> ) of VendorCovRangeType;

.. _UTILITY/VendorCovApiPkg/CreatingAPointItemCoverageBin:

Creating a Point/Item Coverage bin
**********************************

The function :vhdlcode:`VendorCovPointCreate` creates the initial data structure for a point coverage bin and returns
the handle to the bin.

.. code-block:: VHDL

   impure function VendorCovPointCreate( name: string ) return VendorCovHandleType;

.. _UTILITY/VendorCovApiPkg/CreatingACrossCoverageBin:

Creating a Cross Coverage bin
*****************************

The function :vhdlcode:`VendorCovCrossCreate` creates the initial data structure for a cross coverage bin and returns
the handle to the bin.

.. code-block:: VHDL

   impure function VendorCovCrossCreate( name: string ) return VendorCovHandleType;

.. _UTILITY/VendorCovApiPkg/UpdatingACoverageBinName:

Updating a Coverage Bin name
****************************

OSVVM Functional Coverage modeling allows the bin to be named after the initial model is created. The procedure
:vhdlcode:`VendorCovSetName` allows the bin name to be revised after the coverage model has already been created.

.. code-block:: VHDL

   procedure VendorCovSetName( obj: VendorCovHandleType; name: string );

.. _UTILITY/VendorCovApiPkg/AddingCoverageItemsToABin:

Adding Coverage Items to a Bin
******************************

For either point or cross coverage, bins are added to the model using :vhdlcode:`VendorCovBinAdd`.

.. code-block:: VHDL

   procedure VendorCovBinAdd(
     obj      : VendorCovHandleType;
     bins     : VendorCovRangeArrayType;
     Action   : integer;
     atleast  : integer;
     name     : string
   );

The types :vhdlcode:`VendorCovHandleType` and :vhdlcode:`VendorCovRangeArrayType` are explained in
:ref:`Type Definitions <UTILITY/VendorCovApiPkg/TypeDefinitions>` of this document. :vhdlcode:`Action` is 1 for a count
bin, 0 for an ignore bin, and -1 for an illegal bin. The :vhdlcode:`atleast` parameter is the coverage goal. Note that
the coverage goal can be different for different bins - this makes an OSVVM coverage bin more similar to a
SystemVerilog/UCIS coverage group. :vhdlcode:`Name` is the string name of this bin.

.. _UTILITY/VendorCovApiPkg/IncrementingTheCoverage:

Incrementing the Coverage
*************************

:vhdlcode:`VendorCovBinInc` increments the coverage of a bin. The value of :vhdlcode:`index` ranges from 1 to N where N
is the number of coverage bins and is based on the order of capture of the coverage bins.

.. code-block:: VHDL

   procedure VendorCovBinInc( obj: VendorCovHandleType; index: integer );

.. _UTILITY/VendorCovApiPkg/BindingTheProceduresToTheTool:

Binding the Procedures to the Tool.
***********************************

Each of the functions and procedures need to resolve to a call to an item in the vendor tools. This can be either by
calling the appropriate functions or procedures in the subprogram bodies (as demonstrated in
:file:`VendorCovApiPkg.vhd`) or by binding in foreign subprograms (as demonstrated in
:file:`VendorCovApiPkg_Aldec.vhd`).

.. _UTILITY/VendorCovApiPkg/CompilingVendorCovApiPkgAndFriends:

Compiling VendorCovApiPkg and Friends
*************************************

See :osvvmdoc:`OSVVM_release_notes.pdf <osvvm_release_notes>` for the current compilation directions. Rather than
referencing individual packages, we recommend using the context declaration:

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;

.. _UTILITY/VendorCovApiPkg/FutureWork:

Future Work
***********

:file:`VendorCovApiPkg.vhd` is a work in progress and will be updated from time to time.

Caution, undocumented items are experimental and may be removed in a future version.
