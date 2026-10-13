.. _UTILITY/NamePkg:

NamePkg
#######

.. _UTILITY/NamePkg/NamePkgOverview:

NamePkg Overview
****************

:vhdlcode:`NamePkg` provides a basic set and get functionality for string based names. It is used to create names within
other packages in OSVVM. It can also be used by itself as a holder of names for a model.

.. _UTILITY/NamePkg/NamePType:

NamePType
*********

:vhdlcode:`NamePType` is a protected type with the following interface

.. code-block:: VHDL

   type NamePType is protected
     procedure Set (NameIn : String) ;
     impure function Get (DefaultName : string := "") return string ;
     impure function IsSet return boolean ;
     procedure Clear ;
   end protected NamePType ;

.. _UTILITY/NamePkg/Set:

Set
***

The procedure :vhdlcode:`Set` sets a name inside of the protected type. If name already exists, first deallocate it.

.. code-block:: VHDL

   procedure Set (NameIn : String) ;

.. _UTILITY/NamePkg/Get:

Get
***

The function :vhdlcode:`Get` returns the name that is held inside of the protected type.

.. code-block:: VHDL

   impure function Get (DefaultName : string := "") return string ;

.. _UTILITY/NamePkg/IsSet:

IsSet
*****

The function :vhdlcode:`IsSet` returns TRUE if a name is held inside of the protected type.

.. code-block:: VHDL

   impure function IsSet return boolean ;

.. _UTILITY/NamePkg/ClearDeallocate:

Clear / Deallocate
******************

The procedure :vhdlcode:`Clear` (and also :vhdlcode:`Deallocate`) deallocates the value set inside of the protected
type.

.. code-block:: VHDL

   procedure Clear ;

.. _UTILITY/NamePkg/CompilingNamePkgAndFriends:

Compiling NamePkg and Friends
*****************************

See :osvvmdoc:`OSVVM_release_notes.pdf <osvvm_release_notes>` for the current compilation directions. Rather than
referencing individual packages, we recommend using the context declaration:

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;

.. _UTILITY/NamePkg/FutureWork:

Future Work
***********

:file:`NamePkg.vhd` is a work in progress and will be updated from time to time.

Caution, undocumented items are experimental and may be removed in a future version.
