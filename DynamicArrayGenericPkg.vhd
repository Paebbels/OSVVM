--
--  File Name:         DynamicArrayGenericPkg.vhd
--  Design Unit Name:  DynamicArrayGenericPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--
--
--  Package Defines
--      Data structure for name. 
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.05    Initial revision.  
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2026 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--  

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.math_real.all ;
use std.textio.all ;

use work.IfElsePkg.all ;
use work.OsvvmScriptSettingsPkg.all ;
use work.OsvvmSettingsPkg.all ;
use work.TextUtilPkg.all ;
use work.ResolutionPkg.all ;
use work.TranscriptPkg.all ;
use work.AlertLogPkg.all ;
use work.NameStorePkg.all ;
use work.LanguageSupport2019Pkg.all ;
use work.IdFifoPTypePkg.all ; 

package DynamicArrayGenericPkg is 
  generic (type ArrayType is array (type is range <>) of type is private ) ;

  -- Package local definitions
  subtype ElementType is ArrayType'element ; 
  subtype IndexType   is ArrayType'index ; 
  type InternalArrayType is array (integer range <>) of ElementType ; 
  constant FIRST_INDEX   : integer := 0 ; 

  ------------------------------------------------------------
  -- DynamicArrayIDType
  -- ID Type for Dynamic Arrays
  type DynamicArrayIDType is record
    IdNum     : integer_max ;  -- A unique list
    CopyNum   : integer_max ;  -- A unique iterator
  end record DynamicArrayIDType ; 

  constant EMPTY_DYNAMIC_ARRAY_ID : DynamicArrayIDType := (IdNum => 0, CopyNum => 0) ;

  type DynamicArrayIDArrayType is array (integer range <>) of DynamicArrayIDType ;  
  
  ------------------------------------------------------------
  -- IsInitialized
  -- True if singleton has been constructed
  impure function IsInitialized (ID : DynamicArrayIDType) return boolean ; -- ID Valid

  ------------------------------------------------------------
  -- NewID
  -- Construct a new dynamic array
  impure function NewID (
    Name                : String ;
    Size                : natural ; 
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DynamicArrayIDType ;

--  impure function NewID (
--    Name                : String ;
----    Size                : natural ;  -- Size is 0
--    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--    ReportMode          : AlertLogReportModeType  := ENABLED ;
--    Search              : NameSearchType          := PRIVATE_NAME ;
--    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
--  ) return DynamicArrayIDType ;
  
  ------------------------------------------------------------
  -- CopyID
  -- Create a shallow copy of the data structure
  --
  impure function CopyID ( SiblingID : DynamicArrayIDType ) return DynamicArrayIDType ;

  ------------------------------------------------------------
  -- Append
  -- Add element(s) to the end of the list
  procedure Append (
    ID        : DynamicArrayIDType ; 
    iValue    : ElementType
  ) ;

  procedure Append (
    ID        : DynamicArrayIDType ; 
    iValue    : ArrayType
  ) ;

  ------------------------------------------------------------
  -- Get
  -- Return the element(s) at the index
  impure function Get  (
    ID        : DynamicArrayIDType ; 
    Index     : integer 
  ) return ElementType ;

  impure function Get  (
    ID        : DynamicArrayIDType ; 
    Index     : integer ;
    NumValues : integer 
  ) return ArrayType ;

  ------------------------------------------------------------
  -- Set
  -- Set the element(s) at the index
  procedure Set (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ElementType 
  ) ;
  
  procedure Set (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ArrayType 
  ) ;
  
  ------------------------------------------------------------
  -- Insert
  -- Insert element(s) to the list at Index
  -- O(n) operation since array is shifted
  procedure Insert (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ElementType 
  ) ;

  procedure Insert (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ArrayType 
  ) ;

  ------------------------------------------------------------
  -- Prepend
  -- Prepend element(s) to the list at start of list
  -- O(n) operation since array is shifted
  procedure Prepend (
    ID       : DynamicArrayIDType ; 
    iValue   : ElementType 
  ) ;
  
  procedure Prepend (
    ID       : DynamicArrayIDType ; 
    iValue   : ArrayType 
  ) ;

  ------------------------------------------------------------
  -- Delete
  --   Remove element(s) from the list at Index
  --   O(n) operation since array is shifted
  procedure Delete (
    ID        : DynamicArrayIDType ; 
    Index     : integer 
  ) ;
  
  procedure Delete (
    ID        : DynamicArrayIDType ; 
    Index     : integer ;
    NumValues : integer 
  ) ;

  ------------------------------------------------------------
  -- Find
  -- Search for value starting at StartingIndex and return index if found otherwise -1
  impure function Find (
    ID              : DynamicArrayIDType ;
    StartingIndex   : integer ; 
    iValue          : ElementType
  ) return integer ;

  impure function Find (
    ID              : DynamicArrayIDType ;
    StartingIndex   : integer ; 
    iValue          : ArrayType
  ) return integer ;

  ------------------------------------------------------------
  -- Find
  -- Search for value starting at Index 0 and return index if found otherwise -1
  impure function Find (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer ; 

  impure function Find (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer ; 

  ------------------------------------------------------------
  -- Match
  -- Return true if value at StartingIndex matches iValue
  impure function Match (
    ID              : DynamicArrayIDType ;
    Index           : integer ; 
    iValue          : ElementType
  ) return boolean ;

  impure function Match (
    ID              : DynamicArrayIDType ;
    Index           : integer ; 
    iValue          : ArrayType
  ) return boolean ; 

  ------------------------------------------------------------
  -- Each Iterator / Copy maintains an internal index to the list
  -- The following provide means to manipulate that index
  
  ------------------------------------------------------------
  -- GetIndex
  -- Return the current value of the internal index
  impure function GetIndex      (ID : DynamicArrayIDType) return integer ;

  ------------------------------------------------------------
  -- SetIndex
  -- Set the current value of the internal index
  procedure       SetIndex      (ID : DynamicArrayIDType ; Index : integer := FIRST_INDEX) ;

  ------------------------------------------------------------
  -- GetFirstIndex
  -- Return the first index in the list
  impure function GetFirstIndex (ID : DynamicArrayIDType) return integer ;

  ------------------------------------------------------------
  -- GetLastIndex
  -- Return the last index in the list
  -- With NumValues = 0, LastIndex is a reference to the next empty index
  impure function GetLastIndex  (ID : DynamicArrayIDType; NumValues : natural := 0) return integer ;

  ------------------------------------------------------------
  -- IndexNext
  -- Return the current index and then increment index by NumValues
  impure function IndexNext     (ID : DynamicArrayIDType; NumValues : integer := 1) return integer ;

  ------------------------------------------------------------
  -- HasNext
  -- If the index is incremented by NumValues, will the index be within the list
  impure function HasNext       (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean ;

  ------------------------------------------------------------
  -- IndexPrevious
  -- Decrement index by NumValues and return the index value
  impure function IndexPrevious (ID : DynamicArrayIDType; NumValues : integer := 1) return integer ;

  ------------------------------------------------------------
  -- HasPrevious
  -- If the index is decremented by NumValues, will the index be within the list
  impure function HasPrevious   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean ;

  ------------------------------------------------------------
  -- GetNext
  -- Get value at index and then increment index (index++)
  impure function GetNext (
    ID        : DynamicArrayIDType 
  ) return ElementType ; 

  impure function GetNext (
    ID        : DynamicArrayIDType ;
    NumValues : natural 
  ) return ArrayType ; 

  ------------------------------------------------------------
  -- SetNext
  -- Set value at index and then increment index (index++)
  procedure SetNext (
    ID        : DynamicArrayIDType ;
    iValue    : ElementType 
  ) ;

  procedure SetNext (
    ID        : DynamicArrayIDType ;
    iValue    : ArrayType 
  ) ;

  ------------------------------------------------------------
  -- FindNext
  -- Search for value starting at iterator index and return index if found otherwise -1
  impure function FindNext (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer ;

  impure function FindNext (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer ; 

  ------------------------------------------------------------
  -- GetPrevious
  -- Decrement index by NumValues and then get value at index  (--index)
  impure function GetPrevious (
    ID        : DynamicArrayIDType 
  ) return ElementType ;

  impure function GetPrevious (
    ID        : DynamicArrayIDType ;
    NumValues : natural 
  ) return ArrayType ;

  ------------------------------------------------------------
  -- SetPrevious
  -- Decrement index and then set value at index  (--index)
  procedure SetPrevious (
    ID        : DynamicArrayIDType ;
    iValue    : ElementType 
  ) ;

  procedure SetPrevious (
    ID        : DynamicArrayIDType ;
    iValue    : ArrayType 
  ) ;

  ------------------------------------------------------------
  -- FindPrevious
  -- Search for value starting at iterator index and return index if found otherwise -1
  impure function FindPrevious (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer ;

  impure function FindPrevious (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer ; 

  ------------------------------------------------------------
  -- IsEmpty
  -- Does the list have any elements in it
  impure function IsEmpty       (ID : DynamicArrayIDType) return boolean ;  -- Does ID have storage

  ------------------------------------------------------------
  -- Deallocate
  -- Deallocate the current copy.  
  -- If no copies remain free up the list.
  impure function Deallocate    (ID : DynamicArrayIDType) return DynamicArrayIDType; 

  ------------------------------------------------------------
  -- GetSize
  -- Return the number of elements in the list.  
  impure function GetSize      (ID : DynamicArrayIDType) return integer ;

  ------------------------------------------------------------
  -- GetCapacity
  -- Return the maximum number of elements the list can hold.  
  impure function GetCapacity  (ID : DynamicArrayIDType) return integer ;

  ------------------------------------------------------------
  -- MakeEmpty
  -- Set the size of the list to 0 for all copies of the list
  procedure       MakeEmpty    (ID : DynamicArrayIDType) ;

end package DynamicArrayGenericPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body DynamicArrayGenericPkg is
  constant ITERATOR_LENGTH_INIT : integer := 3 ; 
  constant ITERATOR_LENGTH_GROW : integer := 3 ;
  constant INITIAL_ARRAY_SIZE   : integer := 16 ;
  constant INDEX_NOT_FOUND      : integer := -1 ; 

  ------------------------------------------------------------
  -- Package Local - runs only to set constant ELEMENT_TYPE_INITIAL
  function GetElementTypeDefault return ElementType is
    variable DefaultValue : ElementType;
  begin
    return DefaultValue ;
  end function GetElementTypeDefault;

  constant ELEMENT_TYPE_INITIAL : ElementType := GetElementTypeDefault ;

  ------------------------------------------------------------
  -- Package Local - runs only to set ELEMENT_TYPE_INITIAL
  procedure FailureIdNotInitialized(ID : DynamicArrayIDType ; Name : string) is
  begin
    Alert("DynamicArray: " & Name & ", ID not Initialized. IdNum: " & to_string(ID.IdNum) & "  CopyNum: " & to_string(ID.CopyNum), FAILURE) ;
  end procedure FailureIdNotInitialized ; 

  type DynamicArrayPType is protected
    ------------------------------------------------------------
    impure function IsInitialized (ID : DynamicArrayIDType) return boolean ; -- ID Valid

    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      Size                : natural ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType  ;  -- These use the ParentAlertID rather than creating their own AlertLogID
      Search              : NameSearchType ;           -- These are always private and cloned to hand off
      PrintParent         : AlertLogPrintParentType 
    ) return DynamicArrayIDType ;

    ------------------------------------------------------------
    impure function CopyID ( SiblingID : DynamicArrayIDType ) return DynamicArrayIDType ;

    ------------------------------------------------------------
    procedure Append (
      ID        : DynamicArrayIDType ; 
      iValue    : ElementType
    ) ;

    procedure Append (
      ID        : DynamicArrayIDType ; 
      iValue    : InternalArrayType
    ) ;

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicArrayIDType ; 
      Index     : integer 
    ) return ElementType ;

    impure function Get  (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      NumValues : integer 
    ) return InternalArrayType ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : ElementType 
    ) ;
    
    procedure Set (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : InternalArrayType 
    ) ;
    
    ------------------------------------------------------------
    procedure Insert (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : ElementType 
    ) ;
    
    procedure Insert (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : InternalArrayType 
    ) ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicArrayIDType ; 
      Index     : integer 
    ) ;
    
    procedure Delete (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      NumValues : integer 
    ) ;
    
    ------------------------------------------------------------
    impure function GetIndex      (ID : DynamicArrayIDType) return integer ;
    procedure       SetIndex      (ID : DynamicArrayIDType ; Index : integer := FIRST_INDEX) ;
    impure function GetFirstIndex (ID : DynamicArrayIDType) return integer ;
    impure function GetLastIndex  (ID : DynamicArrayIDType; NumValues : natural := 0) return integer ;
    impure function IndexNext     (ID : DynamicArrayIDType; NumValues : integer := 1) return integer ;
    impure function HasNext       (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean ;
    impure function IndexPrevious (ID : DynamicArrayIDType; NumValues : integer := 1) return integer ;
    impure function HasPrevious   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean ;

    ------------------------------------------------------------
    impure function IsEmpty       (ID : DynamicArrayIDType) return boolean ;  -- Does ID have storage
    impure function Deallocate    (ID : DynamicArrayIDType) return DynamicArrayIDType ; 

    ------------------------------------------------------------
    impure function GetSize     (ID : DynamicArrayIDType) return integer ;
    impure function GetCapacity (ID : DynamicArrayIDType) return integer ;
    procedure       MakeEmpty   (ID : DynamicArrayIDType) ;

  end protected DynamicArrayPType ;

  type DynamicArrayPType is protected body

    type IteratorType is record
      HeadIndex   : integer ; 
      InUse       : boolean ; 
    end record IteratorType ; 

    type IteratorArrayType is array (natural range <>) of IteratorType ;
    type IteratorArrayPtrType is access IteratorArrayType ; 

    type ArrayPtrType is access InternalArrayType ; 

    type DynamicArrayRecType is record
      ArrayPtr       : ArrayPtrType ; 
      IteratorPtr    : IteratorArrayPtrType ; 
      TailIndex      : integer ; 
      Capacity       : integer ; 
      MaxCopyNum     : integer ; 
      ActiveClones   : integer ; 
      AlertLogID     : AlertLogIDType ; 
    end record DynamicArrayRecType ; 
    
    type  DynamicArrayRecPtrType is access DynamicArrayRecType ;
    type  SingletonArrayType     is array (integer range <>) of DynamicArrayRecPtrType ; 
    type  SingletonArrayPtrType  is access SingletonArrayType ;

    variable SingletonArrayPtr   : SingletonArrayPtrType ;   
    variable NumItems            : integer := 0 ; 
    variable MaxItems            : integer := 0 ;
    constant MIN_NUM_ITEMS       : integer := 32 ; -- Min amount to resize array

    variable IdFifo : IdFifoPType ; 

    ------------------------------------------------------------
    impure function IsInitialized (ID : DynamicArrayIDType) return boolean is
      constant IdNum : integer := ID.IdNum ; 
    begin
      if IdNum >= 1 and IdNum <= MaxItems then 
        if SingletonArrayPtr(IdNum) /= NULL then
          if SingletonArrayPtr(IdNum).IteratorPtr /= NULL and SingletonArrayPtr(IdNum).ArrayPtr /= NULL then
            if SingletonArrayPtr(IdNum).IteratorPtr(ID.CopyNum).InUse then
              return TRUE ;  -- Initialized
            end if ; 
          end if ; 
        end if ; 
      end if ; 
      return FALSE ; -- Not Initialized
    end function IsInitialized ;

    ------------------------------------------------------------
    -- Package Local
    impure function GetNextIdNumber return integer is
      variable oldItemArrayPtr  : SingletonArrayPtrType ;
    begin
      if not IdFifo.IsEmpty then 
        NumItems := NumItems + 1 ;
        return IdFifo.Pop ; 
      elsif SingletonArrayPtr = NULL then 
        MaxItems := MIN_NUM_ITEMS ; 
        SingletonArrayPtr := new SingletonArrayType(1 to MaxItems) ;
        NumItems := 1 ;
      else 
        AlertIfNotEqual(NumItems, SingletonArrayPtr'length, "GetNextIdNumber: NumItems /= SingletonArrayPtr'length") ;
        MaxItems := MaxItems + 32 ; 
        OldItemArrayPtr := SingletonArrayPtr ;
        SingletonArrayPtr := new SingletonArrayType(1 to MaxItems) ;
        SingletonArrayPtr.all(1 to NumItems) := oldItemArrayPtr.all(1 to NumItems) ;
        deallocate(oldItemArrayPtr) ;
        NumItems := NumItems + 1 ; 
      end if ; 
      for i in NumItems + 1 to MaxItems loop 
        IdFifo.push(i) ;
      end loop ; 
      return NumItems ; 
    end function GetNextIdNumber ;

    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      Size                : natural ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType  ;  -- These use the ParentAlertID rather than creating their own AlertLogID
      Search              : NameSearchType ;           -- These are always private and cloned to hand off
      PrintParent         : AlertLogPrintParentType 
    ) return DynamicArrayIDType is
      variable ID           : DynamicArrayIDType ; 
      variable ResolvedSize : integer ; 
      variable IdNum        : integer ;
    begin
      ResolvedSize := Maximum(Size, INITIAL_ARRAY_SIZE) ;
      -- GrowNumberItems(SingletonArrayPtr, NumItems, 1, MIN_NUM_ITEMS) ;
      IdNum := GetNextIdNumber ; 
      SingletonArrayPtr(IdNum) := new DynamicArrayRecType ;
      SingletonArrayPtr(IdNum).IteratorPtr := new IteratorArrayType'(1 to ITERATOR_LENGTH_INIT => (FIRST_INDEX, FALSE)) ; 
      SingletonArrayPtr(IdNum).IteratorPtr(1).InUse := TRUE ; 
      SingletonArrayPtr(IdNum).TailIndex    := FIRST_INDEX ; 
      SingletonArrayPtr(IdNum).ActiveClones := 1 ; 
      SingletonArrayPtr(IdNum).MaxCopyNum  := 1 ; 
      SingletonArrayPtr(IdNum).AlertLogID   := ParentID ; 
      SingletonArrayPtr(IdNum).Capacity     := ResolvedSize ; 
      SingletonArrayPtr(IdNum).ArrayPtr     := new InternalArrayType(FIRST_INDEX to FIRST_INDEX - 1 + ResolvedSize ) ; 
      ID.IdNum      := IdNum ; 
      ID.CopyNum   := 1 ; 
      return ID ; 
    end function NewID ;

    ------------------------------------------------------------
    impure function CopyID ( SiblingID : DynamicArrayIDType ) return DynamicArrayIDType is
      variable ID : DynamicArrayIDType ; 
      variable IdNum, vCopyNum : integer ; 
      variable OrigIteratorLength : integer ; 
      variable OldIteratorPtr, IteratorPtr : IteratorArrayPtrType ; 
    begin
      IdNum      := SiblingID.IdNum ; 
      ID.IdNum   := IdNum ; 
      vCopyNum   := SingletonArrayPtr(IdNum).MaxCopyNum + 1 ; 
      ID.CopyNum := vCopyNum ; 
      SingletonArrayPtr(IdNum).MaxCopyNum  := vCopyNum ; 
      SingletonArrayPtr(IdNum).ActiveClones := SingletonArrayPtr(IdNum).ActiveClones + 1 ; 
      OrigIteratorLength := SingletonArrayPtr(IdNum).IteratorPtr'length ;
      if vCopyNum > OrigIteratorLength then
        OldIteratorPtr := SingletonArrayPtr(IdNum).IteratorPtr ;
        -- IteratorPtr := new integer_vector'(1 to OrigIteratorLength + ITERATOR_LENGTH_GROW => 1) ;
        IteratorPtr := new IteratorArrayType'(1 to OrigIteratorLength + ITERATOR_LENGTH_GROW => (FIRST_INDEX, FALSE)) ; 
        IteratorPtr.all(1 to OrigIteratorLength) := OldIteratorPtr.all(1 to OrigIteratorLength) ;
        deallocate(OldIteratorPtr) ;
        SingletonArrayPtr(IdNum).IteratorPtr := IteratorPtr ; 
      end if ; 
      SingletonArrayPtr(IdNum).IteratorPtr(vCopyNum).InUse := TRUE ; 
      return ID ; 
    end function CopyID ; 

    ------------------------------------------------------------
    -- PT Local
    procedure IncreaseArrayCapacity (
      IdNum       : Integer ; 
      NewSize     : Integer 
    ) is
      variable OldArrayPtr        : ArrayPtrType ;
      variable OldCapacity, NewCapacity   : integer ;
    begin
      OldCapacity := SingletonArrayPtr(IdNum).Capacity ;
      NewCapacity := OldCapacity ; 
      while NewCapacity < NewSize loop
        NewCapacity := NewCapacity * 2 ; 
      end loop ; 

      OldArrayPtr := SingletonArrayPtr(IdNum).ArrayPtr ; 
      SingletonArrayPtr(IdNum).ArrayPtr := new InternalArrayType(FIRST_INDEX to FIRST_INDEX - 1 + NewCapacity) ;
      SingletonArrayPtr(IdNum).Capacity := NewCapacity ; 
      SingletonArrayPtr(IdNum).ArrayPtr.all(FIRST_INDEX to FIRST_INDEX - 1 + OldCapacity) := OldArrayPtr.all(FIRST_INDEX to FIRST_INDEX - 1 + OldCapacity) ;
      deallocate(OldArrayPtr) ;
    end procedure IncreaseArrayCapacity ;

    ------------------------------------------------------------
    -- PT Local
    procedure SetArrayValue (
      ID             : DynamicArrayIDType ; 
      StartingIndex  : integer ; 
      EndingIndex    : integer ; 
      iValue         : InternalArrayType
    ) is
      alias revValue : InternalArrayType (EndingIndex downto StartingIndex) is iValue ; 
    begin
--      SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) := iValue ; 
      for i in StartingIndex to EndingIndex loop 
        SingletonArrayPtr(ID.IdNum).ArrayPtr(i) := revValue(i) ;
      end loop ; 
    end procedure SetArrayValue ; 

    ------------------------------------------------------------
    -- PT Local
    impure function GetArrayValue (
      ID             : DynamicArrayIDType ; 
      StartingIndex  : integer ; 
      EndingIndex    : integer 
    ) return InternalArrayType is
      variable Result : InternalArrayType(EndingIndex downto StartingIndex) ;
    begin
      for i in StartingIndex to EndingIndex loop 
        Result(i) := SingletonArrayPtr(ID.IdNum).ArrayPtr(i) ;
      end loop ; 
--        return SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) ;
      return Result ; 
    end function GetArrayValue ; 

    ------------------------------------------------------------
    procedure Append (
      ID        : DynamicArrayIDType ; 
      iValue    : ElementType
    ) is
      variable EndingIndex, NewSize : natural ;
      variable IdNum : integer ;
    begin
      IdNum := ID.IdNum ; 
      EndingIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      NewSize     := EndingIndex + 1 ;
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SingletonArrayPtr(IdNum).ArrayPtr(EndingIndex) := iValue ; 
    end procedure Append ;

    ------------------------------------------------------------
    procedure Append (
      ID        : DynamicArrayIDType ; 
      iValue    : InternalArrayType
    ) is
      variable StartingIndex : natural ;
      variable NewSize       : natural ;
      variable EndingIndex   : natural ;
      constant ARRAY_SIZE    : natural := iValue'length ; 
      variable IdNum         : integer ;
    begin
      IdNum := ID.IdNum ; 
      StartingIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      NewSize       := SingletonArrayPtr(IdNum).TailIndex + ARRAY_SIZE ; 
      EndingIndex   := NewSize - 1 ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
--      SingletonArrayPtr(IdNum).ArrayPtr(StartingIndex to EndingIndex) := iValue ; 
      SetArrayValue(ID, StartingIndex, EndingIndex, iValue) ;
    end procedure Append ;

    ------------------------------------------------------------
    -- Package Local
    impure function CheckIndex  (
      ID        : DynamicArrayIDType ; 
      Index    : integer 
    ) return boolean is
    begin
      return Index >= FIRST_INDEX and Index < SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function CheckIndex ; 

    ------------------------------------------------------------
    -- Package Local
    impure function CheckIndex  (
      ID                         : DynamicArrayIDType ; 
      StartingIndex, EndingIndex : integer 
    ) return boolean is
    begin
      return StartingIndex >= FIRST_INDEX and EndingIndex < SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function CheckIndex ; 

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicArrayIDType ; 
      Index     : integer 
    ) return ElementType is
      variable Result : ElementType ;
      variable StartingIndex : integer ; 
    begin
      StartingIndex := FIRST_INDEX + Index ; 
      if CheckIndex(ID, StartingIndex) then 
        return SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex) ;  
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "", FAILURE)  ; 
        return Result ;
      end if ; 
    end function Get ;

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      NumValues : integer 
    ) return InternalArrayType is
      variable Result : InternalArrayType(1 to NumValues) ;
      variable StartingIndex, EndingIndex : integer ;
    begin
      StartingIndex := FIRST_INDEX + Index ; 
      EndingIndex   := StartingIndex + NumValues - 1 ; 
      if CheckIndex(ID, StartingIndex, EndingIndex) then 
