.. _UTILITY/ResolutionPkg:

ResolutionPkg
#############

.. _UTILITY/ResolutionPkg/ResolutionPkgOverview:

ResolutionPkg Overview
**********************

:vhdlcode:`ResolutionPkg` provides resolution functions used to resolve elements of a record. OSVVM uses records as a
means of implementing its transaction interfaces.

.. _UTILITY/ResolutionPkg/MaximumResolutionFunctions:

Maximum Resolution Functions
****************************

.. _UTILITY/ResolutionPkg/ResolvedMax:

Resolved_max
============

A function named :vhdlcode:`resolved_max` is defined for the types :vhdlcode:`std_ulogic`, :vhdlcode:`bit`,
:vhdlcode:`integer`, :vhdlcode:`time`, :vhdlcode:`real`, :vhdlcode:`character`, and :vhdlcode:`Boolean`.

.. code-block:: VHDL

   function resolved_max ( s : std_ulogic_vector) return std_ulogic ;

.. _UTILITY/ResolutionPkg/SubtypesBasedOnResolvedMax:

Subtypes based on Resolved_max
==============================

The following subtypes are defined in :vhdlcode:`ResolutionPkg`:

.. code-block:: VHDL

   subtype  std_logic_max is resolved_max std_ulogic ;
   subtype  std_logic_vector_max is (resolved_max) std_ulogic_vector ;
   subtype  unsigned_max is (resolved_max) unresolved_unsigned ;
   subtype  signed_max   is (resolved_max) unresolved_signed ;
   subtype  bit_max is resolved_max bit ;
   subtype  bit_vector_max is (resolved_max) bit_vector ;
   subtype  integer_max is resolved_max integer ;
   subtype  integer_vector_max is (resolved_max) integer_vector ;
   subtype  time_max is resolved_max time ;
   subtype  time_vector_max is (resolved_max) time_vector ;
   subtype  real_max is resolved_max real ;
   subtype  real_vector_max is (resolved_max) real_vector ;
   subtype  character_max is resolved_max character ;
   subtype  string_max is (resolved_max) string ;
   subtype  boolean_max is resolved_max boolean ;
   subtype  boolean_vector_max is (resolved_max) boolean_vector ;

.. _UTILITY/ResolutionPkg/MaximumResolutionFunctions/UseModel:

Use Model
=========

OSVVM uses records as transaction interfaces. Since the record is inout of more than one entity, one option is to use
the above resolved subtypes as elements of the record.

.. code-block:: VHDL

   package InterfacePkg is
     type InterfaceRecType is record
       Rdy         : std_logic_max ;
       Ack         : std_logic_max ;
       Operation   : integer_max ;
       Address     : integer_max ;
       Data_in     : integer_max ;
       Data_out    : integer_max ;
     end record InterfaceRecType ;

     procedure DoTrans (InterfaceRec : inout InterfaceRecType ; . . . ) ;
     .  .  .
   End package InterfacePkg ;
   entity TestCtrl is
     port (
       InterfaceRec : inout InterfaceRecType ;
       . . .
     ) ;
   end entity TestCtrl ;

   entity InterfaceModel is
     port (
       InterfaceRec : inout InterfaceRecType ;
       . . .
     ) ;
   end entity InterfaceModel ;

The default value on each record element is :vhdlcode:`type'left`. The :vhdlcode:`resolved_max` resolution function
returns the maximum value driven on the record. Undriven record elements from a particular model contribute the value
:vhdlcode:`type'left`, and hence, if the other model is driving the corresponding element of the record, its value is
the maximum value.

By using a subtype, the value will convert automatically to other types that are a subtype of the base type. Going
further it will also convert to the base type since it is a subtype of itself.

.. _UTILITY/ResolutionPkg/MaximumResolutionFunctions/CompatibilityModeTypes:

Compatibility Mode Types
========================

Subtypes of arrays, such as :vhdlcode:`std_logic_vector_max`, that use the resolution function of its elements is a new
feature for VHDL-2008. There are simulators that do not currently support this capability. For that reason, the package
also provides the following type definitions.

