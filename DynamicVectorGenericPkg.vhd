--
--  File Name:         DynamicVectorGenericPkg.vhd
--  Design Unit Name:  DynamicVectorGenericPkg
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

package DynamicVectorGenericPkg is 
  generic (type VectorType is array (type is range <>) of type is private ) ;

  -- Package local definitions
  subtype ElementType is VectorType'element ; 
  subtype IndexType   is VectorType'index ; 
  type InternalVectorType is array (natural range <>) of ElementType ; 
  constant FIRST_INDEX   : natural := 0 ; 
  constant NO_INDEX      : integer := -1 ; 
  constant NO_NATURAL    : integer := -1 ; 

  ------------------------------------------------------------
  -- DynamicVectorIDType
  -- ID Type for Dynamic Arrays
  type DynamicVectorIDType is record
    IdNum     : integer_max ;  -- A unique list
    CopyNum   : integer_max ;  -- A unique iterator
  end record DynamicVectorIDType ; 

  constant EMPTY_DYNAMIC_ARRAY_ID : DynamicVectorIDType := (IdNum => 0, CopyNum => 0) ;

  type DynamicVectorIDArrayType is array (integer range <>) of DynamicVectorIDType ;  
  
  ------------------------------------------------------------
  -- IsInitialized
  -- True if singleton has been constructed
  impure function IsInitialized (ID : DynamicVectorIDType) return boolean ; -- ID Valid

  ------------------------------------------------------------
  -- NewID
  -- Construct a new dynamic array
  impure function NewID (
    Name                : String ;
    Capacity            : natural ; 
    ParentID            : AlertLogIDType          := OSVVM_DYNAMICVECTOR_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := USE_PARENT_ID ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DynamicVectorIDType ;
  
  ------------------------------------------------------------
  -- CopyID
  -- Create a shallow copy of the data structure
  --
  impure function CopyID ( SiblingID : DynamicVectorIDType ) return DynamicVectorIDType ;

  ------------------------------------------------------------
  -- Append
  -- Add element(s) to the end of the list
  procedure Append (
    ID        : DynamicVectorIDType ; 
    iValue    : ElementType
  ) ;

  procedure Append (
    ID        : DynamicVectorIDType ; 
    iValue    : VectorType
  ) ;

  ------------------------------------------------------------
  -- Get
  -- Return the element(s) at the index
  impure function Get  (
    ID        : DynamicVectorIDType ; 
    Index     : natural 
  ) return ElementType ;

  impure function Get  (
    ID        : DynamicVectorIDType ; 
    Index     : natural ;
    NumValues : natural 
  ) return VectorType ;

  ------------------------------------------------------------
  -- Set
  -- Set the element(s) at the index
  procedure Set (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : ElementType 
  ) ;
  
  procedure Set (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : VectorType 
  ) ;
  
  ------------------------------------------------------------
  -- Insert
  -- Insert element(s) to the list at Index
  -- O(n) operation since array is shifted
  procedure Insert (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : ElementType 
  ) ;

  procedure Insert (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : VectorType 
  ) ;

  ------------------------------------------------------------
  -- Prepend
  -- Prepend element(s) to the list at start of list
  -- O(n) operation since array is shifted
  procedure Prepend (
    ID       : DynamicVectorIDType ; 
    iValue   : ElementType 
  ) ;
  
  procedure Prepend (
    ID       : DynamicVectorIDType ; 
    iValue   : VectorType 
  ) ;

  ------------------------------------------------------------
  -- Delete
  --   Remove element(s) from the list at Index
  --   O(n) operation since array is shifted
  procedure Delete (
    ID        : DynamicVectorIDType ; 
    Index     : natural 
  ) ;
  
  procedure Delete (
    ID        : DynamicVectorIDType ; 
    Index     : natural ;
    NumValues : natural 
  ) ;

  ------------------------------------------------------------
  -- Find
  -- Search for value starting at StartingIndex and return index if found otherwise NO_INDEX
  impure function Find (
    ID              : DynamicVectorIDType ;
    StartingIndex   : natural ; 
    iValue          : ElementType
  ) return integer ;

  impure function Find (
    ID              : DynamicVectorIDType ;
    StartingIndex   : natural ; 
    iValue          : VectorType
  ) return integer ;

  ------------------------------------------------------------
  -- Find
  -- Search for value starting at Index 0 and return index if found otherwise NO_INDEX
  impure function Find (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer ; 

  impure function Find (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer ; 

  ------------------------------------------------------------
  -- Match
  -- Return true if value at StartingIndex matches iValue
  impure function Match (
    ID              : DynamicVectorIDType ;
    Index           : natural ; 
    iValue          : ElementType
  ) return boolean ;

  impure function Match (
    ID              : DynamicVectorIDType ;
    Index           : natural ; 
    iValue          : VectorType
  ) return boolean ; 

  ------------------------------------------------------------
  -- Each Iterator / Copy maintains an internal index to the list
  -- The following provide means to manipulate that index
  
  ------------------------------------------------------------
  -- GetIndex
  -- Return the current value of the internal index
  impure function GetIndex      (ID : DynamicVectorIDType) return integer ;

  ------------------------------------------------------------
  -- SetIndex
  -- Set the current value of the internal index
  procedure       SetIndex      (ID : DynamicVectorIDType ; Index : natural := FIRST_INDEX) ;

  ------------------------------------------------------------
  -- GetFirstIndex
  -- Return the first index in the list
  impure function GetFirstIndex (ID : DynamicVectorIDType) return integer ;

  ------------------------------------------------------------
  -- GetLastIndex
  -- Return the last index in the list
  -- With NumValues = 0, LastIndex is a reference to the next empty index
  impure function GetLastIndex  (ID : DynamicVectorIDType; NumValues : natural := 0) return integer ;

  ------------------------------------------------------------
  -- IndexNext
  -- Return the current index and then increment index by NumValues
  impure function IndexNext     (ID : DynamicVectorIDType; NumValues : natural := 1) return integer ;

  ------------------------------------------------------------
  -- HasNext
  -- If the index is incremented by NumValues, will the index be within the list
  impure function HasNext       (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean ;

  ------------------------------------------------------------
  -- IndexPrevious
  -- Decrement index by NumValues and return the index value
  impure function IndexPrevious (ID : DynamicVectorIDType; NumValues : natural := 1) return integer ;

  ------------------------------------------------------------
  -- HasPrevious
  -- If the index is decremented by NumValues, will the index be within the list
  impure function HasPrevious   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean ;

  ------------------------------------------------------------
  -- GetNext
  -- Get value at index and then increment index (index++)
  impure function GetNext (
    ID        : DynamicVectorIDType 
  ) return ElementType ; 

  impure function GetNext (
    ID        : DynamicVectorIDType ;
    NumValues : natural 
  ) return VectorType ; 

  ------------------------------------------------------------
  -- SetNext
  -- Set value at index and then increment index (index++)
  procedure SetNext (
    ID        : DynamicVectorIDType ;
    iValue    : ElementType 
  ) ;

  procedure SetNext (
    ID        : DynamicVectorIDType ;
    iValue    : VectorType 
  ) ;

  ------------------------------------------------------------
  -- FindNext
  -- Search for value starting at iterator index and return index if found otherwise NO_INDEX
  impure function FindNext (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer ;

  impure function FindNext (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer ; 

  ------------------------------------------------------------
  -- GetPrevious
  -- Decrement index by NumValues and then get value at index  (--index)
  impure function GetPrevious (
    ID        : DynamicVectorIDType 
  ) return ElementType ;

  impure function GetPrevious (
    ID        : DynamicVectorIDType ;
    NumValues : natural 
  ) return VectorType ;

  ------------------------------------------------------------
  -- SetPrevious
  -- Decrement index and then set value at index  (--index)
  procedure SetPrevious (
    ID        : DynamicVectorIDType ;
    iValue    : ElementType 
  ) ;

  procedure SetPrevious (
    ID        : DynamicVectorIDType ;
    iValue    : VectorType 
  ) ;

  ------------------------------------------------------------
  -- FindPrevious
  -- Search for value starting at iterator index and return index if found otherwise NO_INDEX
  impure function FindPrevious (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer ;

  impure function FindPrevious (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer ; 

  ------------------------------------------------------------
  -- IsEmpty
  -- Does the list have any elements in it
  impure function IsEmpty       (ID : DynamicVectorIDType) return boolean ;  -- Does ID have storage

  ------------------------------------------------------------
  -- Deallocate
  -- Deallocate the current copy.  
  -- If no copies remain free up the list.
  impure function Deallocate    (ID : DynamicVectorIDType) return DynamicVectorIDType; 

  ------------------------------------------------------------
  -- GetSize
  -- Return the number of elements in the list.  
  impure function GetSize      (ID : DynamicVectorIDType) return integer ;

  ------------------------------------------------------------
  -- GetCapacity
  -- Return the maximum number of elements the list can hold.  
  impure function GetCapacity  (ID : DynamicVectorIDType) return integer ;

  ------------------------------------------------------------
  -- MakeEmpty
  -- Set the size of the list to 0 for all copies of the list
  procedure       MakeEmpty    (ID : DynamicVectorIDType) ;

  ------------------------------------------------------------
  -- GetAlertLogID
  -- Return the AlertLogID that is used internally and set during the call to NewID
  impure function GetAlertLogID (ID : DynamicVectorIDType) return AlertLogIDType ;


end package DynamicVectorGenericPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body DynamicVectorGenericPkg is
  constant ITERATOR_LENGTH_INIT : natural := 3 ; 
  constant ITERATOR_LENGTH_GROW : natural := 3 ;
  constant INITIAL_ARRAY_SIZE   : natural := 16 ;

  ------------------------------------------------------------
  -- Package Local 
  function GetElementTypeDefault return ElementType is
    variable DefaultValue : ElementType;
  begin
    return DefaultValue ;
  end function GetElementTypeDefault;

  ------------------------------------------------------------
  -- Package Local
  procedure FailureIdNotInitialized(ID : DynamicVectorIDType ; Name : string) is
  begin
    if ID.IdNum /= integer'left then 
      Alert("DynamicVector: " & Name & ", invalid ID. IdNum: " & to_string(ID.IdNum) & "  CopyNum: " & to_string(ID.CopyNum), FAILURE) ;
    else
      Alert("DynamicVector: " & Name & ", ID not Initialized. If ID is a signal, be sure to do a ""wait for 0 ns"" after NewID.", FAILURE) ;
    end if ; 
  end procedure FailureIdNotInitialized ; 

  type DynamicVectorPType is protected
    ------------------------------------------------------------
    impure function IsInitialized (ID : DynamicVectorIDType) return boolean ; -- ID Valid

    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      Capacity            : natural ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType  ;  -- These use the ParentAlertID rather than creating their own AlertLogID
      Search              : NameSearchType ;           -- These are always private and cloned to hand off
      PrintParent         : AlertLogPrintParentType 
    ) return DynamicVectorIDType ;

    ------------------------------------------------------------
    impure function CopyID ( SiblingID : DynamicVectorIDType ) return DynamicVectorIDType ;

    ------------------------------------------------------------
    procedure Append (
      ID        : DynamicVectorIDType ; 
      iValue    : ElementType
    ) ;

    procedure Append (
      ID        : DynamicVectorIDType ; 
      iValue    : InternalVectorType
    ) ;

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicVectorIDType ; 
      Index     : natural 
    ) return ElementType ;

    impure function Get  (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      NumValues : natural 
    ) return InternalVectorType ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : ElementType 
    ) ;
    
    procedure Set (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : InternalVectorType 
    ) ;
    
    ------------------------------------------------------------
    procedure Insert (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : ElementType 
    ) ;
    
    procedure Insert (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : InternalVectorType 
    ) ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicVectorIDType ; 
      Index     : natural 
    ) ;
    
    procedure Delete (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      NumValues : natural 
    ) ;
    
    ------------------------------------------------------------
    impure function GetIndex      (ID : DynamicVectorIDType) return integer ;
    procedure       SetIndex      (ID : DynamicVectorIDType ; Index : natural := FIRST_INDEX) ;
    impure function GetFirstIndex (ID : DynamicVectorIDType) return integer ;
    impure function GetLastIndex  (ID : DynamicVectorIDType; NumValues : natural := 0) return integer ;
    impure function IndexNext     (ID : DynamicVectorIDType; NumValues : natural := 1) return integer ;
    impure function HasNext       (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean ;
    impure function IndexPrevious (ID : DynamicVectorIDType; NumValues : natural := 1) return integer ;
    impure function HasPrevious   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean ;

    ------------------------------------------------------------
    impure function IsEmpty       (ID : DynamicVectorIDType) return boolean ;  -- Does ID have storage
    impure function Deallocate    (ID : DynamicVectorIDType) return DynamicVectorIDType ; 

    ------------------------------------------------------------
    impure function GetSize     (ID : DynamicVectorIDType) return integer ;
    impure function GetCapacity (ID : DynamicVectorIDType) return integer ;
    procedure       MakeEmpty   (ID : DynamicVectorIDType) ;

    ------------------------------------------------------------
    impure function GetAlertLogID (ID : DynamicVectorIDType) return AlertLogIDType ;

  end protected DynamicVectorPType ;

  type DynamicVectorPType is protected body

    type IteratorType is record
      HeadIndex   : natural ; 
      InUse       : boolean ; 
    end record IteratorType ; 

    type IteratorArrayType is array (natural range <>) of IteratorType ;
    type IteratorArrayPtrType is access IteratorArrayType ; 

    type ArrayPtrType is access InternalVectorType ; 

    type DynamicVectorRecType is record
      ArrayPtr       : ArrayPtrType ; 
      IteratorPtr    : IteratorArrayPtrType ; 
      TailIndex      : natural ; 
      Capacity       : natural ; 
      MaxCopyNum     : natural ; 
      ActiveClones   : natural ; 
      AlertLogID     : AlertLogIDType ; 
    end record DynamicVectorRecType ; 
    
    type  DynamicVectorRecPtrType is access DynamicVectorRecType ;
    type  SingletonArrayType     is array (natural range <>) of DynamicVectorRecPtrType ; 
    type  SingletonArrayPtrType  is access SingletonArrayType ;

    variable SingletonArrayPtr   : SingletonArrayPtrType ;   
    variable NumItems            : natural := 0 ; 
    variable MaxItems            : natural := 0 ;
    constant MIN_NUM_ITEMS       : natural := 32 ; -- Min amount to resize array

    variable IdFifo : IdFifoPType ; 

    ------------------------------------------------------------
    impure function IsInitialized (ID : DynamicVectorIDType) return boolean is
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
    impure function GetNextIdNumber return natural is
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
      Capacity            : natural ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType  ;  -- These use the ParentAlertID rather than creating their own AlertLogID
      Search              : NameSearchType ;           -- These are always private and cloned to hand off
      PrintParent         : AlertLogPrintParentType 
    ) return DynamicVectorIDType is
      variable ID               : DynamicVectorIDType ; 
      variable ResolvedCapacity : natural ; 
      variable IdNum            : natural ;
    begin
      ResolvedCapacity := Maximum(Capacity, INITIAL_ARRAY_SIZE) ;
      IdNum := GetNextIdNumber ; 
      SingletonArrayPtr(IdNum) := new DynamicVectorRecType ;
      SingletonArrayPtr(IdNum).IteratorPtr := new IteratorArrayType'(1 to ITERATOR_LENGTH_INIT => (FIRST_INDEX, FALSE)) ; 
      SingletonArrayPtr(IdNum).IteratorPtr(1).InUse := TRUE ; 
      SingletonArrayPtr(IdNum).TailIndex    := FIRST_INDEX ; 
      SingletonArrayPtr(IdNum).ActiveClones := 1 ; 
      SingletonArrayPtr(IdNum).MaxCopyNum  := 1 ; 
      SingletonArrayPtr(IdNum).AlertLogID   := NewID(Name, ParentID, ReportMode, PrintParent, CreateHierarchy => FALSE) ; 
      SingletonArrayPtr(IdNum).Capacity     := ResolvedCapacity ; 
      SingletonArrayPtr(IdNum).ArrayPtr     := new InternalVectorType(FIRST_INDEX to FIRST_INDEX - 1 + ResolvedCapacity ) ;
      if Search /= PRIVATE_NAME then  
        Alert(SingletonArrayPtr(IdNum).AlertLogID, "DynamicVector, NewID: Search mode ignored.  " & 
              "Search not currently supported.  " &
              "Please submit use model to GitHub issues site.", WARNING) ;
      end if ; 
      ID.IdNum     := IdNum ; 
      ID.CopyNum   := 1 ; 
      return ID ; 
    end function NewID ;

    ------------------------------------------------------------
    impure function CopyID ( SiblingID : DynamicVectorIDType ) return DynamicVectorIDType is
      variable ID : DynamicVectorIDType ; 
      variable IdNum, vCopyNum : natural ; 
      variable OrigIteratorLength : natural ; 
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
      IdNum       : natural ; 
      NewSize     : natural 
    ) is
      variable OldArrayPtr        : ArrayPtrType ;
      variable OldCapacity, NewCapacity   : natural ;
    begin
      OldCapacity := SingletonArrayPtr(IdNum).Capacity ;
      NewCapacity := OldCapacity ; 
      while NewCapacity < NewSize loop
        NewCapacity := NewCapacity * 2 ; 
      end loop ; 

      OldArrayPtr := SingletonArrayPtr(IdNum).ArrayPtr ; 
      SingletonArrayPtr(IdNum).ArrayPtr := new InternalVectorType(FIRST_INDEX to FIRST_INDEX - 1 + NewCapacity) ;
      SingletonArrayPtr(IdNum).Capacity := NewCapacity ; 
      SingletonArrayPtr(IdNum).ArrayPtr.all(FIRST_INDEX to FIRST_INDEX - 1 + OldCapacity) := OldArrayPtr.all(FIRST_INDEX to FIRST_INDEX - 1 + OldCapacity) ;
      deallocate(OldArrayPtr) ;
    end procedure IncreaseArrayCapacity ;

    ------------------------------------------------------------
    -- PT Local
    procedure SetArrayValue (
      ID             : DynamicVectorIDType ; 
      StartingIndex  : natural ; 
      EndingIndex    : natural ; 
      iValue         : InternalVectorType
    ) is
      alias revValue : InternalVectorType (EndingIndex downto StartingIndex) is iValue ; 
    begin
--      SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) := iValue ; 
      for i in StartingIndex to EndingIndex loop 
        SingletonArrayPtr(ID.IdNum).ArrayPtr(i) := revValue(i) ;
      end loop ; 
    end procedure SetArrayValue ; 

    ------------------------------------------------------------
    -- PT Local
    impure function GetArrayValue (
      ID             : DynamicVectorIDType ; 
      StartingIndex  : natural ; 
      EndingIndex    : natural 
    ) return InternalVectorType is
      variable Result : InternalVectorType(EndingIndex downto StartingIndex) ;
    begin
      for i in StartingIndex to EndingIndex loop 
        Result(i) := SingletonArrayPtr(ID.IdNum).ArrayPtr(i) ;
      end loop ; 
--        return SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex to EndingIndex) ;
      return Result ; 
    end function GetArrayValue ; 

    ------------------------------------------------------------
    procedure Append (
      ID        : DynamicVectorIDType ; 
      iValue    : ElementType
    ) is
      variable EndingIndex, NewSize : natural ;
      variable IdNum : natural ;
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
      ID        : DynamicVectorIDType ; 
      iValue    : InternalVectorType
    ) is
      variable StartingIndex : natural ;
      variable NewSize       : natural ;
      variable EndingIndex   : natural ;
      constant ARRAY_SIZE    : natural := iValue'length ; 
      variable IdNum         : natural ;
    begin
      IdNum := ID.IdNum ; 
      StartingIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      NewSize       := SingletonArrayPtr(IdNum).TailIndex + ARRAY_SIZE ; 
      EndingIndex   := NewSize - 1 ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SetArrayValue(ID, StartingIndex, EndingIndex, iValue) ;
    end procedure Append ;

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicVectorIDType ; 
      Index     : natural 
    ) return ElementType is
      variable StartingIndex, TailIndex : natural ; 
    begin
      StartingIndex := Index ; 
      TailIndex     := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if StartingIndex >= TailIndex then 
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: Get Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(TailIndex-1), FAILURE) ;
        return GetElementTypeDefault ;
      end if ; 
      return SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex) ;  
    end function Get ;

    ------------------------------------------------------------
    impure function Get  (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      NumValues : natural 
    ) return InternalVectorType is
      variable StartingIndex, EndingIndex, TailIndex : natural ;
    begin
      StartingIndex := Index ; 
      EndingIndex   := StartingIndex + NumValues - 1 ; 
      TailIndex     := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if EndingIndex >= TailIndex then 
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: Get Range: " & to_string(Index) & " to " & to_string(EndingIndex) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(TailIndex-1), FAILURE) ;
        return InternalVectorType'(1 to NumValues => GetElementTypeDefault) ; 
      end if ; 
      return GetArrayValue(ID, StartingIndex, EndingIndex) ;
    end function Get ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : ElementType 
    ) is
      variable StartingIndex, TailIndex : natural ; 
    begin
      StartingIndex := Index ; 
      TailIndex     := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if StartingIndex >= TailIndex then 
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: Set Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(TailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      SingletonArrayPtr(ID.IdNum).ArrayPtr(StartingIndex) := iValue ;
    end procedure Set ;

    ------------------------------------------------------------
    procedure Set (
      ID       : DynamicVectorIDType ; 
      Index    : natural ;
      iValue   : InternalVectorType 
    ) is
      variable StartingIndex, EndingIndex, TailIndex : natural ; 
    begin
      StartingIndex := Index ; 
      EndingIndex   := StartingIndex + iValue'length - 1 ; 
      TailIndex     := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if EndingIndex >= TailIndex then 
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: Set Range: " & to_string(Index) & " to " & to_string(EndingIndex) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(TailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      SetArrayValue(ID, StartingIndex, EndingIndex, iValue) ;
    end procedure Set ;

    ------------------------------------------------------------
    procedure Insert (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      iValue    : ElementType
    ) is
      variable OldTailIndex, NewSize : natural ;
      variable IdNum : natural ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      NewSize      := OldTailIndex + 1 ; 
      if Index > OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, 
              "DynamicVector: Insert Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(OldTailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      if Index /= OldTailIndex then
        -- Move the current values over
        SingletonArrayPtr(IdNum).ArrayPtr(Index+1 to OldTailIndex) := 
            SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-1) ;
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SingletonArrayPtr(IdNum).ArrayPtr(Index) := iValue ; 
    end procedure Insert ;

    ------------------------------------------------------------
    procedure Insert (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      iValue    : InternalVectorType
    ) is
      variable OldTailIndex    : natural ;
      variable NewSize         : natural ;
      constant ARRAY_SIZE      : natural := iValue'length ; 
      variable IdNum           : natural ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex  := SingletonArrayPtr(IdNum).TailIndex ;
      NewSize       := SingletonArrayPtr(IdNum).TailIndex + ARRAY_SIZE ; 
      if Index > OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, 
              "DynamicVector: Insert Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(OldTailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      if SingletonArrayPtr(IdNum).Capacity < NewSize then
        IncreaseArrayCapacity(IdNum, NewSize) ; 
      end if ; 
      if Index /= OldTailIndex then
        -- Move the current values over
        SingletonArrayPtr(IdNum).ArrayPtr(Index + ARRAY_SIZE to NewSize - 1) := 
            SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex - 1) ;
      end if ; 
      SingletonArrayPtr(IdNum).TailIndex := NewSize ; 
      SetArrayValue(ID, Index, Index + ARRAY_SIZE - 1, iValue) ;
    end procedure Insert ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicVectorIDType ; 
      Index     : natural 
    ) is
      variable OldTailIndex : natural ;
      variable IdNum : natural ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex := SingletonArrayPtr(IdNum).TailIndex ; 
      if Index >= OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, 
              "DynamicVector: Delete Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(OldTailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      -- Move the current values over
      SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-2) := 
          SingletonArrayPtr(IdNum).ArrayPtr(Index+1 to OldTailIndex-1) ;
      SingletonArrayPtr(IdNum).TailIndex := OldTailIndex-1 ; 
    end procedure Delete ;

    ------------------------------------------------------------
    procedure Delete (
      ID        : DynamicVectorIDType ; 
      Index     : natural ;
      NumValues : natural 
    ) is
      variable OldTailIndex    : natural ;
      variable IdNum           : natural ;
    begin
      IdNum := ID.IdNum ; 
      OldTailIndex  := SingletonArrayPtr(IdNum).TailIndex ;
      if Index >= OldTailIndex then
        Alert(SingletonArrayPtr(IdNum).AlertLogID, 
              "DynamicVector: Delete Index: " & to_string(Index) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(OldTailIndex-1), FAILURE) ;
        return ; 
      end if ; 
      -- Move the current values over
      SingletonArrayPtr(IdNum).ArrayPtr(Index to OldTailIndex-NumValues-1) := 
          SingletonArrayPtr(IdNum).ArrayPtr(Index+NumValues to OldTailIndex-1) ;
      SingletonArrayPtr(IdNum).TailIndex := OldTailIndex-NumValues ; 
    end procedure Delete ;

    ------------------------------------------------------------
    impure function GetIndex (ID : DynamicVectorIDType) return integer is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ; 
    end function GetIndex ; 

    ------------------------------------------------------------
    procedure SetIndex (ID : DynamicVectorIDType ; Index : natural := FIRST_INDEX) is
    begin
      SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := Index ;
    end procedure SetIndex ;

    ------------------------------------------------------------
    impure function GetFirstIndex (ID : DynamicVectorIDType) return integer is
    begin
      return FIRST_INDEX ; 
    end function GetFirstIndex ; 

    ------------------------------------------------------------
    impure function GetLastIndex (ID : DynamicVectorIDType; NumValues : natural := 0) return integer is
    -- With NumValues = 0, LastIndex is a reference to the next empty index
    begin
      return SingletonArrayPtr(ID.IdNum).TailIndex - NumValues ; 
    end function GetLastIndex ; 

    ------------------------------------------------------------
    impure function IndexNext (ID : DynamicVectorIDType; NumValues : natural := 1) return integer is
      variable CurIndex, NextIndex, LastIndex : natural ; 
    begin
      CurIndex := SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ; 
      NextIndex := CurIndex + NumValues ;
      LastIndex := SingletonArrayPtr(ID.IdNum).TailIndex ;
      if NextIndex <= LastIndex then
        SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := NextIndex ; 
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: IndexNext Index: " & to_string(CurIndex) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(LastIndex-1), FAILURE) ;
        return NO_INDEX ;
      end if ; 
      return CurIndex ; 
    end function IndexNext ; 

    ------------------------------------------------------------
    impure function HasNext   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex + NumValues <= SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function HasNext ; 

    ------------------------------------------------------------
    impure function IndexPrevious (ID : DynamicVectorIDType; NumValues : natural := 1) return integer is
      variable PreviousIndex : integer ; 
    begin
      PreviousIndex := SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex - NumValues ; 
      if PreviousIndex >= FIRST_INDEX then
        SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex := PreviousIndex ; 
      else
        Alert(SingletonArrayPtr(ID.IdNum).AlertLogID, 
              "DynamicVector: IndexPrevious Index: " & to_string(PreviousIndex) & 
              " outside of DyanmicArray range: " & to_string(FIRST_INDEX) & 
              " to " & to_string(SingletonArrayPtr(ID.IdNum).TailIndex-1), FAILURE) ;
        return NO_INDEX ;
      end if ; 
      return PreviousIndex ; 
    end function IndexPrevious ; 

    ------------------------------------------------------------
    impure function HasPrevious   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex - NumValues >= FIRST_INDEX ;
    end function HasPrevious ; 
  
    ------------------------------------------------------------
    impure function IsEmpty   (ID : DynamicVectorIDType) return boolean is
    begin
      return SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex >= SingletonArrayPtr(ID.IdNum).TailIndex ;
    end function IsEmpty ; 
  
    ------------------------------------------------------------
    impure function Deallocate(ID : DynamicVectorIDType) return DynamicVectorIDType is
    begin
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
    impure function GetSize (ID : DynamicVectorIDType) return integer is
    begin
      return SingletonArrayPtr(ID.IdNum).TailIndex - 
             SingletonArrayPtr(ID.IdNum).IteratorPtr(ID.CopyNum).HeadIndex ;
    end function GetSize ;

    ------------------------------------------------------------
    impure function GetCapacity (ID : DynamicVectorIDType) return integer is
    begin
      return SingletonArrayPtr(ID.IdNum).Capacity ;
    end function GetCapacity ;

    ------------------------------------------------------------
    procedure MakeEmpty (ID : DynamicVectorIDType) is
    begin
      SingletonArrayPtr(ID.IdNum).TailIndex := FIRST_INDEX ;
      for i in 1 to SingletonArrayPtr(ID.IdNum).IteratorPtr'length loop 
        SingletonArrayPtr(ID.IdNum).IteratorPtr(i).HeadIndex := FIRST_INDEX ;
      end loop ; 
    end procedure MakeEmpty ;

    ------------------------------------------------------------
    impure function GetAlertLogID (ID : DynamicVectorIDType) return AlertLogIDType is 
    begin
      return SingletonArrayPtr(ID.IdNum).AlertLogID ;
    end function GetAlertLogID ;

  end protected body DynamicVectorPType ;
  
  ------------------------------------------------------------
  -- Singleton Data Structure
  ------------------------------------------------------------
  shared variable DynamicVectorStore : DynamicVectorPType ; 
  
  ------------------------------------------------------------
  impure function IsInitialized (ID : DynamicVectorIDType) return boolean is
  begin
    return DynamicVectorStore.IsInitialized(ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    Capacity            : natural ; 
    ParentID            : AlertLogIDType          := OSVVM_DYNAMICVECTOR_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := USE_PARENT_ID ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return DynamicVectorIDType is
  begin
    return DynamicVectorStore.NewID(Name, Capacity, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  impure function CopyID ( SiblingID : DynamicVectorIDType ) return DynamicVectorIDType is
  begin
    if not DynamicVectorStore.IsInitialized(SiblingID) then
      FailureIdNotInitialized(SiblingID, "CopyID") ; 
      return EMPTY_DYNAMIC_ARRAY_ID ;
    end if ; 
    return DynamicVectorStore.CopyID(SiblingID) ;
  end function CopyID ;

  ------------------------------------------------------------
  procedure Append (
    ID        : DynamicVectorIDType ; 
    iValue    : ElementType
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Append") ; 
      return ;
    end if ; 
    DynamicVectorStore.Append(ID, iValue) ;
  end procedure Append ;

  ------------------------------------------------------------
  procedure Append (
    ID        : DynamicVectorIDType ; 
    iValue    : VectorType
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Append") ; 
      return ;
    end if ; 
    DynamicVectorStore.Append(ID, InternalVectorType(iValue)) ;
  end procedure Append ;

  ------------------------------------------------------------
  impure function Get  (
    ID        : DynamicVectorIDType ; 
    Index     : natural 
  ) return ElementType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Get") ; 
      return GetElementTypeDefault ;  
    end if ; 
    return DynamicVectorStore.Get(ID, Index) ;
  end function Get ;

  ------------------------------------------------------------
  impure function Get  (
    ID        : DynamicVectorIDType ; 
    Index     : natural ;
    NumValues : natural 
  ) return VectorType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Get") ; 
      return VectorType(InternalVectorType'(1 to NumValues => GetElementTypeDefault)) ; 
    end if ; 
    return VectorType(DynamicVectorStore.Get(ID, Index, NumValues)) ;
  end function Get ;

  ------------------------------------------------------------
  procedure Set (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : ElementType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Set") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, Index, iValue) ;
  end procedure Set ;
  
  ------------------------------------------------------------
  procedure Set (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : VectorType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Set") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, Index, InternalVectorType(iValue)) ;
  end procedure Set ;
  
  ------------------------------------------------------------
  procedure Insert (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : ElementType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Insert") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Insert(ID, Index, iValue) ;
  end procedure Insert ;
  
  ------------------------------------------------------------
  procedure Insert (
    ID       : DynamicVectorIDType ; 
    Index    : natural ;
    iValue   : VectorType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Insert") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Insert(ID, Index, InternalVectorType(iValue)) ;
  end procedure Insert ;
  
  ------------------------------------------------------------
  procedure Prepend (
    ID       : DynamicVectorIDType ; 
    iValue   : ElementType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Prepend") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Insert(ID, 0, iValue) ;
  end procedure Prepend ;
  
  ------------------------------------------------------------
  procedure Prepend (
    ID       : DynamicVectorIDType ; 
    iValue   : VectorType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Prepend") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Insert(ID, 0, InternalVectorType(iValue)) ;
  end procedure Prepend ;
  
  ------------------------------------------------------------
  procedure Delete (
    ID        : DynamicVectorIDType ; 
    Index     : natural 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Delete") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Delete(ID, Index) ;
  end procedure Delete ;
  
  ------------------------------------------------------------
  procedure Delete (
    ID        : DynamicVectorIDType ; 
    Index     : natural ;
    NumValues : natural 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Delete") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Delete(ID, Index, NumValues) ;
  end procedure Delete ;

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicVectorIDType ;
    StartingIndex   : natural ; 
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Find") ; 
      return NO_INDEX ; 
    end if ; 
    for Index in StartingIndex to DynamicVectorStore.GetLastIndex(ID, 1) loop
      if DynamicVectorStore.Get(ID, Index) = iValue then
        return Index ; 
      end if ; 
    end loop ;
    return NO_INDEX ; 
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicVectorIDType ;
    StartingIndex   : natural ; 
    iValue          : VectorType
  ) return integer is
    constant NUM_VALUES : natural := iValue'length ; 
    variable Index, EndingIndex : integer ; 
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Find") ; 
      return NO_INDEX ; 
    end if ; 
    Index := StartingIndex ; 
    EndingIndex := GetLastIndex(ID, NUM_VALUES) ;
    while Index <= EndingIndex loop 
      if VectorType(DynamicVectorStore.Get(ID, Index, NUM_VALUES)) = iValue then
        return Index ; 
      end if ; 
      Index := Index + NUM_VALUES ; 
    end loop ;
    return NO_INDEX ; 
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    return Find(ID => ID, StartingIndex => 0, iValue => iValue) ;
  end function Find ; 

  ------------------------------------------------------------
  impure function Find (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer is
  begin
    return Find(ID => ID, StartingIndex => 0, iValue => iValue) ;
  end function Find ; 

  ------------------------------------------------------------
  impure function Match (
    ID              : DynamicVectorIDType ;
    Index           : natural ; 
    iValue          : ElementType
  ) return boolean is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Match") ; 
      return FALSE ; 
    end if ; 
    return DynamicVectorStore.Get(ID, Index) = iValue ; 
  end function Match ; 

  ------------------------------------------------------------
  impure function Match (
    ID              : DynamicVectorIDType ;
    Index           : natural ; 
    iValue          : VectorType
  ) return boolean is
    constant NUM_VALUES : natural := iValue'length ; 
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Match") ; 
      return FALSE ; 
    end if ; 
    return VectorType(DynamicVectorStore.Get(ID, Index, NUM_VALUES)) = iValue ; 
  end function Match ; 

  ------------------------------------------------------------
  impure function GetIndex (ID : DynamicVectorIDType) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetIndex") ; 
      return NO_INDEX ; 
    end if ; 
    return DynamicVectorStore.GetIndex(ID) ; 
  end function GetIndex ; 

  ------------------------------------------------------------
  procedure SetIndex (ID : DynamicVectorIDType ; Index : natural := FIRST_INDEX) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetIndex") ; 
      return ; 
    end if ; 
    DynamicVectorStore.SetIndex(ID, Index) ;
  end procedure SetIndex ;

  ------------------------------------------------------------
  impure function GetFirstIndex (ID : DynamicVectorIDType) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetFirstIndex") ; 
      return NO_INDEX ; 
    end if ; 
    return FIRST_INDEX ; 
  end function GetFirstIndex ; 

  ------------------------------------------------------------
  impure function GetLastIndex (ID : DynamicVectorIDType; NumValues : natural := 0) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetLastIndex") ; 
      return NO_INDEX ; 
    end if ; 
    return DynamicVectorStore.GetLastIndex(ID, NumValues) ; 
  end function GetLastIndex ; 

  ------------------------------------------------------------
  impure function IndexNext (ID : DynamicVectorIDType; NumValues : natural := 1) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "IndexNext") ; 
      return NO_INDEX ; 
    end if ; 
    return DynamicVectorStore.IndexNext(ID, NumValues) ; 
  end function IndexNext ; 

  ------------------------------------------------------------
  impure function HasNext   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "HasNext") ; 
      return FALSE ; 
    end if ; 
    return DynamicVectorStore.HasNext(ID, NumValues) ; 
  end function HasNext ; 

  ------------------------------------------------------------
  impure function IndexPrevious (ID : DynamicVectorIDType; NumValues : natural := 1) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "IndexPrevious") ; 
      return NO_INDEX ; 
    end if ; 
    return DynamicVectorStore.IndexPrevious(ID, NumValues) ; 
  end function IndexPrevious ; 

  ------------------------------------------------------------
  impure function HasPrevious   (ID : DynamicVectorIDType; NumValues : natural := 1) return boolean is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "HasPrevious") ; 
      return FALSE ; 
    end if ; 
    return DynamicVectorStore.HasPrevious(ID, NumValues) ; 
  end function HasPrevious ; 

  ------------------------------------------------------------
  impure function GetNext (
    ID        : DynamicVectorIDType 
  ) return ElementType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetNext") ; 
      return GetElementTypeDefault ; 
    end if ; 
    return DynamicVectorStore.Get(ID, DynamicVectorStore.IndexNext(ID, 1)) ; 
  end function GetNext ;

  ------------------------------------------------------------
  impure function GetNext (
    ID        : DynamicVectorIDType ;
    NumValues : natural 
  ) return VectorType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetNext") ; 
      return VectorType(InternalVectorType'(1 to NumValues => GetElementTypeDefault)) ; 
    end if ; 
    return VectorType(DynamicVectorStore.Get(ID => ID, Index => DynamicVectorStore.IndexNext(ID, NumValues), NumValues => NumValues)) ; 
  end function GetNext ;

  ------------------------------------------------------------
  procedure SetNext (
    ID        : DynamicVectorIDType ;
    iValue    : ElementType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetNext") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, DynamicVectorStore.IndexNext(ID, 1), iValue) ; 
  end procedure SetNext ;

  ------------------------------------------------------------
  procedure SetNext (
    ID        : DynamicVectorIDType ;
    iValue    : VectorType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetNext") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, DynamicVectorStore.IndexNext(ID, iValue'length), InternalVectorType(iValue)) ; 
  end procedure SetNext ;

  ------------------------------------------------------------
  impure function FindNext (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindNext") ; 
      return NO_INDEX ; 
    end if ; 
    while DynamicVectorStore.HasNext(ID) loop
      if GetNext(ID) = iValue then
        return DynamicVectorStore.GetIndex(ID)-1 ; 
      end if ; 
    end loop ;
    return NO_INDEX ; 
  end function FindNext ; 

  ------------------------------------------------------------
  impure function FindNext (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer is
    constant NUM_VALUES : natural := iValue'length ; 
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindNext") ; 
      return NO_INDEX ; 
    end if ; 
    while DynamicVectorStore.HasNext(ID, NUM_VALUES) loop
      if GetNext(ID, NUM_VALUES) = iValue then
        return DynamicVectorStore.GetIndex(ID)-NUM_VALUES ; 
      end if ; 
    end loop ;
    return NO_INDEX ; 
  end function FindNext ; 

  ------------------------------------------------------------
  impure function GetPrevious (
    ID        : DynamicVectorIDType 
  ) return ElementType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetPrevious") ; 
      return GetElementTypeDefault ; 
    end if ; 
    return DynamicVectorStore.Get(ID, DynamicVectorStore.IndexPrevious(ID, 1)) ; 
  end function GetPrevious ;

  ------------------------------------------------------------
  impure function GetPrevious (
    ID        : DynamicVectorIDType ;
    NumValues : natural 
  ) return VectorType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetPrevious") ; 
      return VectorType(InternalVectorType'(1 to NumValues => GetElementTypeDefault)) ; 
    end if ; 
    return VectorType(DynamicVectorStore.Get(ID => ID, Index => DynamicVectorStore.IndexPrevious(ID, NumValues), NumValues => NumValues)) ; 
  end function GetPrevious ;

  ------------------------------------------------------------
  procedure SetPrevious (
    ID        : DynamicVectorIDType ;
    iValue    : ElementType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetPrevious") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, DynamicVectorStore.IndexPrevious(ID, 1), iValue) ; 
  end procedure SetPrevious ;

  ------------------------------------------------------------
  procedure SetPrevious (
    ID        : DynamicVectorIDType ;
    iValue    : VectorType 
  ) is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "SetPrevious") ; 
      return ; 
    end if ; 
    DynamicVectorStore.Set(ID, DynamicVectorStore.IndexPrevious(ID, iValue'length), InternalVectorType(iValue)) ; 
  end procedure SetPrevious ;

  ------------------------------------------------------------
  impure function FindPrevious (
    ID              : DynamicVectorIDType ;
    iValue          : ElementType
  ) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindPrevious") ; 
      return NO_INDEX ; 
    end if ; 
    while DynamicVectorStore.HasPrevious(ID) loop
      if GetPrevious(ID) = iValue then
        return DynamicVectorStore.GetIndex(ID) ; 
      end if ; 
    end loop ;
    return NO_INDEX ; 
  end function FindPrevious ; 

  ------------------------------------------------------------
  impure function FindPrevious (
    ID              : DynamicVectorIDType ;
    iValue          : VectorType
  ) return integer is
    constant NUM_VALUES : natural := iValue'length ; 
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "FindPrevious") ; 
      return NO_INDEX ; 
    end if ; 
    while DynamicVectorStore.HasPrevious(ID, NUM_VALUES) loop
      if GetPrevious(ID, NUM_VALUES) = iValue then
        return DynamicVectorStore.GetIndex(ID) ; 
      end if ; 
    end loop ;
    return NO_INDEX ; 
  end function FindPrevious ; 

  ------------------------------------------------------------
  impure function IsEmpty   (ID : DynamicVectorIDType) return boolean is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "IsEmpty") ; 
      return TRUE ; 
    end if ; 
    return DynamicVectorStore.IsEmpty(ID) ;
  end function IsEmpty ;

  ------------------------------------------------------------
  impure function Deallocate(ID : DynamicVectorIDType) return DynamicVectorIDType is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "Deallocate") ; 
      return EMPTY_DYNAMIC_ARRAY_ID ; 
    end if ; 
    return DynamicVectorStore.Deallocate(ID) ;
  end function Deallocate ; 

  ------------------------------------------------------------
  impure function GetSize (ID : DynamicVectorIDType) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetSize") ; 
      return NO_NATURAL ; 
    end if ; 
    return DynamicVectorStore.GetSize(ID) ;
  end function GetSize ;

  ------------------------------------------------------------
  impure function GetCapacity (ID : DynamicVectorIDType) return integer is
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetCapacity") ; 
      return NO_NATURAL ; 
    end if ; 
    return DynamicVectorStore.GetCapacity(ID) ;
  end function GetCapacity ;

  ------------------------------------------------------------
  procedure MakeEmpty (ID : DynamicVectorIDType) is
   begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "MakeEmpty") ; 
      return ; 
    end if ; 
    DynamicVectorStore.MakeEmpty(ID) ;
  end procedure MakeEmpty ;

  ------------------------------------------------------------
  impure function GetAlertLogID (ID : DynamicVectorIDType) return AlertLogIDType is 
  begin
    if not DynamicVectorStore.IsInitialized(ID) then
      FailureIdNotInitialized(ID, "GetAlertLogID") ; 
      return ALERTLOG_ID_UNINITIALZED ; 
    end if ; 
    return DynamicVectorStore.GetAlertLogID(ID) ;
  end function GetAlertLogID ;

end package body DynamicVectorGenericPkg ;