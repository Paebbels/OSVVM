.. _UTILITY/OsvvmGlobalPkg:

OsvvmGlobalPkg
##############

.. _UTILITY/OsvvmGlobalPkg/OsvvmGlobalPkgOverview:

OsvvmGlobalPkg Overview
***********************

Release 2024.03 deprecated most of the functionality in this package. At this point, only
:vhdlcode:`OsvvmOptionsType`, :vhdlcode:`IsEnabled`, and :vhdlcode:`to_OsvvmOptionsType` remain.
:vhdlcode:`OsvvmOptionsType` is used with :vhdlcode:`SetAlertLogOptions` and

.. _UTILITY/OsvvmGlobalPkg/PackageUserSubprogramReference:

Package User Subprogram Reference
*********************************

.. _UTILITY/OsvvmGlobalPkg/PackageReference:

Package Reference
=================

.. code-block:: VHDL

   library osvvm ;
   use osvvm.OsvvmGlobalPkg.all ;

.. _UTILITY/OsvvmGlobalPkg/OsvvmOptionsTypeTypeForOSVVMOptions:

OsvvmOptionsType: Type for OSVVM options
========================================

.. code-block:: VHDL

   type OsvvmOptionsType is (OPT_INIT_PARM_DETECT, OPT_USE_DEFAULT, DISABLED, FALSE,
       ENABLED, TRUE) ;

.. _UTILITY/OsvvmGlobalPkg/IsEnabled:

IsEnabled
=========

.. code-block:: VHDL

   function IsEnabled (A : OsvvmOptionsType) return boolean ;

.. _UTILITY/OsvvmGlobalPkg/ToOsvvmOptionsType:

to_OsvvmOptionsType
===================

.. code-block:: VHDL

   function to_OsvvmOptionsType (A : boolean) return OsvvmOptionsType ;

.. _UTILITY/OsvvmGlobalPkg/DeprecatedAndRemovedItems:

Deprecated and Removed Items
****************************

.. _UTILITY/OsvvmGlobalPkg/MigratingSetOsvvmGlobalOptionsToConstantsInOsvvmSettingsPkg:

Migrating SetOsvvmGlobalOptions to Constants in OsvvmSettingsPkg
================================================================

With OSVVM release 2024.03, the procedure :vhdlcode:`SetOsvvmGlobalOptions` was deprecated and removed. These settings
are now done by constants in :file:`OsvvmSettingsPkg_default.vhd`. If you want to change the setting, copy
:file:`OsvvmSettingsPkg_default.vhd` to :file:`OsvvmSettingsPkg_local.vhd` and make the changes you desire.

The following table shows the parameter of :vhdlcode:`SetOsvvmGlobalOptions` and its corresponding constant in
:vhdlcode:`OsvvmSettingsPkg`.

.. list-table::
   :header-rows: 1
   :widths: 183 465

   * - Parameter Name
     - Constant that replaces it
   * - :vhdlcode:`WritePassFail`
     - :vhdlcode:`COVERAGE_WRITE_PASS_FAIL`
   * - :vhdlcode:`WriteBinInfo`
     - :vhdlcode:`COVERAGE_WRITE_BIN_INFO`
   * - :vhdlcode:`WriteCount`
     - :vhdlcode:`COVERAGE_WRITE_COUNT`
   * - :vhdlcode:`WriteAnyIllegal`
     - :vhdlcode:`COVERAGE_WRITE_ANY_ILLEGAL`
   * - :vhdlcode:`WritePrefix`
     - :vhdlcode:`OSVVM_PRINT_PREFIX`
   * - :vhdlcode:`DoneName`
     - :vhdlcode:`OSVVM_DONE_NAME`
   * - :vhdlcode:`PassName`
     - :vhdlcode:`OSVVM_PASS_NAME`
   * - :vhdlcode:`FailName`
     - :vhdlcode:`OSVVM_FAIL_NAME`

.. _UTILITY/OsvvmGlobalPkg/CompilingAndUsingOSVVMUtilityLibrary:

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