.. code-block:: VHDL

   type     std_logic_vector_max_c is array (natural range <>) of std_logic_max ;
   type     unsigned_max_c is array (natural range <>) of std_logic_max ;
   type     signed_max_c is array (natural range <>) of std_logic_max ;
   type     bit_vector_max_c is array (natural range <>) of bit_max ;
   type     integer_vector_max_c is array (natural range <>) of integer_max ;
   type     time_vector_max_c is array (natural range <>) of time_max ;
   type     real_vector_max_c is array (natural range <>) of real_max ;
   type     string_max_c is array (positive range <>) of character_max ;
   type     boolean_vector_max_c is array (natural range <>) of boolean_max ;

These work well, however, not as well as subtypes. With a type, the conversion between :vhdlcode:`string_max_c` is no
longer automatic with :vhdlcode:`string`. In this case, a type conversion (type cast) can be used.

.. code-block:: VHDL

   signal FileName : string(1 to 10) ;
   type InterfaceRecType is record
     FileName : string_max_c ;
     . . .
   end record InterfaceRecType ;
   signal InterfaceRec : InterfaceRecType ;
   . . .
   InterfaceRec.FileName <= string_max_c(FileName) ;
   . . .
   FileName <= string(InterfaceRec.FileName) ;

.. _UTILITY/ResolutionPkg/SummingResolution:

Summing Resolution
******************

.. _UTILITY/ResolutionPkg/ResolvedSum:

Resolved_sum
============

A function named :vhdlcode:`resolved_sum` is defined for the types :vhdlcode:`integer`, :vhdlcode:`time`, and
:vhdlcode:`real`.

.. code-block:: VHDL

   function resolved_sum ( s : integer_vector ) return integer ;
   function resolved_sum ( s : time_vector ) return time ;
   function resolved_sum ( s : real_vector ) return real ;

.. _UTILITY/ResolutionPkg/Subtypes:

Subtypes
========

The following subtypes are defined in :vhdlcode:`ResolutionPkg`:

.. code-block:: VHDL

   subtype  integer_sum is resolved_sum integer ;
   subtype  integer_vector_sum is (resolved_sum) integer_vector ;
   subtype  time_sum is resolved_sum time ;
   subtype  time_vector_sum is (resolved_sum) time_vector ;
   subtype  real_sum is resolved_sum real ;
   subtype  real_vector_sum is (resolved_sum) real_vector ;

.. _UTILITY/ResolutionPkg/SummingResolution/CompatibilityModeTypes:

Compatibility Mode Types
========================

The package also provides the following type definitions.

.. code-block:: VHDL

   type     integer_vector_sum_c is array (natural range <>) of integer_sum ;
   type     time_vector_sum_c is array (natural range <>) of time_sum ;
   type     real_vector_sum_c is array (natural range <>) of real_sum ;

.. _UTILITY/ResolutionPkg/LegacyResolutionFunctions:

Legacy Resolution Functions
***************************

The legacy resolution functions were the first resolution functions added to :vhdlcode:`ResolutionPkg`. Usage of these
included using :vhdlcode:`std_logic_vector`. The disadvantage to this is that the default initialization of
:vhdlcode:`std_logic` is 'U' and the resolved value of 'U' and any other value is 'U'. As a result, the ports require
initialization to a non-driving state, such as 'Z'.

.. _UTILITY/ResolutionPkg/Resolved:

Resolved
========

A function named :vhdlcode:`resolved` is defined for the types :vhdlcode:`integer`, :vhdlcode:`time`, :vhdlcode:`real`,
:vhdlcode:`character`, and :vhdlcode:`boolean`. These resolution functions require a non-driving value of 0, 0 ns, 0.0,
NUL, and FALSE respectively. If there is more than one non-driving value, these functions will generate an assert
FAILURE. Note though that in most simulators, this will not cause the normal stopping action.

.. code-block:: VHDL

   function resolved ( s : integer_vector ) return integer ;

.. _UTILITY/ResolutionPkg/SubtypesBasedOnResolved:

Subtypes based on Resolved
==========================