--        return SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) ;
        return GetArrayValue(ID, StartingIndex, EndingIndex) ;
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "", FAILURE)  ; 
        return Result ;  
      end if ; 
    end function Get ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : ElementType 
    ) is
      variable StartingIndex : integer ; 
    begin
      StartingIndex := FIRST_INDEX + Index ; 
      if CheckIndex(ID, StartingIndex) then 
        SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex) := iValue ;
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "", FAILURE)  ; 
      end if ; 
    end procedure Set ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicArrayIDType ; 
      Index    : integer ;
      iValue   : InternalArrayType 
    ) is
      variable StartingIndex, EndingIndex : integer ; 
    begin
      StartingIndex := FIRST_INDEX + Index ; 
      EndingIndex   := StartingIndex + iValue'length - 1 ; 
      if CheckIndex(ID, StartingIndex, EndingIndex) then 
--        SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) := iValue ;
        SetArrayValue(ID, StartingIndex, EndingIndex, iValue) ;
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "", FAILURE)  ; 
      end if ; 
    end procedure Set ;

    ------------------------------------------------------------
    procedure Insert (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      iValue    : ElementType
    ) is
      variable OldTailIndex, NewSize : natural ;
      variable IdNum : integer ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      NewSize      := OldTailIndex + 1 ; 
      if Index > OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, "Index not in Array." & 
              "  Index: " & to_string(Index) & 
              "  ArrayBounds: 0 to " & to_string(OldTailIndex - 1), FAILURE) ; 
        return ; 
      end if ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      if Index /= OldTailIndex then
        -- Move the current values over
        SingletonArrayPtr(IdNum).ArrayPtr(Index+1 to OldTailIndex) := 
            SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-1) ;
  --!!      for i in Index to OldTailIndex-1 loop 
  --!!        SingletonArrayPtr(IdNum).ArrayPtr(i+1) := SingletonArrayPtr(IdNum).ArrayPtr(i) ;
  --!!      end loop ; 
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SingletonArrayPtr(IdNum).ArrayPtr(Index) := iValue ; 
    end procedure Insert ;

    ------------------------------------------------------------
    procedure Insert (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      iValue    : InternalArrayType
    ) is
      variable OldTailIndex    : natural ;
      variable NewSize         : natural ;
      constant ARRAY_SIZE      : natural := iValue'length ; 
      variable IdNum           : integer ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex  := SingletonArrayPtr(IdNum).TailIndex ;
      NewSize       := SingletonArrayPtr(IdNum).TailIndex + ARRAY_SIZE ; 
      if Index > OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, "Index not in Dynamic Array." & 
              "  Index: " & to_string(Index) & 
              "  ArrayBounds: 0 to " & to_string(OldTailIndex-1), FAILURE) ; 
        return ; 
      end if ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      if Index /= OldTailIndex then
        -- Move the current values over
        SingletonArrayPtr(IdNum).ArrayPtr(Index + ARRAY_SIZE to NewSize - 1) := 
            SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex - 1) ;
  --!!      for i in Index to OldTailIndex-1 loop 
  --!!        SingletonArrayPtr(IdNum).ArrayPtr(i+ARRAY_SIZE) := SingletonArrayPtr(IdNum).ArrayPtr(i) ;
  --!!      end loop ;
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SetArrayValue(ID, Index, Index + ARRAY_SIZE - 1, iValue) ;
    end procedure Insert ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicArrayIDType ; 
      Index     : integer 
    ) is
      variable OldTailIndex : natural ;
      variable IdNum : integer ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      if Index >= OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, "Index not in Array." & 
              "  Index: " & to_string(Index) & 
              "  ArrayBounds: 0 to " & to_string(OldTailIndex-1), FAILURE) ; 
        return ; 
      end if ; 
      -- Move the current values over
      SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-2) := 
          SingletonArrayPtr(IdNum).ArrayPtr(Index+1 to OldTailIndex-1) ;
      SingletonArrayPtr(IdNum).TailIndex := OldTailIndex-1 ; 
    end procedure Delete ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicArrayIDType ; 
      Index     : integer ;
      NumValues : integer 
    ) is
      variable OldTailIndex    : natural ;
      variable IdNum           : integer ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex  := SingletonArrayPtr(IdNum).TailIndex ;
      if Index >= OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, "Index not in Array." & 
              "  Index: " & to_string(Index) & 
              "  ArrayBounds: 0 to " & to_string(OldTailIndex-1), FAILURE) ; 
        return ; 
      end if ; 
      -- Move the current values over
      SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-NumValues-1) := 
          SingletonArrayPtr(IdNum).ArrayPtr(Index+NumValues to OldTailIndex-1) ;
      SingletonArrayPtr(IdNum).TailIndex := OldTailIndex-NumValues ; 
    end procedure Delete ;

    ------------------------------------------------------------
    impure function GetIndex (ID : DynamicArrayIDType) return integer is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ; 
    end function GetIndex ; 

    ------------------------------------------------------------
    procedure SetIndex (ID : DynamicArrayIDType ; Index : integer := FIRST_INDEX) is
    begin
      SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := Index ;
    end procedure SetIndex ;

    ------------------------------------------------------------
    impure function GetFirstIndex (ID : DynamicArrayIDType) return integer is
    begin
      return FIRST_INDEX ; 
    end function GetFirstIndex ; 

    ------------------------------------------------------------
    impure function GetLastIndex (ID : DynamicArrayIDType; NumValues : natural := 0) return integer is
    -- With NumValues = 0, LastIndex is a reference to the next empty index
    begin
      return SingletonArrayPtr(ID.IdNum).TailIndex - NumValues ; 
    end function GetLastIndex ; 

    ------------------------------------------------------------
    impure function IndexNext (ID : DynamicArrayIDType; NumValues : integer := 1) return integer is
      variable CurIndex, NextIndex, LastIndex : integer ; 
    begin
      CurIndex := SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ; 
      NextIndex := CurIndex + NumValues ;
      LastIndex := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if NextIndex <= LastIndex then
        SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := NextIndex ; 
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "IndexNext:  Next Index Exceeds LastIndex" & 
              "  NextIndex: " & to_string(NextIndex) &
              "  LastIndex: " & to_string(LastIndex), FAILURE) ; 
      end if ; 
      return CurIndex ; 
    end function IndexNext ; 

    ------------------------------------------------------------
    impure function HasNext   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex + NumValues <= SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function HasNext ; 

    ------------------------------------------------------------
    impure function IndexPrevious (ID : DynamicArrayIDType; NumValues : integer := 1) return integer is
      variable PreviousIndex : integer ; 
    begin
      PreviousIndex := SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex - NumValues ; 
      if PreviousIndex >= FIRST_INDEX then
        SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := PreviousIndex ; 
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, "IndexPrevious:  Previous Index is less than FIRST_INDEX" & 
              "  PreviousIndex: " & to_string(PreviousIndex) &
              "  FIRST_INDEX: "   & to_string(FIRST_INDEX), FAILURE) ; 
      end if ; 
      return PreviousIndex ; 
    end function IndexPrevious ; 

    ------------------------------------------------------------
    impure function HasPrevious   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex - NumValues >= FIRST_INDEX ;
    end function HasPrevious ; 
  
    ------------------------------------------------------------
    impure function IsEmpty   (ID : DynamicArrayIDType) return boolean is
    begin
      if not IsInitialized(ID) then
        FailureIdNotInitialized(ID, "IsEmpty") ; 
        return TRUE ; 
      end if ; 
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex >= SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function IsEmpty ; 
  
    ------------------------------------------------------------
    impure function Deallocate(ID : DynamicArrayIDType) return DynamicArrayIDType is
    begin
      if not IsInitialized(ID) then
        FailureIdNotInitialized(ID, "Deallocate") ; 
        return EMPTY_DYNAMIC_ARRAY_ID ; 
      end if ; 
      SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).InUse := FALSE ; 
      SingletonArrayPtr(ID.IdNum).ActiveClones := SingletonArrayPtr(ID.IdNum).ActiveClones - 1 ; 
      if SingletonArrayPtr(ID.IdNum).ActiveClones <= 0 then
