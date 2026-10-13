.. _UTILITY/DynamicVectorPkg:

Dynamic Vector
##############

.. _UTILITY/DynamicVectorPkg/DynamicVectorGenericPkgOverview:

DynamicVectorGenericPkg Overview
********************************

A dynamic vector is a resizable vector. Like a vector it supports random access to elements via indices. The indices are
numbered 0 to N-1, where N is the number of elements in the vector. As a data structure, it supports insertion and
deletion, but it is optimized for insertion and deletion at the end of the vector (index N-1).

Dynamic vectors are implemented in a singleton data structure and can be passed around using their ID. This makes them
suitable for handling burst transfer information – particularly if the bursts are different sizes. As a singleton,
different aspects of the verification environment such as packet generator, verification component (VC) driving the
packet, and VC receiving and checking the packet can all reference the packet of data using its ID.

Dynamic vectors have similarities to C/Rust/Ada vectors, SystemVerilog dynamic arrays, Python lists, and Java
VectorLists.

.. _UTILITY/DynamicVectorPkg/BasicUsage:

Basic Usage
***********

.. _UTILITY/DynamicVectorPkg/PackageReferences:

Package References
==================

Using dynamic vectors requires a package instance (provided for :vhdlcode:`integer_vector` and
:vhdlcode:`std_logic_vector`) and a package reference. Note these are not included in the :vhdlcode:`OsvvmContext`.

.. code-block:: VHDL

   Library osvvm ;
   use osvvm.DynamicVectorPkg_IntV.all ;
   architecture Test1 of tb is

.. _UTILITY/DynamicVectorPkg/DeclaringAVectorID:

Declaring a VectorID
====================

A :vhdlcode:`VectorID` is a reference to the dynamic vector that is created internal to an instance of
:vhdlcode:`DynamicVectorGenericPkg` (such as :vhdlcode:`DynamicVectorPkg_IntV`). The :vhdlcode:`VectorID` has the type
:vhdlcode:`DynamicVectorIDType`. :vhdlcode:`DynamicVectorIDType` is an ordinary type and can be held in a signal or
variable.

.. code-block:: VHDL

   architecture Model of Sram is
     signal VectorID : DynamicVectorIDType ;
    . . .

.. _UTILITY/DynamicVectorPkg/NewIDConstructTheDynamicVector:

NewID: Construct the Dynamic Vector
===================================

:vhdlcode:`NewID` allocates and initializes the dynamic vector data structure. It must be called before any dynamic
vector operations are used.

.. code-block:: VHDL

   VectorID <= NewID(
                Name      => "Packet1",
                Capacity  => 0,
                ParentID  => TbID) ;

.. _UTILITY/DynamicVectorPkg/AppendAddToTheEndOfTheVector:

Append: Add to the End of the Vector
====================================

:vhdlcode:`Append` adds either elements or vectors to the end of the Vector. :vhdlcode:`Append` increases the size of
the vector.