The following subtypes are defined in :vhdlcode:`ResolutionPkg`:

.. code-block:: VHDL

   subtype  resolved_integer is resolved integer ;
   subtype  resolved_time is resolved time ;
   subtype  resolved_real is resolved real ;
   subtype  resolved_character is resolved character ;
   type resolved_string is array (positive range <>) of resolved_character;
   subtype  resolved_boolean is resolved boolean ;

.. _UTILITY/ResolutionPkg/LegacyResolutionFunctions/UseModel:

Use Model
=========

OSVVM uses records as transaction interfaces. Since the record is inout of more than one entity, one option is to use
the above resolved subtypes as elements of the record.

.. code-block:: VHDL

   package InterfacePkg is
     type InterfaceRecType is record
       Rdy         : std_logic ;
       Ack         : std_logic ;
       Operation   : resolved_integer ;
       Address     : resolved_integer ;
       Data_in     : resolved_integer ;
       Data_out    : resolved_integer ;
     end record InterfaceRecType ;

     constant INTERFACE_INIT : InterfaceRecType := (
       Rdy         => 'Z',
       Ack         => 'Z',
       Operation   => 0,
       Address     => 0,
       Data_in     => 0,
       Data_out    => 0
     ) ;

     procedure DoTrans (InterfaceRec : inout InterfaceRecType ; . . . ) ;
     .  .  .
   End package InterfacePkg ;
   entity TestCtrl is
     port (
       InterfaceRec : inout InterfaceRecType := INTERFACE_INIT ;
       . . .
     ) ;
   end entity TestCtrl ;

   entity InterfaceModel is
     port (
       InterfaceRec : inout InterfaceRecType := INTERFACE_INIT ;
       . . .
     ) ;
   end entity InterfaceModel ;

When a value is undriven by a model, the model will contribute the value from the default initialization for that record
element.

Since the types used here are subtypes, values convert automatically.

.. _UTILITY/ResolutionPkg/ConversionFunctions:

Conversion Functions
********************

.. _UTILITY/ResolutionPkg/ExtendAndReduce:

Extend and Reduce
=================

:vhdlcode:`Extend` and :vhdlcode:`Reduce` serve the same purpose as :vhdlcode:`numeric_std.resize`. :vhdlcode:`Extend`
will either make the vector larger or keep it the same size. :vhdlcode:`Reduce` will either make a vector smaller or
keep it the same size.

.. code-block:: VHDL

   function Extend(A: std_logic_vector; Size : natural) return std_logic_vector ;
   function Reduce(A: std_logic_vector; Size : natural) return std_logic_vector ;

Use :vhdlcode:`Extend` when putting a value into the record and :vhdlcode:`Reduce` when taking it out.

.. _UTILITY/ResolutionPkg/ToTransactionAndFromTransaction:

ToTransaction and FromTransaction
=================================

When using the compatibility type :vhdlcode:`std_logic_vector_max_c`, :vhdlcode:`ToTransaction` is intended to simplify
putting a value into the transaction record and :vhdlcode:`FromTransaction` is intended to simplify removing a value
from the transaction record.

.. code-block:: VHDL

   function ToTransaction(A : std_logic_vector) return std_logic_vector_max_c ;
   function ToTransaction(A : std_logic_vector ; Size : integer) return
   std_logic_vector_max_c ;
   function FromTransaction (A: std_logic_vector_max_c) return std_logic_vector ;
   function FromTransaction (A: std_logic_vector_max_c ; Size : natural) return
   std_logic_vector ;

.. _UTILITY/ResolutionPkg/CompilingResolutionPkgAndFriends:

Compiling ResolutionPkg and Friends
***********************************

See :osvvmdoc:`OSVVM_release_notes.pdf <osvvm_release_notes>` for the current compilation directions. Rather than
referencing individual packages, we recommend using the context declaration:

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;

.. _UTILITY/ResolutionPkg/FutureWork:

Future Work
***********

:file:`ResolutionPkg.vhd` is a work in progress and will be updated from time to time.

Caution, undocumented items are experimental and may be removed in a future version.