--!! Put IteratorPtr on a MemoryPool.
        deallocate(SingletonArrayPtr(ID.IdNum).IteratorPtr) ;
--!! Put ArrayPtr on a MemoryPool.
        deallocate(SingletonArrayPtr(ID.IdNum).ArrayPtr) ;
        IdFifo.push(ID.IdNum) ;
        NumItems := NumItems - 1 ; 
      end if ; 
      return EMPTY_DYNAMIC_ARRAY_ID ; 
    end function Deallocate ;

    ------------------------------------------------------------
    impure function GetSize (ID : DynamicArrayIDType) return integer is
    begin
      if not IsInitialized(ID) then
        FailureIdNotInitialized(ID, "GetSize") ; 
        return -1 ; 
      end if ; 
      return SingletonArrayPtr(ID.IdNum).TailIndex - 
             SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ;
    end function GetSize ;

    ------------------------------------------------------------
    impure function GetCapacity (ID : DynamicArrayIDType) return integer is
    begin
      if not IsInitialized(ID) then
        FailureIdNotInitialized(ID, "GetCapacity") ; 
        return -1 ; 
      end if ; 
      return SingletonArrayPtr(ID.IdNum).Capacity ;
    end function GetCapacity ;

    ------------------------------------------------------------
    procedure MakeEmpty (ID : DynamicArrayIDType) is
    begin
      if not IsInitialized(ID) then
        FailureIdNotInitialized(ID, "MakeEmpty") ; 
        return ; 
      end if ; 
      SingletonArrayPtr(ID.IdNum).TailIndex := FIRST_INDEX ;
      for i in 1 to SingletonArrayPtr(ID.IdNum).IteratorPtr'length loop 
        SingletonArrayPtr(ID.IdNum).IteratorPtr(i).HeadIndex := FIRST_INDEX ;
      end loop ; 
    end procedure MakeEmpty ;

  end protected body DynamicArrayPType ;
  
  ------------------------------------------------------------
  -- Singleton Data Structure
  ------------------------------------------------------------
  shared variable DynamicArrayStore : DynamicArrayPType ; 
  
  ------------------------------------------------------------
  impure function IsInitialized (ID : DynamicArrayIDType) return boolean is
  begin
    return DynamicArrayStore.IsInitialized(ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    Size                : natural ; 
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DynamicArrayIDType is
  begin
    return DynamicArrayStore.NewID(Name, Size, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

--  impure function NewID (
--    Name                : String ;
----    Size                : natural ;  -- Size is 0
--    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
--    ReportMode          : AlertLogReportModeType  := ENABLED ;
--    Search              : NameSearchType          := PRIVATE_NAME ;
--    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
--  ) return DynamicArrayIDType is
--  begin
--    return DynamicArrayStore.NewID(Name, 0, ParentID, ReportMode, Search, PrintParent) ;
--  end function NewID ;
  
  ------------------------------------------------------------
  impure function CopyID ( SiblingID : DynamicArrayIDType ) return DynamicArrayIDType is
  begin
    if not DynamicArrayStore.IsInitialized(SiblingID) then
      FailureIdNotInitialized(SiblingID, "CopyID") ; 
      return EMPTY_DYNAMIC_ARRAY_ID ;
    end if ; 
    return DynamicArrayStore.CopyID(SiblingID) ;
  end function CopyID ;

  ------------------------------------------------------------
  procedure Append (
    ID        : DynamicArrayIDType ; 
    iValue    : ElementType
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Append") ; 
      return ;
    end if ; 
    DynamicArrayStore.Append(ID, iValue) ;
  end procedure Append ;

  ------------------------------------------------------------
  procedure Append (
    ID        : DynamicArrayIDType ; 
    iValue    : ArrayType
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Append") ; 
      return ;
    end if ; 
    DynamicArrayStore.Append(ID, InternalArrayType(iValue)) ;
  end procedure Append ;

  ------------------------------------------------------------
  impure function Get  (
    ID        : DynamicArrayIDType ; 
    Index     : integer 
  ) return ElementType is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Get") ; 
      return ELEMENT_TYPE_INITIAL ;  
    end if ; 
    return DynamicArrayStore.Get(ID, Index) ;
  end function Get ;

  ------------------------------------------------------------
  impure function Get  (
    ID        : DynamicArrayIDType ; 
    Index     : integer ;
    NumValues : integer 
  ) return ArrayType is
    constant Result : InternalArrayType := (1 to NumValues => ELEMENT_TYPE_INITIAL) ;
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Get") ; 
      return ArrayType(Result) ; 
    end if ; 
    return ArrayType(DynamicArrayStore.Get(ID, Index, NumValues)) ;
  end function Get ;

  ------------------------------------------------------------
  procedure Set (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ElementType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Set") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, Index, iValue) ;
  end procedure Set ;
  
  ------------------------------------------------------------
  procedure Set (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ArrayType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Set") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, Index, InternalArrayType(iValue)) ;
  end procedure Set ;
  
  ------------------------------------------------------------
  procedure Insert (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ElementType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Insert") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Insert(ID, Index, iValue) ;
  end procedure Insert ;
  
  ------------------------------------------------------------
  procedure Insert (
    ID       : DynamicArrayIDType ; 
    Index    : integer ;
    iValue   : ArrayType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Insert") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Insert(ID, Index, InternalArrayType(iValue)) ;
  end procedure Insert ;
  
  ------------------------------------------------------------
  procedure Prepend (
    ID       : DynamicArrayIDType ; 
    iValue   : ElementType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Prepend") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Insert(ID, 0, iValue) ;
  end procedure Prepend ;
  
  ------------------------------------------------------------
  procedure Prepend (
    ID       : DynamicArrayIDType ; 
    iValue   : ArrayType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Prepend") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Insert(ID, 0, InternalArrayType(iValue)) ;
  end procedure Prepend ;
  
  ------------------------------------------------------------
  procedure Delete (
    ID        : DynamicArrayIDType ; 
    Index     : integer 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Delete") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Delete(ID, Index) ;
  end procedure Delete ;
  
  ------------------------------------------------------------
  procedure Delete (
    ID        : DynamicArrayIDType ; 
    Index     : integer ;
    NumValues : integer 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Delete") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Delete(ID, Index, NumValues) ;
  end procedure Delete ;

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicArrayIDType ;
    StartingIndex   : integer ; 
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Find") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    for Index in StartingIndex to DynamicArrayStore.GetLastIndex(ID, 1) loop
      if DynamicArrayStore.Get(ID, Index) = iValue then
        return Index ; 
      end if ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicArrayIDType ;
    StartingIndex   : integer ; 
    iValue          : ArrayType
  ) return integer is
    constant NUM_VALUES : integer := iValue'length ; 
    variable Index, EndingIndex : integer ; 
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Find") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    Index := StartingIndex ; 
    EndingIndex := GetLastIndex(ID, NUM_VALUES) ;
    while Index <= EndingIndex loop 
      if ArrayType(DynamicArrayStore.Get(ID, Index, NUM_VALUES)) = iValue then
        return Index ; 
      end if ; 
      Index := Index + NUM_VALUES ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    return Find(ID => ID, StartingIndex => 0, iValue => iValue) ;
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer is
  begin
    return Find(ID => ID, StartingIndex => 0, iValue => iValue) ;
  end function Find ; 

  ------------------------------------------------------------
  impure function Match (
    ID              : DynamicArrayIDType ;
    Index           : integer ; 
    iValue          : ElementType
  ) return boolean is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Match") ; 
      return FALSE ; 
    end if ; 
    return DynamicArrayStore.Get(ID, Index) = iValue ; 
  end function Match ; 

  ------------------------------------------------------------
  impure function Match (
    ID              : DynamicArrayIDType ;
    Index           : integer ; 
    iValue          : ArrayType
  ) return boolean is
    constant NUM_VALUES : integer := iValue'length ; 
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Match") ; 
      return FALSE ; 
    end if ; 
    return ArrayType(DynamicArrayStore.Get(ID, Index, NUM_VALUES)) = iValue ; 
  end function Match ; 

  ------------------------------------------------------------
  impure function GetIndex (ID : DynamicArrayIDType) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetIndex") ; 
      return -1 ; 
    end if ; 
    return DynamicArrayStore.GetIndex(ID) ; 
  end function GetIndex ; 

  ------------------------------------------------------------
  procedure SetIndex (ID : DynamicArrayIDType ; Index : integer := FIRST_INDEX) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetIndex") ; 
      return ; 
    end if ; 
    DynamicArrayStore.SetIndex(ID, Index) ;
  end procedure SetIndex ;

  ------------------------------------------------------------
  impure function GetFirstIndex (ID : DynamicArrayIDType) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetFirstIndex") ; 
      return -1 ; 
    end if ; 
    return FIRST_INDEX ; 
  end function GetFirstIndex ; 

  ------------------------------------------------------------
  impure function GetLastIndex (ID : DynamicArrayIDType; NumValues : natural := 0) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetLastIndex") ; 
      return -1 ; 
    end if ; 
    return DynamicArrayStore.GetLastIndex(ID, NumValues) ; 
  end function GetLastIndex ; 

  ------------------------------------------------------------
  impure function IndexNext (ID : DynamicArrayIDType; NumValues : integer := 1) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "IndexNext") ; 
      return -1 ; 
    end if ; 
    return DynamicArrayStore.IndexNext(ID, NumValues) ; 
  end function IndexNext ; 

  ------------------------------------------------------------
  impure function HasNext   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "HasNext") ; 
      return FALSE ; 
    end if ; 
    return DynamicArrayStore.HasNext(ID, NumValues) ; 
  end function HasNext ; 

  ------------------------------------------------------------
  impure function IndexPrevious (ID : DynamicArrayIDType; NumValues : integer := 1) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "IndexPrevious") ; 
      return -1 ; 
    end if ; 
    return DynamicArrayStore.IndexPrevious(ID, NumValues) ; 
  end function IndexPrevious ; 

  ------------------------------------------------------------
  impure function HasPrevious   (ID : DynamicArrayIDType; NumValues : integer := 1) return boolean is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "HasPrevious") ; 
      return FALSE ; 
    end if ; 
    return DynamicArrayStore.HasPrevious(ID, NumValues) ; 
  end function HasPrevious ; 

  ------------------------------------------------------------
  impure function GetNext (
    ID        : DynamicArrayIDType 
  ) return ElementType is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetNext") ; 
      return ELEMENT_TYPE_INITIAL ; 
    end if ; 
    return DynamicArrayStore.Get(ID, DynamicArrayStore.IndexNext(ID, 1)) ; 
  end function GetNext ;

  ------------------------------------------------------------
  impure function GetNext (
    ID        : DynamicArrayIDType ;
    NumValues : natural 
  ) return ArrayType is
    constant Result : InternalArrayType := (1 to NumValues => ELEMENT_TYPE_INITIAL) ;
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetNext") ; 
      return ArrayType(Result) ; 
    end if ; 
    return ArrayType(DynamicArrayStore.Get(ID => ID, Index => DynamicArrayStore.IndexNext(ID, NumValues), NumValues => NumValues)) ; 
  end function GetNext ;

  ------------------------------------------------------------
  procedure SetNext (
    ID        : DynamicArrayIDType ;
    iValue    : ElementType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetNext") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, DynamicArrayStore.IndexNext(ID, 1), iValue) ; 
  end procedure SetNext ;

  ------------------------------------------------------------
  procedure SetNext (
    ID        : DynamicArrayIDType ;
    iValue    : ArrayType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetNext") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, DynamicArrayStore.IndexNext(ID, iValue'length), InternalArrayType(iValue)) ; 
  end procedure SetNext ;

  ------------------------------------------------------------
  impure function FindNext (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindNext") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    while DynamicArrayStore.HasNext(ID) loop
      if GetNext(ID) = iValue then
        return DynamicArrayStore.GetIndex(ID)-1 ; 
      end if ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function FindNext ; 

  ------------------------------------------------------------
  impure function FindNext (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer is
    constant NUM_VALUES : integer := iValue'length ; 
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindNext") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    while DynamicArrayStore.HasNext(ID, NUM_VALUES) loop
      if GetNext(ID, NUM_VALUES) = iValue then
        return DynamicArrayStore.GetIndex(ID)-NUM_VALUES ; 
      end if ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function FindNext ; 

  ------------------------------------------------------------
  impure function GetPrevious (
    ID        : DynamicArrayIDType 
  ) return ElementType is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetPrevious") ; 
      return ELEMENT_TYPE_INITIAL ; 
    end if ; 
    return DynamicArrayStore.Get(ID, DynamicArrayStore.IndexPrevious(ID, 1)) ; 
  end function GetPrevious ;

  ------------------------------------------------------------
  impure function GetPrevious (
    ID        : DynamicArrayIDType ;
    NumValues : natural 
  ) return ArrayType is
    constant Result : InternalArrayType := (1 to NumValues => ELEMENT_TYPE_INITIAL) ;
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetPrevious") ; 
      return ArrayType(Result) ; 
    end if ; 
    return ArrayType(DynamicArrayStore.Get(ID => ID, Index => DynamicArrayStore.IndexPrevious(ID, NumValues), NumValues => NumValues)) ; 
  end function GetPrevious ;

  ------------------------------------------------------------
  procedure SetPrevious (
    ID        : DynamicArrayIDType ;
    iValue    : ElementType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetPrevious") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, DynamicArrayStore.IndexPrevious(ID, 1), iValue) ; 
  end procedure SetPrevious ;

  ------------------------------------------------------------
  procedure SetPrevious (
    ID        : DynamicArrayIDType ;
    iValue    : ArrayType 
  ) is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetPrevious") ; 
      return ; 
    end if ; 
    DynamicArrayStore.Set(ID, DynamicArrayStore.IndexPrevious(ID, iValue'length), InternalArrayType(iValue)) ; 
  end procedure SetPrevious ;

  ------------------------------------------------------------
  impure function FindPrevious (
    ID              : DynamicArrayIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindPrevious") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    while DynamicArrayStore.HasPrevious(ID) loop
      if GetPrevious(ID) = iValue then
        return DynamicArrayStore.GetIndex(ID) ; 
      end if ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function FindPrevious ; 

  ------------------------------------------------------------
  impure function FindPrevious (
    ID              : DynamicArrayIDType ;
    iValue          : ArrayType
  ) return integer is
    constant NUM_VALUES : integer := iValue'length ; 
  begin
    if not DynamicArrayStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindPrevious") ; 
      return INDEX_NOT_FOUND ; 
    end if ; 
    while DynamicArrayStore.HasPrevious(ID, NUM_VALUES) loop
      if GetPrevious(ID, NUM_VALUES) = iValue then
        return DynamicArrayStore.GetIndex(ID) ; 
      end if ; 
    end loop ;
    return INDEX_NOT_FOUND ; 
  end function FindPrevious ; 

  ------------------------------------------------------------
  impure function IsEmpty   (ID : DynamicArrayIDType) return boolean is
  begin
    return DynamicArrayStore.IsEmpty(ID) ;
  end function IsEmpty ;

  ------------------------------------------------------------
  impure function Deallocate(ID : DynamicArrayIDType) return DynamicArrayIDType is
  begin
    return DynamicArrayStore.Deallocate(ID) ;
  end function Deallocate ; 

  ------------------------------------------------------------
  impure function GetSize (ID : DynamicArrayIDType) return integer is
  begin
    return DynamicArrayStore.GetSize(ID) ;
  end function GetSize ;

  ------------------------------------------------------------
  impure function GetCapacity (ID : DynamicArrayIDType) return integer is
  begin
    return DynamicArrayStore.GetCapacity(ID) ;
  end function GetCapacity ;

  ------------------------------------------------------------
  procedure MakeEmpty (ID : DynamicArrayIDType) is
   begin
    DynamicArrayStore.MakeEmpty(ID) ;
  end procedure MakeEmpty ;

end package body DynamicArrayGenericPkg ;