.. code-block:: VHDL

   Append(VectorID, ElementValue) ;
   Append(VectorID, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/GetReadFromASpecifiedIndexOfTheVector:

Get: Read from a specified Index of the Vector
==============================================

The function :vhdlcode:`Get` reads either an element or a vector from an Index location in the Vector. The Index
location must already exist.

.. code-block:: VHDL

   ElementValue := Get(VectorID, Index) ;
   VectorValue  := Get(VectorID, Index, VectorValue'length) ;

.. _UTILITY/DynamicVectorPkg/SetWriteToASpecifiedIndexOfTheVector:

Set: Write to a specified Index of the Vector
=============================================

The procedure :vhdlcode:`Set` writes either an element or a vector to an Index location in the vector. :vhdlcode:`Set`
overwrites any previous values. The Index location must already exist.

.. code-block:: VHDL

   Set(VectorID, Index, ElementValue) ;
   Set(VectorID, Index, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/GetSizeNumberOfElementsInTheVector:

GetSize: Number of elements in the Vector
=========================================

The function :vhdlcode:`GetSize` returns the number of values in the Vector. The vector has the indices 0 to
:vhdlcode:`GetSize` -1.

.. code-block:: VHDL

   Size := GetSize(VectorID) ;

.. _UTILITY/DynamicVectorPkg/GetCapacityNumberOfElementsAllocatedForTheVector:

GetCapacity: Number of elements allocated for the Vector
========================================================

The capacity is the number of elements currently allocated for the vector. When the vector is constructed, the Capacity
is initialized to 16. During an :vhdlcode:`Append`, :vhdlcode:`Insert`, or :vhdlcode:`Prepend`, if the vector size
exceeds the capacity, the capacity is doubled. By doubling the capacity amortizes the costs of increasing the capacity
and makes :vhdlcode:`Append` an O(1) operation on average.

.. code-block:: VHDL

   Capacity := GetCapacity (VectorID) ;

.. _UTILITY/DynamicVectorPkg/PuttingTheBasicPiecesTogether:

Putting the basic pieces together
=================================

The following declares the :vhdlcode:`VectorID` (variable :vhdlcode:`VectorID`), constructs it (:vhdlcode:`NewID`), adds
3 elements to the vector (:vhdlcode:`Append`), checks the first and last value (using :vhdlcode:`Get`), and changes the
value at index 1 to 25 (:vhdlcode:`Set`).

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;
     use osvvm.DynamicVectorPkg_IntV.all ;

   entity Tb_Basic_1 is
   end Tb_Basic_1 ;

   architecture Test1 of Tb_Basic_1 is
   begin

     TestProc : process
       -- Declare the Vector ID
       variable VectorID : DynamicVectorIDType ;
       variable TbID    : AlertLogIDType ;
       variable Data    : integer ;
     begin

       SetTestName("Tb_Basic_1") ;
       TranscriptOpen ;
       SetLogEnable(PASSED, TRUE) ;
       SetTranscriptMirror(TRUE) ;
       TbID := NewID("TbID") ;

       -- Construct the Vector
       VectorID := NewID("ID", 0, TbID) ;

       -- Add 3 elements to the Vector
       Append(VectorID, 10) ;
       Append(VectorID, 20) ;
       Append(VectorID, 30) ;
       AffirmIfEqual(TbID, GetSize(VectorID), 3, "GetSize") ;

       -- Get the first and last elements of the vector
       AffirmIfEqual(TbID, Get(VectorID, 0), 10, "Get") ;
       AffirmIfEqual(TbID, Get(VectorID, 2), 30, "Get") ;

       -- Change the value at index 1 to 25
       Set(VectorID, 1, 25) ;

       TranscriptClose ;

       AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;

       EndOfTestReports ;
       std.env.stop ;
       wait ;
     end process TestProc ;

   end Test1 ;

.. _UTILITY/DynamicVectorPkg/AppendInsertPrependAndDelete:

Append, Insert, Prepend, and Delete
***********************************

:vhdlcode:`Append`, :vhdlcode:`Insert`, :vhdlcode:`Prepend`, and :vhdlcode:`Delete` increase or decrease the size of the
vector. This can result in shifting values and memory allocation. Most of these operations are O(n) – meaning take an
amount of time that is proportional to the size of the vector.

For :vhdlcode:`Append`, which adds values to the end of the vector, this time can be amortized to O(1) – meaning
constant time access independent of the vector size – by doubling the capacity of the vector (amount of information that
the vector can store) every time the size exceeds capacity. As a result, the allocate/deallocate and copy that can occur
with append occurs infrequently.

For insert, prepend, and delete that occur at random locations in the vector or at the beginning, there will always be
shifting of O(n) values. Note that these operations can impact any index or iterator being used to access the vector.

.. _UTILITY/DynamicVectorPkg/InsertAddValueSAtASpecifiedIndex:

Insert: Add value(s) at a specified Index
=========================================

:vhdlcode:`Insert` adds either elements or vectors at the index specified (before any values that were previously at
that index).

.. code-block:: VHDL

   Insert(VectorID, Index, ElementValue) ;
   Insert(VectorID, Index, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/PrependInsertValueSAtTheStartOfTheVector:

Prepend: Insert value(s) at the start of the vector
===================================================

:vhdlcode:`Prepend` adds either elements or vectors at the start of the vector (before any values that were previously
at the start).

.. code-block:: VHDL

   Prepend(VectorID, ElementValue) ;
   Prepend(VectorID, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/DeleteRemoveValuesAtASpecifiedIndex:

Delete: Remove values at a specified Index
==========================================

:vhdlcode:`Delete` removes either elements or vectors at the index specified.

.. code-block:: VHDL

   Delete(VectorID, Index) ;              -- Single Value
   Delete(VectorID, Index, NumValues) ;   -- Vector of Values

.. _UTILITY/DynamicVectorPkg/IndexingIndexOperationsAndIterators:

Indexing, Index Operations, and Iterators
*****************************************

:vhdlcode:`Get` and :vhdlcode:`Set` can access vector values at an index location. Assuming the vector currently
contains 8 8-bit values, then a for loop can be used to iterate across all values in the vector.

.. code-block:: VHDL

   for i in 0 to 7 loop
     DataSlv8 := Get(VectorID1, i*8, 8) ;  --
     Send(StreamTx, DataSlv8) ;
   end loop ;

Each ID of the data structure has an iterator associated with it. The iterator supports sequencing across the data
structure getting one item at a time. As values are set/get the iterator updates. The following accomplishes the same
sequencing as the previous task.

.. code-block:: VHDL

   SetIndex(VectorID1) ;  -- restore iterator to 0 index
   while HasNext(VectorID1) loop
     DataSlv8 := GetNext(VectorID1, 8) ;
     Send(StreamTx, DataSlv8) ;
   end loop ;

The initial iterator is created by :vhdlcode:`NewID` when the vector is constructed. If multiple iterators are
desirable, then additional iterators can be created by :vhdlcode:`CopyID`. The ID returned by :vhdlcode:`CopyID`
references the same vector as the original ID - hence, the copy is referred to as a shallow copy.

The vector exists as long as there is an ID that references it. :vhdlcode:`Deallocate` releases an ID. When
:vhdlcode:`Deallocate` is called on the last iterator associated with an ID, the vector is deallocated.

.. _UTILITY/DynamicVectorPkg/CopyIDCreateNewIterator:

CopyID: Create new iterator
===========================

:vhdlcode:`CopyID` creates a new iterator for the dynamic vector data structure.

.. code-block:: VHDL

   CopyID1 := CopyID( VectorID1) ;

.. _UTILITY/DynamicVectorPkg/GetFirstIndexReturnFirstIndexOfTheVector:

GetFirstIndex: Return first index of the vector
===============================================

Returns the first index of the vector. This is 0 in the current implementation.

.. code-block:: VHDL

   Index := GetFirstIndex( VectorID1) ;

.. _UTILITY/DynamicVectorPkg/GetLastIndexLastIndexOfTheVector:

GetLastIndex: Last index of the vector
======================================

Set :vhdlcode:`NumValues` parameter to the number of elements in the value (1 for an element), and
:vhdlcode:`GetLastIndex` will return the location of the last index.

.. code-block:: VHDL

   Index := GetLastIndex( VectorID1, NumValues => 1) ;

.. _UTILITY/DynamicVectorPkg/GetIndexIteratorIndexValue:

GetIndex: Iterator index value
==============================

Returns the current value of the Iterator index.

.. code-block:: VHDL

   Index := GetIndex( VectorID1) ;

.. _UTILITY/DynamicVectorPkg/SetIndexSetIteratorIndexValue:

SetIndex: Set iterator index value
==================================

Set the iterator index value. Without a parameter, it sets the value to 0.

.. code-block:: VHDL

   SetIndex( VectorID1) ;
   SetIndex( VectorID1, GetLastIndex(VectorID1)) ;

.. _UTILITY/DynamicVectorPkg/HasNext:

HasNext
=======

Return TRUE if there are :vhdlcode:`NumValues` (default = 1) available at the current iterator.

.. code-block:: VHDL

   while HasNext(VectorID1, NumValues) loop
     . . .

.. _UTILITY/DynamicVectorPkg/IndexNext:

IndexNext
=========

Return the current iterator value and then increment the iterator by :vhdlcode:`NumValues` (default = 1).

.. code-block:: VHDL

   Index := IndexNext(VectorID1, NumValues) ;

.. _UTILITY/DynamicVectorPkg/GetNext:

GetNext
=======

Return :vhdlcode:`NumValues` elements using the current iterator and then increment the iterator by
:vhdlcode:`NumValues` (default = 1).

.. code-block:: VHDL

   DataElement := GetNext(VectorID1) ;
   DataVector  := GetNext(VectorID1, NumValues) ;

.. _UTILITY/DynamicVectorPkg/HasPrevious:

HasPrevious
===========

Return TRUE if there are :vhdlcode:`NumValues` (default = 1) available before the current iterator.

.. code-block:: VHDL

   while HasPrevious(VectorID1, NumValues) loop
     . . .

.. _UTILITY/DynamicVectorPkg/IndexPrevious:

IndexPrevious
=============

Decrement the current iterator by :vhdlcode:`NumValues` (default = 1) and return the iterator value.

.. code-block:: VHDL

   Index := IndexPrevious(VectorID1, NumValues) ;

.. _UTILITY/DynamicVectorPkg/GetPrevious:

GetPrevious
===========

Decrement the iterator by :vhdlcode:`NumValues` (default = 1) and then return :vhdlcode:`NumValues` elements using the
current iterator.

.. code-block:: VHDL

   DataElement := GetPrevious(VectorID1) ;
   DataVector  := GetPrevious(VectorID1, NumValues) ;

.. _UTILITY/DynamicVectorPkg/Deallocate:

Deallocate
==========

:vhdlcode:`Deallocate` releases an ID. When :vhdlcode:`Deallocate` is called on the last iterator associated with an ID,
the vector is deallocated. The vector exists as long as there is an ID that references it.

.. code-block:: VHDL

   VectorID1 := Deallocate(VectorID1) ;
   CopyID1   := Deallocate(CopyID1) ;

.. _UTILITY/DynamicVectorPkg/FindMatch:

Find & Match
************

:vhdlcode:`Find` searches for a value and returns the index where it was found or -1 if not found. :vhdlcode:`Match`
gets a value from an index and if it matches the value it returns true.

.. _UTILITY/DynamicVectorPkg/Find:

Find
====

:vhdlcode:`Find` searches from :vhdlcode:`GetFirstIndex` to :vhdlcode:`GetLastIndex` for a value and returns the index
where it was found or -1 if not found.

.. code-block:: VHDL

   Index := Find( VectorID1, ElementValue) ;
   Index := Find( VectorID1, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/FindNext:

FindNext
========

:vhdlcode:`FindNext` searches from the current iterator value to :vhdlcode:`GetLastIndex` for a value and returns the
index where it was found or -1 if not. The iterator is updated using :vhdlcode:`IndexNext`. Allows finding the same
value multiple times within a vector.

.. code-block:: VHDL

   Index := FindNext( VectorID1, ElementValue) ;
   Index := FindNext( VectorID1, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/FindPrevious:

FindPrevious
============

:vhdlcode:`FindPrevious` searches from the current iterator value to :vhdlcode:`GetFirstIndex` for a value and returns
the index where it was found or -1 if not. The iterator is updated using :vhdlcode:`IndexPrevious`. Allows finding a
value multiple times within a vector.

.. code-block:: VHDL

   Index := FindPrevious( VectorID1, ElementValue) ;
   Index := FindPrevious ( VectorID1, VectorValue) ;

.. _UTILITY/DynamicVectorPkg/Match:

Match
=====

:vhdlcode:`Match` gets a value from an index and if it matches the value it returns true.

.. code-block:: VHDL

   if Match( VectorID1, Index, ElementValue) then
   if Match( VectorID1, Index, VectorValue) then

.. _UTILITY/DynamicVectorPkg/InformationAboutTheVector:

Information About the Vector
****************************

.. _UTILITY/DynamicVectorPkg/IsInitialized:

IsInitialized
=============

Returns TRUE when the ID has been initialized.

.. code-block:: VHDL

   if IsInitialized(VectorID1) then
   if IsInitialized(CopyID1) then

.. _UTILITY/DynamicVectorPkg/IsEmpty:

IsEmpty
=======

Returns TRUE when there are no elements in the vector.

.. code-block:: VHDL

   if IsEmpty(VectorID1) then
   if IsEmpty(CopyID1) then

.. _UTILITY/DynamicVectorPkg/MakeEmpty:

MakeEmpty
=========

Remove all elements from the vector. Impacts all iterators to the vector.

.. code-block:: VHDL

   MakeEmpty(VectorID1) ;

.. _UTILITY/DynamicVectorPkg/GetSize:

GetSize
=======

Returns the number of values in the vector.

.. code-block:: VHDL

   Size := GetSize(VectorID1) ;

.. _UTILITY/DynamicVectorPkg/GetCapacity:

GetCapacity
===========

Returns the capacity in the vector. During :vhdlcode:`Append`, :vhdlcode:`Insert`, :vhdlcode:`Prepend`, if size is
greater than capacity, the capacity is doubled. This results in allocating a vector that matches the new capacity,
copying the old values to it, and deallocating the old vector.

.. code-block:: VHDL

   Capacity := GetCapacity(VectorID1) ;

.. _UTILITY/DynamicVectorPkg/GetAlertLogID:

GetAlertLogID
=============

Returns the :vhdlcode:`AlertLogID` of the vector data structure that is either created or copied during the call to
:vhdlcode:`NewID`.

.. code-block:: VHDL

   VectorAlertLogID := GetAlertLogID(VectorID1) ;

.. _UTILITY/DynamicVectorPkg/WritingReadingVectorValues:

Writing/Reading Vector Values
*****************************

Note this feature reflects the current implementation and may change.

Vector values are written and read so that the right most value is stored first. When the vector elements are integer,
this is not so important. When the vector elements are :vhdlcode:`std_logic`, if the low bytes are written into the
vector first and each element is written low bit first, then when 32-bit words are read out (and the bits are reversed),
then the 32-bit word is in the proper order – without any transformations required.

.. _UTILITY/DynamicVectorPkg/GenericsAndInstancesOfDynamicVectorGenericPkg:

Generics and Instances of DynamicVectorGenericPkg
*************************************************

.. _UTILITY/DynamicVectorPkg/GenericInterface:

Generic Interface
=================

The generic interface for :vhdlcode:`DynamicVectorGenericPkg` is shown below.

.. code-block:: VHDL

   package DynamicVectorGenericPkg is
     generic (type VectorType is array (type is range <>) of type is private ) ;
     . . .

.. _UTILITY/DynamicVectorPkg/InstancesOfDynamicVectorGenericPkg:

Instances of DynamicVectorGenericPkg
====================================

There are two primary instances :vhdlcode:`DynamicVectorPkg_IntV` and :vhdlcode:`DynamicVectorPkg_slv`. These are shown
below.

.. code-block:: VHDL

   package DynamicVectorPkg_IntV is new work.DynamicVectorGenericPkg
     generic map (VectorType => integer_vector ) ;

   library ieee ;
   use ieee.std_logic_1164.all ;
   package DynamicVectorPkg_slv is new work.DynamicVectorGenericPkg
     generic map (VectorType => std_logic_vector ) ;

.. _UTILITY/DynamicVectorPkg/CompilingAndUsingOSVVMUtilityLibrary:

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
