--
--  File Name:         CoveragePkg.vhd
--  Design Unit Name:  CoveragePkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          SynthWorks
--     Matthias Alles     Creonic.    Inspired GetMinBinVal, GetMinPoint, GetCov
--     Jerry Kaczynski    Aldec.      Inspired GetBin function
--     Sebastian Dunst                Inspired GetBinName function
--     ...                Aldec       Worked on VendorCov functional coverage interface
--
--  Package Defines
--      Functional coverage modeling utilities and data structure
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2026   2026.05    Added GetNumIDs and WriteAllBins
--    02/2025   2025.02    Added NewReqID.
--                         FindBinIndex
--                         GetBinAction, GetPointAction
--                         IsBinCount, IsBinIllegal, IsBinIgnore, IsPointCount, IsPointIllegal, IsPointIgnore
--    09/2024   2024.09    Updated reporting for integer'high and integer'low
--    07/2024   2024.07    In Yaml reports, print ones with weight = 0 last
--                         Added IsInitialized
--    03/2024   2024.03    Default values for settings are now constants in OsvvmSettingsPkg. 
--                         Allows setting constants for all tests rather than using SetReportOptions.  
--    05/2023   2023.05    Updated InitSeed call in NewID to ensure a unique seed 
--    01/2023   2023.01    OSVVM_TEMP_OUTPUT_DIRECTORY replaced REPORTS_DIRECTORY 
--    11/2022   2022.11    Updated default search to PRIVATE_NAME
--    06/2022   2022.06    Add AlertIfNotCovered.  Settings for YAML output.
--    02/2022   2022.02    Updated NewID with ParentID, ReportMode, Search, PrintParent.
--                         Supports searching for coverage models.
--    01/2022   2022.01    Added DeallocateBins and TCover
--                         Updated AddBins and AddCross s.t. can set AtLeast and Weight to 0
--                             GenBin defaults AtLeast and Weight to 0.  AddBins and AddCross to 1.
--    12/2021   2021.12    Added ReadCovYaml
--    11/2021   2021.11    Updated WriteCovYaml to write CovWeight first.
--                         Updated GetCov calculation with PercentCov.
--    10/2021   2021.10    Added WriteCovYaml to write out coverage as a YAML file
--    08/2021   2021.08    Removed SetAlertLogID from singleton public interface - set instead by NewID
--                         Moved SetName, SetMessage to deprecated
--                         Moved AddBins, AddCross, GenBin, and GenCross with weight parameter to deprecated
--    07/2021   2021.07    Updated for new data structure
--    07/2020   2020.07    Adjusted NextPointModeType:  Changed MIN to MODE_MINIMUM.
--                         The preferred MINIMUM will not work in some tools
--                         Added GetNext{Index, BinVal, Point}[(Mode => {RANDOM|INCREMENT|MODE_MINIMUM})]
--                         Added NextPointModeType = (RANDOM, INCREMENT, MODE_MINIMUM)
--                         Added SetNextPointMode[(Mode => {RANDOM|INCREMENT|MODE_MINIMUM})
--    05/2020   2020.05    Updated LastIndex to also be set during ICover.
--                         Updated deallocate to set all variables to their initial value
--                         Added GetInc{Index, BinVal, Point}
--                         Added GetNext{Index, BinVal, Point}[(Mode => {RANDOM|INCREMENT|MIN})]
--                         Added NextPointModeType = (RANDOM, INCREMENT, MODE_MINIMUM)
--                         Added SetNextPointMode[(Mode => {RANDOM|INCREMENT|MODE_MINIMUM})
--                         Added to_std_logic(integer), to_boolean(integer) + vector forms
--                         RandCov{Point|BinVal} is deprecated, renamed to GetRand{Point|BinVal}
--    01/2020   2020.01    Updated Licenses to Apache
--    04/2018   2018.04    Updated PercentCov calculation so AtLeast of <= 0 is correct
--                         String' Fix for GHDL
--                         Removed Deprecated procedure Increment - see TbUtilPkg as it moved there
--    05/2017   2017.05    Updated WriteBin name printing
--                         ClearCov (deprecates SetCovZero)
--    11/2016   2016.11    Added CoverageVendorApiPkg and calls to bind it in.
--    03/2016   2016.03    Added GetBinName(Index) to retrieve a bin's name
--    01/2016   2016.01    Fixes for pure functions.  Added bounds checking on ICover
--    06/2015   2015.06    AddCross[CovMatrix?Type], Mirroring for WriteBin
--    01/2015   2015.01    Use AlertLogPkg to count assertions and filter log messages
--    12/2014   2014.07a   Fix memory leak in deallocate. Removed initialied pointers which can lead to leaks.
--    7/2014    2014.07    Bin Naming (for requirements tracking), WriteBin with Pass/Fail, GenBin[integer_vector]
--    1/2014    2014.01    Merging of Cov Models, LastIndex
--    5/2013    2013.05    Release with updated RandomPkg.  Minimal changes.
--    04/2013:  2013.04    Thresholding, CovTarget, Merging off by default,
--    01/2012:  2.4        Added Merging of bins
--    01/2012:  2.3        Added Function GetBin from Jerry K.  Made write for RangeArrayType visible
--    12/2011:  2.2b       Fixed minor inconsistencies on interface declarations.
--    11/2011:  2.2a       Changed constants ALL_RANGE, ZERO_BIN, and ONE_BIN to have a 1 index
--    07/2011:  2.2        Added randomization with coverage goals (AtLeast), weight, and percentage thresholds
--    06/2011:  2.1        Removed signal based coverage modeling
--    04/2011:  2.0        Added protected type based data structure:  CovPType
--    02/2011:  1.1        Added GetMinCov, GetMaxCov, CountCovHoles, GetCovHole
--    02/2011:  1.0        Changed CoverBinType to facilitate long term support of cross coverage
--    09/2010              Release in SynthWorks' VHDL Testbenches and Verification classes
--    06/2010:  0.1        Initial revision
--
--
--  Development Notes:
--      The coverage procedures are named ICover to avoid conflicts with
--      future language changes which may add cover as a keyword
--      Procedure WriteBin writes each CovBin on a separate line, as such
--      it was inappropriate to overload either textio write or to_string
--      In the notes VHDL-2008 notes refers to
--      composites with unconstrained elements
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2010 - 2026 by SynthWorks Design Inc.
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
use work.RandomBasePkg.all ;
use work.RandomProcedurePkg.all ;
use work.RandomPkg.all ;
use work.NamePkg.all ;
use work.NameStorePkg.all ;
use work.MessageListPkg.all ;
use work.OsvvmGlobalPkg.all ;
use work.CoverageVendorApiPkg.all ;
use work.LanguageSupport2019Pkg.all ;

package CoveragePkg is

  type CoverageIDType is record
    ID : integer_max ;
  end record CoverageIDType ;
  
  constant COVERAGE_ID_UNINITIALZED : CoverageIdType := (ID => integer'low) ; 

  type CoverageIDArrayType is array (integer range <>) of CoverageIDType ;

-- Merged the two constants in AlertLogPkg  constant OSVVM_COVERAGE_ALERTLOG_ID : AlertLogIDType := OSVVM_COV_ALERTLOG_ID ;

  -- CovPType allocates bins that are multiples of MIN_NUM_BINS
  constant MIN_NUM_BINS : integer := 2**7 ;  -- power of 2

  type RangeType is record
    min : integer ;
    max : integer ;
  end record ;
  type RangeArrayType is array (integer range <>) of RangeType ;
  constant ALL_RANGE : RangeArrayType := (1=>(integer'low, integer'high)) ;

--!!  procedure write ( file f :  text ;  BinVal : RangeArrayType ) ;
  procedure write ( variable buf : inout line ; constant BinVal : in RangeArrayType) ;

  -- CovBinBaseType.action values.
  -- Note that coverage counting depends on these values
  constant COV_COUNT   : integer := 1 ;
  constant COV_IGNORE  : integer := 0 ;
  constant COV_ILLEGAL : integer := -1 ;

--  -- type OsvvmOptionsType is (OPT_DEFAULT, FALSE, TRUE) ;
--  alias OsvvmOptionsType is work.OsvvmGlobalPkg.OsvvmOptionsType ;
  constant COV_OPT_INIT_PARM_DETECT : OsvvmOptionsType := OPT_INIT_PARM_DETECT ;
--  -- For backward compatibility.  Don't add to other packages.
--  alias DISABLED is work.OsvvmGlobalPkg.DISABLED [return work.OsvvmGlobalPkg.OsvvmOptionsType ];
--  alias ENABLED  is work.OsvvmGlobalPkg.ENABLED  [return work.OsvvmGlobalPkg.OsvvmOptionsType ];

-- Deprecated
  -- Used for easy manual entry.  Order: min, max, action
  -- Intentionally did not use a record to allow other input
  -- formats in the future with VHDL-2008 unconstrained arrays
  -- of unconstrained elements
  --  type CovBinManualType is array (natural range <>) of integer_vector(0 to 2) ;

  type CovBinBaseType is record
    BinVal    : RangeArrayType(1 to 1) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovBinType is array (natural range <>) of CovBinBaseType ;

  constant ALL_BIN     : CovBinType := (0 => ( BinVal => ALL_RANGE,  Action => COV_COUNT,   Count => 0, AtLeast => 1, Weight => 1 )) ;
  constant ALL_COUNT   : CovBinType := (0 => ( BinVal => ALL_RANGE,  Action => COV_COUNT,   Count => 0, AtLeast => 1, Weight => 1 )) ;
  constant ALL_ILLEGAL : CovBinType := (0 => ( BinVal => ALL_RANGE,  Action => COV_ILLEGAL, Count => 0, AtLeast => 0, Weight => 0 )) ;
  constant ALL_IGNORE  : CovBinType := (0 => ( BinVal => ALL_RANGE,  Action => COV_IGNORE,  Count => 0, AtLeast => 0, Weight => 0 )) ;
  constant ZERO_BIN    : CovBinType := (0 => ( BinVal => (1=>(0,0)), Action => COV_COUNT,   Count => 0, AtLeast => 1, Weight => 1 )) ;
  constant ONE_BIN     : CovBinType := (0 => ( BinVal => (1=>(1,1)), Action => COV_COUNT,   Count => 0, AtLeast => 1, Weight => 1 )) ;
  constant NULL_BIN    : CovBinType(work.RandomBasePkg.NULL_RANGE_TYPE) := (others => ( BinVal => ALL_RANGE,  Action => integer'high, Count => 0, AtLeast => integer'high, Weight => integer'high )) ;

  type NextPointModeType is (RANDOM, INCREMENT, MODE_MINIMUM) ;

  type CountModeType   is (COUNT_FIRST, COUNT_ALL) ;
  type IllegalModeType is (ILLEGAL_ON, ILLEGAL_FAILURE, ILLEGAL_OFF) ;
  -- WeightModeType other than AT_LEAST or REMAIN is deprecated
  type WeightModeType  is (AT_LEAST, REMAIN, WEIGHT, REMAIN_EXP, REMAIN_SCALED, REMAIN_WEIGHT ) ;


  -- In VHDL-2008 CovMatrix?BaseType and CovMatrix?Type will be subsumed
  -- by CovBinBaseType and CovBinType with RangeArrayType as an unconstrained array.
  type CovMatrix2BaseType is record
    BinVal    : RangeArrayType(1 to 2) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix2Type is array (natural range <>) of CovMatrix2BaseType ;

  type CovMatrix3BaseType is record
    BinVal    : RangeArrayType(1 to 3) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix3Type is array (natural range <>) of CovMatrix3BaseType ;

  type CovMatrix4BaseType is record
    BinVal    : RangeArrayType(1 to 4) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix4Type is array (natural range <>) of CovMatrix4BaseType ;

  type CovMatrix5BaseType is record
    BinVal    : RangeArrayType(1 to 5) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix5Type is array (natural range <>) of CovMatrix5BaseType ;

  type CovMatrix6BaseType is record
    BinVal    : RangeArrayType(1 to 6) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix6Type is array (natural range <>) of CovMatrix6BaseType ;

  type CovMatrix7BaseType is record
    BinVal    : RangeArrayType(1 to 7) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix7Type is array (natural range <>) of CovMatrix7BaseType ;

  type CovMatrix8BaseType is record
    BinVal    : RangeArrayType(1 to 8) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix8Type is array (natural range <>) of CovMatrix8BaseType ;

  type CovMatrix9BaseType is record
    BinVal    : RangeArrayType(1 to 9) ;
    Action    : integer ;
    Count     : integer ;
    AtLeast   : integer ;
    Weight    : integer ;
  end record ;
  type CovMatrix9Type is array (natural range <>) of CovMatrix9BaseType ;

  ------------------------------------------------------------  VendorCov
  -- VendorCov Conversion for Vendor supported functional coverage modeling
  function ToVendorCovBinVal (BinVal : RangeArrayType) return VendorCovRangeArrayType ;

  ------------------------------------------------------------
  function ToMinPoint (A : RangeArrayType) return integer ;
  function ToMinPoint (A : RangeArrayType) return integer_vector ;
  -- BinVal to Minimum Point

  ------------------------------------------------------------
  procedure ToRandPoint(
  -- BinVal to Random Point
  -- better as a function, however, inout not supported on functions
  ------------------------------------------------------------
    variable RV       : inout RandomPType ;
    constant BinVal   : in    RangeArrayType ;
    variable result   : out   integer
  ) ;

  ------------------------------------------------------------
  procedure ToRandPoint(
  -- BinVal to Random Point
  ------------------------------------------------------------
    variable RV       : inout RandomPType ;
    constant BinVal   : in    RangeArrayType ;
    variable result   : out   integer_vector
  ) ;

  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return CoverageIDType ;

  ------------------------------------------------------------
  impure function NewReqID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return CoverageIDType ;

  ------------------------------------------------------------
  impure function GetNumIDs return integer ;
    
  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Global Settings Common to All Coverage Models
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) ;
  procedure FileCloseWriteBin  ;
--  procedure WriteToCovFile (variable buf : inout line) ;
  procedure PrintToCovFile(S : string) ;

  ------------------------------------------------------------
  procedure SetReportOptions (
  ------------------------------------------------------------
    WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
    PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
    FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
  ) ;
  procedure ResetReportOptions ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Model Settings
  -- /////////////////////////////////////////
  ------------------------------------------------------------
-- AlertLogID set by NewID
--  procedure       SetAlertLogID (ID : CoverageIDType; A : AlertLogIDType) ;
--  procedure       SetAlertLogID (ID : CoverageIDType; Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) ;
  impure function GetAlertLogID (ID : CoverageIDType) return AlertLogIDType ;

  ------------------------------------------------------------
-- Name set by NewID
  impure function GetName         (ID : CoverageIDType) return String ;
  impure function GetCovModelName (ID : CoverageIDType) return String ;
  impure function GetNamePlus     (ID : CoverageIDType; prefix, suffix : string) return String ;
  procedure SetItemBinNames (
    ID         : CoverageIDType ;
    Name1      : String ;
            Name2,  Name3,  Name4,  Name5,
    Name6,  Name7,  Name8,  Name9,  Name10,
    Name11, Name12, Name13, Name14, Name15,
    Name16, Name17, Name18, Name19, Name20 : string := ""
  ) ;
  alias SetFieldName is SetItemBinNames [CoverageIDType,
    string, string, string, string, string, string, string, string, string, string,
    string, string, string, string, string, string, string, string, string, string] ;

  procedure       SetCovTarget       (ID : CoverageIDType; Percent : real) ;
  impure function GetCovTarget       (ID : CoverageIDType) return real ;
  procedure       SetThresholding    (ID : CoverageIDType; A : boolean := TRUE ) ;
  procedure       SetCovThreshold    (ID : CoverageIDType; Percent : real) ;
  procedure       SetMerging         (ID : CoverageIDType; A : boolean := TRUE ) ;
  procedure       SetCountMode       (ID : CoverageIDType; A : CountModeType) ;
  procedure       SetIllegalMode     (ID : CoverageIDType; A : IllegalModeType) ;
  procedure       SetNextPointMode   (ID : CoverageIDType; A : NextPointModeType) ;
  --
  -- SetWeightMode with a WeightMode other than AT_LEAST or REMAIN is deprecated
  -- SetWeightMode with a WeightScale parameter is deprecated
  procedure       SetWeightMode      (ID : CoverageIDType; WeightMode : WeightModeType;  WeightScale : real := 1.0) ;
  procedure       SetCovWeight       (ID : CoverageIDType; Weight : integer) ;
  impure function GetCovWeight       (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  -- Seeds are initialized by NewID.
  procedure       InitSeed      (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) ;
  impure function InitSeed      (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) return string ;
  procedure       InitSeed      (ID : CoverageIDType; I : integer; UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) ;

  ------------------------------------------------------------
  procedure       SetSeed (ID : CoverageIDType; RandomSeedIn : RandomSeedType ) ;
  impure function GetSeed (ID : CoverageIDType) return RandomSeedType ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Item / Cross Bin Creation and Destruction
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure SetBinSize (ID : CoverageIDType; NewNumBins : integer) ;
  procedure Deallocate (ID : CoverageIDType) ;
  procedure DeallocateBins (CoverID : CoverageIDType) ;
  alias     DeleteBins is DeallocateBins[CoverageIdType] ;
  
  ------------------------------------------------------------
  procedure AddBins (
  ------------------------------------------------------------
    ID      : CoverageIDType ;
    Name    : String ;
    AtLeast : integer ;
    CovBin  : CovBinType
  ) ;
  procedure AddBins (ID : CoverageIDType; Name : String ;  CovBin : CovBinType) ;
  procedure AddBins (ID : CoverageIDType; AtLeast : integer ; CovBin : CovBinType ) ;
  procedure AddBins (ID : CoverageIDType; CovBin : CovBinType  ) ;


  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    AtLeast    : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    AtLeast    : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  -- AddCross for usage with constants created by GenCross
  ------------------------------------------------------------
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix2Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix3Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix4Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix5Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix6Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix7Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix8Type ; Name : String := "") ;
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix9Type ; Name : String := "") ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Recording and Clearing Coverage
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  ------------------------------------------------------------
  procedure ICoverLast (ID : CoverageIDType) ;
  procedure ICover     (ID : CoverageIDType; CovPoint : integer_vector) ;
  procedure ICover     (ID : CoverageIDType; CovPoint : integer) ;
  procedure TCover     (ID : CoverageIDType; A : integer) ;
  impure function FindBinIndex (ID : CoverageIDType; CovPoint : integer_vector; StartingIndex : integer := 1) return integer ;
  impure function FindBinIndex (ID : CoverageIDType; CovPoint : integer; StartingIndex : integer := 1) return integer ;

  procedure ClearCov (ID : CoverageIDType) ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Information and Statistics
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  ------------------------------------------------------------
  impure function IsBinCovered (ID : CoverageIDType ; BinIndex : integer ; PercentCov : real ) return boolean ;
  impure function IsBinCovered (ID : CoverageIDType ; BinIndex : integer ) return boolean ;
  impure function IsCovered    (ID : CoverageIDType ; PercentCov : real ) return boolean ;
  impure function IsCovered    (ID : CoverageIDType) return boolean ;
  impure function AllCovered   (PercentCov : real )  return boolean ;
  impure function AllCovered                         return boolean ;
  impure function IsNotCovered (ID : CoverageIDType ; PercentCov : real ) return boolean ;
  impure function IsNotCovered (ID : CoverageIDType) return boolean ;

  impure function IsInitialized (ID : CoverageIDType) return boolean ;
  
  ------------------------------------------------------------
  impure function IsBinCount  (ID : CoverageIDType; BinIndex : integer) return boolean ;
  impure function IsBinIllegal(ID : CoverageIDType; BinIndex : integer) return boolean ;
  impure function IsBinIgnore (ID : CoverageIDType; BinIndex : integer) return boolean ;
  
  ------------------------------------------------------------
  impure function IsPointCount  (ID : CoverageIDType; CovPoint : integer_vector) return boolean ;
  impure function IsPointCount  (ID : CoverageIDType; CovPoint : integer) return boolean ;
  impure function IsPointIllegal(ID : CoverageIDType; CovPoint : integer_vector) return boolean ;
  impure function IsPointIllegal(ID : CoverageIDType; CovPoint : integer) return boolean ;
  impure function IsPointIgnore (ID : CoverageIDType; CovPoint : integer_vector) return boolean ;
  impure function IsPointIgnore (ID : CoverageIDType; CovPoint : integer) return boolean ;
  
  ------------------------------------------------------------
  impure function GetItemCount    (ID : CoverageIDType) return integer ;
  impure function GetCov          (ID : CoverageIDType; PercentCov : real ) return real ;
  impure function GetCov          (ID : CoverageIDType) return real ;
  impure function GetTotalCovCount(ID : CoverageIDType; PercentCov : real ) return integer ;
  impure function GetTotalCovCount(ID : CoverageIDType) return integer ;
  impure function GetTotalCovGoal (ID : CoverageIDType; PercentCov : real ) return integer ;
  impure function GetTotalCovGoal (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  impure function GetMinCov   (ID : CoverageIDType) return real ;
  impure function GetMinCount (ID : CoverageIDType) return integer ;
  impure function GetMaxCov   (ID : CoverageIDType) return real ;
  impure function GetMaxCount (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  impure function CountCovHoles (ID : CoverageIDType; PercentCov : real ) return integer ;
  impure function CountCovHoles (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Generating Coverage Points, BinValues, and Indices
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- Return Points
  ------------------------------------------------------------
  -- to be replaced in VHDL-2019 by version that uses RandomSeed as an inout
  impure function ToRandPoint   (ID : CoverageIDType; BinVal : RangeArrayType ) return integer ;
  impure function ToRandPoint   (ID : CoverageIDType; BinVal : RangeArrayType ) return integer_vector ;

  ------------------------------------------------------------
  -- Return Points
  impure function GetPoint     (ID : CoverageIDType; BinIndex : integer ) return integer ;
  impure function GetPoint     (ID : CoverageIDType; BinIndex : integer ) return integer_vector ;
  impure function GetRandPoint (ID : CoverageIDType) return integer ;
  impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer ;
  impure function GetRandPoint (ID : CoverageIDType) return integer_vector ;
  impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector ;
  impure function GetIncPoint  (ID : CoverageIDType) return integer ;
  impure function GetIncPoint  (ID : CoverageIDType) return integer_vector ;
  impure function GetMinPoint  (ID : CoverageIDType) return integer ;
  impure function GetMinPoint  (ID : CoverageIDType) return integer_vector ;
  impure function GetMaxPoint  (ID : CoverageIDType) return integer ;
  impure function GetMaxPoint  (ID : CoverageIDType) return integer_vector ;
  impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer ;
  impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer_vector ;
  impure function GetNextPoint (ID : CoverageIDType) return integer ;
  impure function GetNextPoint (ID : CoverageIDType) return integer_vector ;

  ------------------------------------------------------------
  -- deprecated, see GetRandPoint
  impure function RandCovPoint (ID : CoverageIDType) return integer ;
  impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer ;
  impure function RandCovPoint (ID : CoverageIDType) return integer_vector ;
  impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector ;

  ------------------------------------------------------------
  -- Return BinVals
  impure function GetBinVal     (ID : CoverageIDType; BinIndex : integer ) return RangeArrayType ;
  impure function GetRandBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType ;
  impure function GetRandBinVal (ID : CoverageIDType) return RangeArrayType ;
  impure function GetLastBinVal (ID : CoverageIDType) return RangeArrayType ;
  impure function GetIncBinVal  (ID : CoverageIDType) return RangeArrayType ;
  impure function GetMinBinVal  (ID : CoverageIDType) return RangeArrayType ;
  impure function GetMaxBinVal  (ID : CoverageIDType) return RangeArrayType ;
  impure function GetNextBinVal (ID : CoverageIDType; Mode : NextPointModeType) return RangeArrayType ;
  impure function GetNextBinVal (ID : CoverageIDType) return RangeArrayType ;
  impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType ;
  impure function GetHoleBinVal (ID : CoverageIDType; PercentCov : real  ) return RangeArrayType ;
  impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer := 1 ) return RangeArrayType ;

  -- deprecated RandCovBinVal, see GetRandBinVal
  impure function RandCovBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType ;
  impure function RandCovBinVal (ID : CoverageIDType) return RangeArrayType ;

  -- Return Index Values
  ------------------------------------------------------------
  impure function GetNumBins   (ID : CoverageIDType) return integer ;
  impure function GetRandIndex (ID : CoverageIDType; CovTargetPercent : real ) return integer ;
  impure function GetRandIndex (ID : CoverageIDType) return integer ;
  impure function GetLastIndex (ID : CoverageIDType) return integer ;
  impure function GetIncIndex  (ID : CoverageIDType) return integer ;
  impure function GetMinIndex  (ID : CoverageIDType) return integer ;
  impure function GetMaxIndex  (ID : CoverageIDType) return integer ;
  impure function GetNextIndex (ID : CoverageIDType; Mode : NextPointModeType) return integer ;
  impure function GetNextIndex (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Accessing Coverage Bin Information
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- ------------------------------------------------------------
  -- Get all bin information except the BinVal (since it is sized)
  impure function GetBinInfo (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType ;

  -- ------------------------------------------------------------
  -- Get Pieces of Bin Information
  impure function GetBinValLength (ID : CoverageIDType) return integer ;  -- Length of BinVal
  impure function GetBinAction    (ID : CoverageIDType; BinIndex : integer) return integer ;
  impure function GetBinName      (ID : CoverageIDType; BinIndex : integer; DefaultName : string := "" ) return string ;
  procedure SetBinName            (ID : CoverageIDType; BinIndex : integer; Name : string) ;
  
  impure function GetPointAction  (ID : CoverageIDType; CovPoint : integer_vector) return integer ;
  impure function GetPointAction  (ID : CoverageIDType; CovPoint : integer) return integer ;

  -- ------------------------------------------------------------
  -- Eventually the multiple GetBin functions will be replaced by a
  -- a single GetBin that returns CovBinBaseType with BinVal as an
  -- unconstrained element
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix2BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix3BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix4BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix5BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix6BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix7BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix8BaseType ;
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix9BaseType ;

  ------------------------------------------------------------
  impure function GetErrorCount (ID : CoverageIDType) return integer ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Printing Coverage Bin Information
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- To specify the following, see SetReportOptions
  --   WritePassFail, WriteBinInfo, WriteCount, WriteAnyIllegal
  --   WritePrefix, PassName, FailName
  ------------------------------------------------------------
  procedure WriteBin (ID : CoverageIDType) ;
  procedure WriteBin (ID : CoverageIDType; LogLevel : LogType ) ;  -- With LogLevel
  procedure WriteBin (ID : CoverageIDType; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE) ;
  procedure WriteBin (ID : CoverageIDType; LogLevel : LogType; FileName : string; OpenKind : File_Open_Kind := APPEND_MODE) ;
  procedure WriteAllBins (FileName : string := "" ; OpenKind : File_Open_Kind := WRITE_MODE) ;

  ------------------------------------------------------------
  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType := ALWAYS ) ;
  procedure WriteCovHoles (ID : CoverageIDType; PercentCov : real ) ;
  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  PercentCov : real ) ;
  procedure WriteCovHoles (ID : CoverageIDType; FileName : string;   OpenKind : File_Open_Kind := APPEND_MODE ) ;
  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
  procedure WriteCovHoles (ID : CoverageIDType; FileName : string;   PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;
  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Writing Out RAW Coverage Bin Information
  --  Note that read supports merging of coverage models
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure ReadCovDb  (ID : CoverageIDType; FileName : string; Merge : boolean := FALSE) ;
  procedure WriteCovDb (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;
  --     procedure WriteCovDb (ID : CoverageIDType) ;
  procedure ReadCovYaml (variable ID : inout CoverageIDType; FileName : string := ""; Merge : boolean := FALSE) ;
  procedure WriteCovYaml (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Operations across all coverage models
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure WriteCovYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) ;
  procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) ;
  impure function GotCoverage return boolean ;
  procedure RecordCovRequirements ;
  impure function GetCov (PercentCov : real ) return real ;
  impure function GetCov return real ;
  procedure AffirmIfCovered ; 
  procedure AlertIfNotCovered (Level : AlertType := ERROR) ; 

  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    constant Bin1       : in    CoverageIDType ;
    constant Bin2       : in    CoverageIDType ;
    variable Valid      : out   Boolean
  ) ;

  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    constant Bin1       : in    CoverageIDType ;
    constant Bin2       : in    CoverageIDType
  ) ;

  --
  --  Support for AddBins and AddCross
  --
  ------------------------------------------------------------
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Min, Max      : integer ;
    NumBin        : integer
  ) return CovBinType ;

  -- Each item in range in a separate CovBin
  function GenBin(Min, Max, NumBin : integer ) return CovBinType ;
  function GenBin(Min, Max : integer) return CovBinType ;
  function GenBin(A : integer) return CovBinType ;

  ------------------------------------------------------------
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    A             : integer_vector
  ) return CovBinType ;

  function GenBin ( A : integer_vector ) return CovBinType ;

  ------------------------------------------------------------
  function IllegalBin ( Min, Max, NumBin : integer ) return CovBinType ;
  ------------------------------------------------------------

  -- All items in range in a single CovBin
  function IllegalBin ( Min, Max : integer ) return CovBinType ;
  function IllegalBin ( A : integer ) return CovBinType ;


-- IgnoreBin should never have an AtLeast parameter
  ------------------------------------------------------------
  function IgnoreBin (Min, Max, NumBin : integer) return CovBinType ;
  ------------------------------------------------------------
  function IgnoreBin (Min, Max : integer) return CovBinType ;  -- All items in range in a single CovBin
  function IgnoreBin (A : integer) return CovBinType ;


  -- With VHDL-2008, there will be one GenCross that returns CovBinType
  -- and has inputs initialized to NULL_BIN - see AddCross
  ------------------------------------------------------------
  function GenCross(  -- 2
  -- Cross existing bins
  -- Use AddCross for adding values directly to coverage database
  -- Use GenCross for constants
  ------------------------------------------------------------
    AtLeast     : integer ;
    Bin1, Bin2  : CovBinType
  ) return CovMatrix2Type ;

  function GenCross(Bin1, Bin2 : CovBinType) return CovMatrix2Type ;

  ------------------------------------------------------------
  function GenCross(  -- 3
  ------------------------------------------------------------
    AtLeast           : integer ;
    Bin1, Bin2, Bin3  : CovBinType
  ) return CovMatrix3Type ;

  function GenCross( Bin1, Bin2, Bin3 : CovBinType ) return CovMatrix3Type ;

  ------------------------------------------------------------
  function GenCross(  -- 4
  ------------------------------------------------------------
    AtLeast                 : integer ;
    Bin1, Bin2, Bin3, Bin4  : CovBinType
  ) return CovMatrix4Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4 : CovBinType ) return CovMatrix4Type ;

  ------------------------------------------------------------
  function GenCross(  -- 5
  ------------------------------------------------------------
    AtLeast                       : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5  : CovBinType
  ) return CovMatrix5Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5 : CovBinType ) return CovMatrix5Type ;

  ------------------------------------------------------------
  function GenCross(  -- 6
  ------------------------------------------------------------
    AtLeast                             : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6  : CovBinType
  ) return CovMatrix6Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6 : CovBinType ) return CovMatrix6Type ;

  ------------------------------------------------------------
  function GenCross(  -- 7
  ------------------------------------------------------------
    AtLeast                                   : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7  : CovBinType
  ) return CovMatrix7Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7 : CovBinType ) return CovMatrix7Type ;

  ------------------------------------------------------------
  function GenCross(  -- 8
  ------------------------------------------------------------
    AtLeast                                         : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8  : CovBinType
  ) return CovMatrix8Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8 : CovBinType ) return CovMatrix8Type ;

  ------------------------------------------------------------
  function GenCross(  -- 9
  ------------------------------------------------------------
    AtLeast                                               : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9  : CovBinType
  ) return CovMatrix9Type ;

  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9 : CovBinType ) return CovMatrix9Type ;

  ------------------------------------------------------------
  -- Utilities.  Remove if added to std.standard
  function to_integer   ( B : boolean    ) return integer ;
  function to_boolean   ( I : integer    ) return boolean ;
  function to_integer   ( SL : std_logic ) return integer ;
  function to_std_logic ( I : integer    ) return std_logic ;
  function to_integer_vector   ( BV : boolean_vector    ) return integer_vector ;
  function to_boolean_vector   ( IV : integer_vector    ) return boolean_vector ;
  function to_integer_vector   ( SLV : std_logic_vector ) return integer_vector ;
  function to_std_logic_vector ( IV : integer_vector    ) return std_logic_vector ;
  alias to_slv is to_std_logic_vector[integer_vector return std_logic_vector] ;


  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------
  type CovPType is protected
    ------------------------------------------------------------
    impure function NewID (
      Name                : String ;
      Goal                : real ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType ;
      Search              : NameSearchType ;
      PrintParent         : AlertLogPrintParentType
    ) return CoverageIDType ;

    impure function GetNumIDs return integer ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Coverage Global Settings Common to All Coverage Models
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) ;
    procedure FileCloseWriteBin  ;
--    procedure WriteToCovFile (variable buf : inout line) ;
    procedure PrintToCovFile(S : string) ;

    ------------------------------------------------------------
    procedure SetReportOptions (
    ------------------------------------------------------------
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) ;
    procedure ResetReportOptions ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Coverage Model Settings
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure       SetName         (ID : CoverageIDType; Name : String) ;
    impure function SetName         (ID : CoverageIDType; Name : String) return string ;
    procedure       DeallocateName  (ID : CoverageIDType) ;
    impure function GetName         (ID : CoverageIDType) return String ;
    impure function GetCovModelName (ID : CoverageIDType) return String ;
    impure function GetNamePlus     (ID : CoverageIDType; prefix, suffix : string) return String ;
    procedure SetItemBinNames (
      ID         : CoverageIDType ;
      Name1      : String ;
              Name2,  Name3,  Name4,  Name5,
      Name6,  Name7,  Name8,  Name9,  Name10,
      Name11, Name12, Name13, Name14, Name15,
      Name16, Name17, Name18, Name19, Name20 : string := ""
    ) ;

    ------------------------------------------------------------
    procedure       SetMessage         (ID : CoverageIDType; Message : String) ;
    procedure       DeallocateMessage  (ID : CoverageIDType) ;

    procedure       SetCovTarget       (ID : CoverageIDType; Percent : real) ;
    impure function GetCovTarget       (ID : CoverageIDType) return real ;
    procedure       SetThresholding    (ID : CoverageIDType; A : boolean := TRUE ) ;
    procedure       SetCovThreshold    (ID : CoverageIDType; Percent : real) ;
    procedure       SetMerging         (ID : CoverageIDType; A : boolean := TRUE ) ;
    procedure       SetCountMode       (ID : CoverageIDType; A : CountModeType) ;
    procedure       SetIllegalMode     (ID : CoverageIDType; A : IllegalModeType) ;
    procedure       SetWeightMode      (ID : CoverageIDType; WeightMode : WeightModeType;  WeightScale : real := 1.0) ;
    procedure       SetNextPointMode   (ID : CoverageIDType; A : NextPointModeType) ;
    procedure       SetCovWeight       (ID : CoverageIDType; Weight : integer) ;
    impure function GetCovWeight       (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    procedure       SetAlertLogID (ID : CoverageIDType; A : AlertLogIDType) ;
    procedure       SetAlertLogID (ID : CoverageIDType; Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) ;
    impure function GetAlertLogID (ID : CoverageIDType) return AlertLogIDType ;

    ------------------------------------------------------------
    procedure       InitSeed      (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) ;
    impure function InitSeed      (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) return string ;
    procedure       InitSeed      (ID : CoverageIDType; I : integer; UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) ;

    ------------------------------------------------------------
    procedure       SetSeed (ID : CoverageIDType; RandomSeedIn : RandomSeedType ) ;
    impure function GetSeed (ID : CoverageIDType) return RandomSeedType ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Item / Cross Bin Creation and Destruction
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure SetBinSize (ID : CoverageIDType; NewNumBins : integer) ;
    procedure Deallocate (ID : CoverageIDType) ;
    procedure DeallocateBins (CoverID : CoverageIDType) ;

    ------------------------------------------------------------
    -- Weight Deprecated
    procedure AddBins (
    ------------------------------------------------------------
      ID      : CoverageIDType ;
      Name    : String ;
      AtLeast : integer ;
      Weight  : integer ;
      CovBin  : CovBinType
    ) ;
    procedure AddBins (ID : CoverageIDType; Name : String ; AtLeast : integer ; CovBin : CovBinType ) ;
    procedure AddBins (ID : CoverageIDType; Name : String ;  CovBin : CovBinType) ;
    procedure AddBins (ID : CoverageIDType; AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) ;     -- Weight Deprecated
    procedure AddBins (ID : CoverageIDType; AtLeast : integer ; CovBin : CovBinType ) ;
    procedure AddBins (ID : CoverageIDType; CovBin : CovBinType  ) ;

    ------------------------------------------------------------
    -- Weight Deprecated
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    -- Weight Deprecated
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    -- AddCross for usage with constants created by GenCross
    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix2Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix3Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix4Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix5Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix6Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix7Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix8Type ; Name : String := "") ;
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix9Type ; Name : String := "") ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Recording and Clearing Coverage
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure ICoverLast (ID : CoverageIDType) ;
    procedure ICover     (ID : CoverageIDType; CovPoint : integer_vector) ;
    procedure ICover     (ID : CoverageIDType; CovPoint : integer) ;
    procedure TCover     (ID : CoverageIDType; A : integer) ;
    impure function FindBinIndex(ID : CoverageIDType; CovPoint : integer_vector; StartingIndex : integer := 1) return integer ;

    procedure ClearCov (ID : CoverageIDType) ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Coverage Information and Statistics
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    ------------------------------------------------------------
    impure function IsBinCovered (ID : CoverageIDType ; BinIndex : integer ; PercentCov : real ) return boolean ;
    impure function IsBinCovered (ID : CoverageIDType ; BinIndex : integer ) return boolean ;
    impure function IsCovered    (ID : CoverageIDType ; PercentCov : real ) return boolean ;
    impure function IsCovered    (ID : CoverageIDType) return boolean ;
    impure function AllCovered (PercentCov : real ) return boolean ;
    impure function AllCovered return boolean ;

    impure function IsInitialized (ID : CoverageIDType) return boolean ;

    ------------------------------------------------------------
    impure function GetItemCount    (ID : CoverageIDType) return integer ;
    procedure GetTotalCovCountAndGoal     (ID : CoverageIDType; PercentCov : real; TotalCovCount : out integer; TotalCovGoal : out integer ) ;
    procedure GetTotalCovCountAndGoal     (ID : CoverageIDType; TotalCovCount : out integer; TotalCovGoal : out integer ) ;
    impure function GetCov          (ID : CoverageIDType; PercentCov : real ) return real ;
    impure function GetCov          (ID : CoverageIDType) return real ;
    impure function GetTotalCovCount(ID : CoverageIDType; PercentCov : real ) return integer ;
    impure function GetTotalCovCount(ID : CoverageIDType) return integer ;
    impure function GetTotalCovGoal (ID : CoverageIDType; PercentCov : real ) return integer ;
    impure function GetTotalCovGoal (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    impure function GetMinCov   (ID : CoverageIDType) return real ;
    impure function GetMinCount (ID : CoverageIDType) return integer ;
    impure function GetMaxCov   (ID : CoverageIDType) return real ;
    impure function GetMaxCount (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    impure function CountCovHoles (ID : CoverageIDType; PercentCov : real ) return integer ;
    impure function CountCovHoles (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Generating Coverage Points, BinValues, and Indices
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    -- Return Points
    ------------------------------------------------------------
    -- to be replaced in VHDL-2019 by version that uses RandomSeed as an inout
    impure function ToRandPoint   (ID : CoverageIDType; BinVal : RangeArrayType ) return integer ;
    impure function ToRandPoint   (ID : CoverageIDType; BinVal : RangeArrayType ) return integer_vector ;

    ------------------------------------------------------------
    -- Return Points
    impure function GetPoint     (ID : CoverageIDType; BinIndex : integer ) return integer ;
    impure function GetPoint     (ID : CoverageIDType; BinIndex : integer ) return integer_vector ;
    impure function GetRandPoint (ID : CoverageIDType) return integer ;
    impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer ;
    impure function GetRandPoint (ID : CoverageIDType) return integer_vector ;
    impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector ;
    impure function GetIncPoint  (ID : CoverageIDType) return integer ;
    impure function GetIncPoint  (ID : CoverageIDType) return integer_vector ;
    impure function GetMinPoint  (ID : CoverageIDType) return integer ;
    impure function GetMinPoint  (ID : CoverageIDType) return integer_vector ;
    impure function GetMaxPoint  (ID : CoverageIDType) return integer ;
    impure function GetMaxPoint  (ID : CoverageIDType) return integer_vector ;
    impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer ;
    impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer_vector ;
    impure function GetNextPoint (ID : CoverageIDType) return integer ;
    impure function GetNextPoint (ID : CoverageIDType) return integer_vector ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint (ID : CoverageIDType) return integer ;
    impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer ;
    impure function RandCovPoint (ID : CoverageIDType) return integer_vector ;
    impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector ;

    ------------------------------------------------------------
    -- Return BinVals
    impure function GetBinVal     (ID : CoverageIDType; BinIndex : integer ) return RangeArrayType ;
    impure function GetRandBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType ;
    impure function GetRandBinVal (ID : CoverageIDType) return RangeArrayType ;
    impure function GetLastBinVal (ID : CoverageIDType) return RangeArrayType ;
    impure function GetIncBinVal  (ID : CoverageIDType) return RangeArrayType ;
    impure function GetMinBinVal  (ID : CoverageIDType) return RangeArrayType ;
    impure function GetMaxBinVal  (ID : CoverageIDType) return RangeArrayType ;
    impure function GetNextBinVal (ID : CoverageIDType; Mode : NextPointModeType) return RangeArrayType ;
    impure function GetNextBinVal (ID : CoverageIDType) return RangeArrayType ;
    impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType ;
    impure function GetHoleBinVal (ID : CoverageIDType; PercentCov : real  ) return RangeArrayType ;
    impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer := 1 ) return RangeArrayType ;

    -- deprecated RandCovBinVal, see GetRandBinVal
    impure function RandCovBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType ;
    impure function RandCovBinVal (ID : CoverageIDType) return RangeArrayType ;

    -- Return Index Values
    ------------------------------------------------------------
    impure function GetNumBins   (ID : CoverageIDType) return integer ;
    impure function GetRandIndex (ID : CoverageIDType; CovTargetPercent : real ) return integer ;
    impure function GetRandIndex (ID : CoverageIDType) return integer ;
    impure function GetLastIndex (ID : CoverageIDType) return integer ;
    impure function GetIncIndex  (ID : CoverageIDType) return integer ;
    impure function GetMinIndex  (ID : CoverageIDType) return integer ;
    impure function GetMaxIndex  (ID : CoverageIDType) return integer ;
    impure function GetNextIndex (ID : CoverageIDType; Mode : NextPointModeType) return integer ;
    impure function GetNextIndex (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Accessing Coverage Bin Information
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    -- ------------------------------------------------------------
    -- Get all bin information except the BinVal (since it is sized)
    impure function GetBinInfo (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType ;

    -- ------------------------------------------------------------
    -- Get Pieces of Bin Information
    impure function GetBinValLength (ID : CoverageIDType) return integer ;  -- Length of BinVal
    impure function GetBinAction    (ID : CoverageIDType; BinIndex : integer) return integer ;
    impure function GetBinName      (ID : CoverageIDType; BinIndex : integer; DefaultName : string := "" ) return string ;
    procedure SetBinName            (ID : CoverageIDType; BinIndex : integer; Name : string) ;

    impure function GetPointAction  (ID : CoverageIDType; CovPoint : integer_vector) return integer ;

    -- ------------------------------------------------------------
    -- Eventually the multiple GetBin functions will be replaced by a
    -- a single GetBin that returns CovBinBaseType with BinVal as an
    -- unconstrained element
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix2BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix3BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix4BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix5BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix6BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix7BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix8BaseType ;
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix9BaseType ;

    ------------------------------------------------------------
    impure function GetErrorCount (ID : CoverageIDType) return integer ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Printing Coverage Bin Information
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    -- To specify the following, see SetReportOptions
    --   WritePassFail, WriteBinInfo, WriteCount, WriteAnyIllegal
    --   WritePrefix, PassName, FailName
    ------------------------------------------------------------
    procedure WriteBin (ID : CoverageIDType) ;
    procedure WriteBin (ID : CoverageIDType; LogLevel : LogType ) ;  -- With LogLevel
    procedure WriteBin (ID : CoverageIDType; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE) ;
    procedure WriteBin (ID : CoverageIDType; LogLevel : LogType; FileName : string; OpenKind : File_Open_Kind := APPEND_MODE) ;
    procedure WriteAllBins (FileName : string := "" ; OpenKind : File_Open_Kind := WRITE_MODE) ;

    ------------------------------------------------------------
    procedure DumpBin (ID : CoverageIDType; LogLevel : LogType := DEBUG) ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType := ALWAYS ) ;
    procedure WriteCovHoles (ID : CoverageIDType; PercentCov : real ) ;
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  PercentCov : real ) ;
    procedure WriteCovHoles (ID : CoverageIDType; FileName : string;   OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles (ID : CoverageIDType; FileName : string;   PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Writing Out RAW Coverage Bin Information
    --  Note that read supports merging of coverage models
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure ReadCovDb  (ID : CoverageIDType; FileName : string; Merge : boolean := FALSE) ;
    procedure WriteCovDb (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;
    --     procedure WriteCovDb (ID : CoverageIDType) ;
    procedure WriteCovYaml (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;
    procedure WriteCovYaml (FileName : string := ""; Coverage : real ; OpenKind : File_Open_Kind := WRITE_MODE) ;
    procedure ReadCovYaml  (variable ID : inout CoverageIDType; FileName : string := ""; Merge : boolean := FALSE) ;
    procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) ;
    impure function GotCoverage return boolean ;
    procedure RecordCovRequirements ;
    procedure SetErrorIfNotCovered(Checked : boolean := FALSE) ; 


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  -- Compatibility Methods - Allows CoveragePkg to Work as a PT still
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------
    procedure       SetName    (Name : String) ;
    impure function SetName    (Name : String) return string ;
    procedure       DeallocateName ;    -- clear name
    impure function GetName return String ;
    impure function GetCovModelName return String ;

    ------------------------------------------------------------
    procedure       SetMessage (Message : String) ;
    procedure       DeallocateMessage ; -- clear message

    procedure       SetCovTarget     (Percent : real) ;       -- 2.5
    impure function GetCovTarget return real ;          -- 2.5
    procedure       SetThresholding  (A : boolean := TRUE ) ; -- 2.5
    procedure       SetCovThreshold  (Percent : real) ;
    procedure       SetMerging       (A : boolean := TRUE ) ; -- 2.5
    procedure       SetCountMode     (A : CountModeType) ;
    procedure       SetIllegalMode   (A : IllegalModeType) ;
    procedure       SetWeightMode    (A : WeightModeType;  Scale : real := 1.0) ;
    procedure       SetNextPointMode (A : NextPointModeType) ;

    ------------------------------------------------------------
    procedure       SetAlertLogID (A : AlertLogIDType) ;
    procedure       SetAlertLogID (Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) ;
    impure function GetAlertLogID return AlertLogIDType ;

    ------------------------------------------------------------
    procedure       InitSeed   (S  : string;   UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) ;
    impure function InitSeed   (S  : string;   UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) return string ;
    procedure       InitSeed   (I  : integer;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) ;

    ------------------------------------------------------------
    procedure       SetSeed    (RandomSeedIn : RandomSeedType ) ;
    impure function GetSeed return RandomSeedType ;

    ------------------------------------------------------------
    procedure SetBinSize (NewNumBins : integer) ;
    procedure Deallocate ;

    ------------------------------------------------------------
    -- Weight Deprecated
    procedure AddBins (
    ------------------------------------------------------------
      Name    : String ;
      AtLeast : integer ;
      Weight  : integer ;
      CovBin  : CovBinType
    ) ;
    procedure AddBins ( Name : String ; AtLeast : integer ; CovBin : CovBinType ) ;
    procedure AddBins ( Name : String ;  CovBin : CovBinType) ;
    procedure AddBins ( AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) ;
    procedure AddBins ( AtLeast : integer ; CovBin : CovBinType ) ;
    procedure AddBins ( CovBin : CovBinType ) ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      Name       : string ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
      Name       : string ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
      Name       : string ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    procedure AddCross(
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) ;

    ------------------------------------------------------------
    -- AddCross for usage with constants created by GenCross
    procedure AddCross (CovBin : CovMatrix2Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix3Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix4Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix5Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix6Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix7Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix8Type ; Name : String := "") ;
    procedure AddCross (CovBin : CovMatrix9Type ; Name : String := "") ;

    ------------------------------------------------------------
    --  Recording and Clearing Coverage
    procedure ICoverLast ;
    procedure ICover( CovPoint : integer) ;
    procedure ICover( CovPoint : integer_vector) ;
    procedure TCover( A : integer) ;

    procedure ClearCov ;
    procedure SetCovZero ;  -- Deprecated

    ------------------------------------------------------------
    --  Coverage Information and Statistics
    impure function IsCovered return boolean ;
    impure function IsCovered ( PercentCov : real ) return boolean ;
    impure function IsInitialized return boolean ;

    ------------------------------------------------------------
    impure function GetItemCount return integer ;
    impure function GetCov ( PercentCov : real ) return real ;
    impure function GetCov return real ; -- PercentCov of entire model/all bins
    impure function GetTotalCovCount ( PercentCov : real ) return integer ;
    impure function GetTotalCovCount return integer ;
    impure function GetTotalCovGoal ( PercentCov : real ) return integer ;
    impure function GetTotalCovGoal return integer ;

    ------------------------------------------------------------
    impure function GetMinCov return real ;       -- PercentCov
    impure function GetMinCount return integer ;  -- Count
    impure function GetMaxCov return real ;       -- PercentCov
    impure function GetMaxCount return integer ;  -- Count

    ------------------------------------------------------------
    impure function CountCovHoles ( PercentCov : real ) return integer ;
    impure function CountCovHoles return integer ;

    ------------------------------------------------------------
    -- Return Points
    impure function GetPoint     ( BinIndex : integer ) return integer ;
    impure function GetPoint     ( BinIndex : integer ) return integer_vector ;
    impure function GetRandPoint return integer ;
    impure function GetRandPoint ( PercentCov : real ) return integer ;
    impure function GetRandPoint return integer_vector ;
    impure function GetRandPoint ( PercentCov : real ) return integer_vector ;
    impure function GetIncPoint return integer ;
    impure function GetIncPoint return integer_vector ;
    impure function GetMinPoint return integer ;
    impure function GetMinPoint return integer_vector ;
    impure function GetMaxPoint return integer ;
    impure function GetMaxPoint return integer_vector ;
    impure function GetNextPoint  return integer ;
    impure function GetNextPoint  return integer_vector ;
    impure function GetNextPoint(Mode : NextPointModeType)  return integer ;
    impure function GetNextPoint(Mode : NextPointModeType)  return integer_vector ;

    -- RandCovPoint is deprecated, renamed to GetRandPoint
    impure function RandCovPoint return integer ;
    impure function RandCovPoint ( PercentCov : real ) return integer ;
    impure function RandCovPoint return integer_vector ;
    impure function RandCovPoint ( PercentCov : real ) return integer_vector ;

    ------------------------------------------------------------
    -- Return BinVals
    impure function GetBinVal ( BinIndex : integer ) return RangeArrayType ;
    impure function GetRandBinVal return RangeArrayType ;
    impure function GetRandBinVal ( PercentCov : real ) return RangeArrayType ;
    impure function GetLastBinVal return RangeArrayType ;
    impure function GetIncBinVal  return RangeArrayType ;
    impure function GetMinBinVal  return RangeArrayType ;
    impure function GetMaxBinVal  return RangeArrayType ;
    impure function GetNextBinVal  return RangeArrayType ;
    impure function GetNextBinVal(Mode : NextPointModeType)  return RangeArrayType ;
    impure function GetHoleBinVal ( ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType ;
    impure function GetHoleBinVal ( PercentCov : real ) return RangeArrayType ;
    impure function GetHoleBinVal ( ReqHoleNum : integer := 1 ) return RangeArrayType ;

    -- RandCovBinVal is deprecated, renamed to GetRandBinVal
    impure function RandCovBinVal return RangeArrayType ;
    impure function RandCovBinVal ( PercentCov : real ) return RangeArrayType ; -- deprecated,  see GetRandBinVal

    ------------------------------------------------------------
    -- Return Index
    impure function GetNumBins return integer ;
    impure function GetRandIndex return integer ;
    impure function GetRandIndex ( CovTargetPercent : real ) return integer ;
    impure function GetLastIndex return integer ;
    impure function GetIncIndex return integer ;
    impure function GetMinIndex return integer ;
    impure function GetMaxIndex return integer ;
    impure function GetNextIndex  return integer ;
    impure function GetNextIndex(Mode : NextPointModeType)  return integer ;

    -- The return value may change as the package evolves
    -- Get all bin information except the BinVal (since it is sized)
    impure function GetBinInfo ( BinIndex : integer ) return CovBinBaseType ;
    impure function GetBinValLength return integer ;
    impure function GetBinName ( BinIndex : integer; DefaultName : string := "" ) return string ;

    -- GetBin returns an internal value of the coverage data structure
    impure function GetBin ( BinIndex : integer ) return CovBinBaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix2BaseType  ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix3BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix4BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix5BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix6BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix7BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix8BaseType ;
    impure function GetBin ( BinIndex : integer ) return CovMatrix9BaseType ;
    impure function GetErrorCount return integer ;

    ------------------------------------------------------------
    procedure WriteBin (
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) ;

    ------------------------------------------------------------
    procedure WriteBin (  -- With LogLevel
      LogLevel        : LogType ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) ;

    ------------------------------------------------------------
    procedure WriteBin (
      FileName        : string;
      OpenKind        : File_Open_Kind := APPEND_MODE ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) ;

    ------------------------------------------------------------
    procedure WriteBin (  -- With LogLevel
      LogLevel        : LogType ;
      FileName        : string;
      OpenKind        : File_Open_Kind := APPEND_MODE ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) ;

    procedure DumpBin (LogLevel : LogType := DEBUG) ;  -- Development only

    procedure WriteCovHoles ( LogLevel : LogType := ALWAYS ) ;
    procedure WriteCovHoles ( PercentCov : real ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  PercentCov : real ) ;
    procedure WriteCovHoles ( FileName : string;   OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( FileName : string;   PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;

    procedure ReadCovDb (FileName : string; Merge : boolean := FALSE) ;
    procedure WriteCovDb (FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;


------------------------------------------------------------
--  Remaining are Deprecated
--
    -- Deprecated/Subsumed by versions with PercentCov Parameter (rather than AtLeast value)
    impure function RandCovPoint  (AtLeast : integer ) return integer ;
    impure function RandCovPoint  (AtLeast : integer ) return integer_vector ;
    impure function RandCovBinVal (AtLeast : integer ) return RangeArrayType ;
    impure function RandCovHole   (AtLeast : integer ) return RangeArrayType ;
    impure function CountCovHoles (AtLeast : integer ) return integer ;
    impure function IsCovered     (AtLeast : integer ) return boolean ;
    impure function GetHoleBinVal (ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType ;
    impure function GetCovHole    (ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType ;
    procedure       WriteCovHoles (AtLeast : integer ) ;
    procedure       WriteCovHoles (LogLevel : LogType;    AtLeast : integer ) ;
    procedure       WriteCovHoles (FileName : string;     AtLeast : integer;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure       WriteCovHoles (LogLevel : LogType;    FileName : string;  AtLeast  : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) ;

    -- Deprecated.  Replaced by SetMessage
    procedure       SetItemName   (ItemNameIn : String) ;  -- Replaced by SetMessage

    -- Deprecated.  Replaced by GetErrorCount
    impure function CovBinErrCnt return integer ;  -- Replaced by GetErrorCount

    -- Deprecated.  Replaced by GetRandBinVal/RandCovBinVal
    impure function RandCovHole   (PercentCov : real) return RangeArrayType ;  -- Deprecated
    impure function RandCovHole return RangeArrayType ;  -- Deprecated

    -- Deprecated.  Replaced by GetHoleBinVal
    impure function GetCovHole    (ReqHoleNum : integer ; PercentCov : real ) return RangeArrayType ;
    impure function GetCovHole    (PercentCov : real ) return RangeArrayType ;
    impure function GetCovHole    (ReqHoleNum : integer := 1 ) return RangeArrayType ;

    -- Deprecated.  Replaced by GetMinCount / GetMaxCount
    impure function GetMinCov return integer ;  -- Replaced by GetMinCount
    impure function GetMaxCov return integer ;  -- Replaced by GetMaxCount

    -- Deprecated.  Replaced by AddCross.
    procedure AddBins (CovBin : CovMatrix2Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix3Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix4Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix5Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix6Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix7Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix8Type ; Name : String := "") ;
    procedure AddBins (CovBin : CovMatrix9Type ; Name : String := "") ;

  end protected CovPType ;
  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------

  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    variable Bin1       : inout CovPType ;
    variable Bin2       : inout CovPType ;
    variable ErrorCount : inout integer
  ) ;

  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    variable Bin1       : inout CovPType ;
    variable Bin2       : inout CovPType
  ) ;

  ------------------------------------------------------------
  -- Deprecated items
  -- The following will be removed from the package in the future.
  --

  ------------------------------------------------------------
  -- SetName is deprecated, see NewID
  procedure       SetName         (ID : CoverageIDType; Name : String) ;
  impure function SetName         (ID : CoverageIDType; Name : String) return string ;
  procedure       DeallocateName  (ID : CoverageIDType) ;

  ------------------------------------------------------------
  -- SetMessage is deprecated, see PrintToCovFile
  procedure       SetMessage         (ID : CoverageIDType; Message : String) ;
  procedure       DeallocateMessage  (ID : CoverageIDType) ;

  ------------------------------------------------------------
  -- DumpBin is deprecated
  procedure DumpBin (ID : CoverageIDType; LogLevel : LogType := DEBUG) ;

  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddBins (
  ------------------------------------------------------------
    ID      : CoverageIDType ;
    Name    : String ;
    AtLeast : integer ;
    Weight  : integer ;
    CovBin  : CovBinType
  ) ;
  procedure AddBins (ID : CoverageIDType; AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) ;     -- Weight Deprecated

  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    AtLeast    : integer ;
    Weight     : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    AtLeast    : integer ;
    Weight     : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) ;

  ------------------------------------------------------------
  -- Weight Parameter is deprecated
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Weight        : integer ;
    Min, Max      : integer ;
    NumBin        : integer
  ) return CovBinType ;

  ------------------------------------------------------------
  -- Weight Parameter is deprecated
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Weight        : integer ;
    A             : integer_vector
  ) return CovBinType ;

  ------------------------------------------------------------
  function GenCross(  -- 2
  -- Cross existing bins
  -- Use AddCross for adding values directly to coverage database
  -- Use GenCross for constants
  ------------------------------------------------------------
    AtLeast     : integer ;
    Weight      : integer ;
    Bin1, Bin2  : CovBinType
  ) return CovMatrix2Type ;

  ------------------------------------------------------------
  function GenCross(  -- 3
  ------------------------------------------------------------
    AtLeast           : integer ;
    Weight            : integer ;
    Bin1, Bin2, Bin3  : CovBinType
  ) return CovMatrix3Type ;

  ------------------------------------------------------------
  function GenCross(  -- 4
  ------------------------------------------------------------
    AtLeast                 : integer ;
    Weight                  : integer ;
    Bin1, Bin2, Bin3, Bin4  : CovBinType
  ) return CovMatrix4Type ;

  ------------------------------------------------------------
  function GenCross(  -- 5
  ------------------------------------------------------------
    AtLeast                       : integer ;
    Weight                        : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5  : CovBinType
  ) return CovMatrix5Type ;

  ------------------------------------------------------------
  function GenCross(  -- 6
  ------------------------------------------------------------
    AtLeast                             : integer ;
    Weight                              : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6  : CovBinType
  ) return CovMatrix6Type ;

  ------------------------------------------------------------
  function GenCross(  -- 7
  ------------------------------------------------------------
    AtLeast                                   : integer ;
    Weight                                    : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7  : CovBinType
  ) return CovMatrix7Type ;

  ------------------------------------------------------------
  function GenCross(  -- 8
  ------------------------------------------------------------
    AtLeast                                         : integer ;
    Weight                                          : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8  : CovBinType
  ) return CovMatrix8Type ;

  ------------------------------------------------------------
  function GenCross(  -- 9
  ------------------------------------------------------------
    AtLeast                                               : integer ;
    Weight                                                : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9  : CovBinType
  ) return CovMatrix9Type ;


end package CoveragePkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body CoveragePkg is

  constant DEFAULT_WEIGHT_MODE : WeightModeType := WeightModeType'value(COVERAGE_DEFAULT_WEIGHT_MODE) ;


  ------------------------------------------------------------
  --  package local
  function ActionToName(Action : integer) return string is
  ------------------------------------------------------------
  begin
    case Action is
      when 1 =>        return "COUNT" ;
      when 0 =>        return "IGNORE"  ;
      when others =>   return "ILLEGAL" ;
    end case ;
  end function ActionToName ;

  ------------------------------------------------------------
  function inside (
  -- package local
  ------------------------------------------------------------
    CovPoint : integer_vector ;
    BinVal   : RangeArrayType
  ) return boolean is
    alias iCovPoint : integer_vector(BinVal'range) is CovPoint ;
  begin
    for i in BinVal'range loop
      if not (iCovPoint(i) >= BinVal(i).min and iCovPoint(i) <= BinVal(i).max) then
        return FALSE ;
      end if ;
    end loop ;
    return TRUE ;
  end function inside ;

  ------------------------------------------------------------
  function inside (
  -- package local, used by InsertBin
  -- True when BinVal1 is inside BinVal2
  ------------------------------------------------------------
    BinVal1  : RangeArrayType ;
    BinVal2  : RangeArrayType
  ) return boolean is
    alias iBinVal2 : RangeArrayType(BinVal1'range) is BinVal2 ;
  begin
    for i in BinVal1'range loop
      if not (BinVal1(i).min >= iBinVal2(i).min and BinVal1(i).max <= iBinVal2(i).max) then
        return FALSE ;
      end if ;
    end loop ;
    return TRUE ;
  end function inside ;

  ------------------------------------------------------------
  procedure write (
    variable buf : inout line ;
    CovPoint     : integer_vector
  ) is
  -- package local.  called by ICover
  ------------------------------------------------------------
    alias iCovPoint : integer_vector(1 to CovPoint'length) is CovPoint ;
  begin
    write(buf, "(" & to_string_max(iCovPoint(1)) ) ;
    for i in 2 to iCovPoint'right loop
      write(buf, "," & to_string_max(iCovPoint(i)) ) ;
    end loop ;
    swrite(buf, ")") ;
  end procedure write ;

  ------------------------------------------------------------
  procedure write (
  -- called by WriteBin and WriteCovHoles
  ------------------------------------------------------------
    variable buf    : inout line ;
    constant BinVal : in    RangeArrayType
  ) is
  ------------------------------------------------------------
  begin
    for i in BinVal'range loop
      if BinVal(i).min = BinVal(i).max then
        write(buf, "(" & to_string_max(BinVal(i).min) & ") " ) ;
      elsif  (BinVal(i).min = integer'low) and (BinVal(i).max = integer'high) then
        swrite(buf, "(ALL) " ) ;
      else
        write(buf, "(" & to_string_max(BinVal(i).min) & " to " &
                       to_string_max(BinVal(i).max) & ") " ) ;
      end if ;
    end loop ;
  end procedure write ;

  ------------------------------------------------------------
  impure function to_string ( BinVal : RangeArrayType ) return string is
  -- error handling in InsertBin
  ------------------------------------------------------------
    variable buf : line ; 
    impure function buf_to_string return string is
      variable s : string(buf'range) ; 
    begin
      s := buf.all ; 
      deallocate(buf) ;
      return s ;
    end function buf_to_string ; 
  begin
    write(buf, BinVal) ; 
    return buf_to_string ; 
  end function to_string ; 


  ------------------------------------------------------------
  procedure WriteBinVal (
  -- package local for now
  ------------------------------------------------------------
    variable buf    : inout line ;
    constant BinVal : in    RangeArrayType
  ) is
  begin
    for i in BinVal'range loop
      write(buf, BinVal(i).min) ;
      write(buf, ' ') ;
      write(buf, BinVal(i).max) ;
      write(buf, ' ') ;
    end loop ;
  end procedure WriteBinVal ;

  ------------------------------------------------------------
  -- package local for now
  procedure read (
  -- if public, also create one that does not use valid flag
  ------------------------------------------------------------
    variable buf    : inout line ;
    variable BinVal : out   RangeArrayType ;
    variable Valid  : out   boolean
  ) is
    variable ReadValid : boolean ;
  begin
    for i in BinVal'range loop
      read(buf, BinVal(i).min, ReadValid) ;
      exit when not ReadValid ;
      read(buf, BinVal(i).max, ReadValid) ;
      exit when not ReadValid ;
    end loop ;
    Valid := ReadValid ;
  end procedure read ;

  ------------------------------------------------------------
  function CalcPercentCov( Count : integer ; AtLeast : integer ) return real is
  -- package local, called by MergeBin, InsertBin, ClearCov, ReadCovDbDatabase
  ------------------------------------------------------------
--sig    variable PercentCov : real ;
  begin
    if AtLeast > 0 then
      return real(Count)*100.0/real(AtLeast) ;
    elsif AtLeast = 0 then
      return 100.0 ;
    else
      return real'right ;
    end if ;
  end function CalcPercentCov ;

  -- ------------------------------------------------------------
  function BinLengths (
  -- package local, used by AddCross, GenCross
  -- ------------------------------------------------------------
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
    Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
 ) return integer_vector is
   variable result : integer_vector(1 to 20) := (others => 0 ) ;
   variable i : integer := result'left ;
   variable Len : integer ;
  begin
    loop
      case i is
        when  1 =>  Len := Bin1'length ;
        when  2 =>  Len := Bin2'length ;
        when  3 =>  Len := Bin3'length ;
        when  4 =>  Len := Bin4'length ;
        when  5 =>  Len := Bin5'length ;
        when  6 =>  Len := Bin6'length ;
        when  7 =>  Len := Bin7'length ;
        when  8 =>  Len := Bin8'length ;
        when  9 =>  Len := Bin9'length ;
        when 10 =>  Len := Bin10'length ;
        when 11 =>  Len := Bin11'length ;
        when 12 =>  Len := Bin12'length ;
        when 13 =>  Len := Bin13'length ;
        when 14 =>  Len := Bin14'length ;
        when 15 =>  Len := Bin15'length ;
        when 16 =>  Len := Bin16'length ;
        when 17 =>  Len := Bin17'length ;
        when 18 =>  Len := Bin18'length ;
        when 19 =>  Len := Bin19'length ;
        when 20 =>  Len := Bin20'length ;
        when others =>  Len := 0 ;
      end case ;
      result(i) := Len ;
      exit when Len = 0 ;
      i := i + 1 ;
      exit when i = 21 ;
    end loop ;
    return result(1 to (i-1)) ;
  end function BinLengths ;

  -- ------------------------------------------------------------
  function CalcNumCrossBins ( BinLens : integer_vector ) return integer is
  -- package local, used by AddCross
  -- ------------------------------------------------------------
    variable result : integer := 1 ;
  begin
    for i in BinLens'range loop
      result := result * BinLens(i) ;
    end loop ;
    return result ;
  end function CalcNumCrossBins ;

  -- ------------------------------------------------------------
  procedure IncBinIndex (
  -- package local, used by AddCross
  -- ------------------------------------------------------------
    variable BinIndex : inout integer_vector ;
    constant BinLens  : in    integer_vector
  ) is
    alias aBinIndex : integer_vector(1 to BinIndex'length) is BinIndex ;
    alias aBinLens  : integer_vector(aBinIndex'range) is BinLens ;
  begin
    -- increment right most one, then if overflow, increment next
    -- assumes bins numbered from 1 to N.  - assured by ConcatenateBins
    for i in aBinIndex'reverse_range loop
      aBinIndex(i) := aBinIndex(i) + 1 ;
      exit when aBinIndex(i) <= aBinLens(i) ;
      aBinIndex(i) := 1 ;
    end loop ;
  end procedure IncBinIndex ;

  -- ------------------------------------------------------------
  function ConcatenateBins (
  -- package local, used by AddCross and GenCross
  -- ------------------------------------------------------------
    BinIndex : integer_vector ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
    Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) return CovBinType is
    alias aBin1  : CovBinType (1 to Bin1'length) is Bin1 ;
    alias aBin2  : CovBinType (1 to Bin2'length) is Bin2 ;
    alias aBin3  : CovBinType (1 to Bin3'length) is Bin3 ;
    alias aBin4  : CovBinType (1 to Bin4'length) is Bin4 ;
    alias aBin5  : CovBinType (1 to Bin5'length) is Bin5 ;
    alias aBin6  : CovBinType (1 to Bin6'length) is Bin6 ;
    alias aBin7  : CovBinType (1 to Bin7'length) is Bin7 ;
    alias aBin8  : CovBinType (1 to Bin8'length) is Bin8 ;
    alias aBin9  : CovBinType (1 to Bin9'length) is Bin9 ;
    alias aBin10 : CovBinType (1 to Bin10'length) is Bin10 ;
    alias aBin11 : CovBinType (1 to Bin11'length) is Bin11 ;
    alias aBin12 : CovBinType (1 to Bin12'length) is Bin12 ;
    alias aBin13 : CovBinType (1 to Bin13'length) is Bin13 ;
    alias aBin14 : CovBinType (1 to Bin14'length) is Bin14 ;
    alias aBin15 : CovBinType (1 to Bin15'length) is Bin15 ;
    alias aBin16 : CovBinType (1 to Bin16'length) is Bin16 ;
    alias aBin17 : CovBinType (1 to Bin17'length) is Bin17 ;
    alias aBin18 : CovBinType (1 to Bin18'length) is Bin18 ;
    alias aBin19 : CovBinType (1 to Bin19'length) is Bin19 ;
    alias aBin20 : CovBinType (1 to Bin20'length) is Bin20 ;
    alias aBinIndex : integer_vector(1 to BinIndex'length) is BinIndex ;
    variable result : CovBinType(aBinIndex'range) ;
  begin
    for i in aBinIndex'range loop
      case i is
        when  1 =>  result(i) := aBin1(aBinIndex(i)) ;
        when  2 =>  result(i) := aBin2(aBinIndex(i)) ;
        when  3 =>  result(i) := aBin3(aBinIndex(i)) ;
        when  4 =>  result(i) := aBin4(aBinIndex(i)) ;
        when  5 =>  result(i) := aBin5(aBinIndex(i)) ;
        when  6 =>  result(i) := aBin6(aBinIndex(i)) ;
        when  7 =>  result(i) := aBin7(aBinIndex(i)) ;
        when  8 =>  result(i) := aBin8(aBinIndex(i)) ;
        when  9 =>  result(i) := aBin9(aBinIndex(i)) ;
        when 10 =>  result(i) := aBin10(aBinIndex(i)) ;
        when 11 =>  result(i) := aBin11(aBinIndex(i)) ;
        when 12 =>  result(i) := aBin12(aBinIndex(i)) ;
        when 13 =>  result(i) := aBin13(aBinIndex(i)) ;
        when 14 =>  result(i) := aBin14(aBinIndex(i)) ;
        when 15 =>  result(i) := aBin15(aBinIndex(i)) ;
        when 16 =>  result(i) := aBin16(aBinIndex(i)) ;
        when 17 =>  result(i) := aBin17(aBinIndex(i)) ;
        when 18 =>  result(i) := aBin18(aBinIndex(i)) ;
        when 19 =>  result(i) := aBin19(aBinIndex(i)) ;
        when 20 =>  result(i) := aBin20(aBinIndex(i)) ;
        when others =>
          -- pure functions cannot use alert and/or print
          report "CoveragePkg.AddCross: More than 20 bins not supported"
            severity FAILURE ;
      end case ;
    end loop ;
    return result ;
  end function ConcatenateBins ;

  ------------------------------------------------------------
  function MergeState( CrossBins : CovBinType) return integer is
  -- package local, Used by AddCross, GenCross
  ------------------------------------------------------------
    variable resultState : integer ;
  begin
    resultState := COV_COUNT ;
    for i in CrossBins'range loop
      if CrossBins(i).action = COV_ILLEGAL then
        return COV_ILLEGAL ;
      end if ;
      if CrossBins(i).action = COV_IGNORE then
        resultState := COV_IGNORE ;
      end if ;
    end loop ;
    return resultState ;
  end function MergeState ;

  ------------------------------------------------------------
  function MergeBinVal( CrossBins : CovBinType) return RangeArrayType is
  -- package local, Used by AddCross, GenCross
  ------------------------------------------------------------
    alias aCrossBins : CovBinType(1 to CrossBins'length) is CrossBins ;
    variable BinVal : RangeArrayType(aCrossBins'range) ;
  begin
    for i in aCrossBins'range loop
      BinVal(i to i) := aCrossBins(i).BinVal ;
    end loop ;
    return BinVal ;
  end function MergeBinVal ;

  ------------------------------------------------------------
  function MergeAtLeast(
  -- package local, Used by AddCross, GenCross
  ------------------------------------------------------------
    Action    : in integer ;
    AtLeast   : in integer ;
    CrossBins : in CovBinType
  ) return integer is
    variable Result : integer := AtLeast ;
  begin
    if Action /= COV_COUNT then
      return 0 ;
    end if ;
    for i in CrossBins'range loop
      if CrossBins(i).Action = Action then
        Result := maximum (Result, CrossBins(i).AtLeast) ;
      end if ;
    end loop ;
    return result ;
  end function MergeAtLeast ;

  ------------------------------------------------------------
  function MergeWeight(
  -- package local, Used by AddCross, GenCross
  ------------------------------------------------------------
    Action    : in integer ;
    Weight    : in integer ;
    CrossBins : in CovBinType
  ) return integer is
    variable Result : integer := Weight ;
  begin
    if Action /= COV_COUNT then
      return 0 ;
    end if ;
    for i in CrossBins'range loop
      if CrossBins(i).Action = Action then
        Result := maximum (Result, CrossBins(i).Weight) ;
      end if ;
    end loop ;
    return result ;
  end function MergeWeight ;

  ------------------------------------------------------------  VendorCov
  -- VendorCov Conversion for Vendor supported functional coverage modeling
  function ToVendorCovBinVal (BinVal : RangeArrayType) return VendorCovRangeArrayType is
  ------------------------------------------------------------
    variable VendorCovBinVal :  VendorCovRangeArrayType(BinVal'range);
  begin                                                        -- VendorCov
    for ArrIdx in BinVal'LEFT to BinVal'RIGHT loop             -- VendorCov
      VendorCovBinVal(ArrIdx) := (min => BinVal(ArrIdx).min,   -- VendorCov
                                  max => BinVal(ArrIdx).max) ; -- VendorCov
    end loop;                                                  -- VendorCov
    return VendorCovBinVal ;
  end function ToVendorCovBinVal ;

  ------------------------------------------------------------
  function ToMinPoint (A : RangeArrayType) return integer is
  -- Used in testing
  ------------------------------------------------------------
  begin
    return A(A'left).min ;
  end function ToMinPoint ;

  ------------------------------------------------------------
  function ToMinPoint (A : RangeArrayType) return integer_vector is
  -- Used in testing
  ------------------------------------------------------------
    variable result : integer_vector(A'range) ;
  begin
    for i in A'range loop
      result(i) := A(i).min ;
    end loop ;
    return result ;
  end function ToMinPoint ;

  ------------------------------------------------------------
  procedure ToRandPoint(
  ------------------------------------------------------------
    variable RV       : inout RandomPType ;
    constant BinVal   : in    RangeArrayType ;
    variable result   : out   integer
  ) is
  begin
    result := RV.RandInt(BinVal(BinVal'left).min, BinVal(BinVal'left).max) ;
  end procedure ToRandPoint ;

  ------------------------------------------------------------
  procedure ToRandPoint(
  ------------------------------------------------------------
    variable RV       : inout RandomPType ;
    constant BinVal   : in    RangeArrayType ;
    variable result   : out   integer_vector
  ) is
    variable VectorVal : integer_vector(BinVal'range) ;
  begin
    for i in BinVal'range loop
      VectorVal(i) := RV.RandInt(BinVal(i).min, BinVal(i).max) ;
    end loop ;
    result := VectorVal ;
  end procedure ToRandPoint ;

  ------------------------------------------------------------
  -- Local.  Get first word from a string
  function GetWord (Message : string) return string is
  ------------------------------------------------------------
    alias aMessage : string( 1 to Message'length) is Message ;
  begin
    for i in aMessage'range loop
      if aMessage(i) = ' ' or aMessage(i) = HT then
        return aMessage(1 to i-1) ;
      end if ;
    end loop ;
    return aMessage ;
  end function GetWord ;

  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------
  type CovPType is protected body
    constant COV_READ_YAML_ALERT_LEVEL : AlertType := ERROR ;

    ------------------------------------------------------------
    -- Global Settings for Coverage Modeling
    -- Local WriteBin and WriteCovHoles formatting settings, defaults determined by CoverageGlobals
    variable WritePassFailVar   : boolean := COVERAGE_WRITE_PASS_FAIL   ;
    variable WriteBinInfoVar    : boolean := COVERAGE_WRITE_BIN_INFO    ;
    variable WriteCountVar      : boolean := COVERAGE_WRITE_COUNT       ;
    variable WriteAnyIllegalVar : boolean := COVERAGE_WRITE_ANY_ILLEGAL ;
--!!    variable WritePrefixVar     : NamePType ;
--!!    variable PassNameVar        : NamePType ;
--!!    variable FailNameVar        : NamePType ;
    variable ErrorIfNotCoveredVar           : boolean := FALSE ;
--!!    variable CheckedForErrorIfNotCoveredVar : boolean := FALSE ;

    file OsvvmCoverageWriteBinFile : text ;
    variable WriteBinFileInit : boolean := FALSE ;
--!!    variable UsingLocalFile   : boolean := FALSE ;


    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- CoverageBin Data Structures
    -- /////////////////////////////////////////
    type RangeArrayPtrType is access RangeArrayType ;

    type CovBinInternalBaseType is record
      BinVal        : RangeArrayPtrType ;
      Action        : integer ;
      Count         : integer ;
      AtLeast       : integer ;
      Weight        : integer ;
      PercentCov    : real ;
      Name          : line ;
    end record CovBinInternalBaseType ;
    type CovBinInternalType is array (natural range <>) of CovBinInternalBaseType ;
    type CovBinPtrType is access CovBinInternalType ;

    type FieldNameArrayType is array (natural range <>) of Line ;
    type FieldNameArrayPtrType is access FieldNameArrayType ;

    type IntegerVectorPtrType is access integer_vector ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- Coverage Information and Settings Structure
    -- /////////////////////////////////////////
    type CovStructType is record
      --  Coverage Bin Structure
      CovBinPtr          : CovBinPtrType ;
      CovName            : line ;
      NumBins            : integer ;
      BinValLength       : integer ;
      FieldName          : FieldNameArrayPtrType ;
      CovWeight          : integer ; -- Set GetCov for entire model

      TCoverCount        : integer ;
      TCoverValuePtr     : IntegerVectorPtrType ;

      CovMessage         : MessageStructPtrType ;
      VendorCovHandle    : VendorCovHandleType ;

      --  Statistics and History
      ItemCount          : integer ;  -- Count of randomizations
      LastIndex          : integer ;  -- Index of last Stimulus Gen or Coverage Collection
      LastStimGenIndex   : integer ;  -- Index of last stimulus gen

      -- Internal Modes and Settings
      NextPointMode      : NextPointModeType ;
      IllegalMode        : IllegalModeType ;
      IllegalModeLevel   : AlertType ;
      WeightMode         : WeightModeType ;
      WeightScale        : real ;

      ThresholdingEnable : boolean ; -- thresholding disabled by default
      CovThreshold       : real ;
      CovTarget          : real ;

      MergingEnable      : boolean ; -- merging disabled by default
      CountMode          : CountModeType ;

      -- Randomization Variable
      RV                 : RandomSeedType ;
      RvSeedInit         : boolean ;

      AlertLogID         : AlertLogIDType ;
      IsRequirement      : boolean ; 
--??      Goal               : real ; 
    end record CovStructType ;

    variable COV_STRUCT_INIT : CovStructType :=
      (
        --  Coverage Bin Structure
        CovBinPtr          =>  NULL,
        CovName            =>  NULL,
        NumBins            =>  0,
        BinValLength       =>  1,
        FieldName          =>  NULL,
        CovWeight          =>  1,

        TCoverCount        =>  0,
        TCoverValuePtr     =>  NULL,

        CovMessage         =>  NULL,
        VendorCovHandle    =>  INIT_VENDOR_COV_HANDLE,

        --  Statistics and History
        ItemCount          =>  0,   -- Count of randomizations
        LastIndex          =>  1,   -- Index of last Stimulus Gen or Coverage Collection
        LastStimGenIndex   =>  1,   -- Index of last stimulus gen

        -- Internal Modes and Settings
        NextPointMode      =>  RANDOM,
        IllegalMode        =>  ILLEGAL_ON,
        IllegalModeLevel   =>  ERROR,
        WeightMode         =>  DEFAULT_WEIGHT_MODE,
        WeightScale        =>  1.0,

        ThresholdingEnable =>  FALSE, -- thresholding disabled by default
        CovThreshold       =>  45.0,
        CovTarget          =>  100.0,

        MergingEnable      =>  FALSE, -- merging disabled by default
        CountMode          =>  COUNT_FIRST,

        -- Randomization Variable
        RV                 =>  (1, 7),
        RvSeedInit         =>  FALSE,

        AlertLogID         =>  OSVVM_COVERAGE_ALERTLOG_ID,
        IsRequirement      => FALSE 
      ) ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- Adjustable Array Data Structure and Creation
    -- /////////////////////////////////////////
    type     ItemArrayType    is array (integer range <>) of CovStructType ;
    type     ItemArrayPtrType is access ItemArrayType ;

    variable Template : ItemArrayType(1 to 1) := (1 => COV_STRUCT_INIT) ;

    constant COV_STRUCT_ID_DEFAULT : CoverageIDType := (ID => Template'left) ;
    variable CovStructPtr          : ItemArrayPtrType := new ItemArrayType'(Template) ;
    variable NumItems              : integer := 0 ;
--    constant MIN_NUM_ITEMS         : integer := 4 ; -- Temporarily small for testing
    constant MIN_NUM_ITEMS         : integer := 32 ; -- Min amount to resize array
    variable LocalNameStore        : NameStorePType ;

    ------------------------------------------------------------
    -- Package Local
    function NormalizeArraySize( NewNumItems, MinNumItems : integer ) return integer is
    ------------------------------------------------------------
      variable NormNumItems : integer := NewNumItems ;
      variable ModNumItems  : integer := 0;
    begin
      ModNumItems := NewNumItems mod MinNumItems ;
      if ModNumItems > 0 then
        NormNumItems := NormNumItems + (MinNumItems - ModNumItems) ;
      end if ;
      return NormNumItems ;
    end function NormalizeArraySize ;

    ------------------------------------------------------------
    -- Package Local
    procedure GrowNumberItems (
    ------------------------------------------------------------
      variable ItemArrayPtr     : InOut ItemArrayPtrType ;
      variable NumItems         : InOut integer ;
      constant GrowAmount       : in integer ;
      constant MinNumItems      : in integer
    ) is
      variable oldItemArrayPtr  : ItemArrayPtrType ;
      variable NewNumItems : integer ;
    begin
      NewNumItems := NumItems + GrowAmount ;
      if ItemArrayPtr = NULL then
        ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
      elsif NewNumItems > ItemArrayPtr'length then
        oldItemArrayPtr := ItemArrayPtr ;
        ItemArrayPtr := new ItemArrayType(1 to NormalizeArraySize(NewNumItems, MinNumItems)) ;
        ItemArrayPtr(1 to NumItems) := ItemArrayType'(oldItemArrayPtr(1 to NumItems)) ;
        deallocate(oldItemArrayPtr) ;
      end if ;
      NumItems := NewNumItems ;
    end procedure GrowNumberItems ;

    ------------------------------------------------------------
    impure function NewID (
    ------------------------------------------------------------
      Name                : string ;
      Goal                : real ; 
      ParentID            : AlertLogIDType ;
      ReportMode          : AlertLogReportModeType ;
      Search              : NameSearchType ;
      PrintParent         : AlertLogPrintParentType
    ) return CoverageIDType is
      variable NewCoverageID       : CoverageIDType ;
      variable NameID              : integer ;
      variable ResolvedSearch      : NameSearchType ;
      variable ResolvedPrintParent : AlertLogPrintParentType ;
    begin
      ResolvedSearch      := ResolveSearch     (ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, Search) ;
      ResolvedPrintParent := ResolvePrintParent(ParentID /= OSVVM_COVERAGE_ALERTLOG_ID, PrintParent) ;

      NameID := LocalNameStore.find(Name, ParentID, ResolvedSearch) ;

      if NameID /= ID_NOT_FOUND.ID then
--!! Check if IsRequirement and currently a requirement, then update AlertLogID
        NewCoverageID := (ID => NameID) ;
        SetName(NewCoverageID, Name) ; -- redundant - refactor after diverge.  Needed if deallocate
        return NewCoverageID ;
      else
        -- Add New Coverage Model to Structure
        GrowNumberItems(CovStructPtr, NumItems, 1, MIN_NUM_ITEMS) ;
        CovStructPtr(NumItems) := CovStructType'(COV_STRUCT_INIT) ;
        NewCoverageID := (ID => NumItems) ;
        -- Create AlertLogID
        if Goal > 0.0 then 
          CovStructPtr(NumItems).AlertLogID    := NewReqID(Name, 1, ParentID, ReportMode, ResolvedPrintParent, CreateHierarchy => FALSE) ;
          CovStructPtr(NumItems).IsRequirement := TRUE ; 
--??          CovStructPtr(NumItems).Goal          := Goal ; 
        else
          CovStructPtr(NumItems).AlertLogID    := NewID(Name, ParentID, ReportMode, ResolvedPrintParent, CreateHierarchy => FALSE) ;
          CovStructPtr(NumItems).IsRequirement := FALSE ; 
--??          CovStructPtr(NumItems).Goal          := Goal ; 
        end if ; 
        -- Add item to NameStore
        NameID := LocalNameStore.NewID(Name, ParentID, ResolvedSearch) ;
        AlertIfNotEqual(CovStructPtr(NumItems).AlertLogID, NameID, NumItems, "CoveragePkg: Index of LocalNameStore /= CoverageID") ;
--         InitSeed( NewCoverageID, Name) ; -- Replaced in 2023.05
        -- Ensure that name to generate the seed is unique by using ParentID 
        --   Note that ParentID must be unique for each VC (take care with for generate).  
        --   Considered adding NewCoverageID.ID, but that will result in construction order dependencies
        InitSeed( NewCoverageID, Name & string'(GetAlertLogName(ParentID))) ;   -- & to_string(NewCoverageID.ID) 
        SetName( NewCoverageID, Name) ; -- redundant - refactor after diverge
        return NewCoverageID ;
      end if ;
    end function NewID ;

    ------------------------------------------------------------
    impure function GetNumIDs return integer is
    ------------------------------------------------------------
    begin
      return NumItems ;
    end function GetNumIDs ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Coverage Global Settings Common to All Coverage Models
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) is
    ------------------------------------------------------------
    begin
      WriteBinFileInit := TRUE ;
      file_open( OsvvmCoverageWriteBinFile , FileName , OpenKind );
    end procedure FileOpenWriteBin ;

    ------------------------------------------------------------
    procedure FileCloseWriteBin is
    ------------------------------------------------------------
    begin
      WriteBinFileInit := FALSE ;
      file_close( OsvvmCoverageWriteBinFile) ;
    end procedure FileCloseWriteBin ;

    ------------------------------------------------------------
    -- PT Local for now as it uses an access type
    procedure WriteToCovFile (variable buf : inout line) is
    ------------------------------------------------------------
    begin
      if buf /= NULL then
        if WriteBinFileInit then
          -- Write to Local OsvvmCoverageWriteBinFile - Deprecated, recommend use TranscriptFile instead
          writeline(OsvvmCoverageWriteBinFile, buf) ;
        elsif IsTranscriptEnabled then
          if IsTranscriptMirrored then
            -- Write to TranscriptFile and OUTPUT
            tee(TranscriptFile, buf) ;
          else
            -- Write to TranscriptFile
            writeline(TranscriptFile, buf) ;
          end if ;
        else
          -- Default Write to OUTPUT
          writeline(OUTPUT, buf) ;
        end if ;
      end if ;
    end procedure WriteToCovFile ;

    ------------------------------------------------------------
    procedure PrintToCovFile(S : string) is
    ------------------------------------------------------------
      variable buf : line ;
    begin
      write(buf, S) ;
      WriteToCovFile(buf) ;
    end procedure PrintToCovFile ;

--      ------------------------------------------------------------
--      procedure FileOpen (FileName : string; OpenKind : File_Open_Kind ) is
--      ------------------------------------------------------------
--      begin
--        WriteCovDbFileInit := TRUE ;
--        file_open( WriteCovDbFile , FileName , OpenKind );
--      end procedure FileOpenWriteCovDb ;
--
--      ------------------------------------------------------------
--      procedure FileCloseWriteCovDb is
--      ------------------------------------------------------------
--      begin
--        WriteCovDbFileInit := FALSE ;
--        file_close( WriteCovDbFile );
--      end procedure FileCloseWriteCovDb ;

    ------------------------------------------------------------
    procedure SetReportOptions (
    ------------------------------------------------------------
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
-- Deprecated parameters.  Are ignored.
      WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
    ) is
    begin
      if WritePassFail /= COV_OPT_INIT_PARM_DETECT then
        WritePassFailVar   := IsEnabled(WritePassFail) ;
      end if ;
      if WriteBinInfo /= COV_OPT_INIT_PARM_DETECT then
        WriteBinInfoVar    := IsEnabled(WriteBinInfo) ;
      end if ;
      if WriteCount /= COV_OPT_INIT_PARM_DETECT then
        WriteCountVar      := IsEnabled(WriteCount) ;
      end if ;
      if WriteAnyIllegal /= COV_OPT_INIT_PARM_DETECT then
        WriteAnyIllegalVar := IsEnabled(WriteAnyIllegal) ;
      end if ;
      if WritePrefix /= OSVVM_STRING_INIT_PARM_DETECT then
--!!        WritePrefixVar.Set(WritePrefix) ;
        Alert(ALERTLOG_DEFAULT_ID, "OsvvmSettingsPkg.COVERAGE_PRINT_PREFIX replaced SetReportOptions(WritePrefix)", WARNING) ;  
      end if ;
      if PassName /= OSVVM_STRING_INIT_PARM_DETECT then
--!!        PassNameVar.Set(PassName) ;
        Alert(ALERTLOG_DEFAULT_ID, "OsvvmSettingsPkg.COVERAGE_PASS_NAME replaced SetReportOptions(PassName)", WARNING) ;  
      end if ;
      if FailName /= OSVVM_STRING_INIT_PARM_DETECT then
--!!        FailNameVar.Set(FailName) ;
        Alert(ALERTLOG_DEFAULT_ID, "OsvvmSettingsPkg.COVERAGE_FAIL_NAME replaced SetReportOptions(FailName)", WARNING) ;  
      end if ;
    end procedure SetReportOptions ;

    ------------------------------------------------------------
    procedure ResetReportOptions is
    ------------------------------------------------------------
    begin
      -- Globals - for all coverage models
      WritePassFailVar   := COVERAGE_WRITE_PASS_FAIL   ;
      WriteBinInfoVar    := COVERAGE_WRITE_BIN_INFO    ;
      WriteCountVar      := COVERAGE_WRITE_COUNT       ;
      WriteAnyIllegalVar := COVERAGE_WRITE_ANY_ILLEGAL ;
--!!      WritePrefixVar.deallocate ;
--!!      PassNameVar.deallocate ;
--!!      FailNameVar.deallocate ;
    end procedure ResetReportOptions ;


    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Coverage Model Settings
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    impure function IsInitialized (ID : CoverageIDType) return boolean is
    ------------------------------------------------------------
    begin
      if ID =  COVERAGE_ID_UNINITIALZED then 
        return FALSE ; 
      else 
        return CovStructPtr(ID.ID).NumBins > 0 ;
      end if ; 
    end function IsInitialized ;

    ------------------------------------------------------------
    procedure InitSeed (ID : CoverageIDType; S : string;    UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
    ------------------------------------------------------------
    begin
      if UseNewSeedMethods then
        CovStructPtr(ID.ID).RV := GenRandSeed(S) ;
      else
        CovStructPtr(ID.ID).RV := OldGenRandSeed(S) ;
      end if ;
      CovStructPtr(ID.ID).RvSeedInit := TRUE ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    impure function InitSeed (ID : CoverageIDType; S : string; UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) return string is
    ------------------------------------------------------------
    begin
      InitSeed(ID, S, UseNewSeedMethods) ;
      CovStructPtr(ID.ID).RvSeedInit := TRUE ;
      return S ;
    end function InitSeed ;

    ------------------------------------------------------------
    procedure InitSeed (ID : CoverageIDType; I : integer; UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) is
    ------------------------------------------------------------
    begin
      if UseNewSeedMethods then
        CovStructPtr(ID.ID).RV := GenRandSeed(I) ;
      else
        CovStructPtr(ID.ID).RV := OldGenRandSeed(I) ;
      end if ;
      CovStructPtr(ID.ID).RvSeedInit := TRUE ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    procedure SetSeed (ID : CoverageIDType; RandomSeedIn : RandomSeedType ) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).RV         := RandomSeedIn ;
      CovStructPtr(ID.ID).RvSeedInit := TRUE ;
    end procedure SetSeed ;

    ------------------------------------------------------------
    impure function GetSeed (ID : CoverageIDType) return RandomSeedType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).RV ;
    end function GetSeed ;

    ------------------------------------------------------------
    procedure SetName (ID : CoverageIDType; Name : String) is
    ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovName /= NULL then
        deallocate (CovStructPtr(ID.ID).CovName) ;
      end if;
      CovStructPtr(ID.ID).CovName := new string'(Name) ;

      -- Update if name updated after model created                      -- VendorCov
      if IsInitialized(ID) then                                          -- VendorCov
        VendorCovSetName(CovStructPtr(ID.ID).VendorCovHandle, Name) ;    -- VendorCov
      end if ;                                                           -- VendorCov

      -- Init seed if not already initialized
      if not CovStructPtr(ID.ID).RvSeedInit then
        InitSeed(ID, Name) ;
        CovStructPtr(ID.ID).RvSeedInit := TRUE ;
      end if ;
    end procedure SetName ;

    ------------------------------------------------------------
    impure function SetName (ID : CoverageIDType; Name : String) return string is
    ------------------------------------------------------------
    begin
      SetName(ID, Name) ; -- call procedure above
      return Name ;
    end function SetName ;

    ------------------------------------------------------------
    procedure DeallocateName (ID : CoverageIDType) is
    ------------------------------------------------------------
    begin
      Deallocate (CovStructPtr(ID.ID).CovName) ;
    end procedure DeallocateName ;

    ------------------------------------------------------------
    impure function GetName (ID : CoverageIDType) return String is
    ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovName /= NULL then
        return CovStructPtr(ID.ID).CovName.all ;
      else
        return "!!! CovName is NULL !!!" ;
      end if ;
    end function GetName ;

    ------------------------------------------------------------
    impure function GetCovModelName (ID : CoverageIDType) return String is
    ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovName /= NULL then
        -- return Name if set
        return CovStructPtr(ID.ID).CovName.all ;
      elsif CovStructPtr(ID.ID).AlertLogID /= OSVVM_COVERAGE_ALERTLOG_ID then
        -- otherwise return AlertLogName if it is set
        return GetAlertLogName(CovStructPtr(ID.ID).AlertLogID) ;
      elsif CovStructPtr(ID.ID).CovMessage /= NULL then
        -- otherwise Get the first word of the Message if it is set
        return GetWord(CovStructPtr(ID.ID).CovMessage.Name.all) ;
      else
        return "" ;
      end if ;
    end function GetCovModelName ;

    ------------------------------------------------------------
    -- Called in calls to AlertLogID to add Name to if set different from AlertLogID name
    impure function GetNamePlus(ID : CoverageIDType; prefix, suffix : string) return String is
    ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovName /= NULL and (CovStructPtr(ID.ID).CovName.all /= GetAlertLogName(CovStructPtr(ID.ID).AlertLogID)) then
        -- return Name if set
        return prefix & CovStructPtr(ID.ID).CovName.all & suffix ;
      elsif CovStructPtr(ID.ID).AlertLogID = OSVVM_COVERAGE_ALERTLOG_ID and CovStructPtr(ID.ID).CovMessage /= NULL then
        -- If AlertLogID not set, then use Message
        return prefix & GetWord(CovStructPtr(ID.ID).CovMessage.Name.all) & suffix ;
      else
        return "" ;
      end if ;
    end function GetNamePlus ;

    ------------------------------------------------------------
    -- PT Local
    impure function NewNamePtr(Name : string) return Line is
    ------------------------------------------------------------
    begin
      if Name /= "" then
        return new string'(Name) ;
      else
        return NULL ;
      end if;
    end function NewNamePtr ;

--    ------------------------------------------------------------
--    -- pt local
--    procedure CheckBinValLength(ID : CoverageIDType; CurBinValLength : integer ; Caller : string ) is
--    ------------------------------------------------------------
--    begin
--      if CovStructPtr(ID.ID).NumBins = 0 then
--        CovStructPtr(ID.ID).BinValLength := CurBinValLength ; -- number of points in cross
--      else
--        AlertIfNotEqual(CovStructPtr(ID.ID).AlertLogID, CovStructPtr(ID.ID).BinValLength, CurBinValLength, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg." & Caller & ":" &
--        " Cross coverage bins of different dimensions prohibited", FAILURE) ;
--      end if;
--    end procedure CheckBinValLength ;

    ------------------------------------------------------------
    -- pt local
    impure function BinValLengthNotEqual(CoverID : CoverageIDType; CurBinValLength : integer) return boolean is
    ------------------------------------------------------------
      constant ID : integer := CoverID.ID ;
    begin
      if CovStructPtr(ID).NumBins = 0 then
        CovStructPtr(ID).BinValLength   := CurBinValLength ;
        CovStructPtr(ID).TCoverValuePtr := new integer_vector(1 to CurBinValLength) ;
        return FALSE ;
      else
        return CurBinValLength /= CovStructPtr(ID).BinValLength ;
      end if;
    end function BinValLengthNotEqual ;

    ------------------------------------------------------------
    procedure SetItemBinNames (
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name1      : String ;
              Name2,  Name3,  Name4,  Name5,
      Name6,  Name7,  Name8,  Name9,  Name10,
      Name11, Name12, Name13, Name14, Name15,
      Name16, Name17, Name18, Name19, Name20 : string := ""
    ) is
      variable NamePtr : Line ;
      variable FieldNameArray : FieldNameArrayType(1 to 20) ;
      variable Dimensions : integer := 0 ;
    begin
      -- Support names for up to a cross of 20
      for CrossNum in 1 to 20 loop
        if CovStructPtr(ID.ID).FieldName /= NULL then
          for Field in 1 to CovStructPtr(ID.ID).FieldName'length loop
            deallocate (CovStructPtr(ID.ID).FieldName(Field)) ;
          end loop ;
          deallocate (CovStructPtr(ID.ID).FieldName) ;
        end if;
        case CrossNum is
          when  1 =>  NamePtr := NewNamePtr(Name1) ;
          when  2 =>  NamePtr := NewNamePtr(Name2) ;
          when  3 =>  NamePtr := NewNamePtr(Name3) ;
          when  4 =>  NamePtr := NewNamePtr(Name4) ;
          when  5 =>  NamePtr := NewNamePtr(Name5) ;
          when  6 =>  NamePtr := NewNamePtr(Name6) ;
          when  7 =>  NamePtr := NewNamePtr(Name7) ;
          when  8 =>  NamePtr := NewNamePtr(Name8) ;
          when  9 =>  NamePtr := NewNamePtr(Name9) ;
          when 10 =>  NamePtr := NewNamePtr(Name10) ;
          when 11 =>  NamePtr := NewNamePtr(Name11) ;
          when 12 =>  NamePtr := NewNamePtr(Name12) ;
          when 13 =>  NamePtr := NewNamePtr(Name13) ;
          when 14 =>  NamePtr := NewNamePtr(Name14) ;
          when 15 =>  NamePtr := NewNamePtr(Name15) ;
          when 16 =>  NamePtr := NewNamePtr(Name16) ;
          when 17 =>  NamePtr := NewNamePtr(Name17) ;
          when 18 =>  NamePtr := NewNamePtr(Name18) ;
          when 19 =>  NamePtr := NewNamePtr(Name19) ;
          when 20 =>  NamePtr := NewNamePtr(Name20) ;
        end case ;
        exit when NamePtr = NULL ;
        FieldNameArray(CrossNum) := NamePtr ;
        Dimensions := CrossNum ;
      end loop ;
      CovStructPtr(ID.ID).FieldName := new FieldNameArrayType'(FieldNameArray(1 to Dimensions)) ;
      -- Check that Dimensions match bin dimensions
      if BinValLengthNotEqual(ID, Dimensions) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.SetItemBinNames: Coverage bins of different dimensions prohibited", FAILURE) ;
      end if ;
    end procedure SetItemBinNames ;

    ------------------------------------------------------------
    procedure SetMessage (ID : CoverageIDType; Message : String) is
    ------------------------------------------------------------
    begin
      SetMessage(CovStructPtr(ID.ID).CovMessage, Message) ;
      -- VendorCov update if name updated after model created
      if IsInitialized(ID) then                                       -- VendorCov
        -- Refine this?   If CovName or AlertLogID is set,            -- VendorCov
        -- it may be set to the same name again.                      -- VendorCov
        VendorCovSetName(CovStructPtr(ID.ID).VendorCovHandle, GetCovModelName(ID)) ;   -- VendorCov
      end if ;                                                        -- VendorCov
      if not CovStructPtr(ID.ID).RvSeedInit then  -- Init seed if not initialized
        InitSeed(ID, Message) ;
        CovStructPtr(ID.ID).RvSeedInit := TRUE ;
      end if ;
    end procedure SetMessage ;

    ------------------------------------------------------------
    procedure DeallocateMessage (ID : CoverageIDType) is
    ------------------------------------------------------------
    begin
      DeallocateMessage(CovStructPtr(ID.ID).CovMessage) ;
    end procedure DeallocateMessage ;

    ------------------------------------------------------------
    procedure SetThresholding (ID : CoverageIDType; A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).ThresholdingEnable := A ;
    end procedure SetThresholding ;

    ------------------------------------------------------------
    procedure SetCovThreshold (ID : CoverageIDType; Percent : real) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).ThresholdingEnable := TRUE ;
      if Percent >= 0.0 then
        CovStructPtr(ID.ID).CovThreshold := Percent + 0.0001 ; -- used in less than
      else
        CovStructPtr(ID.ID).CovThreshold := 0.0001 ; -- used in less than
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.SetCovThreshold:" &
                      " Invalid Threshold Value " & real'image(Percent), FAILURE) ;
      end if ;
    end procedure SetCovThreshold ;

    ------------------------------------------------------------
    procedure SetCovTarget (ID : CoverageIDType; Percent : real) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).CovTarget := Percent ;
    end procedure SetCovTarget ;

    ------------------------------------------------------------
    impure function GetCovTarget (ID : CoverageIDType) return real is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovTarget ;
    end function GetCovTarget ;

    ------------------------------------------------------------
    procedure SetMerging (ID : CoverageIDType; A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).MergingEnable := A ;
    end procedure SetMerging ;

    ------------------------------------------------------------
    procedure SetCountMode (ID : CoverageIDType; A : CountModeType) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).CountMode := A ;
    end procedure SetCountMode ;

    ------------------------------------------------------------
    procedure SetAlertLogID (ID : CoverageIDType; A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).AlertLogID := A ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(ID : CoverageIDType; Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).AlertLogID := GetAlertLogID(Name, ParentID, CreateHierarchy) ;
      if not CovStructPtr(ID.ID).RvSeedInit then  -- Init seed if not initialized
        InitSeed(ID, Name) ;
        CovStructPtr(ID.ID).RvSeedInit := TRUE ;
      end if ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    impure function GetAlertLogID(ID : CoverageIDType) return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).AlertLogID ;
    end function GetAlertLogID ;

    ------------------------------------------------------------
    procedure SetNextPointMode (ID : CoverageIDType; A : NextPointModeType) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).NextPointMode := A ;
    end procedure SetNextPointMode ;

    ------------------------------------------------------------
    procedure SetIllegalMode (ID : CoverageIDType; A : IllegalModeType) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).IllegalMode := A ;
      if A = ILLEGAL_FAILURE then
        CovStructPtr(ID.ID).IllegalModeLevel := FAILURE ;
      else
        CovStructPtr(ID.ID).IllegalModeLevel := ERROR ;
      end if ;
    end procedure SetIllegalMode ;

    ------------------------------------------------------------
    procedure SetWeightMode (
    ------------------------------------------------------------
      ID          : CoverageIDType ; 
      WeightMode  : WeightModeType ; 
--!! Deprecated       
      WeightScale : real := 1.0
    ) is
--sig      variable buf : line ;
    begin
      CovStructPtr(ID.ID).WeightMode := WeightMode ;
      
--!! Remaining Deprecated
      CovStructPtr(ID.ID).WeightScale := WeightScale ;

      if (WeightMode = REMAIN_EXP) and (WeightScale > 2.0) then
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.SetWeightMode:" &
                      " WeightScale > 2.0 and large Counts can cause RandCovPoint to fail due to integer values out of range", WARNING) ;
      end if ;
      if (WeightScale < 1.0) and (WeightMode = REMAIN_WEIGHT or WeightMode = REMAIN_SCALED) then
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.SetWeightMode:" &
                      " WeightScale must be > 1.0 when WeightMode = REMAIN_WEIGHT or WeightMode = REMAIN_SCALED", FAILURE) ;
        CovStructPtr(ID.ID).WeightScale := 1.0 ;
      end if;
      if WeightScale <= 0.0 then
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.SetWeightMode:" &
                      " WeightScale must be > 0.0", FAILURE) ;
        CovStructPtr(ID.ID).WeightScale := 1.0 ;
      end if;
    end procedure SetWeightMode ;

    ------------------------------------------------------------
    procedure SetCovWeight (ID : CoverageIDType; Weight : integer) is
    ------------------------------------------------------------
    begin
      CovStructPtr(ID.ID).CovWeight := Weight ;
    end procedure SetCovWeight ;

    ------------------------------------------------------------
    impure function GetCovWeight (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovWeight ;
    end function GetCovWeight ;

    ------------------------------------------------------------
    procedure SetBinSize (ID : CoverageIDType; NewNumBins : integer) is
    -- Sets a CovBin to a particular size
    -- Use for small bins to save space or large bins to
    -- suppress the resize and copy as a CovBin autosizes.
    ------------------------------------------------------------
      variable oldCovBinPtr : CovBinPtrType ;
    begin
      if CovStructPtr(ID.ID).CovBinPtr = NULL then
        CovStructPtr(ID.ID).CovBinPtr := new CovBinInternalType(1 to NewNumBins) ;
      elsif NewNumBins > CovStructPtr(ID.ID).CovBinPtr'length then
        -- make message bigger
        oldCovBinPtr := CovStructPtr(ID.ID).CovBinPtr ;
        CovStructPtr(ID.ID).CovBinPtr := new CovBinInternalType(1 to NewNumBins) ;
        CovStructPtr(ID.ID).CovBinPtr.all(1 to CovStructPtr(ID.ID).NumBins) := oldCovBinPtr.all(1 to CovStructPtr(ID.ID).NumBins) ;
        deallocate(oldCovBinPtr) ;
      end if ;
    end procedure SetBinSize ;

    ------------------------------------------------------------
    --  pt local
    impure function NormalizeNumBins(ID : CoverageIDType; ReqNumBins : integer ) return integer is
      variable NormNumBins : integer := MIN_NUM_BINS ;
    begin
      while NormNumBins < ReqNumBins loop
        NormNumBins := NormNumBins + MIN_NUM_BINS ;
      end loop ;
      return NormNumBins ;
    end function NormalizeNumBins ;

    ------------------------------------------------------------
    --  pt local
    procedure GrowBins (ID : CoverageIDType; ReqNumBins : integer) is
      variable oldCovBinPtr : CovBinPtrType ;
      variable NewNumBins   : integer ;
    begin
      NewNumBins := CovStructPtr(ID.ID).NumBins + ReqNumBins ;
      if CovStructPtr(ID.ID).CovBinPtr = NULL then
        CovStructPtr(ID.ID).CovBinPtr := new CovBinInternalType(1 to NormalizeNumBins(ID, NewNumBins)) ;
      elsif NewNumBins > CovStructPtr(ID.ID).CovBinPtr'length then
        -- make message bigger
        oldCovBinPtr := CovStructPtr(ID.ID).CovBinPtr ;
        CovStructPtr(ID.ID).CovBinPtr := new CovBinInternalType(1 to NormalizeNumBins(ID, NewNumBins)) ;
        CovStructPtr(ID.ID).CovBinPtr.all(1 to CovStructPtr(ID.ID).NumBins) := oldCovBinPtr.all(1 to CovStructPtr(ID.ID).NumBins) ;
        deallocate(oldCovBinPtr) ;
      end if ;
    end procedure GrowBins ;

    ------------------------------------------------------------
    --  pt local, called by InsertBin
    -- Finds index of bin if it is inside an existing bins
    procedure FindBinInside(
      ID           : CoverageIDType ;
      BinVal       : RangeArrayType ;
      Position     : out integer ;
      FoundInside  : out boolean
    ) is
    begin
      Position     := CovStructPtr(ID.ID).NumBins + 1 ;
      FoundInside  := FALSE ;
      FindLoop : for i in CovStructPtr(ID.ID).NumBins downto 1 loop
        -- skip this CovBin if CovPoint is not in it
        next FindLoop when not inside(BinVal, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;
        Position := i ;
        FoundInside := TRUE ;
        exit ;
      end loop ;
    end procedure FindBinInside ;

    ------------------------------------------------------------
    --  pt local
    -- Inserts values into a new bin.
    -- Called by InsertBin
    procedure InsertNewBin(
      ID           : CoverageIDType ;
      BinVal       : RangeArrayType ;
      Action       : integer ;
      Count        : integer ;
      AtLeast      : integer ;
      Weight       : integer ;
      Name         : string ;
      PercentCov   : real
    ) is
    begin
      if (not IsInitialized(ID)) then                                                              -- VendorCov
        if (BinVal'length > 1) then  -- Cross Bin                                              -- VendorCov
          CovStructPtr(ID.ID).VendorCovHandle := VendorCovCrossCreate(GetCovModelName(ID)) ;                            -- VendorCov
        else                                                                                   -- VendorCov
          CovStructPtr(ID.ID).VendorCovHandle := VendorCovPointCreate(GetCovModelName(ID));                             -- VendorCov
      	end if;                                                                                -- VendorCov
      end if;                                                                                  -- VendorCov
      VendorCovBinAdd(CovStructPtr(ID.ID).VendorCovHandle, ToVendorCovBinVal(BinVal), Action, AtLeast, Name) ;  -- VendorCov
      CovStructPtr(ID.ID).NumBins := CovStructPtr(ID.ID).NumBins + 1 ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).BinVal      := new RangeArrayType'(BinVal) ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).Action      := Action ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).Count       := Count ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).AtLeast     := AtLeast ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).Weight      := Weight ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).Name        := new String'(Name) ;
      CovStructPtr(ID.ID).CovBinPtr.all(CovStructPtr(ID.ID).NumBins).PercentCov  := PercentCov ;
    end procedure InsertNewBin ;

    ------------------------------------------------------------
    --  pt local
    -- Inserts values into a new bin.
    -- Called by InsertBin
    procedure MergeBin (
      ID           : CoverageIDType ;
      Position     : Natural ;
      Count        : integer ;
      AtLeast      : integer ;
      Weight       : integer
    ) is
    begin
      CovStructPtr(ID.ID).CovBinPtr.all(Position).Count   := CovStructPtr(ID.ID).CovBinPtr.all(Position).Count + Count ;
      CovStructPtr(ID.ID).CovBinPtr.all(Position).AtLeast := CovStructPtr(ID.ID).CovBinPtr.all(Position).AtLeast + AtLeast ;
      CovStructPtr(ID.ID).CovBinPtr.all(Position).Weight  := CovStructPtr(ID.ID).CovBinPtr.all(Position).Weight + Weight ;
      CovStructPtr(ID.ID).CovBinPtr.all(Position).PercentCov := CalcPercentCov(
        Count => CovStructPtr(ID.ID).CovBinPtr.all(Position).Count,
        AtLeast =>  CovStructPtr(ID.ID).CovBinPtr.all(Position).AtLeast ) ;
    end procedure MergeBin ;

    ------------------------------------------------------------
    --  pt local
    -- All insertion comes here
    -- Enforces the general insertion use model:
    --   Earlier bins supercede later bins - except with COUNT_ALL
    --   Add Illegal and Ignore bins first to remove regions of larger count bins
    --   Later ignore bins can be used to miss an illegal catch-all
    --   Add Illegal bins last as a catch-all to find things that missed other bins
    procedure InsertBin(
      ID           : CoverageIDType ;
      BinVal       : RangeArrayType ;
      Action       : integer ;
      Count        : integer ;
      AtLeast      : integer ;
      Weight       : integer ;
      Name         : string
    ) is
      variable Position    : integer ;
      variable FoundInside : boolean ;
      variable PercentCov  : real ;
    begin
      PercentCov := CalcPercentCov(Count => Count,  AtLeast =>  AtLeast) ;

      if not CovStructPtr(ID.ID).MergingEnable then
        InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, Name, PercentCov) ;

      else -- handle merging
-- future optimization, FindBinInside only checks against Ignore and Illegal bins
        FindBinInside(ID, BinVal, Position, FoundInside) ;

        if not FoundInside then
          InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, Name, PercentCov) ;

        elsif Action = COV_COUNT then
-- when check only ignore and illegal bins, only action is to drop
          if CovStructPtr(ID.ID).CovBinPtr.all(Position).Action /= COV_COUNT then
            null ; -- drop count bin when it is inside a Illegal or Ignore bin

          elsif CovStructPtr(ID.ID).CovBinPtr.all(Position).BinVal.all = BinVal and CovStructPtr(ID.ID).CovBinPtr.all(Position).Name.all = Name then
            -- Bins match, so merge the count values
            MergeBin (ID, Position, Count, AtLeast, Weight) ;
          else
            -- Bins overlap, but do not match, insert new bin
            InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, Name, PercentCov) ;
          end if;

        elsif Action = COV_IGNORE then
-- when check only ignore and illegal bins, only action is to log
          if CovStructPtr(ID.ID).CovBinPtr.all(Position).Action = COV_COUNT then
            InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, Name, PercentCov) ;
          else
            -- Drop the ignore bin it is redundant
            log(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.InsertBin (AddBins/AddCross):" &
                          " ignore bin " & to_string(BinVal) & " dropped.  It is a subset of prior bin", DEBUG) ;
          end if;

        elsif Action = COV_ILLEGAL then
-- when check only ignore and illegal bins, only action is to log 
          if CovStructPtr(ID.ID).CovBinPtr.all(Position).Action = COV_COUNT then
            InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, Name, PercentCov) ;
          else
            -- Drop the illegal bin it is redundant
            log(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.InsertBin (AddBins/AddCross):" &
                          " illegal bin " & to_string(BinVal) & " dropped.  It is a subset of prior bin", DEBUG) ;
          end if;
        end if ;
      end if ; -- merging enabled
    end procedure InsertBin ;

    ------------------------------------------------------------
    procedure AddBins (
    ------------------------------------------------------------
      ID      : CoverageIDType ;
      Name    : String ;
      AtLeast : integer ;
      Weight  : integer ;
      CovBin  : CovBinType
    ) is
      variable vCalcAtLeast : integer ;
      variable vCalcWeight  : integer ;
    begin
      if BinValLengthNotEqual(ID, 1) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddBins: Coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;

      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        if CovBin(i).Action = COV_COUNT then
          vCalcAtLeast := maximum(AtLeast, CovBin(i).AtLeast) ;
          vCalcWeight  := maximum(Weight, CovBin(i).Weight) ;
        else
          vCalcAtLeast := 0 ;
          vCalcWeight  := 0 ;
        end if ;
        InsertBin(
          ID       => ID,
          BinVal   => CovBin(i).BinVal,
          Action   => CovBin(i).Action,
          Count    => CovBin(i).Count,
          AtLeast  => vCalcAtLeast,
          Weight   => vCalcWeight,
          Name     => Name
        ) ;
      end loop ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (ID : CoverageIDType; Name : String ; AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins(ID, Name, AtLeast, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (ID : CoverageIDType; Name : String ;  CovBin : CovBinType) is
    ------------------------------------------------------------
    begin
      AddBins(ID, Name, 1, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (ID : CoverageIDType; AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins(ID, "", AtLeast, Weight, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (ID : CoverageIDType; AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins(ID, "", AtLeast, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (ID : CoverageIDType; CovBin : CovBinType  ) is
    ------------------------------------------------------------
    begin
      AddBins(ID, "", 1, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
      constant BIN_LENS : integer_vector :=
          BinLengths(
             Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
             Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
           ) ;
      constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
      variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
      variable CrossBins    : CovBinType(BinIndex'range) ;
      variable vCalcAction, vCalcCount, vCalcAtLeast, vCalcWeight : integer ;
      variable vCalcBinVal   : RangeArrayType(BinIndex'range) ;
    begin
      if BinValLengthNotEqual(ID, BIN_LENS'length) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;

      GrowBins(ID, NUM_NEW_BINS) ;
      vCalcCount := 0 ;
      for MatrixIndex in 1 to NUM_NEW_BINS loop
        CrossBins := ConcatenateBins(BinIndex,
             Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
             Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
           ) ;
        vCalcAction   := MergeState (CrossBins) ;
        vCalcBinVal   := MergeBinVal(CrossBins) ;
        vCalcAtLeast  := MergeAtLeast( vCalcAction, AtLeast, CrossBins) ;
        vCalcWeight   := MergeWeight ( vCalcAction, Weight,  CrossBins) ;
        InsertBin(ID, vCalcBinVal, vCalcAction, vCalcCount, vCalcAtLeast, vCalcWeight, Name) ;
        IncBinIndex( BinIndex, BIN_LENS) ; -- increment right most one, then if overflow, increment next
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(ID, Name, AtLeast, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Name       : string ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(ID, Name, 1, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(ID, "", AtLeast, Weight,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(ID, "", AtLeast, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      ID         : CoverageIDType ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(ID, "", 1, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure DeallocateBins(CoverID : CoverageIDType) is
    ------------------------------------------------------------
      constant Index   : integer := CoverID.ID ;
    begin
      -- Local for a particular CoverageModel
      if CovStructPtr(Index).CovBinPtr /= NULL then
        for i in 1 to CovStructPtr(Index).NumBins loop
          deallocate(CovStructPtr(Index).CovBinPtr(i).BinVal) ;
          deallocate(CovStructPtr(Index).CovBinPtr(i).Name) ;
        end loop ;
        deallocate(CovStructPtr(Index).CovBinPtr) ;
      end if ;
      CovStructPtr(Index).NumBins := 0 ;
    end procedure DeallocateBins ;

    ------------------------------------------------------------
    procedure Deallocate(ID : CoverageIDType) is
    ------------------------------------------------------------
      constant Index   : integer := ID.ID ;
    begin
--!!?? These are only done when removing all coverage models.
--      -- Globals - for all coverage models
--      WritePassFailVar   := COV_OPT_INIT_PARM_DETECT ;
--      WriteBinInfoVar    := COV_OPT_INIT_PARM_DETECT ;
--      WriteCountVar      := COV_OPT_INIT_PARM_DETECT ;
--      WriteAnyIllegalVar := COV_OPT_INIT_PARM_DETECT ;
--      WritePrefixVar.deallocate ;
--      PassNameVar.deallocate ;
--      FailNameVar.deallocate ;
      DeallocateBins(ID) ;
      DeallocateName(ID) ;
      DeallocateMessage(ID) ;
      -- Restore internal variables to their default values
--      CovStructPtr(Index) := COV_STRUCT_INIT ;

      CovStructPtr(Index).BinValLength       := 1 ;
      CovStructPtr(Index).VendorCovHandle    := INIT_VENDOR_COV_HANDLE ;
      CovStructPtr(Index).ItemCount          := 0 ;
      CovStructPtr(Index).LastIndex          := 1 ;
      CovStructPtr(Index).LastStimGenIndex   := 1 ;

      -- Changing these is beyond what deallocate should do.
      CovStructPtr(Index).NextPointMode      := RANDOM ;
      CovStructPtr(Index).IllegalMode        := ILLEGAL_ON ;
      CovStructPtr(Index).IllegalModeLevel   := ERROR ;
      CovStructPtr(Index).WeightMode         := DEFAULT_WEIGHT_MODE ;
      CovStructPtr(Index).WeightScale        := 1.0 ;
      CovStructPtr(Index).ThresholdingEnable := FALSE ;
      CovStructPtr(Index).CovThreshold       := 45.0 ;
      CovStructPtr(Index).CovTarget          := 100.0 ;
      CovStructPtr(Index).MergingEnable      := FALSE ;
      CovStructPtr(Index).CountMode          := COUNT_FIRST ;
--      CovStructPtr(Index).RV                 := (1, 7) ;
--      CovStructPtr(Index).RvSeedInit         := FALSE ;
--      CovStructPtr(Index).AlertLogID         := OSVVM_COVERAGE_ALERTLOG_ID ;

    end procedure deallocate ;

    ------------------------------------------------------------
    -- Local
    procedure ICoverIndex(ID : CoverageIDType; Index : integer ; CovPoint : integer_vector ) is
    ------------------------------------------------------------
      variable buf : line ;
    begin
      -- Update Count, PercentCov
      CovStructPtr(ID.ID).CovBinPtr(Index).Count := CovStructPtr(ID.ID).CovBinPtr(Index).Count + CovStructPtr(ID.ID).CovBinPtr(Index).action ;
      VendorCovBinInc(CovStructPtr(ID.ID).VendorCovHandle, Index);   -- VendorCov
      CovStructPtr(ID.ID).CovBinPtr(Index).PercentCov := CalcPercentCov(
          Count => CovStructPtr(ID.ID).CovBinPtr.all(Index).Count,
          AtLeast =>  CovStructPtr(ID.ID).CovBinPtr.all(Index).AtLeast
        ) ;
      if CovStructPtr(ID.ID).CovBinPtr(Index).action = COV_ILLEGAL then
        if CovStructPtr(ID.ID).IllegalMode /= ILLEGAL_OFF then
--          if CovPoint = NULL_INTV then
          if CovPoint'length = 0 then
            alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.ICoverLast:" &
                          " Value randomized is in an illegal bin.", CovStructPtr(ID.ID).IllegalModeLevel) ;
          else
            write(buf, CovPoint) ;
            alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.ICover:" &
                          " Value " & buf.all & " is in an illegal bin.", CovStructPtr(ID.ID).IllegalModeLevel) ;
            deallocate(buf) ;
          end if ;
        else
          IncAlertCount(CovStructPtr(ID.ID).AlertLogID, ERROR) ; -- silent alert.
        end if ;
      end if ;
    end procedure ICoverIndex ;

    ------------------------------------------------------------
    procedure ICoverLast (ID : CoverageIDType) is
    ------------------------------------------------------------
    begin
     ICoverIndex(ID, CovStructPtr(ID.ID).LastStimGenIndex, NULL_INTV) ;
    end procedure ICoverLast ;

    ------------------------------------------------------------
    procedure ICover(ID : CoverageIDType; CovPoint : integer_vector) is
    ------------------------------------------------------------
    begin
      if CovPoint'length /= CovStructPtr(ID.ID).BinValLength then
        -- Fatal:  Bin size mismatch 
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg." &
        " ICover: CovPoint length = " & to_string(CovPoint'length) &
        "  does not match Coverage Bin dimensions = " & to_string(CovStructPtr(ID.ID).BinValLength), FAILURE) ;
      elsif CovStructPtr(ID.ID).CountMode = COUNT_FIRST and inside(CovPoint, CovStructPtr(ID.ID).CovBinPtr(CovStructPtr(ID.ID).LastStimGenIndex).BinVal.all) then
        -- Found point in CovStructPtr(ID.ID).LastStimGenIndex 
        ICoverIndex(ID, CovStructPtr(ID.ID).LastStimGenIndex, CovPoint) ;
      else
        -- Search for bin
        CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
          next CovLoop when not inside(CovPoint, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;  -- skip if not found
          CovStructPtr(ID.ID).LastIndex := i ;                              -- Mark found index
          ICoverIndex(ID, i, CovPoint) ;                                    -- Mark Covered
          exit CovLoop when CovStructPtr(ID.ID).CountMode = COUNT_FIRST ;   -- Find additional if not COUNT_FIRST
        end loop CovLoop ;
      end if ;
     end procedure ICover ;

    ------------------------------------------------------------
    procedure ICover (ID : CoverageIDType; CovPoint : integer) is
    ------------------------------------------------------------
    begin
     ICover(ID, (1=> CovPoint)) ;
    end procedure ICover ;

    ------------------------------------------------------------
    procedure TCover (ID : CoverageIDType; A : integer) is
    ------------------------------------------------------------
      constant CoverID : integer := ID.ID ;
    begin
      CovStructPtr(CoverID).TCoverCount        := CovStructPtr(CoverID).TCoverCount + 1 ;
      CovStructPtr(CoverID).TCoverValuePtr.all := CovStructPtr(CoverID).TCoverValuePtr.all(2 to CovStructPtr(CoverID).BinValLength) & A ;
      if (CovStructPtr(CoverID).TCoverCount >= CovStructPtr(CoverID).BinValLength) then
        ICover(ID, CovStructPtr(CoverID).TCoverValuePtr.all) ;
      end if ;
    end procedure TCover ;

    ------------------------------------------------------------
    impure function FindBinIndex(ID : CoverageIDType; CovPoint : integer_vector; StartingIndex : integer := 1) return integer is
    ------------------------------------------------------------
    begin
      if CovPoint'length /= CovStructPtr(ID.ID).BinValLength then
        -- Fatal:  Bin size mismatch 
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg." &
        " FindBinIndex: CovPoint length = " & to_string(CovPoint'length) &
        "  does not match Coverage Bin dimensions = " & to_string(CovStructPtr(ID.ID).BinValLength), FAILURE) ;
        return -1 ; 
      elsif CovStructPtr(ID.ID).CountMode = COUNT_FIRST and inside(CovPoint, CovStructPtr(ID.ID).CovBinPtr(CovStructPtr(ID.ID).LastStimGenIndex).BinVal.all) then
        -- Found point in CovStructPtr(ID.ID).LastStimGenIndex 
        return CovStructPtr(ID.ID).LastStimGenIndex ;
      else
        -- Search for bin
        CovLoop : for i in StartingIndex to CovStructPtr(ID.ID).NumBins loop
          next CovLoop when not inside(CovPoint, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ; -- skip if not found
          return i ; 
        end loop CovLoop ;
        return 0 ; 
      end if ;
     end function FindBinIndex ;
     
    ------------------------------------------------------------
    procedure ClearCov (ID : CoverageIDType) is
    ------------------------------------------------------------
    begin
      for i in 1 to CovStructPtr(ID.ID).NumBins loop
        CovStructPtr(ID.ID).CovBinPtr(i).Count := 0 ;
        CovStructPtr(ID.ID).CovBinPtr(i).PercentCov := CalcPercentCov(
          Count => CovStructPtr(ID.ID).CovBinPtr.all(i).Count,
          AtLeast =>  CovStructPtr(ID.ID).CovBinPtr.all(i).AtLeast ) ;
      end loop ;
    end procedure ClearCov ;

    ------------------------------------------------------------
    impure function GetMinCov (ID : CoverageIDType) return real is
    ------------------------------------------------------------
      variable MinCov : real := real'right ;  -- big number
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < MinCov then
          MinCov := CovStructPtr(ID.ID).CovBinPtr(i).PercentCov ;
        end if ;
      end loop CovLoop ;
      return MinCov ;
    end function GetMinCov ;

    ------------------------------------------------------------
    impure function GetMinCount (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable MinCount : integer := integer'high ;  -- big number
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < MinCount then
          MinCount := CovStructPtr(ID.ID).CovBinPtr(i).Count ;
        end if ;
      end loop CovLoop ;
      return MinCount ;
    end function GetMinCount ;

    ------------------------------------------------------------
    impure function GetMaxCov (ID : CoverageIDType) return real is
    ------------------------------------------------------------
      variable MaxCov : real := 0.0 ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov > MaxCov then
          MaxCov := CovStructPtr(ID.ID).CovBinPtr(i).PercentCov ;
        end if ;
      end loop CovLoop ;
      return MaxCov ;
    end function GetMaxCov ;

    ------------------------------------------------------------
    impure function GetMaxCount (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable MaxCount : integer := 0 ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count > MaxCount then
          MaxCount := CovStructPtr(ID.ID).CovBinPtr(i).Count ;
        end if ;
      end loop CovLoop ;
      return MaxCount ;
    end function GetMaxCount ;

    ------------------------------------------------------------
    impure function CountCovHoles (ID : CoverageIDType; PercentCov : real ) return integer is
    ------------------------------------------------------------
      variable HoleCount : integer := 0 ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < PercentCov then
          HoleCount := HoleCount + 1 ;
        end if ;
      end loop CovLoop ;
      return HoleCount ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    impure function IsBinCovered (ID : CoverageIDType; BinIndex : integer ; PercentCov : real ) return boolean is
    ------------------------------------------------------------
    begin
      if (CovStructPtr(ID.ID).CovBinPtr(BinIndex).action = COV_COUNT) then
        return CovStructPtr(ID.ID).CovBinPtr(BinIndex).PercentCov >= PercentCov ;
      else
        return false;
      end if;
    end function IsBinCovered ;

    ------------------------------------------------------------
    impure function IsBinCovered (ID : CoverageIDType; BinIndex : integer  ) return boolean is
    ------------------------------------------------------------
    begin
      return IsBinCovered(ID, BinIndex, CovStructPtr(ID.ID).CovTarget) ;
    end function IsBinCovered ;

    ------------------------------------------------------------
    impure function CountCovHoles (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return CountCovHoles(ID, CovStructPtr(ID.ID).CovTarget) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    impure function IsCovered (ID : CoverageIDType; PercentCov : real ) return boolean is
    ------------------------------------------------------------
      variable HasACountBin : boolean := FALSE ; 
    begin
      -- return false ASAP - like a short-circuit operation
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT then
          if CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < PercentCov then
            return FALSE ; 
          end if ; 
          HasACountBin := TRUE ; 
        end if ;
      end loop CovLoop ; 
      -- if has at least one count bin return TRUE otherwise returns FALSE (model not initalized?)
      return HasACountBin ; 
    end function IsCovered ;

    ------------------------------------------------------------
    impure function IsCovered (ID : CoverageIDType) return boolean is
    ------------------------------------------------------------
    begin
      return IsCovered(ID, CovStructPtr(ID.ID).CovTarget) ; 
    end function IsCovered ;

    ------------------------------------------------------------
    impure function AllCovered (PercentCov : real ) return boolean is
    -- All Coverage models Covered in the singleton.  Not for PT
    ------------------------------------------------------------
      variable AllCov : boolean := FALSE ; 
    begin
      if NumItems > 0 then
        -- Is a singleton 
        for i in 1 to NumItems loop
          AllCov := IsCovered(CoverageIDType'(ID => i), PercentCov) ; 
          exit when not AllCov ; 
        end loop ;
        return AllCov ; 
      else
        -- singleton not initialized.  Return FALSE.
        alert(OSVVM_COVERAGE_ALERTLOG_ID, "AllCovered: Coverage model is either a PT or not initialized") ;
        return FALSE ; 
      end if ;
    end function AllCovered ;
    
    ------------------------------------------------------------
    impure function AllCovered return boolean is
    -- All Coverage models Covered in the singleton.  Not for PT
    ------------------------------------------------------------
      variable AllCov : boolean := FALSE ; 
    begin
      if NumItems > 0 then
        -- Is a singleton 
        for i in 1 to NumItems loop
          AllCov := IsCovered(CoverageIDType'(ID => i)) ; 
          exit when not AllCov ; 
        end loop ;
        return AllCov ; 
      else
        -- singleton not initialized.  Return FALSE.
        alert(OSVVM_COVERAGE_ALERTLOG_ID, "AllCovered: Coverage model is either a PT or not initialized") ;
        return FALSE ; 
      end if ;
    end function AllCovered ;
    
    ------------------------------------------------------------
    procedure GetTotalCovCountAndGoal (ID : CoverageIDType; PercentCov : real; TotalCovCount : out integer; TotalCovGoal : out integer ) is
    ------------------------------------------------------------
      variable ScaledCovGoal : integer := 0 ;
    begin
      TotalCovCount := 0 ;
      TotalCovGoal  := 0 ;
      BinLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT then
          ScaledCovGoal := integer(ceil(PercentCov * real(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)/100.0)) ;
          TotalCovGoal := TotalCovGoal + ScaledCovGoal ;
          if CovStructPtr(ID.ID).CovBinPtr(i).Count <= ScaledCovGoal then
            TotalCovCount := TotalCovCount + CovStructPtr(ID.ID).CovBinPtr(i).Count ;
          else
            -- do not count the extra values that exceed their cov goal
            TotalCovCount := TotalCovCount + ScaledCovGoal ;
          end if ;
        end if ;
      end loop BinLoop ;
    end procedure GetTotalCovCountAndGoal ;

    ------------------------------------------------------------
    procedure GetTotalCovCountAndGoal (ID : CoverageIDType; TotalCovCount : out integer; TotalCovGoal : out integer ) is
    ------------------------------------------------------------
    begin
      GetTotalCovCountAndGoal(ID, CovStructPtr(ID.ID).CovTarget, TotalCovCount, TotalCovGoal) ;
    end procedure GetTotalCovCountAndGoal ;

    ------------------------------------------------------------
    impure function GetCov (ID : CoverageIDType; PercentCov : real ) return real is
    ------------------------------------------------------------
      variable TotalCovCount, TotalCovGoal : integer ;
    begin
      GetTotalCovCountAndGoal(ID, PercentCov, TotalCovCount, TotalCovGoal) ;
      if TotalCovGoal > 0 then
        return 100.0 * real(TotalCovCount) / real(TotalCovGoal) ;
      else
        return 0.0 ;
      end if ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetCov (ID : CoverageIDType) return real is
    ------------------------------------------------------------
    begin
      return GetCov(ID, CovStructPtr(ID.ID).CovTarget ) ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetTotalCovCount (ID : CoverageIDType; PercentCov : real ) return integer is
    ------------------------------------------------------------
      variable TotalCovCount, TotalCovGoal : integer ;
    begin
      GetTotalCovCountAndGoal(ID, PercentCov, TotalCovCount, TotalCovGoal) ;
      return TotalCovCount ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovCount (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovCount(ID, CovStructPtr(ID.ID).CovTarget) ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal (ID : CoverageIDType; PercentCov : real ) return integer is
    ------------------------------------------------------------
      variable TotalCovCount, TotalCovGoal : integer ;
    begin
      GetTotalCovCountAndGoal(ID, PercentCov, TotalCovCount, TotalCovGoal) ;
      return TotalCovGoal ;
    end function GetTotalCovGoal ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovGoal(ID, CovStructPtr(ID.ID).CovTarget) ;
    end function GetTotalCovGoal ;

    ------------------------------------------------------------
    impure function GetItemCount (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).ItemCount ;
    end function GetItemCount ;

    -- Return Index Values
    ------------------------------------------------------------
    impure function GetNumBins (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).NumBins ;
    end function GetNumBins ;

    ------------------------------------------------------------
    impure function GetLastIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).LastIndex ;
    end function GetLastIndex ;

    ------------------------------------------------------------
    impure function CalcWeight (ID : CoverageIDType; BinIndex : integer ; MaxCovPercent : real  ) return integer is
    --  pt local
    ------------------------------------------------------------
    begin
      case CovStructPtr(ID.ID).WeightMode is
        when AT_LEAST =>    -- AtLeast
          return CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast ;

        when REMAIN =>       -- (Adjust * AtLeast) - Count
--?? simpler integer( Ceil (MaxCovPercent - CovStructPtr(ID.ID).CovBinPtr(BinIndex).PercentCov)) * CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast
          return integer( Ceil( MaxCovPercent * real(CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast)/100.0)) -
                          CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ;

-- ?? Deprecated??
        when WEIGHT =>       -- Weight
          return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight ;

--!!
--!! Remaining are deprecated
--!! 

        when REMAIN_EXP =>       -- Weight * (REMAIN **WeightScale)
          -- Experimental may be removed
-- CAUTION:  for large numbers and/or WeightScale > 2.0, result can be > 2**31 (max integer value)
          -- both Weight and WeightScale default to 1
            return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight *
                    integer( Ceil (
                      ( (MaxCovPercent * real(CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast)/100.0) -
                            real(CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count) ) ** CovStructPtr(ID.ID).WeightScale ) );

        when REMAIN_SCALED =>   -- (WeightScale * Adjust * AtLeast) - Count
          -- Experimental may be removed
          -- Biases remainder toward AT_LEAST value.
          -- WeightScale must be > 1.0
          return integer( Ceil( CovStructPtr(ID.ID).WeightScale * MaxCovPercent * real(CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast)/100.0)) -
                          CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ;

        when REMAIN_WEIGHT =>     -- Weight * ((WeightScale * Adjust * AtLeast) - Count)
          -- Experimental may be removed
          -- WeightScale must be > 1.0
          return   CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight * (
                   integer( Ceil( CovStructPtr(ID.ID).WeightScale * MaxCovPercent * real(CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast)/100.0)) -
                            CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count) ;

      end case ;
    end function CalcWeight ;

    ------------------------------------------------------------
    impure function GetRandIndex (ID : CoverageIDType; CovTargetPercent : real ) return integer is
    ------------------------------------------------------------
      variable WeightVec : integer_vector(0 to CovStructPtr(ID.ID).NumBins-1) ;  
      variable MaxCovPercent : real ;
      variable MinCovPercent : real ;
      variable rInt : integer ;
    begin
      CovStructPtr(ID.ID).ItemCount := CovStructPtr(ID.ID).ItemCount + 1 ;
      MinCovPercent := GetMinCov(ID) ;
      if CovStructPtr(ID.ID).ThresholdingEnable then
        MaxCovPercent := MinCovPercent + CovStructPtr(ID.ID).CovThreshold ;
        if MinCovPercent < CovTargetPercent then
          -- Clip at CovTargetPercent until reach CovTargetPercent
          MaxCovPercent := minimum(MaxCovPercent, CovTargetPercent);
        end if ;
      else
        if MinCovPercent < CovTargetPercent then
          MaxCovPercent := CovTargetPercent ;
        else
-- Determines what is done after IsCovered is true.
          -- Done, Enable all bins
          MaxCovPercent := GetMaxCov(ID) + 1.0 ;
          -- MaxCovPercent := real'right ;  -- weight scale issues
        end if ;
      end if ;
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < MaxCovPercent then
          -- Calculate Weight based on CovStructPtr(ID.ID).WeightMode
          --   Scale to current percentage goal:  MaxCov which can be < or > 100.0
          WeightVec(i-1) := CalcWeight(ID, i, MaxCovPercent) ;
        else
          WeightVec(i-1) := 0 ;
        end if ;
      end loop CovLoop ;
      -- DistInt returns integer range 0 to CovStructPtr(ID.ID).NumBins-1
      -- Caution:  DistInt can fail when sum(WeightVec) > 2**31
      --           See notes in CalcWeight for REMAIN_EXP
--      CovStructPtr(ID.ID).LastStimGenIndex := 1 + RV.DistInt( WeightVec )  ; -- return range 1 to CovStructPtr(ID.ID).NumBins
      DistInt(CovStructPtr(ID.ID).RV, rInt, WeightVec) ;
      CovStructPtr(ID.ID).LastStimGenIndex := 1 + rInt  ; -- return range 1 to CovStructPtr(ID.ID).NumBins
      CovStructPtr(ID.ID).LastIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      return CovStructPtr(ID.ID).LastStimGenIndex ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetRandIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetRandIndex(ID, CovStructPtr(ID.ID).CovTarget) ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetIncIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable CurIndex : integer ;
    begin
      CurIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      CovStructPtr(ID.ID).LastStimGenIndex := (CovStructPtr(ID.ID).LastStimGenIndex mod CovStructPtr(ID.ID).NumBins) + 1 ;
      CovStructPtr(ID.ID).LastIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      return CurIndex ;
    end function GetIncIndex ;

    ------------------------------------------------------------
    impure function GetMinIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable MinCov : real := real'right ;  -- big number
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < MinCov then
          MinCov := CovStructPtr(ID.ID).CovBinPtr(i).PercentCov ;
          CovStructPtr(ID.ID).LastStimGenIndex := i ;
        end if ;
      end loop CovLoop ;
      CovStructPtr(ID.ID).LastIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      return CovStructPtr(ID.ID).LastStimGenIndex ;
    end function GetMinIndex ;

    ------------------------------------------------------------
    impure function GetMaxIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable MaxCov : real := -1.0 ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov > MaxCov then
          MaxCov := CovStructPtr(ID.ID).CovBinPtr(i).PercentCov ;
          CovStructPtr(ID.ID).LastStimGenIndex := i ;
        end if ;
      end loop CovLoop ;
      CovStructPtr(ID.ID).LastIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      return CovStructPtr(ID.ID).LastStimGenIndex ;
    end function GetMaxIndex ;

    ------------------------------------------------------------
    impure function GetNextIndex (ID : CoverageIDType; Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      case Mode is
        when RANDOM =>      return GetRandIndex(ID) ;
        when INCREMENT =>   return GetIncIndex (ID) ;
        when others =>      return GetMinIndex (ID) ;
      end case ;
    end function GetNextIndex;

    ------------------------------------------------------------
    impure function GetNextIndex (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetNextIndex(ID, CovStructPtr(ID.ID).NextPointMode) ;
    end function GetNextIndex ;

    -- Return BinVals
    ------------------------------------------------------------
    impure function GetBinVal (ID : CoverageIDType; BinIndex : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr( BinIndex ).BinVal.all ;
    end function GetBinVal ;

    ------------------------------------------------------------
    impure function GetLastBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr( CovStructPtr(ID.ID).LastIndex ).BinVal.all ;
    end function GetLastBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr( GetRandIndex(ID, PercentCov) ).BinVal.all ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return CovStructPtr(ID.ID).CovBinPtr( GetRandIndex(ID, CovStructPtr(ID.ID).CovTarget ) ).BinVal.all ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetIncBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetBinVal(ID, GetIncIndex(ID)) ;
    end function GetIncBinVal ;

    ------------------------------------------------------------
    impure function GetMinBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetBinVal(ID, GetMinIndex(ID) ) ;
    end function GetMinBinVal ;

    ------------------------------------------------------------
    impure function GetMaxBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetBinVal(ID, GetMaxIndex(ID) ) ;
    end function GetMaxBinVal ;

    ------------------------------------------------------------
    impure function GetNextBinVal (ID : CoverageIDType; Mode : NextPointModeType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetBinVal(ID, GetNextIndex(ID, Mode)) ;
    end function GetNextBinVal;

    ------------------------------------------------------------
    impure function GetNextBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetBinVal(ID, GetNextIndex(ID, CovStructPtr(ID.ID).NextPointMode)) ;
    end function GetNextBinVal ;

    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr( GetRandIndex(ID, PercentCov) ).BinVal.all ;  -- GetBinVal
    end function RandCovBinVal ;

    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal (ID : CoverageIDType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return CovStructPtr(ID.ID).CovBinPtr( GetRandIndex(ID, CovStructPtr(ID.ID).CovTarget ) ).BinVal.all ;  -- GetBinVal
    end function RandCovBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
      variable HoleCount : integer := 0 ;
--sig      variable buf : line ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < PercentCov then
          HoleCount := HoleCount + 1 ;
          if HoleCount = ReqHoleNum  then
           return CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all ;
          end if ;
        end if ;
      end loop CovLoop ;
      Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.GetHoleBinVal:" &
                    " did not find a coverage hole.  HoleCount = "  & integer'image(HoleCount) &
                    " ReqHoleNum = " & integer'image(ReqHoleNum), ERROR
      ) ;
      return CovStructPtr(ID.ID).CovBinPtr(CovStructPtr(ID.ID).NumBins).BinVal.all ;

    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal (ID : CoverageIDType; PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(ID, 1, PercentCov) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer := 1 ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(ID, ReqHoleNum, CovStructPtr(ID.ID).CovTarget) ;
    end function GetHoleBinVal ;

    -- Return Points
    ------------------------------------------------------------
    impure function ToRandPoint(ID : CoverageIDType; BinVal : RangeArrayType ) return integer is
    --  pt local
    ------------------------------------------------------------
      variable rInt : integer ;
    begin
--      return RV.RandInt(BinVal(BinVal'left).min, BinVal(BinVal'left).max) ;
      RandInt(CovStructPtr(ID.ID).RV, rInt, BinVal(BinVal'left).min, BinVal(BinVal'left).max) ;
      return rInt ;
    end function ToRandPoint ;

    ------------------------------------------------------------
    impure function ToRandPoint(ID : CoverageIDType; BinVal : RangeArrayType ) return integer_vector is
    --  pt local
    ------------------------------------------------------------
      variable CovPoint : integer_vector(BinVal'range) ;
      variable normCovPoint : integer_vector(1 to BinVal'length) ;
    begin
      for i in BinVal'range loop
--        CovPoint(i) := RV.RandInt(BinVal(i).min, BinVal(i).max) ;
        Uniform(CovStructPtr(ID.ID).RV, CovPoint(i), BinVal(i).min, BinVal(i).max) ;
      end loop ;
      normCovPoint := CovPoint ;
      return normCovPoint ;
    end function ToRandPoint ;

    ------------------------------------------------------------
    impure function GetPoint (ID : CoverageIDType; BinIndex : integer ) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, BinIndex)) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetPoint (ID : CoverageIDType; BinIndex : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, BinIndex)) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, CovStructPtr(ID.ID).CovTarget)) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, PercentCov)) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, CovStructPtr(ID.ID).CovTarget)) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, PercentCov)) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetIncIndex(ID)) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetIncIndex(ID)) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, GetMinIndex(ID) )) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, GetMinIndex(ID) )) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, GetMaxIndex(ID) )) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetBinVal(ID, GetMaxIndex(ID) )) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetNextIndex(ID, Mode)) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer_vector is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetNextIndex(ID, Mode)) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    impure function GetNextPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetNextIndex(ID, CovStructPtr(ID.ID).NextPointMode)) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return GetPoint(ID, GetNextIndex(ID, CovStructPtr(ID.ID).NextPointMode)) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, CovStructPtr(ID.ID).CovTarget)) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, PercentCov)) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint (ID : CoverageIDType) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, CovStructPtr(ID.ID).CovTarget)) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, GetRandBinVal(ID, PercentCov)) ;
    end function RandCovPoint ;

    -- ------------------------------------------------------------
    -- Get all bin information except the BinVal (since it is sized)
    impure function GetBinInfo (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
      variable result : CovBinBaseType ;
    begin
      result.BinVal  := ALL_RANGE;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBinInfo ;

    -- ------------------------------------------------------------
    -- Get Pieces of Bin Information
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    impure function GetBinValLength (ID : CoverageIDType) return integer is
    -- ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).BinValLength ;
    end function GetBinValLength ;
    
    ------------------------------------------------------------
    impure function GetBinAction(ID : CoverageIDType; BinIndex : integer) return integer is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action ; 
    end function GetBinAction ;

    -- ------------------------------------------------------------
    impure function GetBinName (ID : CoverageIDType; BinIndex : integer; DefaultName : string := "" ) return string is
    -- ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovBinPtr(BinIndex).Name.all /= "" then
        return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Name.all ;
      else
        return DefaultName ;
      end if;
    end function GetBinName ;

    -- ------------------------------------------------------------
    procedure SetBinName  (ID : CoverageIDType; BinIndex : integer; Name : string ) is
    -- ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).CovBinPtr(BinIndex).Name /= NULL then
        deallocate(CovStructPtr(ID.ID).CovBinPtr(BinIndex).Name) ;
      end if ; 
      CovStructPtr(ID.ID).CovBinPtr(BinIndex).Name := new string'(Name) ;
    end procedure SetBinName ;

    ------------------------------------------------------------
    impure function GetPointAction(ID : CoverageIDType; CovPoint : integer_vector) return integer is
    ------------------------------------------------------------
      variable BinIndex : integer ; 
    begin
      BinIndex := FindBinIndex(ID, CovPoint) ;
      if BinIndex > 0 then 
        return GetBinAction( ID, BinIndex ) ; 
      else 
        return -2 ; 
      end if ; 
    end function GetPointAction ;


-- Eventually the multiple GetBin functions will be replaced by a
-- a single GetBin that returns CovBinBaseType with BinVal as an
-- unconstrained element
    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
      variable result : CovBinBaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix2BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix2BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix3BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix3BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix4BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix4BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix5BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix5BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix6BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix6BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix7BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix7BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix8BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix8BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix9BaseType is
    -- ------------------------------------------------------------
      variable result : CovMatrix9BaseType ;
    begin
      result.BinVal  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).BinVal.all;
      result.Action  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Action;
      result.Count   := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count;
      result.AtLeast := CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast;
      result.Weight  := CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight;
      return result ;
    end function GetBin ;

    ------------------------------------------------------------
    -- pt local for now -- file formal parameter not allowed with a public method
--    procedure WriteBinName (ID : CoverageIDType; file f : text ; S : string ; Prefix : string := "%% " ) is
    procedure WriteBinName (ID : CoverageIDType; variable buf : inout line; S : string ; Prefix : string := "%% " ) is
    ------------------------------------------------------------
      variable Message : MessageStructPtrType ;
--sig      variable MessageIndex : integer := 1 ;
    begin
      Message := CovStructPtr(ID.ID).CovMessage ;
      if Message = NULL then
        write(buf, Prefix & S & GetCovModelName(ID)) ; -- Print name when no message
        write(buf, "" & LF) ;
      else
        if CovStructPtr(ID.ID).CovName /= NULL then
          -- Print Name if set
          write(buf, Prefix & S & CovStructPtr(ID.ID).CovName.all) ;
        elsif CovStructPtr(ID.ID).AlertLogID /= OSVVM_COVERAGE_ALERTLOG_ID then
          -- otherwise Print AlertLogName if it is set
          write(buf, Prefix & S & string'(GetAlertLogName(CovStructPtr(ID.ID).AlertLogID)) ) ;
        else
          -- otherwise print the first line of the message
          write(buf, Prefix & S & Message.Name.all) ;
          Message := Message.NextPtr ;
        end if ;
        write(buf, "" & LF) ;
--        writeline(f, buf) ;
        WriteMessage(buf, Message, Prefix) ;
      end if ;
    end procedure WriteBinName ;

    ------------------------------------------------------------
    --  pt local for now -- file formal parameter not allowed with method
    procedure WriteBin (
      ID              : CoverageIDType ;
      variable buf    : inout line ;
--      file f          : text ;
--!!      WritePassFail   : OsvvmOptionsType ;
--!!      WriteBinInfo    : OsvvmOptionsType ;
--!!      WriteCount      : OsvvmOptionsType ;
--!!      WriteAnyIllegal : OsvvmOptionsType ;
      WritePassFail   : boolean ;
      WriteBinInfo    : boolean ;
      WriteCount      : boolean ;
      WriteAnyIllegal : boolean ;
      WritePrefix     : string ;
      PassName        : string ;
      FailName        : string ;
      UsingLocalFile  : boolean := FALSE
    ) is
    ------------------------------------------------------------
    begin
      if CovStructPtr(ID.ID).NumBins < 1 then
        if WriteBinFileInit or UsingLocalFile then
          swrite(buf, WritePrefix & " " & FailName & " ") ;
          swrite(buf, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteBin: Coverage model is empty.  Nothing to print.") ;
--          writeline(f, buf) ;
        end if ;
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteBin:" &
                      " Coverage model is empty.  Nothing to print.", FAILURE) ;
        return ;
      end if ;
      -- Models with Bins
      WriteBinName(ID, buf, "WriteBin: ", WritePrefix) ;
      for i in 1 to CovStructPtr(ID.ID).NumBins loop      -- CovStructPtr(ID.ID).CovBinPtr.all'range
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT or
--           (CovStructPtr(ID.ID).CovBinPtr(i).action = COV_ILLEGAL and IsEnabled(WriteAnyIllegal)) or
           (CovStructPtr(ID.ID).CovBinPtr(i).action = COV_ILLEGAL and WriteAnyIllegal) or
           CovStructPtr(ID.ID).CovBinPtr(i).count < 0  -- Illegal bin with errors
        then
          -- WriteBin Info
          swrite(buf, WritePrefix) ;
          if CovStructPtr(ID.ID).CovBinPtr(i).Name.all /= "" then
            swrite(buf, CovStructPtr(ID.ID).CovBinPtr(i).Name.all & "  ") ;
          end if ;
--!!          if IsEnabled(WritePassFail) then
          if (WritePassFail) then
            -- For illegal bins, AtLeast = 0 and count is negative.
            if CovStructPtr(ID.ID).CovBinPtr(i).count >= CovStructPtr(ID.ID).CovBinPtr(i).AtLeast then
              swrite(buf, PassName & ' ') ;
            else
              swrite(buf, FailName & ' ') ;
            end if ;
          end if ;
--!!          if IsEnabled(WriteBinInfo) then
          if (WriteBinInfo) then
            if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT then
              swrite(buf, "Bin:") ;
            else
              swrite(buf, "Illegal Bin:") ;
            end if;
            write(buf, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;
          end if ;
--!!          if IsEnabled(WriteCount) then
          if (WriteCount) then
            write(buf, "  Count = " & integer'image(abs(CovStructPtr(ID.ID).CovBinPtr(i).count))) ;
            write(buf, "  AtLeast = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)) ;
            if CovStructPtr(ID.ID).WeightMode = WEIGHT or CovStructPtr(ID.ID).WeightMode = REMAIN_WEIGHT then
              -- Print Weight only when it is used
              write(buf, "  Weight = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Weight)) ;
            end if ;
          end if ;
          write(buf, "" & LF) ;
--          writeline(f, buf) ;
        end if ;
      end loop ;
      swrite(buf, "") ;
--      writeline(f, buf) ;
    end procedure WriteBin ;

    ------------------------------------------------------------
    procedure WriteBin (ID : CoverageIDType) is
    ------------------------------------------------------------
      variable buf              : line ;
    begin
      WriteBin (
        ID              => ID,
        buf             => buf,
        WritePassFail   => WritePassFailVar,
        WriteBinInfo    => WriteBinInfoVar,
        WriteCount      => WriteCountVar,
        WriteAnyIllegal => WriteAnyIllegalVar,
        WritePrefix     => COVERAGE_PRINT_PREFIX,
        PassName        => COVERAGE_PASS_NAME,
        FailName        => COVERAGE_FAIL_NAME
      ) ;
      WriteToCovFile(buf) ;
    end procedure WriteBin ;

    ------------------------------------------------------------
    procedure WriteBin (ID : CoverageIDType; LogLevel : LogType ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteBin (
          ID              => ID
        ) ;
      end if ;
    end procedure WriteBin ;  -- With LogLevel

    ------------------------------------------------------------
    procedure WriteBin (ID : CoverageIDType; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE) is
    ------------------------------------------------------------
      file LocalWriteBinFile : text ;
      variable buf               : line ;
    begin
      file_open(LocalWriteBinFile, FileName, OpenKind) ;
      WriteBin (
        ID              => ID,
        buf             => buf,
        WritePassFail   => WritePassFailVar,
        WriteBinInfo    => WriteBinInfoVar,
        WriteCount      => WriteCountVar,
        WriteAnyIllegal => WriteAnyIllegalVar,
        WritePrefix     => COVERAGE_PRINT_PREFIX,
        PassName        => COVERAGE_PASS_NAME,
        FailName        => COVERAGE_FAIL_NAME,
        UsingLocalFile  => TRUE
      );
      writeline(LocalWriteBinFile, buf) ;
    end procedure WriteBin ;

    ------------------------------------------------------------
    procedure WriteBin (  -- With LogLevel
    ------------------------------------------------------------
      ID              : CoverageIDType ;
      LogLevel        : LogType ;
      FileName        : string ;
      OpenKind        : File_Open_Kind := APPEND_MODE
    ) is
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteBin (
          ID              => ID,
          FileName        => FileName,
          OpenKind        => OpenKind
        ) ;
      end if ;
    end procedure WriteBin ;  -- With LogLevel

    ------------------------------------------------------------
    procedure WriteAllBins (FileName : string := "" ; OpenKind : File_Open_Kind := WRITE_MODE) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := ifelse(FileName = "", OSVVM_TEMP_OUTPUT_DIRECTORY & GetTestName & "_cov.txt", FileName) ;
      file CovFile : text ;
      variable buf : line ;
    begin
      file_open(CovFile, RESOLVED_FILE_NAME, OpenKind) ;
      swrite(buf, "TestCase: "  & GetTestName  & LF) ;
      swrite(buf, "Total Coverage: " & to_string(GetCov, 2) & LF) ;
      writeline(CovFile, buf) ;
--      WriteSettingsYaml(CovFile) ;
--      swrite(buf, "Models: ") ;
--      writeline(CovFile, buf) ;
      for i in 1 to NumItems loop
        if CovStructPtr(i).NumBins >= 1 then
          if CovStructPtr(i).CovWeight >= 1 then
            WriteBin (
              ID              => CoverageIDType'(ID => i),
              buf             => buf,
              WritePassFail   => WritePassFailVar,
              WriteBinInfo    => WriteBinInfoVar,
              WriteCount      => WriteCountVar,
              WriteAnyIllegal => WriteAnyIllegalVar,
              WritePrefix     => COVERAGE_PRINT_PREFIX,
              PassName        => COVERAGE_PASS_NAME,
              FailName        => COVERAGE_FAIL_NAME,
              UsingLocalFile  => TRUE
            );
            writeline(CovFile, buf) ;
          end if ;
        end if ;
      end loop ;
--!!      for i in 1 to NumItems loop
--!!        if CovStructPtr(i).NumBins >= 1 then
--!!          if CovStructPtr(i).CovWeight < 1 then
--!!            WriteCovYaml(CoverageIDType'(ID => i), CovFile, GetTestName) ;
--!!          end if ;
--!!        end if ;
--!!      end loop ;
      file_close(CovFile) ;
    end procedure WriteAllBins ;

    ------------------------------------------------------------
    -- Development only
    --  pt local for now -- file formal parameter not allowed with method
--    procedure DumpBin (ID : CoverageIDType; file f : text ) is
    procedure DumpBin (ID : CoverageIDType; variable buf : inout line ) is
    ------------------------------------------------------------
--      variable buf : line ;
    begin
      WriteBinName(ID, buf, "DumpBin: ") ;
--      writeline(f, buf) ;
      -- if CovStructPtr(ID.ID).NumBins < 1 then
      --   Write(f, "%%FATAL, Coverage Model is empty.  Nothing to print." & LF ) ;
      -- end if ;
      for i in 1 to CovStructPtr(ID.ID).NumBins loop      -- CovStructPtr(ID.ID).CovBinPtr.all'range
        swrite(buf, "%% ") ;
        if CovStructPtr(ID.ID).CovBinPtr(i).Name.all /= "" then
          swrite(buf, CovStructPtr(ID.ID).CovBinPtr(i).Name.all & "  ") ;
        end if ;
        swrite(buf, "Bin:") ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;
        case CovStructPtr(ID.ID).CovBinPtr(i).action is
          when COV_COUNT   =>   swrite(buf, "    Count = ") ;
          when COV_IGNORE  =>   swrite(buf, "   Ignore = ") ;
          when COV_ILLEGAL =>   swrite(buf, "  Illegal = ") ;
          when others      =>   swrite(buf, "  BOGUS BOGUS BOGUS = ") ;
        end case ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(i).count) ;
        write(buf, "   AtLeast = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)) ;
        write(buf, "   Weight = "  & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Weight)) ;
        write(buf, "" & LF) ;
--        writeline(f, buf) ;
      end loop ;
      swrite(buf, "") ;
--      writeline(f,buf) ;
    end procedure DumpBin ;

    ------------------------------------------------------------
    procedure DumpBin (ID : CoverageIDType; LogLevel : LogType := DEBUG) is
    ------------------------------------------------------------
      variable buf : line ;
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        DumpBin(ID, buf) ;
        WriteToCovFile(buf) ;
      end if ;
    end procedure DumpBin ;

    ------------------------------------------------------------
    --  pt local
--    procedure WriteCovHoles (ID : CoverageIDType; file f : text;  PercentCov : real := 100.0;  UsingLocalFile : boolean := FALSE) is
    procedure WriteCovHoles (ID : CoverageIDType; variable buf : inout line;  PercentCov : real := 100.0;  UsingLocalFile : boolean := FALSE) is
    ------------------------------------------------------------
--      variable buf : line ;
    begin
      if CovStructPtr(ID.ID).NumBins < 1 then
        if WriteBinFileInit or UsingLocalFile then
          -- Duplicate Alert in specified file
          swrite(buf, "%% Alert FAILURE  " & GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteCovHoles:" &
                      " coverage model empty.  Nothing to print.") ;
--          writeline(f, buf) ;
        end if ;
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteCovHoles:" &
                      " coverage model empty.  Nothing to print.", FAILURE) ;
        return ;
      end if ;
      -- Models with Bins
      WriteBinName(ID, buf, "WriteCovHoles: ") ;
--      writeline(f, buf) ;
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).PercentCov < PercentCov then
          swrite(buf, "%% ") ;
          if CovStructPtr(ID.ID).CovBinPtr(i).Name.all /= "" then
            swrite(buf, CovStructPtr(ID.ID).CovBinPtr(i).Name.all & "  ") ;
          end if ;
          swrite(buf, "Bin:") ;
          write(buf, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;
          write(buf, "  Count = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Count)) ;
          write(buf, "  AtLeast = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)) ;
          if CovStructPtr(ID.ID).WeightMode = WEIGHT or CovStructPtr(ID.ID).WeightMode = REMAIN_WEIGHT then
            -- Print Weight only when it is used
            write(buf, "  Weight = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Weight)) ;
          end if ;
          write(buf, "" & LF) ;
--          writeline(f, buf) ;
        end if ;
      end loop CovLoop ;
      swrite(buf, "") ;
--      writeline(f, buf) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; PercentCov : real ) is
    ------------------------------------------------------------
      variable buf : line ;
    begin
      WriteCovHoles(ID, buf, PercentCov) ;
      WriteToCovFile(buf) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType := ALWAYS ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, CovStructPtr(ID.ID).CovTarget) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType ; PercentCov : real ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, PercentCov) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
--x      file CovHoleFile : text open OpenKind is FileName ;
      file CovHoleFile : text ;
      variable buf : line ;
    begin
      file_open(CovHoleFile, FileName, OpenKind) ;
--      WriteCovHoles(ID, CovHoleFile, CovStructPtr(ID.ID).CovTarget, TRUE) ;
      WriteCovHoles(ID, buf, CovStructPtr(ID.ID).CovTarget, TRUE) ;
      writeline(CovHoleFile, buf) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType ; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, FileName, OpenKind) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
--x      file CovHoleFile : text open OpenKind is FileName ;
      file CovHoleFile : text ;
      variable buf : line ;
    begin
      file_open(CovHoleFile, FileName, OpenKind) ;
      -- WriteCovHoles(ID, CovHoleFile, PercentCov, TRUE) ;
      WriteCovHoles(ID, buf, PercentCov, TRUE) ;
      writeline(CovHoleFile, buf) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType ; FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, FileName, PercentCov, OpenKind) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    --  pt local
    impure function FindExactBin (
    -- find an exact match to a bin wrt BinVal, Action, AtLeast, Weight, and Name
    ------------------------------------------------------------
      ID      : CoverageIDType ;
      Merge   : boolean ;
	    BinVal  : RangeArrayType ;
      Action  : integer ;
      AtLeast : integer ;
      Weight  : integer ;
      Name    : string
    ) return integer is
    begin
      if Merge then
        for i in 1 to CovStructPtr(ID.ID).NumBins loop
          if (BinVal = CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) and (Action = CovStructPtr(ID.ID).CovBinPtr(i).Action) and
             (AtLeast = CovStructPtr(ID.ID).CovBinPtr(i).AtLeast) and 
             (Weight = CovStructPtr(ID.ID).CovBinPtr(i).Weight or Weight = -1) and
             (Name = CovStructPtr(ID.ID).CovBinPtr(i).Name.all) then
            return i ;
          end if;
        end loop ;
      end if ;
      return 0 ;
    end function FindExactBin ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadNamePtr (
    ------------------------------------------------------------
      buf         : inout line ;
      NamePtr     : inout line ;
      NameLength  : in integer ;
      ReadValid   : inout boolean
    ) is
      variable Name : string(1 to NameLength) ;
    begin
      ReadValid := TRUE ; 
      NamePtr   := NULL ; 
      if NameLength > 0 then
        read(buf, Name, ReadValid) ;
        if ReadValid then 
          NamePtr := new string'(Name) ;
        end if ; 
      end if ;
    end procedure ReadNamePtr ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovVars (ID : CoverageIDType; file CovDbFile : text; Good : out boolean ) is
    ------------------------------------------------------------
      variable buf                  : line ;
      variable Empty                : boolean ;
      variable MultiLineComment     : boolean := FALSE ;
      variable ReadValid            : boolean ;
      variable GoodLoop1            : boolean ;
      variable iSeed                : RandomSeedType ;
      variable iIllegalMode         : integer ;
      variable iWeightMode          : integer ;
      variable iWeightScale         : real ;
      variable iCovThreshold        : real ;
      variable iCountMode           : integer ;
      variable iNumberOfMessages    : integer ;
      variable iThresholdingEnable  : boolean ;
      variable iCovTarget           : real ;
      variable iMergingEnable       : boolean ;
    begin
      -- ReadLoop0 : while not EndFile(CovDbFile) loop
      ReadLoop0 : loop   -- allows emulation of "return when"
        -- ReadLine to Get Coverage Model Name, skip blank and comment lines, fails when file empty
        exit when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: No Coverage Data to read", FAILURE) ;
        ReadLine(CovDbFile, buf) ;
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        next when Empty ;

        if buf.all /= "Coverage_Model_Not_Named" then
          SetName(ID, buf.all) ;
        end if ;

        exit ReadLoop0 ;
      end loop ReadLoop0 ;

      -- ReadLoop1 : while not EndFile(CovDbFile) loop
      ReadLoop1 : loop
        -- ReadLine to Get Variables, skip blank and comment lines, fails when file empty
        exit when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                      "CoveragePkg.ReadCovDb: Coverage DB File Incomplete", FAILURE) ;
        ReadLine(CovDbFile, buf) ;
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        next when Empty ;

        read(buf, iSeed, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Seed", FAILURE) ;
--        RV.SetSeed( iSeed ) ;
        CovStructPtr(ID.ID).RV         := iSeed ;
        CovStructPtr(ID.ID).RvSeedInit := TRUE ;

        read(buf, iCovThreshold, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading CovThreshold", FAILURE) ;
        CovStructPtr(ID.ID).CovThreshold := iCovThreshold ;

        read(buf, iIllegalMode, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading IllegalMode", FAILURE) ;
        SetIllegalMode(ID, IllegalModeType'val( iIllegalMode )) ;

        read(buf, iWeightMode, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading WeightMode", FAILURE) ;
        CovStructPtr(ID.ID).WeightMode := WeightModeType'val( iWeightMode ) ;

        read(buf, iWeightScale, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading WeightScale", FAILURE) ;
        CovStructPtr(ID.ID).WeightScale := iWeightScale  ;

        read(buf, iCountMode, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading CountMode", FAILURE) ;
        CovStructPtr(ID.ID).CountMode := CountModeType'val( iCountMode ) ;

        read(buf, iThresholdingEnable, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading ThresholdingEnable", FAILURE) ;
        CovStructPtr(ID.ID).ThresholdingEnable := iThresholdingEnable ;

        read(buf, iCovTarget, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading CovTarget", FAILURE) ;
        CovStructPtr(ID.ID).CovTarget := iCovTarget ;

        read(buf, iMergingEnable, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading MergingEnable", FAILURE) ;
        CovStructPtr(ID.ID).MergingEnable := iMergingEnable ;

        exit ReadLoop1 ;
      end loop ReadLoop1 ;

      GoodLoop1 := ReadValid ;

      -- ReadLoop2 : while not EndFile(CovDbFile) loop
      ReadLoop2 : while ReadValid loop
        -- ReadLine to Coverage Model Header WriteBin Message, skip blank and comment lines, fails when file empty
        exit when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Coverage DB File Incomplete", FAILURE) ;
        ReadLine(CovDbFile, buf) ;
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        next when Empty ;

        read(buf, iNumberOfMessages, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading NumberOfMessages", FAILURE) ;

        for i in 1 to iNumberOfMessages loop
          exit when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: End of File while reading Messages", FAILURE) ;
          ReadLine(CovDbFile, buf) ;
          SetMessage(ID, buf.all) ;
        end loop ;

        exit ReadLoop2 ;
      end loop ReadLoop2 ;

      Good := ReadValid and  GoodLoop1 ;
    end procedure ReadCovVars ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovDbInfo (
    ------------------------------------------------------------
      ID                     :     CoverageIDType ;
      File     CovDbFile     :     text ;
      variable NumRangeItems : out integer ;
      variable NumLines      : out integer ;
      variable Good          : out boolean
    ) is
      variable buf               : line ;
      variable ReadValid         : boolean ;
      variable Empty             : boolean ;
      variable MultiLineComment  : boolean := FALSE ;
    begin

      ReadLoop : loop
        -- ReadLine to RangeItems NumLines, skip blank and comment lines, fails when file empty
        exit when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Coverage DB File Incomplete", FAILURE) ;
        ReadLine(CovDbFile, buf) ;
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        next when Empty ;

        read(buf, NumRangeItems, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading NumRangeItems", FAILURE) ;
        CovStructPtr(ID.ID).BinValLength := NumRangeItems ;
        
        read(buf, NumLines, ReadValid) ;
        exit when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading NumLines", FAILURE) ;
        exit ;
      end loop ReadLoop ;
      Good := ReadValid ;
    end procedure ReadCovDbInfo ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovDbDataBase (
    ------------------------------------------------------------
      ID                     :     CoverageIDType ;
      File     CovDbFile     :     text ;
      constant NumRangeItems : in  integer ;
      constant NumLines      : in  integer ;
      constant Merge         : in  boolean ;
      variable Good          : out boolean
    )  is
      variable buf              : line ;
      variable Empty            : boolean ;
      variable MultiLineComment : boolean := FALSE ;
      variable ReadValid        : boolean ;
      -- Format:  Action Count min1 max1 min2 max2 ....
      variable Action           : integer ;
      variable Count            : integer ;
      variable BinVal           : RangeArrayType(1 to NumRangeItems) ;
      variable index            : integer ;
      variable AtLeast          : integer ;
      variable Weight           : integer ;
      variable PercentCov       : real ;
      variable NameLength       : integer ;
      variable SkipBlank        : character ;
      variable NamePtr          : line ;
    begin
      GrowBins(ID, NumLines) ;
      ReadLoop : for i in 1 to NumLines loop

        GetValidLineLoop: loop
          exit ReadLoop when AlertIf(CovStructPtr(ID.ID).AlertLogID, EndFile(CovDbFile), GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Did not read specified number of lines", FAILURE) ;
          ReadLine(CovDbFile, buf) ;
          EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
          next GetValidLineLoop when Empty ;  -- replace with EmptyLine(buf)
          exit GetValidLineLoop ;
        end loop ;

        read(buf, Action, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Action", FAILURE) ;
        read(buf, Count, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Count", FAILURE) ;
        read(buf, AtLeast, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading AtLeast", FAILURE) ;
        read(buf, Weight, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Weight", FAILURE) ;
        read(buf, PercentCov, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading PercentCov", FAILURE) ;
        read(buf, BinVal, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading BinVal", FAILURE) ;
        read(buf, NameLength, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Bin Name Length", FAILURE) ;
        read(buf, SkipBlank, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Bin Name Length", FAILURE) ;
        ReadNamePtr(buf, NamePtr, NameLength, ReadValid) ;
        exit ReadLoop when AlertIfNot(CovStructPtr(ID.ID).AlertLogID, ReadValid, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.ReadCovDb: Failed while reading Bin Name", FAILURE) ;
        if NamePtr /= NULL then 
          index := FindExactBin(ID, Merge, BinVal, Action, AtLeast, Weight, NamePtr.all) ;
        else
          index := FindExactBin(ID, Merge, BinVal, Action, AtLeast, Weight, "") ;
        end if ; 
        if index > 0 then
          -- Bin is an exact match so only merge the count values
          CovStructPtr(ID.ID).CovBinPtr(index).Count := CovStructPtr(ID.ID).CovBinPtr(index).Count + Count ;
          CovStructPtr(ID.ID).CovBinPtr(index).PercentCov := CalcPercentCov(
            Count => CovStructPtr(ID.ID).CovBinPtr.all(index).Count,
            AtLeast =>  CovStructPtr(ID.ID).CovBinPtr.all(index).AtLeast ) ;
        else
          if NamePtr /= NULL then 
            InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, NamePtr.all, PercentCov) ;
          else
            InsertNewBin(ID, BinVal, Action, Count, AtLeast, Weight, "", PercentCov) ;
          end if ; 
        end if ;
        deallocate(NamePtr) ;
      end loop ReadLoop ;
      Good := ReadValid ;
    end ReadCovDbDataBase ;
    
    ------------------------------------------------------------
    --  pt local
    procedure ReadCovDbFieldNames (
    ------------------------------------------------------------
      ID                     :     CoverageIDType ;
      File     CovDbFile     :     text ;
      constant NumRangeItems : in  integer ;
      variable Good          : out boolean
    )  is
      variable buf              : line ;
      variable Empty            : boolean ;
      variable MultiLineComment : boolean := FALSE ;
--sig      variable ReadValid        : boolean ;
      variable FieldNameArray   : FieldNameArrayType(1 to NumRangeItems) ;
    begin
      ReadLoop : for FieldNameIndex in 1 to NumRangeItems loop 
        exit ReadLoop when EndFile(CovDbFile) ;  -- If nothing to read, skip reading
        ReadLine(CovDbFile, buf) ;
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        exit ReadLoop when Empty or buf = NULL ;  
        FieldNameArray(FieldNameIndex) := buf ; 
        buf := NULL ; 
        if FieldNameIndex = NumRangeItems then 
          CovStructPtr(ID.ID).FieldName := new FieldNameArrayType'(FieldNameArray) ;
        end if ; 
      end loop ReadLoop ; 
    end procedure ReadCovDbFieldNames ;

    ------------------------------------------------------------
    -- pt local
    procedure ReadCovDb (ID : CoverageIDType; File CovDbFile : text; Merge : boolean := FALSE) is
    ------------------------------------------------------------
      -- Format:  Action Count min1 max1 min2 max2
      variable NumRangeItems : integer ;
      variable NumLines      : integer ;
      variable ReadValid    : boolean ;
    begin
      if not Merge then
        Deallocate(ID) ;  -- remove any old bins
      end if ;

      ReadLoop : loop
        -- Read coverage private variables to the file
        ReadCovVars(ID, CovDbFile, ReadValid) ;
        exit when not ReadValid ;

        -- Get Coverage dimensions and number of items in file.
        ReadCovDbInfo(ID, CovDbFile, NumRangeItems, NumLines, ReadValid) ;
        exit when not ReadValid ;

        -- Read the file
        ReadCovDbDataBase(ID, CovDbFile, NumRangeItems, NumLines, Merge, ReadValid) ;
        exit when not ReadValid ;
        
        -- Read the field names (if they are set)
        ReadCovDbFieldNames (ID, CovDbFile, NumRangeItems, ReadValid) ;
        exit ; 

      end loop ReadLoop ;
    end ReadCovDb ;

    ------------------------------------------------------------
    procedure ReadCovDb (ID : CoverageIDType; FileName : string; Merge : boolean := FALSE) is
    ------------------------------------------------------------
      -- Format:  Action Count min1 max1 min2 max2
      file CovDbFile         : text open READ_MODE is FileName ;
    begin
      ReadCovDb(ID, CovDbFile, Merge) ;
    end procedure ReadCovDb ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovDbVars (ID : CoverageIDType; file CovDbFile : text ) is
    ------------------------------------------------------------
      variable buf             : line ;
      variable CovMessageCount : integer ;
    begin
      -- write coverage private variables to the file
      if CovStructPtr(ID.ID).CovName /= NULL then
        swrite(buf, CovStructPtr(ID.ID).CovName.all) ;
      else
        swrite(buf, "Coverage_Model_Not_Named") ;
      end if ;
      writeline(CovDbFile, buf) ;

      write(buf, CovStructPtr(ID.ID).RV ) ;
      write(buf, ' ') ;
      write(buf, CovStructPtr(ID.ID).CovThreshold, RIGHT, 0, 5) ;
      write(buf, ' ') ;
      write(buf, IllegalModeType'pos(CovStructPtr(ID.ID).IllegalMode)) ;
      write(buf, ' ') ;
      write(buf, WeightModeType'pos(CovStructPtr(ID.ID).WeightMode)) ;
      write(buf, ' ') ;
      write(buf, CovStructPtr(ID.ID).WeightScale, RIGHT, 0, 6) ;
      write(buf, ' ') ;
      write(buf, CountModeType'pos(CovStructPtr(ID.ID).CountMode)) ;
      write(buf, ' ') ;
      write(buf, to_upper(boolean'image(CovStructPtr(ID.ID).ThresholdingEnable))) ; -- boolean
      write(buf, ' ') ;
      write(buf, CovStructPtr(ID.ID).CovTarget, RIGHT, 0, 6) ; -- Real
      write(buf, ' ') ;
      write(buf, to_upper(boolean'image(CovStructPtr(ID.ID).MergingEnable))) ; -- boolean
      write(buf, ' ') ;
      writeline(CovDbFile, buf) ;
      GetMessageCount(CovStructPtr(ID.ID).CovMessage, CovMessageCount) ;
      write(buf, CovMessageCount ) ;
      writeline(CovDbFile, buf) ;
      WriteMessage(CovDbFile, CovStructPtr(ID.ID).CovMessage) ;
    end procedure WriteCovDbVars ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovDb (ID : CoverageIDType; file CovDbFile : text ) is
    ------------------------------------------------------------
      -- Format:  Action Count min1 max1 min2 max2
      variable buf       : line ;
    begin
      -- write Cover variables to the file
      WriteCovDbVars(ID, CovDbFile ) ;

      -- write NumRangeItems, NumLines
      write(buf, CovStructPtr(ID.ID).CovBinPtr(1).BinVal'length) ;
      write(buf, ' ') ;
      write(buf, CovStructPtr(ID.ID).NumBins) ;
      write(buf, ' ') ;
      writeline(CovDbFile, buf) ;
      -- write coverage to a file
      writeloop : for LineCount in 1 to CovStructPtr(ID.ID).NumBins loop
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).Action) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).Count) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).AtLeast) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).Weight) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).PercentCov, RIGHT, 0, 4) ;
        write(buf, ' ') ;
        WriteBinVal(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).BinVal.all) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).Name'length) ;
        write(buf, ' ') ;
        write(buf, CovStructPtr(ID.ID).CovBinPtr(LineCount).Name.all) ;
        writeline(CovDbFile, buf) ;
      end loop WriteLoop ;
      FieldNameLoop : for FieldNameIndex in 1 to CovStructPtr(ID.ID).CovBinPtr(1).BinVal'length loop
        exit when CovStructPtr(ID.ID).FieldName = NULL ; 
        write(buf, CovStructPtr(ID.ID).FieldName(FieldNameIndex).all) ; 
        writeline(CovDbFile, buf) ;
      end loop FieldNameLoop ; 
    end procedure WriteCovDb ;

    ------------------------------------------------------------
    procedure WriteCovDb (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
    ------------------------------------------------------------
      -- Format:  Action Count min1 max1 min2 max2
      file CovDbFile : text ;
    begin
      file_open(CovDbFile, FileName, OpenKind) ;
      if CovStructPtr(ID.ID).NumBins >= 1 then
        WriteCovDb(ID, CovDbFile) ;
      else
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.WriteCovDb: no bins defined ", FAILURE) ;
      end if ;
      file_close(CovDbFile) ;
    end procedure WriteCovDb ;

--     ------------------------------------------------------------
--     procedure WriteCovDb (ID : CoverageIDType) is
--     ------------------------------------------------------------
--     begin
--       if WriteCovDbFileInit then
--         WriteCovDb(ID, WriteCovDbFile) ;
--       else
--         report "CoveragePkg: WriteCovDb file not specified" severity failure ;
--       end if ;
--     end procedure WriteCovDb ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovSettingsYaml (ID : CoverageIDType; variable buf : inout LINE; Prefix : string ) is
    ------------------------------------------------------------
      variable TotalCovCount, TotalCovGoal : integer ;
    begin
      -- write bins to YAML file
      write(buf, Prefix & "Settings: " & LF) ;
      write(buf, Prefix & "  CovWeight: "          & to_string(CovStructPtr(ID.ID).CovWeight)                    & LF) ;
      write(buf, Prefix & "  Goal: "               & to_string(CovStructPtr(ID.ID).CovTarget, 1)                 & LF) ;
      write(buf, Prefix & "  WeightMode: """       & to_upper(to_string(CovStructPtr(ID.ID).WeightMode))         & '"' & LF) ;
      write(buf, Prefix & "  Seeds: ["             & to_string(CovStructPtr(ID.ID).RV, ", ") & "]"               & LF) ;
      write(buf, Prefix & "  CountMode: """        & to_upper(to_string(CovStructPtr(ID.ID).CountMode))          & '"' & LF) ;
      write(buf, Prefix & "  IllegalMode: """      & to_upper(to_string(CovStructPtr(ID.ID).IllegalMode))        & '"' & LF) ;
      write(buf, Prefix & "  Threshold: "          & to_string(CovStructPtr(ID.ID).CovThreshold, 1)              & LF) ;
      write(buf, Prefix & "  ThresholdEnable: """  & to_upper(to_string(CovStructPtr(ID.ID).ThresholdingEnable)) & '"' & LF) ;
      write(buf, Prefix & "  IsRequirement: """    & to_upper(to_string(CovStructPtr(ID.ID).IsRequirement))      & '"' & LF) ;
      GetTotalCovCountAndGoal (ID, TotalCovCount, TotalCovGoal) ;
      write(buf, Prefix & "  TotalCovCount: "      & to_string(TotalCovCount)                                    & LF) ;
      write(buf, Prefix & "  TotalCovGoal: "       & to_string(TotalCovGoal)                                     & LF) ;
    end procedure WriteCovSettingsYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovFieldNameYaml (ID : CoverageIDType; variable buf : inout LINE; Prefix : string ) is
    ------------------------------------------------------------
      variable Dimensions : integer ;
      variable FieldWidth : integer ;
      variable FieldName  : FieldNameArrayPtrType ;
    begin
      FieldName  := CovStructPtr(ID.ID).FieldName ;
      Dimensions := CovStructPtr(ID.ID).BinValLength ;
      if FieldName = NULL then
        FieldWidth := 0 ;
      else
        FieldWidth := FieldName'length;
      end if;

      write(buf, Prefix & "  FieldNames: " & LF) ;
      for i in 1 to Dimensions loop
        if i > FieldWidth then
          write(buf, Prefix & "    - ""Bin" & to_string(i)  & '"' & LF) ;
        else
          write(buf, Prefix & "    - """ & FieldName(i).all & '"' & LF) ;
        end if ;
      end loop ;
    end procedure WriteCovFieldNameYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovBinInfoYaml (ID : CoverageIDType; variable buf : inout LINE; Prefix : string ) is
    ------------------------------------------------------------
    begin
      -- write bins to YAML file
      write(buf, Prefix & "BinInfo: " & LF) ;
      write(buf, Prefix & "  Dimensions: " & to_string(CovStructPtr(ID.ID).BinValLength) & LF) ;
      WriteCovFieldNameYaml(ID, buf, Prefix) ;
      write(buf, Prefix & "  NumBins: " & to_string(CovStructPtr(ID.ID).NumBins) & LF) ;
    end procedure WriteCovBinInfoYaml ;

    ------------------------------------------------------------
    procedure WriteBinValYaml (
    -- package local for now
    ------------------------------------------------------------
      variable buf    : inout line ;
      constant BinVal : in    RangeArrayType ;
      constant Prefix : in    string
    ) is
    begin
      for i in BinVal'range loop
        write(buf, Prefix &
            "- {Min: " & to_string(BinVal(i).min) &
            ", Max: "  & to_string(BinVal(i).max) & "}" & LF) ;
      end loop ;
    end procedure WriteBinValYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovBinsYaml (ID : CoverageIDType; variable buf : inout LINE; Prefix : string ) is
    ------------------------------------------------------------
      variable CovBin : CovBinInternalBaseType ;
    begin
      -- write bins to YAML file
      write(buf, Prefix & "Bins: " & LF) ;
      writeloop : for EachLine in 1 to CovStructPtr(ID.ID).NumBins loop
        CovBin := CovStructPtr(ID.ID).CovBinPtr(EachLine) ;
        write(buf, Prefix & "  - Name: """ & CovBin.Name.all             & '"' & LF) ;
        write(buf, Prefix & "    Type: """ & ActionToName(CovBin.Action) & '"' & LF ) ;
        write(buf, Prefix & "    Range: " & LF) ;
        WriteBinValYaml(buf, CovBin.BinVal.all, Prefix & "      ") ;
        write(buf, Prefix & "    Count: "      & to_string(CovBin.Count) & LF) ;
        write(buf, Prefix & "    AtLeast: "    & to_string(CovBin.AtLeast) & LF) ;
        write(buf, Prefix & "    PercentCov: " & to_string(CovBin.PercentCov, 4) & LF) ;
      end loop writeloop ;
    end procedure WriteCovBinsYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteCovYaml (ID : CoverageIDType; file CovYamlFile : text; TestCaseName : string ) is
    ------------------------------------------------------------
      variable buf       : line ;
      constant NAME_PREFIX : string := "  " ;
    begin
      -- If no bins, FAIL and return (if resumed)
      if CovStructPtr(ID.ID).NumBins < 1 then
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") &
                       "CoveragePkg.WriteCovYaml: no bins defined ", FAILURE) ;
        return ;
      end if ;

      write(buf, NAME_PREFIX & "- Name: "     & '"' & GetName(ID) & '"' & LF) ;
--!! TODO: Add Writing for ParentName, ReportMode, Search, PrintParent
      write(buf, NAME_PREFIX & "  TestCases: " & LF) ;
      write(buf, NAME_PREFIX & "    - " & '"' & TestCaseName & '"' & LF) ;
--!! Add code to list out merged tests
      write(buf, NAME_PREFIX & "  Coverage: " & to_string(GetCov(ID), 2) & LF) ;
      WriteCovSettingsYaml(ID, buf, NAME_PREFIX &  "  ") ;
      WriteCovBinInfoYaml (ID, buf, NAME_PREFIX &  "  ") ;
      WriteCovBinsYaml    (ID, buf, NAME_PREFIX &  "  ") ;
      writeline(CovYamlFile, buf) ;
    end procedure WriteCovYaml ;

    ------------------------------------------------------------
    procedure WriteCovYaml (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
    ------------------------------------------------------------
--x      file CovYamlFile : text open OpenKind is FileName ;
      file CovYamlFile : text ;
    begin
      file_open(CovYamlFile, FileName, OpenKind) ;
      WriteCovYaml(ID, CovYamlFile, GetTestName) ;
      file_close(CovYamlFile) ;
    end procedure WriteCovYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure WriteSettingsYaml (file CovYamlFile : text) is
    ------------------------------------------------------------
      variable buf            : line ;
      constant NAME_PREFIX    : string := "" ;
 --!!     constant rWritePassFail : boolean := IsEnabled(ResolveCovWritePassFail(WritePassFailVar)) ;
    begin
      write(buf, NAME_PREFIX & "Settings: " & LF) ;
      -- write(buf, NAME_PREFIX & "  AlertIfNotCovered: " & ifelse(AlertIfNotCoveredVar, "1", "0") & LF) ;
      write(buf, NAME_PREFIX & "  WritePassFail: "     & ifelse(WritePassFailVar or ErrorIfNotCoveredVar, "1", "0")) ;
      writeline(CovYamlFile, buf) ;
    end procedure WriteSettingsYaml ;

    ------------------------------------------------------------
    procedure WriteCovYaml (FileName : string := ""; Coverage : real ; OpenKind : File_Open_Kind := WRITE_MODE) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := ifelse(FileName = "", OSVVM_TEMP_OUTPUT_DIRECTORY & GetTestName & "_cov.yml", FileName) ;
--x      file CovYamlFile : text open OpenKind is RESOLVED_FILE_NAME ;
      file CovYamlFile : text ;
      variable buf : line ;
    begin
      file_open(CovYamlFile, RESOLVED_FILE_NAME, OpenKind) ;
      swrite(buf, "Version: "  & '"' & COVERAGE_YAML_VERSION & '"' & LF) ;
      swrite(buf, "Coverage: " & to_string(Coverage, 2) ) ;
      writeline(CovYamlFile, buf) ;
      WriteSettingsYaml(CovYamlFile) ;
      swrite(buf, "Models: ") ;
      writeline(CovYamlFile, buf) ;
      for i in 1 to NumItems loop
        if CovStructPtr(i).NumBins >= 1 then
          if CovStructPtr(i).CovWeight >= 1 then
            WriteCovYaml(CoverageIDType'(ID => i), CovYamlFile, GetTestName) ;
          end if ;
        end if ;
      end loop ;
      for i in 1 to NumItems loop
        if CovStructPtr(i).NumBins >= 1 then
          if CovStructPtr(i).CovWeight < 1 then
            WriteCovYaml(CoverageIDType'(ID => i), CovYamlFile, GetTestName) ;
          end if ;
        end if ;
      end loop ;
      file_close(CovYamlFile) ;
    end procedure WriteCovYaml ;

    ------------------------------------------------------------
    --  pt local.  Find a specific token potentially split across lines
    procedure ReadFindToken (
    ------------------------------------------------------------
      file     ReadFile :       text ;
      constant Token    : in    string ;
      variable buf      : inout line ;
      variable Found    : out   boolean
    ) is
      variable Empty, MultiLineComment, ReadValid  : boolean ;
      variable vToken     : string(1 to Token'length) ;
    begin
      Found := FALSE ;

      ReadLoop : loop
        if buf = NULL or buf.all'length = 0  then
          -- return Good FALSE when file empty
          exit ReadLoop when EndFile(ReadFile) ;
          -- Get Next Line
          ReadLine(ReadFile, buf) ;
        end if ;
        -- Skip blank and multi-line comment lines
        EmptyOrCommentLine(buf, Empty, MultiLineComment) ;
        next ReadLoop when Empty;

        read(buf, vToken, ReadValid) ;
        if not ReadValid then
          deallocate(buf) ;
          next ReadLoop ;
        end if ;
        next ReadLoop when vToken /= Token ;
        Found := TRUE ;
        exit ReadLoop ;
      end loop ReadLoop ;
    end procedure ReadFindToken ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadQuotedString (
    ------------------------------------------------------------
      variable buf      : inout line ;
      variable Name     : inout line
    ) is
      variable char    : character ;
      variable vString : string(1 to buf'length) ;
      variable Index   : integer := 1 ;
      variable Found, Empty, ReadValid : boolean ;
    begin
      Found := FALSE ;
      if Name /= NULL then
        deallocate(Name) ;
      end if ;

      ReadLoop : loop
        SkipWhiteSpace(buf, Empty) ;  -- Skips white space at beginning of line
        exit ReadLoop when Empty ;

        exit ReadLoop when buf.all(buf'left) /= '"' ;
        Read(buf, Char, ReadValid) ;
        exit ReadLoop when not ReadValid ;

        for i in vString'range loop
          Read(buf, vString(i), ReadValid) ;
          exit ReadLoop when not ReadValid ;
          if vString(i) = '"' then
            Index := i - 1 ;
            Found := TRUE ;
            exit ;
          end if ;
          exit ReadLoop when buf.all'length = 0 ;
        end loop ;
      end loop ReadLoop ;

      if Found then
        Name := new string'(vString(1 to Index)) ;
      end if ;
    end procedure ReadQuotedString ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovModelNameYaml (
    ------------------------------------------------------------
      variable ID          : inout CoverageIDType ;
      file     CovYamlFile :       text ;
      variable Found       : out   boolean
    ) is
      variable buf  : line ;
      variable sName : line ;
    begin
      Found := FALSE ;
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "- Name:", buf, Found) ;
        exit ReadLoop when not Found ;
        -- Get the Name
        ReadQuotedString(buf, sName) ;
        exit when AlertIf(OSVVM_COVERAGE_ALERTLOG_ID, sName = NULL,
            "CoveragePkg.ReadCovYaml: Unnamed Coverage Model.", COV_READ_YAML_ALERT_LEVEL);

--!! TODO: Add reading for ParentName, ReportMode, Search, PrintParent
        if ID.ID > 0 then 
          SetName(ID, sName.all) ; 
        else
          ID := NewID(sName.all, ReportMode => ENABLED, Search => NAME_AND_PARENT, PrintParent => PRINT_NAME_AND_PARENT) ;
        end if ; 
        deallocate(sName) ;
        Found := TRUE ;
        exit ;
      end loop ReadLoop ;
    end procedure ReadCovModelNameYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovSettingsYaml (
    ------------------------------------------------------------
      constant CovID       : in  CoverageIDType ;
      file     CovYamlFile :     text ;
      variable Found       : out boolean
    ) is
      variable buf          : line ;
      variable Name         : line ;
      constant ID           : integer := CovID.ID ;
      constant AlertLogID   : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
      variable vInteger     : integer ;
      variable vReal        : real ;
      variable Seed1, Seed2 : integer ;
      variable ReadValid    : boolean ;
    begin
      Found := FALSE ;
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "Settings:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Settings:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- CovWeight
        ReadFindToken (CovYamlFile, "CovWeight:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Settings:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading CovWeight value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovWeight := vInteger ;

        -- Goal / CovTarget
        ReadFindToken (CovYamlFile, "Goal:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Goal:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vReal, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading CovTarget value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovTarget := vReal ;

       -- WeightMode
        ReadFindToken (CovYamlFile, "WeightMode:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""WeightMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ;
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL,
            "CoveragePkg.ReadCovYaml Error while reading WeightMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "REMAIN" then
          CovStructPtr(ID).WeightMode := REMAIN ;
        else -- at_least
          CovStructPtr(ID).WeightMode := AT_LEAST ;
        end if ;

       -- Seeds
        ReadFindToken (CovYamlFile, "Seeds:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Seeds:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- [
        ReadFindToken (CovYamlFile, "[", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find Seeds ""[""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Seed1, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading Seed1 value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- ,
        ReadFindToken (CovYamlFile, ",", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find Seed #2 "",""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Seed2, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading Seed2 value.", COV_READ_YAML_ALERT_LEVEL) ;

        CovStructPtr(ID).RV := (Seed1, Seed2) ;

       -- CountMode
        ReadFindToken (CovYamlFile, "CountMode:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""CountMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ;
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL,
            "CoveragePkg.ReadCovYaml Error while reading CountMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "COUNT_ALL" then
          CovStructPtr(ID).CountMode := COUNT_ALL ;
        else
          CovStructPtr(ID).CountMode := COUNT_FIRST ;
        end if ;

       -- IllegalMode
        ReadFindToken (CovYamlFile, "IllegalMode:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""IllegalMode:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ;
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL,
            "CoveragePkg.ReadCovYaml Error while reading IllegalMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "ILLEGAL_OFF" then
          CovStructPtr(ID).IllegalMode := ILLEGAL_OFF ;
        elsif Name.all = "ILLEGAL_FAILURE" then
          CovStructPtr(ID).IllegalMode := ILLEGAL_FAILURE ;
        else
          CovStructPtr(ID).IllegalMode := ILLEGAL_ON ;
        end if ;

       -- Threshold
        ReadFindToken (CovYamlFile, "Threshold:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Threshold:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vReal, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading Threshold value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).CovThreshold := vReal ;

       -- ThresholdEnable
        ReadFindToken (CovYamlFile, "ThresholdEnable:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""ThresholdEnable:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ;
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL,
            "CoveragePkg.ReadCovYaml Error while reading IllegalMode value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "TRUE" then
          CovStructPtr(ID).ThresholdingEnable := TRUE ;
        else
          CovStructPtr(ID).ThresholdingEnable := FALSE ;
        end if ;

       -- TotalCovCount - read and toss
        ReadFindToken (CovYamlFile, "TotalCovCount:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""TotalCovCount:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading TotalCovCount value.", COV_READ_YAML_ALERT_LEVEL) ;
        -- Value not used

       -- TotalCovGoal - read and toss
        ReadFindToken (CovYamlFile, "TotalCovGoal:", buf, Found) ;
        exit ReadLoop when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""TotalCovGoal:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, vInteger, ReadValid) ;
        exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading TotalCovGoal value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- End
        Found := TRUE ;
        exit ReadLoop ;
      end loop ReadLoop ;
      deallocate(Name) ;
    end procedure ReadCovSettingsYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovBinInfoYaml (
    ------------------------------------------------------------
      constant CovID       : in  CoverageIDType ;
      file     CovYamlFile :     text ;
      variable Dimensions  : out integer ;
      variable NumBins     : out integer ;
      variable Found       : out boolean
    ) is
      variable buf            : line ;
      variable FieldNameArray : FieldNameArrayType(1 to 20) ;
      constant ID             : integer := CovID.ID ;
      constant AlertLogID     : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
      variable ReadValid      : boolean ;
      variable FoundFieldName : boolean ;
    begin
      Found := FALSE ;
      Dimensions := 0 ;
      NumBins := 0 ;
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "BinInfo:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""BinInfo:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- Dimensions
        ReadFindToken (CovYamlFile, "Dimensions:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Dimensions:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Dimensions, ReadValid) ;
        exit when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading Dimensions value.", COV_READ_YAML_ALERT_LEVEL) ;
        CovStructPtr(ID).BinValLength := Dimensions ;

        -- FieldNames
        ReadFindToken (CovYamlFile, "FieldNames:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""FieldNames:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- FieldNames Values
        FoundFieldName := FALSE ;
        for i in 1 to Dimensions loop
          ReadFindToken (CovYamlFile, "-", buf, Found) ;
          exit when AlertIf(AlertLogID, not Found,
              "CoveragePkg.ReadCovYaml did not find Field Name deliminter '-'.", COV_READ_YAML_ALERT_LEVEL) ;
          ReadQuotedString(buf, FieldNameArray(i)) ;
          exit ReadLoop when AlertIf(AlertLogID, FieldNameArray(i) = NULL,
              "CoveragePkg.ReadCovYaml Error while reading Field Name value # " & to_string(i), COV_READ_YAML_ALERT_LEVEL) ;
          if FieldNameArray(i).all /= ("Bin" & to_string(i)) then
            FoundFieldName := TRUE ;
          end if ;
        end loop ;
        if FoundFieldName then
          CovStructPtr(ID).FieldName := new FieldNameArrayType'(FieldNameArray(1 to Dimensions)) ;
        end if ;

        -- NumBins
        ReadFindToken (CovYamlFile, "NumBins:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""NumBins:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, NumBins, ReadValid) ;
        exit when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading NumBins value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- End
        Found := TRUE ;
        exit ;
      end loop ReadLoop ;
      if not Found or not FoundFieldName then
        -- clean up pointers
        for i in 1 to Dimensions loop
          deallocate(FieldNameArray(i)) ;
        end loop ;
      end if ;
    end procedure ReadCovBinInfoYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovBinValYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ;
      constant AlertLogID  : in  AlertLogIDType ;
      variable BinVal      : out RangeArrayType ;
      variable Found       : out boolean
    ) is
      variable buf         : line ;
      variable Min, Max    : integer ;
      variable ReadValid   : boolean ;
    begin
      Found := FALSE ;
      ReadLoop: loop
        -- Range:
        ReadFindToken (CovYamlFile, "Range:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Range:""", COV_READ_YAML_ALERT_LEVEL) ;

        -- RangeArrayType
        for i in BinVal'range loop
          -- - {Min:
          ReadFindToken (CovYamlFile, "- {Min:", buf, Found) ;
          exit ReadLoop when AlertIf(AlertLogID, not Found,
              "CoveragePkg.ReadCovYaml did not find Bins ""Min:""", COV_READ_YAML_ALERT_LEVEL) ;
          Read(buf, Min, ReadValid) ;
          exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
              "CoveragePkg.ReadCovYaml Error while reading Min value.", COV_READ_YAML_ALERT_LEVEL) ;

          -- , Max:
          ReadFindToken (CovYamlFile, ", Max:", buf, Found) ;
          exit ReadLoop  when AlertIf(AlertLogID, not Found,
              "CoveragePkg.ReadCovYaml did not find Bins ""Max:""", COV_READ_YAML_ALERT_LEVEL) ;
          Read(buf, Max, ReadValid) ;
          exit ReadLoop when AlertIf(AlertLogID, not ReadValid,
              "CoveragePkg.ReadCovYaml Error while reading Max value.", COV_READ_YAML_ALERT_LEVEL) ;

          BinVal(i) := (Min => Min, Max => Max) ;
        end loop ;

        Found := TRUE ;
        exit ReadLoop ;
      end loop ;
    end procedure ReadCovBinValYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovOneBinYaml (
    ------------------------------------------------------------
      file     CovYamlFile :     text ;
      constant CovID       : in  CoverageIDType ;
      constant Merge       : in  boolean ;
      constant Dimensions  : in  integer ;
      variable Found       : out boolean
    ) is
      variable buf         : line ;
      variable Name        : line ;
      constant ID          : integer := CovID.ID ;
      constant AlertLogID  : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
      variable NamePtr     : line ;
      variable Action      : integer ;
      variable BinVal      : RangeArrayType(1 to Dimensions) ;
      variable Count       : integer ;
      variable AtLeast     : integer ;
      variable Weight      : integer ;
      variable PercentCov  : real ;
      variable Index       : integer ;
      variable ReadValid   : boolean ;
    begin
      Found := FALSE ;
      ReadLoop: loop
        -- - Name:
        ReadFindToken (CovYamlFile, "- Name:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find Bins ""Name:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, NamePtr) ;
        exit ReadLoop when AlertIf(AlertLogID, NamePtr = NULL,
            "CoveragePkg.ReadCovYaml Error while reading Name value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- Type:
        ReadFindToken (CovYamlFile, "Type:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Type:""", COV_READ_YAML_ALERT_LEVEL) ;
        ReadQuotedString(buf, Name) ;
        exit ReadLoop when AlertIf(AlertLogID, Name = NULL,
            "CoveragePkg.ReadCovYaml Error while reading Type value.", COV_READ_YAML_ALERT_LEVEL) ;
        if Name.all = "COUNT" then
          Action := 1 ;
        elsif Name.all = "IGNORE" then
          Action := 0 ;
        else -- Illegal
          Action := -1 ;
        end if ;
        deallocate(Name) ;

        -- BinVal
        ReadCovBinValYaml(CovYamlFile, AlertLogID, BinVal, Found) ;
        exit when not Found ;

        -- Count:
        ReadFindToken (CovYamlFile, "Count:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Count:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, Count, ReadValid) ;
        exit when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading Count value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- AtLeast:
        ReadFindToken (CovYamlFile, "AtLeast:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""AtLeast:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, AtLeast, ReadValid) ;
        exit when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading AtLeast value.", COV_READ_YAML_ALERT_LEVEL) ;
        Weight  := AtLeast ;

        -- PercentCov:
        ReadFindToken (CovYamlFile, "PercentCov:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""PercentCov:""", COV_READ_YAML_ALERT_LEVEL) ;
        Read(buf, PercentCov, ReadValid) ;
        exit when AlertIf(AlertLogID, not ReadValid,
            "CoveragePkg.ReadCovYaml Error while reading PercentCov value.", COV_READ_YAML_ALERT_LEVEL) ;

        -- Insert the Bin
        Index := FindExactBin(CovID, Merge, BinVal, Action, AtLeast, -1, NamePtr.all) ;
        if Index > 0 then
          -- Bin is an exact match so only merge the count values
          CovStructPtr(ID).CovBinPtr(Index).Count := CovStructPtr(ID).CovBinPtr(Index).Count + Count ;
          CovStructPtr(ID).CovBinPtr(Index).PercentCov := CalcPercentCov(
              Count   =>  CovStructPtr(ID).CovBinPtr.all(Index).Count,
              AtLeast =>  CovStructPtr(ID).CovBinPtr.all(Index).AtLeast ) ;
        else
          InsertNewBin(CovID, BinVal, Action, Count, AtLeast, Weight, NamePtr.all, PercentCov) ;
        end if ;
        deallocate(NamePtr) ;

        -- End
        Found := TRUE ;
        exit ;
      end loop ReadLoop ;
    end procedure ReadCovOneBinYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovBinsYaml (
    ------------------------------------------------------------
      constant CovID       : in  CoverageIDType ;
      file     CovYamlFile :     text ;
      constant Dimensions  : in  integer ;
      constant NumBins     : in  integer ;
      variable Found       : out boolean ;
      constant Merge       : in  boolean := FALSE
    ) is
      variable buf            : line ;
--sig      variable FieldNameArray : FieldNameArrayType(1 to 20) ;
      constant ID             : integer := CovID.ID ;
      constant AlertLogID     : AlertLogIDType := CovStructPtr(ID).AlertLogID ;
    begin
      Found := FALSE ;
      ReadLoop: loop
        ReadFindToken (CovYamlFile, "Bins:", buf, Found) ;
        exit when AlertIf(AlertLogID, not Found,
            "CoveragePkg.ReadCovYaml did not find ""Bins:""", COV_READ_YAML_ALERT_LEVEL) ;

        GrowBins(CovID, NumBins) ;

        for i in 1 to NumBins loop
          ReadCovOneBinYaml(CovYamlFile, CovID, Merge, Dimensions, Found) ;
          exit ReadLoop when not Found ;
        end loop ;

        -- End
        Found := TRUE ;
        exit ;
      end loop ReadLoop ;
    end procedure ReadCovBinsYaml ;

    ------------------------------------------------------------
    --  pt local
    procedure ReadCovModelYaml (
    ------------------------------------------------------------
      file     CovYamlFile :       text ;
      variable CovID       : inout CoverageIDType ;
      variable Found       : out   boolean ;
      constant Merge       : in    boolean := FALSE
    ) is
      variable Dimensions : integer ;
      variable NumBins    : integer ;
      variable FoundModelName : boolean ;
    begin
      Found          := FALSE ;
      FoundModelName := FALSE ;

      ReadLoop: loop
        ReadCovModelNameYaml(CovID, CovYamlFile, Found) ;
        exit when not Found ;
        FoundModelName := TRUE ;

        if not Merge then  -- remove any old bins
          DeallocateBins(CovID) ;
        end if ;

-- Nothing to do with this for now
--        ReadCovTestCasesYaml(CovID, CovYamlFile, Found) ;
--        exit when not Found ;

-- On merge, new settings apply
        ReadCovSettingsYaml(CovID, CovYamlFile, Found) ;
        exit when not Found ;

-- On merge, new settings apply
        ReadCovBinInfoYaml(CovID, CovYamlFile, Dimensions, NumBins, Found) ;
        exit when not Found ;

        -- On merge, matching bins are merged
        ReadCovBinsYaml(CovID, CovYamlFile, Dimensions, NumBins, Found, Merge) ;
        exit when not Found ;

        -- End
        Found := TRUE ;
        exit ;
      end loop ReadLoop ;

      if FoundModelName and not Found then
        -- remove partially constructed model
        Deallocate(CovID) ;
      end if ;
    end procedure ReadCovModelYaml ;

    ------------------------------------------------------------
    procedure ReadCovYaml (variable ID : inout CoverageIDType; FileName : string := ""; Merge : boolean := FALSE) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := ifelse(FileName = "", OSVVM_TEMP_OUTPUT_DIRECTORY & GetTestName & "_cov.yml", FileName) ;
      file CovYamlFile : text ;
      variable Found   : boolean ;
    begin
      file_open(CovYamlFile, RESOLVED_FILE_NAME, READ_MODE) ;
      ReadCovModelYaml(CovYamlFile, ID, Found, Merge) ;
      file_close(CovYamlFile) ;
    end procedure ReadCovYaml ;

    ------------------------------------------------------------
    procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) is
    ------------------------------------------------------------
      constant RESOLVED_FILE_NAME : string := ifelse(FileName = "", OSVVM_TEMP_OUTPUT_DIRECTORY & GetTestName & "_cov.yml", FileName) ;
      file CovYamlFile : text ;
      variable buf     : line ;
      variable Found   : boolean ;
      variable CovID   : CoverageIDType ;
    begin
      file_open(CovYamlFile, RESOLVED_FILE_NAME, READ_MODE) ;
      ReadFindToken (CovYamlFile, "Models:", buf, Found) ;
      if not Found then
        Alert(OSVVM_COVERAGE_ALERTLOG_ID,
            "No Coverage Models found in " & RESOLVED_FILE_NAME, COV_READ_YAML_ALERT_LEVEL) ;
        return ;
      end if;

      loop
        CovID := CoverageIDType'(ID => integer'low) ;  -- Coverage Model Empty
        ReadCovModelYaml(CovYamlFile, CovID, Found, Merge) ;
        exit when not Found ;
      end loop ;
      file_close(CovYamlFile) ;
    end procedure ReadCovYaml ;

    ------------------------------------------------------------
    impure function GotCoverage return boolean is
    ------------------------------------------------------------
    begin
      for i in 1 to NumItems loop
        if CovStructPtr(i).NumBins >= 1 then
          return TRUE ;
        end if;
      end loop ;
      return FALSE ;
    end function GotCoverage ;
    
    ------------------------------------------------------------
    --  pt local
    procedure RecordCovRequirements (ID : CoverageIDType) is
    ------------------------------------------------------------
      variable CovBin : CovBinInternalBaseType ;
      variable AlertLogID : AlertLogIDType ; 
      variable RequirementsMet : boolean := TRUE ; 
    begin
      if not CovStructPtr(ID.ID).IsRequirement then
        -- this procedure only handles when the model is a requirement.
        return ; 
      end if ; 
      -- COVERAGE_REQUIREMENT_BY_BIN set by OsvvmSettingsPkg
      --   if TRUE, each bin of a coverage model is one requirement. 
      --   if FALSE, an entire coverage model is one requirement, 
      AlertLogID    := CovStructPtr(ID.ID).AlertLogID ;
      if COVERAGE_REQUIREMENT_BY_BIN then  
        SetPassedGoal(AlertLogID, CovStructPtr(ID.ID).NumBins) ; -- Update passed goal to 1 pass per bin in coverage model        
      end if ; 
      
      writeloop : for EachLine in 1 to CovStructPtr(ID.ID).NumBins loop
        CovBin := CovStructPtr(ID.ID).CovBinPtr(EachLine) ;
        case CovBin.Action Is
          when COV_COUNT => 
            if COVERAGE_REQUIREMENT_BY_BIN then 
              --1  AffirmIf( AlertLogID, CovBin.Count >= CovBin.AtLeast, "Coverage Count: " & to_string(CovBin.Count) & "  Goal: " & to_string(CovBin.AtLeast) & ".  Action:  Count") ;
              if CovBin.Count >= CovBin.AtLeast then 
                --3.1  AffirmPassed( AlertLogID, "Coverage Count: " & to_string(CovBin.Count) & "  Goal: " & to_string(CovBin.AtLeast) & ".  Action:  Count") ;  -- info already in print of coverage model
                IncAffirmPassedCount(AlertLogID) ;
              end if ; 
            else 
              if CovBin.Count < CovBin.AtLeast then 
                RequirementsMet := FALSE ;
              end if ; 
            end if ; 
          when COV_ILLEGAL => 
            if COVERAGE_REQUIREMENT_BY_BIN then 
              --1  AffirmIf( AlertLogID, CovBin.Count = 0, "Coverage Count: " & to_string(abs(CovBin.Count)) & "  Goal: 0.  Action: Illegal" ) ;
              if CovBin.Count = 0 then 
                --3.1 AffirmPassed(AlertLogID, "Coverage Count: " & to_string(abs(CovBin.Count)) & "  Goal: 0.  Action: Illegal" ) ; -- info already in print of coverage model
                IncAffirmPassedCount(AlertLogID) ;
              end if ; 
            else 
              if CovBin.Count /= 0 then 
                RequirementsMet := FALSE ;
              end if ; 
            end if ; 
          when others => 
            if COVERAGE_REQUIREMENT_BY_BIN then 
              -- Counting Ignore bins as anything other than PASSED is contrary to the definition of an ignore bin.
              -- Count of an ignore bin is always 0 so there is nothing to check.
              IncAffirmPassedCount(AlertLogID) ;
              -- ignore bins always pass
            end if ; 
        end case ; 
      end loop writeloop ;
      if not COVERAGE_REQUIREMENT_BY_BIN then 
        --2   AffirmIf(AlertLogID, RequirementsMet, "Coverage Bin: " & CovBin.Name.all & "  Requirements met = " & to_upper(to_string(RequirementsMet)) ) ; 
        if RequirementsMet then 
          IncAffirmPassedCount(AlertLogID) ;
        end if ; 
      end if ; 
    end procedure RecordCovRequirements ;
    
    ------------------------------------------------------------
    procedure RecordCovRequirements is
    ------------------------------------------------------------
    begin

      for i in 1 to NumItems loop
        if CovStructPtr(i).NumBins >= 1 then
          RecordCovRequirements(CoverageIDType'(ID => i)) ;
        end if ;
      end loop ;
    end procedure RecordCovRequirements ;

    ------------------------------------------------------------
    procedure SetErrorIfNotCovered(Checked : boolean := FALSE) is 
    ------------------------------------------------------------
    begin
      ErrorIfNotCoveredVar             := TRUE ;
--!!      if Checked then 
--!!        CheckedForErrorIfNotCoveredVar := TRUE ;
--!!      end if ; 
    end procedure SetErrorIfNotCovered ;

    ------------------------------------------------------------
    impure function GetErrorCount (ID : CoverageIDType) return integer is
    ------------------------------------------------------------
      variable ErrorCnt : integer := 0 ;
    begin
      if CovStructPtr(ID.ID).NumBins < 1 then
        return 1 ;  -- return error if model empty
      else
        for i in 1 to CovStructPtr(ID.ID).NumBins loop
          if CovStructPtr(ID.ID).CovBinPtr(i).count < 0 then -- illegal CovBin
            ErrorCnt := ErrorCnt + CovStructPtr(ID.ID).CovBinPtr(i).count ;
          end if ;
        end loop ;
        return - ErrorCnt ;
      end if ;
    end function GetErrorCount ;

    ------------------------------------------------------------
    --  pt local
    -- Adjusted InsertBin
    --   Ensures minimum of Count and AtLeast are 1
    procedure AdjustedInsertBin (
      ID           : CoverageIDType ;
      BinVal       : RangeArrayType ;
      Action       : integer ;
      Count        : integer ;
      AtLeast      : integer ;
      Weight       : integer ;
      Name         : string
    ) is
      variable vCalcAtLeast : integer ;
      variable vCalcWeight  : integer ;
    begin
      if Action = COV_COUNT then
        vCalcAtLeast := maximum(0, AtLeast) ;
        vCalcWeight  := maximum(0,  Weight) ;
      else
        vCalcAtLeast := 0 ;
        vCalcWeight  := 0 ;
      end if ;
      InsertBin(
        ID       => ID,
        BinVal   => BinVal,
        Action   => Action,
        Count    => Count,
        AtLeast  => vCalcAtLeast,
        Weight   => vCalcWeight,
        Name     => Name
      ) ;
    end procedure AdjustedInsertBin ;

    ------------------------------------------------------------
    -- These support usage of cross coverage constants
    -- Also support the older AddCross(GenCross(...)) methodology
    -- which has been replaced by AddCross(GenBin, GenBin, ...)
    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix2Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 2) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        InsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix3Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 3) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix4Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 4) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix5Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 5) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix6Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 6) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix7Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 7) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix8Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 8) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix9Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      if BinValLengthNotEqual(ID, 9) then
        Alert(CovStructPtr(ID.ID).AlertLogID, "CoveragePkg.AddCross: Cross coverage bins of different dimensions prohibited", FAILURE) ;
        return ;
      end if ;
      GrowBins(ID, CovBin'length) ;
      for i in CovBin'range loop
        AdjustedInsertBin(ID,
          CovBin(i).BinVal, CovBin(i).Action, CovBin(i).Count,
          CovBin(i).AtLeast, CovBin(i).Weight, Name
        ) ;
      end loop ;
    end procedure AddCross ;

--!!!! How to handle this - do not support in main interface
--------------------------------------------------------------
--------------------------------------------------------------
-- Deprecated / Subsumed by versions with PercentCov Parameter
-- Maintained for backward compatibility only and
-- may be removed in the future.
-- ------------------------------------------------------------
   ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function CountCovHoles (ID : CoverageIDType; AtLeast : integer ) return integer is
    ------------------------------------------------------------
      variable HoleCount : integer := 0 ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
--         if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < minimum(AtLeast, CovStructPtr(ID.ID).CovBinPtr(i).AtLeast) then
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < AtLeast then
          HoleCount := HoleCount + 1 ;
        end if ;
      end loop CovLoop ;
      return HoleCount ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function IsCovered (ID : CoverageIDType; AtLeast : integer ) return boolean is
    ------------------------------------------------------------
    begin
      return CountCovHoles(ID, AtLeast) = 0 ;
    end function IsCovered ;

    ------------------------------------------------------------
    impure function CalcWeight (ID : CoverageIDType; BinIndex : integer ; MaxAtLeast : integer  ) return integer is
    --  pt local
    ------------------------------------------------------------
    begin
      case CovStructPtr(ID.ID).WeightMode is
        when AT_LEAST =>
          return CovStructPtr(ID.ID).CovBinPtr(BinIndex).AtLeast ;

        when WEIGHT =>
          return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight ;

        when REMAIN =>
          return MaxAtLeast - CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ;

        when REMAIN_SCALED =>
          -- Experimental may be removed
          return integer( Ceil( CovStructPtr(ID.ID).WeightScale * real(MaxAtLeast))) -
                          CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ;

        when REMAIN_WEIGHT =>
          -- Experimental may be removed
          return CovStructPtr(ID.ID).CovBinPtr(BinIndex).Weight * (
                   integer( Ceil( CovStructPtr(ID.ID).WeightScale * real(MaxAtLeast))) -
                   CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ) ;

        when others =>
          Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.CalcWeight:" &
                      " Selected Weight Mode not supported with deprecated RandCovPoint(AtLeast), see RandCovPoint(PercentCov)", FAILURE) ;
          return MaxAtLeast - CovStructPtr(ID.ID).CovBinPtr(BinIndex).Count ;

      end case ;
    end function CalcWeight ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    -- If keep this, need to be able to scale AtLeast Value
    impure function GetRandIndex (ID : CoverageIDType; AtLeast : integer ) return integer is
    --  pt local
    ------------------------------------------------------------
      variable WeightVec : integer_vector(0 to CovStructPtr(ID.ID).NumBins-1) ;  -- Prep for change to DistInt
      variable MinCount, AdjAtLeast, MaxAtLeast : integer ;
      variable rInt : integer ;
    begin
      CovStructPtr(ID.ID).ItemCount := CovStructPtr(ID.ID).ItemCount + 1 ;
      MinCount := GetMinCount(ID) ;
      -- iAtLeast := integer(ceil(CovStructPtr(ID.ID).CovTarget * real(AtLeast)/100.0)) ;
      if CovStructPtr(ID.ID).ThresholdingEnable then
        AdjAtLeast := MinCount + integer(CovStructPtr(ID.ID).CovThreshold) + 1 ;
        if MinCount < AtLeast then
          -- Clip at AtLeast until reach AtLeast
          AdjAtLeast := minimum(AdjAtLeast, AtLeast) ;
        end if ;
      else
        if MinCount < AtLeast then
          AdjAtLeast := AtLeast ;  -- Valid
        else
          -- Done, Enable all bins
          -- AdjAtLeast := integer'high ;  -- Get All
          AdjAtLeast := GetMaxCount(ID) + 1 ;  -- Get All
        end if ;
      end if;
      MaxAtLeast := AdjAtLeast ;
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
--         if not CovStructPtr(ID.ID).ThresholdingEnable then
--           -- When not thresholding, consider bin Bin.AtLeast
--           -- iBinAtLeast := integer(ceil(CovStructPtr(ID.ID).CovTarget * real(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)/100.0)) ;
--           MaxAtLeast := maximum(AdjAtLeast, CovStructPtr(ID.ID).CovBinPtr(i).AtLeast) ;
--         end if ;
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < MaxAtLeast then
          WeightVec(i-1) := CalcWeight(ID, i, MaxAtLeast ) ; -- CovStructPtr(ID.ID).CovBinPtr(i).Weight ;
        else
          WeightVec(i-1) := 0 ;
        end if ;
      end loop CovLoop ;
      -- DistInt returns integer range 0 to CovStructPtr(ID.ID).NumBins-1
--      CovStructPtr(ID.ID).LastStimGenIndex := 1 + RV.DistInt( WeightVec )  ; -- return range 1 to CovStructPtr(ID.ID).NumBins
      DistInt(CovStructPtr(ID.ID).RV, rInt, WeightVec) ;
      CovStructPtr(ID.ID).LastStimGenIndex := 1 + rInt  ; -- return range 1 to CovStructPtr(ID.ID).NumBins
      CovStructPtr(ID.ID).LastIndex := CovStructPtr(ID.ID).LastStimGenIndex ;
      return CovStructPtr(ID.ID).LastStimGenIndex ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function RandCovBinVal (ID : CoverageIDType; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return CovStructPtr(ID.ID).CovBinPtr( GetRandIndex(ID, AtLeast) ).BinVal.all ;  -- GetBinVal
    end function RandCovBinVal ;

-- Maintained for backward compatibility.  Repeated until aliases work for methods
    ------------------------------------------------------------
    -- Deprecated+  New versions use PercentCov.  Name change.
    impure function RandCovHole (ID : CoverageIDType; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return RandCovBinVal(ID, AtLeast) ;  -- GetBinVal
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function RandCovPoint (ID : CoverageIDType; AtLeast : integer ) return integer is
    ------------------------------------------------------------
      variable BinVal : RangeArrayType(1 to 1) ;
      variable rInt   : integer ;
    begin
      BinVal := RandCovBinVal(ID, AtLeast) ;
--      return RV.RandInt(BinVal(1).min, BinVal(1).max) ;
      Uniform(CovStructPtr(ID.ID).RV, rInt, BinVal(1).min, BinVal(1).max) ;
      return rInt ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    impure function RandCovPoint (ID : CoverageIDType; AtLeast : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return ToRandPoint(ID, RandCovBinVal(ID, AtLeast)) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
      variable HoleCount : integer := 0 ;
--sig      variable buf : line ;
    begin
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
--        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < minimum(AtLeast, CovStructPtr(ID.ID).CovBinPtr(i).AtLeast) then
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < AtLeast then
          HoleCount := HoleCount + 1 ;
          if HoleCount = ReqHoleNum  then
           return CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all ;
          end if ;
        end if ;
      end loop CovLoop ;
      Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.GetHoleBinVal:" &
                    " did not find hole.  HoleCount = " & integer'image(HoleCount) &
                    "ReqHoleNum = " & integer'image(ReqHoleNum), ERROR
      ) ;
      return CovStructPtr(ID.ID).CovBinPtr(CovStructPtr(ID.ID).NumBins).BinVal.all ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    -- Deprecated+.  New versions use PercentCov.  Name Change.
    impure function GetCovHole (ID : CoverageIDType; ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(ID, ReqHoleNum, AtLeast) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    --  pt local
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles (ID : CoverageIDType; file f : text;  AtLeast : integer;  UsingLocalFile : boolean := FALSE ) is
    ------------------------------------------------------------
      -- variable minAtLeast : integer ;
      variable buf : line ;
    begin
      WriteBinName(ID, buf, "WriteCovHoles: ") ;
--      writeline(f, buf) ;
      if CovStructPtr(ID.ID).NumBins < 1 then
        if WriteBinFileInit or UsingLocalFile then
          -- Duplicate Alert in specified file
          swrite(buf, "%% Alert FAILURE " & GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteCovHoles:" &
                      " coverage model is empty.  Nothing to print.") ;
          writeline(f, buf) ;
        end if ;
        Alert(CovStructPtr(ID.ID).AlertLogID, GetNamePlus(ID, prefix => "in ", suffix => ", ") & "CoveragePkg.WriteCovHoles:" &
                      " coverage model is empty.  Nothing to print.", FAILURE) ;
      end if ;
      CovLoop : for i in 1 to CovStructPtr(ID.ID).NumBins loop
--        minAtLeast := minimum(AtLeast,CovStructPtr(ID.ID).CovBinPtr(i).AtLeast) ;
--         if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < minAtLeast then
        if CovStructPtr(ID.ID).CovBinPtr(i).action = COV_COUNT and CovStructPtr(ID.ID).CovBinPtr(i).Count < AtLeast then
          swrite(buf, "%% Bin:") ;
          write(buf, CovStructPtr(ID.ID).CovBinPtr(i).BinVal.all) ;
          write(buf, "  Count = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Count)) ;
          write(buf, "  AtLeast = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).AtLeast)) ;
          if CovStructPtr(ID.ID).WeightMode = WEIGHT or CovStructPtr(ID.ID).WeightMode = REMAIN_WEIGHT then
            -- Print Weight only when it is used
            write(buf, "  Weight = " & integer'image(CovStructPtr(ID.ID).CovBinPtr(i).Weight)) ;
          end if ;
          writeline(f, buf) ;
        end if ;
      end loop CovLoop ;
      swrite(buf, "") ;
      writeline(f, buf) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles (ID : CoverageIDType; AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      if WriteBinFileInit then
        -- Write to Local OsvvmCoverageWriteBinFile - Deprecated, recommend use TranscriptFile instead
        WriteCovHoles(ID, OsvvmCoverageWriteBinFile, AtLeast) ;
      elsif IsTranscriptEnabled then
        -- Write to TranscriptFile
        WriteCovHoles(ID, TranscriptFile, AtLeast) ;
        if IsTranscriptMirrored then
          -- Mirrored to OUTPUT
          WriteCovHoles(ID, OUTPUT, AtLeast) ;
        end if ;
      else
        -- Default Write to OUTPUT
        WriteCovHoles(ID, OUTPUT, AtLeast) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType ; AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, AtLeast) ;
      end if;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles (ID : CoverageIDType; FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
--x      file CovHoleFile : text open OpenKind is FileName ;
      file CovHoleFile : text ;
    begin
      file_open(CovHoleFile, FileName, OpenKind) ;
      WriteCovHoles(ID, CovHoleFile, AtLeast, TRUE) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType ; FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      if IsLogEnabled(CovStructPtr(ID.ID).AlertLogID, LogLevel) then
        WriteCovHoles(ID, FileName, AtLeast, OpenKind) ;
      end if;
    end procedure WriteCovHoles ;


------------------------------------------------------------
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- Compatibility Methods - Allows CoveragePkg to Work as a PT still
-- /////////////////////////////////////////
-- /////////////////////////////////////////
------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
      SetAlertLogID(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) is
    ------------------------------------------------------------
      constant SeedInit : boolean := CovStructPtr(COV_STRUCT_ID_DEFAULT.ID).RvSeedInit ;
    begin
      SetAlertLogID(COV_STRUCT_ID_DEFAULT, Name, ParentID, CreateHierarchy) ;
      if not SeedInit then
        InitSeed(COV_STRUCT_ID_DEFAULT, Name) ;
      end if ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    impure function GetAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
    begin
      return GetAlertLogID(COV_STRUCT_ID_DEFAULT) ;
    end function GetAlertLogID ;

    ------------------------------------------------------------
    procedure SetName (Name : String) is
    ------------------------------------------------------------
      constant SeedInit : boolean := CovStructPtr(COV_STRUCT_ID_DEFAULT.ID).RvSeedInit ;
    begin
      SetName(COV_STRUCT_ID_DEFAULT, Name) ;
      if not SeedInit then
        InitSeed(COV_STRUCT_ID_DEFAULT, Name) ;
      end if ;
    end procedure SetName ;

    ------------------------------------------------------------
    impure function SetName (Name : String) return string is
    ------------------------------------------------------------
    begin
      SetName(Name) ; -- call procedure above
      return Name ;
    end function SetName ;

    ------------------------------------------------------------
    impure function GetName return String is
    ------------------------------------------------------------
    begin
      return GetName(COV_STRUCT_ID_DEFAULT) ;
    end function GetName ;

    ------------------------------------------------------------
    impure function GetCovModelName return String is
    ------------------------------------------------------------
    begin
      return GetCovModelName(COV_STRUCT_ID_DEFAULT) ;
    end function GetCovModelName ;

    ------------------------------------------------------------
    impure function GetNamePlus(prefix, suffix : string) return String is
    ------------------------------------------------------------
    begin
      return GetNamePlus(COV_STRUCT_ID_DEFAULT, prefix, suffix) ;
    end function GetNamePlus ;

    ------------------------------------------------------------
    procedure SetMessage (Message : String) is
    ------------------------------------------------------------
      constant SeedInit : boolean := CovStructPtr(COV_STRUCT_ID_DEFAULT.ID).RvSeedInit ;
    begin
      SetMessage(COV_STRUCT_ID_DEFAULT, Message) ;
      if not SeedInit then
        InitSeed(COV_STRUCT_ID_DEFAULT, Message) ;
      end if ;
    end procedure SetMessage ;

    ------------------------------------------------------------
    procedure SetNextPointMode (A : NextPointModeType) is
    ------------------------------------------------------------
    begin
      SetNextPointMode(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetNextPointMode ;

    ------------------------------------------------------------
    procedure SetIllegalMode (A : IllegalModeType) is
    ------------------------------------------------------------
    begin
      SetIllegalMode(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetIllegalMode ;

    ------------------------------------------------------------
    procedure SetWeightMode (A : WeightModeType;  Scale : real := 1.0) is
    ------------------------------------------------------------
    begin
      SetWeightMode(COV_STRUCT_ID_DEFAULT, A, Scale) ;
    end procedure SetWeightMode ;

    ------------------------------------------------------------
    procedure DeallocateMessage is
    ------------------------------------------------------------
    begin
      DeallocateMessage(COV_STRUCT_ID_DEFAULT) ;
    end procedure DeallocateMessage ;

    ------------------------------------------------------------
    procedure DeallocateName is
    ------------------------------------------------------------
    begin
      DeallocateName(COV_STRUCT_ID_DEFAULT) ;
    end procedure DeallocateName ;

    ------------------------------------------------------------
    procedure SetThresholding (A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      SetThresholding(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetThresholding ;

    ------------------------------------------------------------
    procedure SetCovThreshold (Percent : real) is
    ------------------------------------------------------------
    begin
      SetCovThreshold(COV_STRUCT_ID_DEFAULT, Percent) ;
    end procedure SetCovThreshold ;

    ------------------------------------------------------------
    procedure SetCovTarget (Percent : real) is
    ------------------------------------------------------------
    begin
      SetCovTarget(COV_STRUCT_ID_DEFAULT, Percent) ;
    end procedure SetCovTarget ;

    ------------------------------------------------------------
    impure function GetCovTarget return real is
    ------------------------------------------------------------
    begin
      return GetCovTarget(COV_STRUCT_ID_DEFAULT) ;
    end function GetCovTarget ;

    ------------------------------------------------------------
    procedure SetMerging (A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      SetMerging(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetMerging ;

    ------------------------------------------------------------
    procedure SetCountMode (A : CountModeType) is
    ------------------------------------------------------------
    begin
      SetCountMode(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure SetCountMode ;

    ------------------------------------------------------------
    procedure InitSeed (S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
    ------------------------------------------------------------
    begin
      InitSeed(COV_STRUCT_ID_DEFAULT, S, UseNewSeedMethods) ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    impure function InitSeed (S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) return string is
    ------------------------------------------------------------
    begin
      return InitSeed(COV_STRUCT_ID_DEFAULT, S, UseNewSeedMethods) ;
    end function InitSeed ;

    ------------------------------------------------------------
    procedure InitSeed (I : integer;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
    ------------------------------------------------------------
    begin
      InitSeed(COV_STRUCT_ID_DEFAULT, I, UseNewSeedMethods) ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    procedure SetSeed (RandomSeedIn : RandomSeedType ) is
    ------------------------------------------------------------
    begin
      SetSeed(COV_STRUCT_ID_DEFAULT, RandomSeedIn) ;
    end procedure SetSeed ;

    ------------------------------------------------------------
    impure function GetSeed return RandomSeedType is
    ------------------------------------------------------------
    begin
      return GetSeed(COV_STRUCT_ID_DEFAULT) ;
    end function GetSeed ;

    ------------------------------------------------------------
    procedure SetBinSize (NewNumBins : integer) is
    -- Sets a CovBin to a particular size
    -- Use for small bins to save space or large bins to
    -- suppress the resize and copy as a CovBin autosizes.
    ------------------------------------------------------------
    begin
      SetBinSize(COV_STRUCT_ID_DEFAULT, NewNumBins) ;
    end procedure SetBinSize ;

    ------------------------------------------------------------
    procedure AddBins (
    ------------------------------------------------------------
      Name    : String ;
      AtLeast : integer ;
      Weight  : integer ;
      CovBin  : CovBinType
    ) is
    begin
      AddBins(COV_STRUCT_ID_DEFAULT, Name, AtLeast, Weight, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( Name : String ; AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins(Name, AtLeast, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (Name : String ;  CovBin : CovBinType) is
    ------------------------------------------------------------
    begin
      AddBins(Name, 1, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins("", AtLeast, Weight, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins("", AtLeast, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( CovBin : CovBinType  ) is
    ------------------------------------------------------------
    begin
      AddBins("", 1, 1, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      Name       : string ;
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, Name, AtLeast, Weight,
        Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10,
        Bin11, Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      Name       : string ;
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(Name, AtLeast, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      Name       : string ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross(Name, 1, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      AtLeast    : integer ;
      Weight     : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross("", AtLeast, Weight,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      AtLeast    : integer ;
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross("", AtLeast, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross(
    ------------------------------------------------------------
      Bin1, Bin2 : CovBinType ;
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
    ) is
    begin
      AddCross("", 1, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure Deallocate is
    ------------------------------------------------------------
    begin
      ResetReportOptions ;
      Deallocate(COV_STRUCT_ID_DEFAULT) ;
    end procedure deallocate ;

    ------------------------------------------------------------
    procedure ICoverLast is
    ------------------------------------------------------------
    begin
      ICoverLast(COV_STRUCT_ID_DEFAULT) ;
    end procedure ICoverLast ;

    ------------------------------------------------------------
    procedure ICover ( CovPoint : integer) is
    ------------------------------------------------------------
    begin
      ICover(COV_STRUCT_ID_DEFAULT, (1=> CovPoint)) ;
    end procedure ICover ;

    ------------------------------------------------------------
    procedure ICover( CovPoint : integer_vector) is
    ------------------------------------------------------------
    begin
      ICover(COV_STRUCT_ID_DEFAULT, CovPoint) ;
     end procedure ICover ;

    ------------------------------------------------------------
    procedure TCover ( A : integer) is
    ------------------------------------------------------------
    begin
      TCover(COV_STRUCT_ID_DEFAULT, A) ;
    end procedure TCover ;


    ------------------------------------------------------------
    procedure ClearCov is
    ------------------------------------------------------------
    begin
      ClearCov(COV_STRUCT_ID_DEFAULT) ;
    end procedure ClearCov ;

    ------------------------------------------------------------
    -- deprecated
    procedure SetCovZero is
    ------------------------------------------------------------
    begin
      ClearCov(COV_STRUCT_ID_DEFAULT) ;
    end procedure SetCovZero ;

    ------------------------------------------------------------
    impure function IsInitialized return boolean is
    ------------------------------------------------------------
    begin
      return IsInitialized(COV_STRUCT_ID_DEFAULT) ;
    end function IsInitialized ;

    ------------------------------------------------------------
    impure function GetMinCov return real is
    ------------------------------------------------------------
    begin
      return GetMinCov(COV_STRUCT_ID_DEFAULT) ;
    end function GetMinCov ;

    ------------------------------------------------------------
    impure function GetMinCount return integer is
    ------------------------------------------------------------
    begin
      return GetMinCount (COV_STRUCT_ID_DEFAULT);
    end function GetMinCount ;

    ------------------------------------------------------------
    impure function GetMaxCov return real is
    ------------------------------------------------------------
    begin
      return GetMaxCov(COV_STRUCT_ID_DEFAULT) ;
    end function GetMaxCov ;

    ------------------------------------------------------------
    impure function GetMaxCount return integer is
    ------------------------------------------------------------
    begin
      return GetMaxCount(COV_STRUCT_ID_DEFAULT);
    end function GetMaxCount ;

    ------------------------------------------------------------
    impure function CountCovHoles ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return CountCovHoles(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    impure function CountCovHoles return integer is
    ------------------------------------------------------------
    begin
      return CountCovHoles(COV_STRUCT_ID_DEFAULT) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    impure function IsCovered ( PercentCov : real ) return boolean is
    ------------------------------------------------------------
    begin
      return IsCovered(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function IsCovered ;

    ------------------------------------------------------------
    impure function IsCovered return boolean is
    ------------------------------------------------------------
    begin
      return IsCovered(COV_STRUCT_ID_DEFAULT) ;
    end function IsCovered ;

    ------------------------------------------------------------
    impure function GetCov ( PercentCov : real ) return real is
    ------------------------------------------------------------
    begin
      return GetCov(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetCov return real is
    ------------------------------------------------------------
    begin
      return GetCov(COV_STRUCT_ID_DEFAULT ) ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetItemCount return integer is
    ------------------------------------------------------------
    begin
      return GetItemCount(COV_STRUCT_ID_DEFAULT) ;
    end function GetItemCount ;

    ------------------------------------------------------------
    impure function GetTotalCovCount ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovCount(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovCount return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovCount(COV_STRUCT_ID_DEFAULT) ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovGoal(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetTotalCovGoal ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovGoal(COV_STRUCT_ID_DEFAULT) ;
    end function GetTotalCovGoal ;

    -- Return Index Values
    ------------------------------------------------------------
    impure function GetNumBins return integer is
    ------------------------------------------------------------
    begin
      return GetNumBins(COV_STRUCT_ID_DEFAULT) ;
    end function GetNumBins ;

    ------------------------------------------------------------
    impure function GetLastIndex return integer is
    ------------------------------------------------------------
    begin
      return GetLastIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetLastIndex ;

    ------------------------------------------------------------
    impure function GetRandIndex ( CovTargetPercent : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetRandIndex(COV_STRUCT_ID_DEFAULT, CovTargetPercent) ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetRandIndex return integer is
    ------------------------------------------------------------
    begin
      return GetRandIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetIncIndex return integer is
    ------------------------------------------------------------
    begin
      return GetIncIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetIncIndex ;

    ------------------------------------------------------------
    impure function GetMinIndex return integer is
    ------------------------------------------------------------
    begin
      return GetMinIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetMinIndex ;

    ------------------------------------------------------------
    impure function GetMaxIndex return integer is
    ------------------------------------------------------------
    begin
      return GetMaxIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetMaxIndex ;

    ------------------------------------------------------------
    impure function GetNextIndex (Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      return GetNextIndex(COV_STRUCT_ID_DEFAULT, Mode) ;
    end function GetNextIndex;

    ------------------------------------------------------------
    impure function GetNextIndex return integer is
    ------------------------------------------------------------
    begin
      return GetNextIndex(COV_STRUCT_ID_DEFAULT) ;
    end function GetNextIndex ;

    -- Return BinVals
    ------------------------------------------------------------
    impure function GetBinVal ( BinIndex : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetBinVal(COV_STRUCT_ID_DEFAULT, BinIndex ) ;
    end function GetBinVal ;

    ------------------------------------------------------------
    impure function GetLastBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetLastBinVal(COV_STRUCT_ID_DEFAULT) ;
    end function GetLastBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetRandBinVal(COV_STRUCT_ID_DEFAULT, PercentCov) ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetRandBinVal(COV_STRUCT_ID_DEFAULT) ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetIncBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetIncBinVal( COV_STRUCT_ID_DEFAULT ) ;
    end function GetIncBinVal ;

    ------------------------------------------------------------
    impure function GetMinBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetMinBinVal( COV_STRUCT_ID_DEFAULT ) ;
    end function GetMinBinVal ;

    ------------------------------------------------------------
    impure function GetMaxBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetMaxBinVal( COV_STRUCT_ID_DEFAULT ) ;
    end function GetMaxBinVal ;

    ------------------------------------------------------------
    impure function GetNextBinVal (Mode : NextPointModeType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetNextBinVal (COV_STRUCT_ID_DEFAULT, Mode) ;
    end function GetNextBinVal;

    ------------------------------------------------------------
    impure function GetNextBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetNextBinVal (COV_STRUCT_ID_DEFAULT) ;
    end function GetNextBinVal ;

    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetRandBinVal(COV_STRUCT_ID_DEFAULT, PercentCov) ;  -- GetBinVal
    end function RandCovBinVal ;


    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetRandBinVal(COV_STRUCT_ID_DEFAULT) ;  -- GetBinVal
    end function RandCovBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(COV_STRUCT_ID_DEFAULT, ReqHoleNum, PercentCov) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(COV_STRUCT_ID_DEFAULT, 1, PercentCov) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( ReqHoleNum : integer := 1 ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(COV_STRUCT_ID_DEFAULT, ReqHoleNum) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetPoint ( BinIndex : integer ) return integer is
    ------------------------------------------------------------
    begin
      return     GetPoint(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetPoint ( BinIndex : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetPoint(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint ( PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetIncPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetIncPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetMinPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetMinPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetMaxPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetMaxPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint (Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(COV_STRUCT_ID_DEFAULT, Mode) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    impure function GetNextPoint (Mode : NextPointModeType) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(COV_STRUCT_ID_DEFAULT, Mode) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    impure function GetNextPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(COV_STRUCT_ID_DEFAULT) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint ( PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function RandCovPoint ;

    -- ------------------------------------------------------------
    -- Intended as a stand in until we get a more general GetBin
    impure function GetBinInfo ( BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBinInfo(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBinInfo ;

    -- ------------------------------------------------------------
    -- Intended as a stand in until we get a more general GetBin
    impure function GetBinValLength return integer is
    -- ------------------------------------------------------------
    begin
      return     GetBinValLength(COV_STRUCT_ID_DEFAULT) ;
    end function GetBinValLength ;

-- Eventually the multiple GetBin functions will be replaced by a
-- a single GetBin that returns CovBinBaseType with BinVal as an
-- unconstrained element
    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix2BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix3BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix4BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix5BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix6BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix7BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix8BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;


    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix9BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(COV_STRUCT_ID_DEFAULT, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBinName ( BinIndex : integer; DefaultName : string := "" ) return string is
    -- ------------------------------------------------------------
    begin
      return GetBinName(COV_STRUCT_ID_DEFAULT, BinIndex, DefaultName) ;
    end function GetBinName;

    ------------------------------------------------------------
    procedure WriteBin (
    ------------------------------------------------------------
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string         := OSVVM_STRING_INIT_PARM_DETECT
    ) is
--!!      constant rWritePassFail   : OsvvmOptionsType := ResolveCovWritePassFail  (WritePassFail,    WritePassFailVar) ;
--!!      constant rWriteBinInfo    : OsvvmOptionsType := ResolveCovWriteBinInfo   (WriteBinInfo,     WriteBinInfoVar  ) ;
--!!      constant rWriteCount      : OsvvmOptionsType := ResolveCovWriteCount     (WriteCount,       WriteCountVar    ) ;
--!!      constant rWriteAnyIllegal : OsvvmOptionsType := ResolveCovWriteAnyIllegal(WriteAnyIllegal,  WriteAnyIllegalVar) ;
      constant rWritePassFail   : boolean := IfElse(WritePassFail   /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WritePassFail),    WritePassFailVar) ;
      constant rWriteBinInfo    : boolean := IfElse(WriteBinInfo    /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteBinInfo),     WriteBinInfoVar  ) ;
      constant rWriteCount      : boolean := IfElse(WriteCount      /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteCount),       WriteCountVar    ) ;
      constant rWriteAnyIllegal : boolean := IfElse(WriteAnyIllegal /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteAnyIllegal),  WriteAnyIllegalVar) ;
      -- constant rWritePrefix     : string         := ResolveOsvvmWritePrefix  (WritePrefix,      WritePrefixVar.GetOpt) ;
      -- constant rPassName        : string         := ResolveOsvvmPassName     (PassName,         PassNameVar.GetOpt  ) ;
      -- constant rFailName        : string         := ResolveOsvvmFailName     (FailName,         FailNameVar.GetOpt  ) ;
      variable buf : line ;
    begin
      WriteBin (
        ID              => COV_STRUCT_ID_DEFAULT,
        buf             => buf,
        WritePassFail   => rWritePassFail,
        WriteBinInfo    => rWriteBinInfo,
        WriteCount      => rWriteCount,
        WriteAnyIllegal => rWriteAnyIllegal,
--!!        WritePrefix     => rWritePrefix,
--!!        PassName        => rPassName,
--!!        FailName        => rFailName
--!!        WritePrefix     => ResolveOsvvmWritePrefix  (WritePrefix,      WritePrefixVar.GetOpt),
--!!        PassName        => ResolveOsvvmPassName     (PassName,         PassNameVar.GetOpt  ),
--!!        FailName        => ResolveOsvvmFailName     (FailName,         FailNameVar.GetOpt  )
        WritePrefix     => COVERAGE_PRINT_PREFIX,
        PassName        => COVERAGE_PASS_NAME,
        FailName        => COVERAGE_FAIL_NAME
        ) ;
      WriteToCovFile(buf) ;
    end procedure WriteBin ;

    ------------------------------------------------------------
    -- Deprecated
    procedure WriteBin (  -- With LogLevel
    ------------------------------------------------------------
      LogLevel        : LogType ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string         := OSVVM_STRING_INIT_PARM_DETECT
    ) is
    begin
      if IsLogEnabled(CovStructPtr(COV_STRUCT_ID_DEFAULT.ID).AlertLogID, LogLevel) then
        WriteBin (
          WritePassFail   => WritePassFail,
          WriteBinInfo    => WriteBinInfo,
          WriteCount      => WriteCount,
          WriteAnyIllegal => WriteAnyIllegal,
          WritePrefix     => WritePrefix,
          PassName        => PassName,
          FailName        => FailName
        ) ;
      end if ;
    end procedure WriteBin ;  -- With LogLevel

    ------------------------------------------------------------
    procedure WriteBin (
    ------------------------------------------------------------
      FileName        : string;
      OpenKind        : File_Open_Kind   := APPEND_MODE ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string           := OSVVM_STRING_INIT_PARM_DETECT ;  --!! Deprecated
      PassName        : string           := OSVVM_STRING_INIT_PARM_DETECT ;  --!! Deprecated
      FailName        : string           := OSVVM_STRING_INIT_PARM_DETECT    --!! Deprecated
    ) is
--x      file LocalWriteBinFile : text open OpenKind is FileName ;
      file LocalWriteBinFile : text ;
--!!      constant rWritePassFail   : OsvvmOptionsType := ResolveCovWritePassFail   (WritePassFail,    WritePassFailVar) ;
--!!      constant rWriteBinInfo    : OsvvmOptionsType := ResolveCovWriteBinInfo    (WriteBinInfo,     WriteBinInfoVar  ) ;
--!!      constant rWriteCount      : OsvvmOptionsType := ResolveCovWriteCount      (WriteCount,       WriteCountVar    ) ;
--!!      constant rWriteAnyIllegal : OsvvmOptionsType := ResolveCovWriteAnyIllegal (WriteAnyIllegal,  WriteAnyIllegalVar) ;
      -- If input set, use it.
      constant rWritePassFail   : boolean := IfElse(WritePassFail   /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WritePassFail),    WritePassFailVar) ;
      constant rWriteBinInfo    : boolean := IfElse(WriteBinInfo    /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteBinInfo),     WriteBinInfoVar  ) ;
      constant rWriteCount      : boolean := IfElse(WriteCount      /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteCount),       WriteCountVar    ) ;
      constant rWriteAnyIllegal : boolean := IfElse(WriteAnyIllegal /= COV_OPT_INIT_PARM_DETECT,  IsEnabled(WriteAnyIllegal),  WriteAnyIllegalVar) ;
      -- constant rWritePrefix     : string         := ResolveOsvvmWritePrefix   (WritePrefix,      WritePrefixVar.GetOpt) ;
      -- constant rPassName        : string         := ResolveOsvvmPassName      (PassName,         PassNameVar.GetOpt  ) ;
      -- constant rFailName        : string         := ResolveOsvvmFailName      (FailName,         FailNameVar.GetOpt  ) ;
      variable buf : line ;
    begin
      file_open(LocalWriteBinFile, FileName, OpenKind) ;
      WriteBin (
        ID              => COV_STRUCT_ID_DEFAULT,
        buf             => buf,
        WritePassFail   => rWritePassFail,
        WriteBinInfo    => rWriteBinInfo,
        WriteCount      => rWriteCount,
        WriteAnyIllegal => rWriteAnyIllegal,
--!!      WritePrefix     => rWritePrefix,
--!!      PassName        => rPassName,
--!!      FailName        => rFailName
--!!      WritePrefix     => ResolveOsvvmWritePrefix  (WritePrefix,      WritePrefixVar.GetOpt),
--!!      PassName        => ResolveOsvvmPassName     (PassName,         PassNameVar.GetOpt  ),
--!!      FailName        => ResolveOsvvmFailName     (FailName,         FailNameVar.GetOpt  ),
        WritePrefix     => COVERAGE_PRINT_PREFIX,
        PassName        => COVERAGE_PASS_NAME,
        FailName        => COVERAGE_FAIL_NAME,
        UsingLocalFile  => TRUE
      );
      writeline(LocalWriteBinFile, buf) ;
    end procedure WriteBin ;

    ------------------------------------------------------------
    procedure WriteBin (  -- With LogLevel
    ------------------------------------------------------------
      LogLevel        : LogType ;
      FileName        : string;
      OpenKind        : File_Open_Kind := APPEND_MODE ;
      WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
      WritePrefix     : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName        : string         := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName        : string         := OSVVM_STRING_INIT_PARM_DETECT
    ) is
    begin
      if IsLogEnabled(CovStructPtr(COV_STRUCT_ID_DEFAULT.ID).AlertLogID, LogLevel) then
        WriteBin (
          FileName        => FileName,
          OpenKind        => OpenKind,
          WritePassFail   => WritePassFail,
          WriteBinInfo    => WriteBinInfo,
          WriteCount      => WriteCount,
          WriteAnyIllegal => WriteAnyIllegal,
          WritePrefix     => WritePrefix,
          PassName        => PassName,
          FailName        => FailName
        ) ;
      end if ;
    end procedure WriteBin ;  -- With LogLevel

    ------------------------------------------------------------
    procedure DumpBin (LogLevel : LogType := DEBUG) is
    ------------------------------------------------------------
    begin
      DumpBin (COV_STRUCT_ID_DEFAULT, LogLevel) ;
    end procedure DumpBin ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( PercentCov : real ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType := ALWAYS ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; PercentCov : real ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel, PercentCov) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, FileName, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel, FileName, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, FileName, PercentCov, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel, FileName, PercentCov, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure ReadCovDb (FileName : string; Merge : boolean := FALSE) is
    ------------------------------------------------------------
    begin
      ReadCovDb(COV_STRUCT_ID_DEFAULT, FileName, Merge) ;
    end procedure ReadCovDb ;

    ------------------------------------------------------------
    procedure WriteCovDb (FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovDb (COV_STRUCT_ID_DEFAULT, FileName, OpenKind) ;
    end procedure WriteCovDb ;

    ------------------------------------------------------------
    impure function GetErrorCount return integer is
    ------------------------------------------------------------
    begin
      return GetErrorCount(COV_STRUCT_ID_DEFAULT) ;
    end function GetErrorCount ;

    ------------------------------------------------------------
    -- These support usage of cross coverage constants
    -- Also support the older AddCross(GenCross(...)) methodology
    -- which has been replaced by AddCross
    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix2Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix3Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix4Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix5Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix6Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix7Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix8Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix9Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddCross ;

-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- Deprecated / Subsumed by versions with PercentCov Parameter
-- Maintained for backward compatibility only and
-- may be removed in the future.
-- ------------------------------------------------------------

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function CountCovHoles ( AtLeast : integer ) return integer is
    ------------------------------------------------------------
    begin
      return     CountCovHoles (COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function IsCovered ( AtLeast : integer ) return boolean is
    ------------------------------------------------------------
    begin
      return     IsCovered(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function IsCovered ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function RandCovBinVal (AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     RandCovBinVal(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function RandCovBinVal ;

-- Maintained for backward compatibility.  Repeated until aliases work for methods
    ------------------------------------------------------------
    -- Deprecated+  New versions use PercentCov.  Name change.
    impure function RandCovHole (AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     RandCovHole(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function RandCovPoint (AtLeast : integer ) return integer is
    ------------------------------------------------------------
    begin
      return     RandCovPoint(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    impure function RandCovPoint (AtLeast : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     RandCovPoint(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function GetHoleBinVal ( ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal (COV_STRUCT_ID_DEFAULT, ReqHoleNum, AtLeast) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    -- Deprecated+.  New versions use PercentCov.  Name Change.
    impure function GetCovHole ( ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetCovHole(COV_STRUCT_ID_DEFAULT, ReqHoleNum, AtLeast) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, AtLeast) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( LogLevel : LogType ; AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel, AtLeast) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, FileName, AtLeast, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(COV_STRUCT_ID_DEFAULT, LogLevel, FileName, AtLeast, OpenKind) ;
    end procedure WriteCovHoles ;

--------------------------------------------------------------
--------------------------------------------------------------
-- Deprecated.  Due to name changes to promote greater consistency
-- Maintained for backward compatibility - but only for PT version
-- Not available in Data Structure
-- ------------------------------------------------------------

    ------------------------------------------------------------
    impure function CovBinErrCnt return integer is
    -- Deprecated.  Name changed to ErrorCount for package to package consistency
    ------------------------------------------------------------
    begin
      return GetErrorCount(COV_STRUCT_ID_DEFAULT) ;
    end function CovBinErrCnt ;

    ------------------------------------------------------------
    -- Deprecated.  Same as RandCovBinVal
    impure function RandCovHole ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return RandCovBinVal(COV_STRUCT_ID_DEFAULT, PercentCov)  ;
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as RandCovBinVal
    impure function RandCovHole return RangeArrayType is
    ------------------------------------------------------------
    begin
      return RandCovBinVal(COV_STRUCT_ID_DEFAULT)  ;
    end function RandCovHole ;

    -- GetCovHole replaced by GetHoleBinVal
    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( ReqHoleNum : integer ; PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(COV_STRUCT_ID_DEFAULT, ReqHoleNum, PercentCov) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(COV_STRUCT_ID_DEFAULT, PercentCov) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( ReqHoleNum : integer := 1 ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(COV_STRUCT_ID_DEFAULT, ReqHoleNum) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Replaced by SetMessage with multi-line support
    procedure SetItemName (ItemNameIn : String) is
    ------------------------------------------------------------
    begin
      SetMessage(COV_STRUCT_ID_DEFAULT, ItemNameIn) ;
    end procedure SetItemName ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetMinCount
    impure function GetMinCov return integer is
    ------------------------------------------------------------
    begin
      return GetMinCount(COV_STRUCT_ID_DEFAULT) ;
    end function GetMinCov ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetMaxCount
    impure function GetMaxCov return integer is
    ------------------------------------------------------------
    begin
      return GetMaxCount(COV_STRUCT_ID_DEFAULT) ;
    end function GetMaxCov ;

    ------------------------------------------------------------
    -- Deprecated.  Use AddCross Instead.
    procedure AddBins (CovBin : CovMatrix2Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix3Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix4Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix5Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix6Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix7Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix8Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix9Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(COV_STRUCT_ID_DEFAULT, CovBin, Name) ;
    end procedure AddBins ;

  end protected body CovPType ;

  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  -- Singleton Data Structure
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  shared variable CoverageStore : CovPType ;


  ------------------------------------------------------------
  impure function NewID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return CoverageIDType is
    constant GOAL : real := 0.0 ; 
  begin
    return CoverageStore.NewID (Name, GOAL, ParentID, ReportMode, Search, PrintParent) ;
  end function NewID ;

  ------------------------------------------------------------
  impure function NewReqID (
    Name                : String ;
    ParentID            : AlertLogIDType          := OSVVM_COVERAGE_ALERTLOG_ID ;
    ReportMode          : AlertLogReportModeType  := ENABLED ;
    Search              : NameSearchType          := PRIVATE_NAME ;
    PrintParent         : AlertLogPrintParentType := PRINT_NAME_AND_PARENT
  ) return CoverageIDType is
    constant GOAL : real := 100.0 ; 
  begin
    return CoverageStore.NewID (Name, GOAL, ParentID, ReportMode, Search, PrintParent) ;
  end function NewReqID ;

  ------------------------------------------------------------
  impure function GetNumIDs return integer is
  ------------------------------------------------------------
  begin
    return CoverageStore.GetNumIDs ;
  end function GetNumIDs ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Global Settings Common to All Coverage Models
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) is
  begin
    CoverageStore.FileOpenWriteBin (FileName, OpenKind) ;
  end procedure FileOpenWriteBin ;

  procedure FileCloseWriteBin is
  begin
    CoverageStore.FileCloseWriteBin ;
  end procedure FileCloseWriteBin ;

--  procedure WriteToCovFile (variable buf : inout line) is
--  begin
--    CoverageStore.WriteToCovFile (buf) ;
--  end procedure WriteToCovFile ;

  procedure PrintToCovFile(S : string) is
  begin
    CoverageStore.PrintToCovFile (S) ;
  end procedure PrintToCovFile ;

  ------------------------------------------------------------
  procedure SetReportOptions (
  ------------------------------------------------------------
    WritePassFail   : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteBinInfo    : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteCount      : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WriteAnyIllegal : OsvvmOptionsType := COV_OPT_INIT_PARM_DETECT ;
    WritePrefix     : string := OSVVM_STRING_INIT_PARM_DETECT ;
    PassName        : string := OSVVM_STRING_INIT_PARM_DETECT ;
    FailName        : string := OSVVM_STRING_INIT_PARM_DETECT
  ) is
  begin
    CoverageStore.SetReportOptions (
      WritePassFail, WriteBinInfo, WriteCount, WriteAnyIllegal,
      WritePrefix, PassName, FailName
    ) ;
  end procedure SetReportOptions ;

  procedure ResetReportOptions is
  begin
    CoverageStore.ResetReportOptions ;
  end procedure ResetReportOptions ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Model Settings
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure SetName (ID : CoverageIDType; Name : String) is
  begin
    CoverageStore.SetName (ID, Name) ;
  end procedure SetName ;

  impure function SetName (ID : CoverageIDType; Name : String) return string is
  begin
    return CoverageStore.SetName (ID, Name) ;
  end function SetName ;

  procedure DeallocateName (ID : CoverageIDType) is
  begin
    CoverageStore.DeallocateName (ID) ;
  end procedure DeallocateName ;

  impure function GetName (ID : CoverageIDType) return String is
  begin
    return CoverageStore.GetName(ID => ID) ;
  end function GetName ;

  impure function GetCovModelName (ID : CoverageIDType) return String is
  begin
    return CoverageStore.GetCovModelName(ID => ID) ;
  end function GetCovModelName ;

  impure function GetNamePlus (ID : CoverageIDType; prefix, suffix : string) return String is
  begin
    return CoverageStore.GetNamePlus (ID, prefix, suffix) ;
  end function GetNamePlus ;

  procedure SetItemBinNames (
    ID         : CoverageIDType ;
    Name1      : String ;
            Name2,  Name3,  Name4,  Name5,
    Name6,  Name7,  Name8,  Name9,  Name10,
    Name11, Name12, Name13, Name14, Name15,
    Name16, Name17, Name18, Name19, Name20 : string := ""
  ) is
  begin
    CoverageStore.SetItemBinNames (
      ID,
      Name1,  Name2,  Name3,  Name4,  Name5,
      Name6,  Name7,  Name8,  Name9,  Name10,
      Name11, Name12, Name13, Name14, Name15,
      Name16, Name17, Name18, Name19, Name20
    ) ;
  end procedure SetItemBinNames ;


  ------------------------------------------------------------
  procedure SetMessage (ID : CoverageIDType; Message : String) is
  begin
    CoverageStore.SetMessage(ID, Message) ;
  end procedure SetMessage ;

  procedure DeallocateMessage (ID : CoverageIDType) is
  begin
    CoverageStore.DeallocateMessage(ID) ;
  end procedure DeallocateMessage ;


  procedure SetCovTarget (ID : CoverageIDType; Percent : real) is
  begin
    CoverageStore.SetCovTarget(ID, Percent) ;
  end procedure SetCovTarget ;

  impure function GetCovTarget (ID : CoverageIDType) return real is
  begin
    return CoverageStore.GetCovTarget(ID) ;
  end function GetCovTarget ;

  procedure SetThresholding (ID : CoverageIDType; A : boolean := TRUE ) is
  begin
    CoverageStore.SetThresholding(ID, A) ;
  end procedure SetThresholding ;

  procedure SetCovThreshold (ID : CoverageIDType; Percent : real) is
  begin
    CoverageStore.SetCovThreshold(ID, Percent) ;
  end procedure SetCovThreshold ;

  procedure SetMerging (ID : CoverageIDType; A : boolean := TRUE ) is
  begin
    CoverageStore.SetMerging(ID, A) ;
  end procedure SetMerging ;

  procedure SetCountMode (ID : CoverageIDType; A : CountModeType) is
  begin
    CoverageStore.SetCountMode(ID, A) ;
  end procedure SetCountMode ;

  procedure SetIllegalMode (ID : CoverageIDType; A : IllegalModeType) is
  begin
    CoverageStore.SetIllegalMode(ID, A) ;
  end procedure SetIllegalMode ;

  procedure SetWeightMode (ID : CoverageIDType; WeightMode : WeightModeType;  WeightScale : real := 1.0) is
  begin
    CoverageStore.SetWeightMode(ID, WeightMode, WeightScale) ;
  end procedure SetWeightMode ;

  procedure SetCovWeight (ID : CoverageIDType; Weight : integer) is
  begin
    CoverageStore.SetCovWeight(ID, Weight) ;
  end procedure SetCovWeight ;

  impure function GetCovWeight (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetCovWeight(ID) ;
  end function GetCovWeight ;

  procedure SetNextPointMode (ID : CoverageIDType; A : NextPointModeType) is
  begin
    CoverageStore.SetNextPointMode(ID, A) ;
  end procedure SetNextPointMode ;


  ------------------------------------------------------------
--sig  procedure SetAlertLogID (ID : CoverageIDType; A : AlertLogIDType) is
--sig  begin
--sig    CoverageStore.SetAlertLogID (ID, A) ;
--sig  end procedure SetAlertLogID ;
--sig
--sig  procedure SetAlertLogID (ID : CoverageIDType; Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) is
--sig  begin
--sig    CoverageStore.SetAlertLogID (ID, Name, ParentID, CreateHierarchy) ;
--sig  end procedure SetAlertLogID ;

  impure function GetAlertLogID (ID : CoverageIDType) return AlertLogIDType is
  begin
    return CoverageStore.GetAlertLogID(ID) ;
  end function GetAlertLogID ;


  ------------------------------------------------------------
  procedure InitSeed (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
  begin
    CoverageStore.InitSeed(ID, S, UseNewSeedMethods) ;
  end procedure InitSeed ;

  impure function InitSeed (ID : CoverageIDType; S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) return string is
  begin
    return CoverageStore.InitSeed(ID, S, UseNewSeedMethods) ;
  end function InitSeed ;

  procedure InitSeed (ID : CoverageIDType; I : integer; UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS ) is
  begin
    CoverageStore.InitSeed(ID, I, UseNewSeedMethods) ;
  end procedure InitSeed ;


  ------------------------------------------------------------
  procedure SetSeed (ID : CoverageIDType; RandomSeedIn : RandomSeedType ) is
  begin
    CoverageStore.SetSeed (ID, RandomSeedIn) ;
  end procedure SetSeed ;

  impure function GetSeed (ID : CoverageIDType) return RandomSeedType is
  begin
    return CoverageStore.GetSeed (ID => ID) ;
  end function GetSeed ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Item / Cross Bin Creation and Destruction
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure SetBinSize (ID : CoverageIDType; NewNumBins : integer) is
  begin
    CoverageStore.SetBinSize (ID, NewNumBins) ;
  end procedure SetBinSize ;

  procedure DeallocateBins (CoverID : CoverageIDType) is
  begin
    CoverageStore.DeallocateBins (CoverID) ;
  end procedure DeallocateBins ;

  procedure Deallocate (ID : CoverageIDType) is
  begin
    CoverageStore.Deallocate (ID) ;
  end procedure Deallocate ;


  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddBins (
  ------------------------------------------------------------
    ID      : CoverageIDType ;
    Name    : String ;
    AtLeast : integer ;
    Weight  : integer ;
    CovBin  : CovBinType
  ) is
  begin
    CoverageStore.AddBins (ID, Name, AtLeast, Weight, CovBin) ;
  end procedure AddBins ;

  procedure AddBins (ID : CoverageIDType; Name : String ; AtLeast : integer ; CovBin : CovBinType ) is
  begin
    CoverageStore.AddBins (ID, Name, AtLeast, CovBin) ;
  end procedure AddBins ;

  procedure AddBins (ID : CoverageIDType; Name : String ;  CovBin : CovBinType) is
  begin
    CoverageStore.AddBins (ID, Name, CovBin) ;
  end procedure AddBins ;

  procedure AddBins (ID : CoverageIDType; AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) is
  begin
    CoverageStore.AddBins (ID, AtLeast, Weight, CovBin) ;
  end procedure AddBins ;

  procedure AddBins (ID : CoverageIDType; AtLeast : integer ; CovBin : CovBinType ) is
  begin
    CoverageStore.AddBins (ID, AtLeast, CovBin) ;
  end procedure AddBins ;

  procedure AddBins (ID : CoverageIDType; CovBin : CovBinType  ) is
  begin
    CoverageStore.AddBins (ID, CovBin) ;
  end procedure AddBins ;


  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddCross (
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    AtLeast    : integer ;
    Weight     : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, Name, AtLeast, Weight, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;


  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    AtLeast    : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, Name, AtLeast, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;


  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Name       : string ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, Name, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;

  ------------------------------------------------------------
  -- Weight Deprecated
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    AtLeast    : integer ;
    Weight     : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, AtLeast, Weight, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;

  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    AtLeast    : integer ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, AtLeast, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;

  ------------------------------------------------------------
  procedure AddCross(
  ------------------------------------------------------------
    ID         : CoverageIDType ;
    Bin1, Bin2 : CovBinType ;
    Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
    Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20 : CovBinType := NULL_BIN
  ) is
  begin
    CoverageStore.AddCross(ID, Bin1, Bin2,
      Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11, Bin12, Bin13,
      Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
    );
  end procedure AddCross ;

  ------------------------------------------------------------
  -- AddCross for usage with constants created by GenCross
  ------------------------------------------------------------
  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix2Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix3Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix4Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix5Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix6Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix7Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix8Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;

  procedure AddCross (ID : CoverageIDType; CovBin : CovMatrix9Type ; Name : String := "") is
  begin
    CoverageStore.AddCross (ID, CovBin, Name) ;
  end procedure AddCross ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Recording and Clearing Coverage
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  ------------------------------------------------------------
  procedure ICoverLast (ID : CoverageIDType) is
  begin
    CoverageStore.ICoverLast (ID) ;
  end procedure ICoverLast ;

  procedure ICover (ID : CoverageIDType; CovPoint : integer_vector) is
  begin
    CoverageStore.ICover (ID, CovPoint) ;
  end procedure ICover ;

  procedure ICover (ID : CoverageIDType; CovPoint : integer) is
  begin
    CoverageStore.ICover (ID, (1 => CovPoint)) ;
  end procedure ICover ;

  procedure TCover (ID : CoverageIDType; A : integer) is
  begin
    CoverageStore.TCover (ID, A) ;
  end procedure TCover ;
  
  impure function FindBinIndex(ID : CoverageIDType; CovPoint : integer_vector; StartingIndex : integer := 1) return integer is
    variable BinIndex : integer ; 
  begin
    BinIndex := CoverageStore.FindBinIndex(ID, CovPoint, StartingIndex) ;
    return BinIndex ; 
  end function FindBinIndex ; 
  
  impure function FindBinIndex(ID : CoverageIDType; CovPoint : integer; StartingIndex : integer := 1) return integer is
    variable BinIndex : integer ; 
  begin
    BinIndex := CoverageStore.FindBinIndex(ID, (1 => CovPoint), StartingIndex) ;
    return BinIndex ; 
  end function FindBinIndex ; 

  procedure ClearCov (ID : CoverageIDType) is
  begin
    CoverageStore.ClearCov (ID) ;
  end procedure ClearCov ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Coverage Information and Statistics
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  ------------------------------------------------------------
  impure function IsBinCovered (ID : CoverageIDType; BinIndex : integer ; PercentCov : real ) return boolean is
  begin
    return CoverageStore.IsBinCovered (ID, BinIndex, PercentCov) ;
  end function IsBinCovered ;

  impure function IsBinCovered (ID : CoverageIDType ; BinIndex : integer ) return boolean is
  begin
    return CoverageStore.IsBinCovered (ID, BinIndex) ;
  end function IsBinCovered ;

  impure function IsCovered (ID : CoverageIDType; PercentCov : real ) return boolean is
  begin
    return CoverageStore.IsCovered (ID, PercentCov) ;
  end function IsCovered ;

  impure function IsCovered (ID : CoverageIDType) return boolean is
  begin
    return CoverageStore.IsCovered (ID) ;
  end function IsCovered ;

  impure function AllCovered return boolean is
  begin
    return CoverageStore.AllCovered ;
  end function AllCovered ;

  impure function AllCovered (PercentCov : real ) return boolean is
  begin
    return CoverageStore.AllCovered(PercentCov) ;
  end function AllCovered ;

  impure function IsNotCovered (ID : CoverageIDType; PercentCov : real ) return boolean is
  begin
    return not CoverageStore.IsCovered (ID, PercentCov) ;
  end function IsNotCovered ;

  impure function IsNotCovered (ID : CoverageIDType) return boolean is
  begin
    return not CoverageStore.IsCovered (ID) ;
  end function IsNotCovered ;

  impure function IsInitialized (ID : CoverageIDType) return boolean is
  begin
    return CoverageStore.IsInitialized (ID) ;
  end function IsInitialized ;

  ------------------------------------------------------------
  impure function IsBinCount(ID : CoverageIDType; BinIndex : integer) return boolean is
  begin
    return CoverageStore.GetBinAction(ID, BinIndex) = COV_COUNT ;
  end function IsBinCount ; 

  ------------------------------------------------------------
  impure function IsBinIllegal(ID : CoverageIDType; BinIndex : integer) return boolean is
  begin
    return CoverageStore.GetBinAction(ID, BinIndex) = COV_ILLEGAL ;
  end function IsBinIllegal ; 

  ------------------------------------------------------------
  impure function IsBinIgnore(ID : CoverageIDType; BinIndex : integer) return boolean is
  begin
    return CoverageStore.GetBinAction(ID, BinIndex) = COV_IGNORE ;
  end function IsBinIgnore ; 

  ------------------------------------------------------------
  impure function IsPointCount(ID : CoverageIDType; CovPoint : integer_vector) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, CovPoint) = COV_COUNT ;
  end function IsPointCount ; 

  impure function IsPointCount(ID : CoverageIDType; CovPoint : integer) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, (1 => CovPoint)) = COV_COUNT ;
  end function IsPointCount ; 

  ------------------------------------------------------------
  impure function IsPointIllegal(ID : CoverageIDType; CovPoint : integer_vector) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, CovPoint) = COV_ILLEGAL ;
  end function IsPointIllegal ; 

  impure function IsPointIllegal(ID : CoverageIDType; CovPoint : integer) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, (1 => CovPoint)) = COV_ILLEGAL ;
  end function IsPointIllegal ; 

  ------------------------------------------------------------
  impure function IsPointIgnore(ID : CoverageIDType; CovPoint : integer_vector) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, CovPoint) = COV_IGNORE ;
  end function IsPointIgnore ; 

  impure function IsPointIgnore(ID : CoverageIDType; CovPoint : integer) return boolean is
  begin
    return CoverageStore.GetPointAction(ID, (1 => CovPoint)) = COV_IGNORE ;
  end function IsPointIgnore ; 

  ------------------------------------------------------------
  impure function GetItemCount (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetItemCount (ID) ;
  end function GetItemCount ;

  impure function GetCov (ID : CoverageIDType; PercentCov : real ) return real is
  begin
    return CoverageStore.GetCov (ID, PercentCov) ;
  end function GetCov ;

  impure function GetCov (ID : CoverageIDType) return real is
  begin
    return CoverageStore.GetCov (ID) ;
  end function GetCov ;

  impure function GetTotalCovCount (ID : CoverageIDType; PercentCov : real ) return integer is
  begin
    return CoverageStore.GetTotalCovCount (ID, PercentCov) ;
  end function GetTotalCovCount ;

  impure function GetTotalCovCount (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetTotalCovCount (ID) ;
  end function GetTotalCovCount ;

  impure function GetTotalCovGoal (ID : CoverageIDType; PercentCov : real ) return integer is
  begin
    return CoverageStore.GetTotalCovGoal (ID, PercentCov) ;
  end function GetTotalCovGoal ;

  impure function GetTotalCovGoal (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetTotalCovGoal (ID) ;
  end function GetTotalCovGoal ;


  ------------------------------------------------------------
  impure function GetMinCov (ID : CoverageIDType) return real is
  begin
    return CoverageStore.GetMinCov (ID) ;
  end function GetMinCov ;

  impure function GetMinCount (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMinCount (ID) ;
  end function GetMinCount ;

  impure function GetMaxCov (ID : CoverageIDType) return real is
  begin
    return CoverageStore.GetMaxCov (ID) ;
  end function GetMaxCov ;

  impure function GetMaxCount (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMaxCount (ID) ;
  end function GetMaxCount ;


  ------------------------------------------------------------
  impure function CountCovHoles (ID : CoverageIDType; PercentCov : real ) return integer is
  begin
    return CoverageStore.CountCovHoles (ID, PercentCov) ;
  end function CountCovHoles ;

  impure function CountCovHoles (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.CountCovHoles (ID) ;
  end function CountCovHoles ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Generating Coverage Points, BinValues, and Indices
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- Return Points
  ------------------------------------------------------------
  -- to be replaced in VHDL-2019 by version that uses RandomSeed as an inout
  impure function ToRandPoint (ID : CoverageIDType; BinVal : RangeArrayType ) return integer is
  begin
    return CoverageStore.ToRandPoint (ID, BinVal) ;
  end function ToRandPoint ;

  impure function ToRandPoint (ID : CoverageIDType; BinVal : RangeArrayType ) return integer_vector is
  begin
    return CoverageStore.ToRandPoint (ID, BinVal) ;
  end function ToRandPoint ;


  ------------------------------------------------------------
  -- Return Points
  impure function GetPoint     (ID : CoverageIDType; BinIndex : integer ) return integer is
  begin
    return CoverageStore.GetPoint (ID, BinIndex) ;
  end function GetPoint ;

  impure function GetPoint (ID : CoverageIDType; BinIndex : integer ) return integer_vector is
  begin
    return CoverageStore.GetPoint (ID, BinIndex) ;
  end function GetPoint ;

  impure function GetRandPoint (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetRandPoint (ID) ;
  end function GetRandPoint ;

  impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer is
  begin
    return CoverageStore.GetRandPoint (ID, PercentCov) ;
  end function GetRandPoint ;

  impure function GetRandPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.GetRandPoint (ID) ;
  end function GetRandPoint ;

  impure function GetRandPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector is
  begin
    return CoverageStore.GetRandPoint (ID, PercentCov) ;
  end function GetRandPoint ;

  impure function GetIncPoint  (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetIncPoint (ID => ID) ;
  end function GetIncPoint ;

  impure function GetIncPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.GetIncPoint (ID => ID) ;
  end function GetIncPoint ;

  impure function GetMinPoint  (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMinPoint (ID => ID) ;
  end function GetMinPoint ;

  impure function GetMinPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.GetMinPoint (ID => ID) ;
  end function GetMinPoint ;

  impure function GetMaxPoint  (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMaxPoint (ID => ID) ;
  end function GetMaxPoint ;

  impure function GetMaxPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.GetMaxPoint (ID => ID) ;
  end function GetMaxPoint ;

  impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer is
  begin
    return CoverageStore.GetNextPoint (ID, Mode) ;
  end function GetNextPoint ;

  impure function GetNextPoint (ID : CoverageIDType; Mode : NextPointModeType) return integer_vector is
  begin
    return CoverageStore.GetNextPoint (ID, Mode) ;
  end function GetNextPoint ;

  impure function GetNextPoint (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetNextPoint (ID) ;
  end function GetNextPoint ;

  impure function GetNextPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.GetNextPoint (ID) ;
  end function GetNextPoint ;


  ------------------------------------------------------------
  -- deprecated, see GetRandPoint
  impure function RandCovPoint (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.RandCovPoint (ID) ;
  end function RandCovPoint ;

  impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer is
  begin
    return CoverageStore.RandCovPoint (ID, PercentCov) ;
  end function RandCovPoint ;

  impure function RandCovPoint (ID : CoverageIDType) return integer_vector is
  begin
    return CoverageStore.RandCovPoint (ID) ;
  end function RandCovPoint ;

  impure function RandCovPoint (ID : CoverageIDType; PercentCov : real ) return integer_vector is
  begin
    return CoverageStore.RandCovPoint (ID, PercentCov) ;
  end function RandCovPoint ;


  ------------------------------------------------------------
  -- Return BinVals
  impure function GetBinVal (ID : CoverageIDType; BinIndex : integer ) return RangeArrayType is
  begin
    return CoverageStore.GetBinVal (ID, BinIndex) ;
  end function GetBinVal ;

  impure function GetRandBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType is
  begin
    return CoverageStore.GetRandBinVal (ID, PercentCov) ;
  end function GetRandBinVal ;

  impure function GetRandBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetRandBinVal (ID => ID) ;
  end function GetRandBinVal ;

  impure function GetLastBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetLastBinVal (ID => ID) ;
  end function GetLastBinVal ;

  impure function GetIncBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetIncBinVal (ID => ID) ;
  end function GetIncBinVal ;

  impure function GetMinBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetMinBinVal (ID => ID) ;
  end function GetMinBinVal ;

  impure function GetMaxBinVal  (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetMaxBinVal (ID => ID) ;
  end function GetMaxBinVal ;

  impure function GetNextBinVal (ID : CoverageIDType; Mode : NextPointModeType) return RangeArrayType is
  begin
    return CoverageStore.GetNextBinVal (ID, Mode) ;
  end function GetNextBinVal ;

  impure function GetNextBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.GetNextBinVal (ID => ID) ;
  end function GetNextBinVal ;

  impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType is
  begin
    return CoverageStore.GetHoleBinVal (ID, ReqHoleNum, PercentCov) ;
  end function GetHoleBinVal ;

  impure function GetHoleBinVal (ID : CoverageIDType; PercentCov : real  ) return RangeArrayType is
  begin
    return CoverageStore.GetHoleBinVal (ID, PercentCov) ;
  end function GetHoleBinVal ;

  impure function GetHoleBinVal (ID : CoverageIDType; ReqHoleNum : integer := 1 ) return RangeArrayType is
  begin
    return CoverageStore.GetHoleBinVal (ID, ReqHoleNum) ;
  end function GetHoleBinVal ;


  -- deprecated RandCovBinVal, see GetRandBinVal
  impure function RandCovBinVal (ID : CoverageIDType; PercentCov : real ) return RangeArrayType is
  begin
    return CoverageStore.RandCovBinVal (ID, PercentCov) ;
  end function RandCovBinVal ;

  impure function RandCovBinVal (ID : CoverageIDType) return RangeArrayType is
  begin
    return CoverageStore.RandCovBinVal (ID => ID) ;
  end function RandCovBinVal ;


  ------------------------------------------------------------
  -- Return Index Values
  impure function GetNumBins (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetNumBins (ID => ID) ;
  end function GetNumBins ;

  impure function GetRandIndex (ID : CoverageIDType; CovTargetPercent : real ) return integer is
  begin
    return CoverageStore.GetRandIndex (ID, CovTargetPercent) ;
  end function GetRandIndex ;

  impure function GetRandIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetRandIndex (ID => ID)  ;
  end function GetRandIndex ;

  impure function GetLastIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetLastIndex (ID => ID) ;
  end function GetLastIndex ;

  impure function GetIncIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetIncIndex (ID => ID) ;
  end function GetIncIndex ;

  impure function GetMinIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMinIndex  (ID => ID) ;
  end function GetMinIndex ;

  impure function GetMaxIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetMaxIndex  (ID => ID) ;
  end function GetMaxIndex ;

  impure function GetNextIndex (ID : CoverageIDType; Mode : NextPointModeType) return integer is
  begin
    return CoverageStore.GetNextIndex (ID, Mode) ;
  end function GetNextIndex;

  impure function GetNextIndex (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetNextIndex (ID => ID) ;
  end function GetNextIndex ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Accessing Coverage Bin Information
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- ------------------------------------------------------------
  -- Get all bin information except the BinVal (since it is sized)
  impure function GetBinInfo (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType is
  begin
    return CoverageStore.GetBinInfo(ID, BinIndex) ;
  end function GetBinInfo ;


  -- ------------------------------------------------------------
  -- Get Pieces of Bin Information
  impure function GetBinValLength (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetBinValLength(ID => ID);
  end function GetBinValLength ;

  impure function GetBinAction(ID : CoverageIDType; BinIndex : integer) return integer is
  begin
    return CoverageStore.GetBinAction(ID, BinIndex) ;
  end function GetBinAction ; 
  
  impure function GetBinName (ID : CoverageIDType; BinIndex : integer; DefaultName : string := "" ) return string is
  begin
    return CoverageStore.GetBinName (ID, BinIndex, DefaultName) ;
  end function GetBinName ;

  procedure SetBinName  (ID : CoverageIDType; BinIndex : integer; Name : string ) is
  begin
    CoverageStore.SetBinName (ID, BinIndex, Name) ;
  end procedure SetBinName ;

  impure function GetPointAction(ID : CoverageIDType; CovPoint : integer_vector) return integer is
  begin
    return CoverageStore.GetPointAction(ID, CovPoint) ;
  end function GetPointAction ; 

  impure function GetPointAction(ID : CoverageIDType; CovPoint : integer) return integer is
  begin
    return CoverageStore.GetPointAction(ID, (1 => CovPoint)) ;
  end function GetPointAction ; 


  -- ------------------------------------------------------------
  -- Eventually the multiple GetBin functions will be replaced by a
  -- a single GetBin that returns CovBinBaseType with BinVal as an
  -- unconstrained element
  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovBinBaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix2BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix3BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix4BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix5BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix6BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix7BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix8BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  impure function GetBin (ID : CoverageIDType; BinIndex : integer ) return CovMatrix9BaseType is
  begin
    return CoverageStore.GetBin(ID, BinIndex) ;
  end function GetBin ;

  ------------------------------------------------------------
  impure function GetErrorCount (ID : CoverageIDType) return integer is
  begin
    return CoverageStore.GetErrorCount (ID => ID) ;
  end function GetErrorCount ;

  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Printing Coverage Bin Information
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  -- To specify the following, see SetReportOptions
  --   WritePassFail, WriteBinInfo, WriteCount, WriteAnyIllegal
  --   WritePrefix, PassName, FailName
  ------------------------------------------------------------
  procedure WriteBin (ID : CoverageIDType) is
  begin
    CoverageStore.WriteBin (ID => ID) ;
  end procedure WriteBin ;

  procedure WriteBin (ID : CoverageIDType; LogLevel : LogType ) is
  begin
    CoverageStore.WriteBin (ID, LogLevel) ;
  end procedure WriteBin ;

  procedure WriteBin (ID : CoverageIDType; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE) is
  begin
    CoverageStore.WriteBin (ID, FileName, OpenKind) ;
  end procedure WriteBin ;

  procedure WriteBin (ID : CoverageIDType; LogLevel : LogType; FileName : string; OpenKind : File_Open_Kind := APPEND_MODE) is
  begin
    CoverageStore.WriteBin (ID, LogLevel, FileName, OpenKind) ;
  end procedure WriteBin ;

  procedure WriteAllBins (FileName : string := "" ; OpenKind : File_Open_Kind := WRITE_MODE) is
  begin
    CoverageStore.WriteAllBins (FileName, OpenKind) ;
  end procedure WriteAllBins ;

  ------------------------------------------------------------
  procedure DumpBin (ID : CoverageIDType; LogLevel : LogType := DEBUG) is
  begin
    CoverageStore.DumpBin (ID, LogLevel) ;
  end procedure DumpBin ;


  ------------------------------------------------------------
  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType := ALWAYS ) is
  begin
    CoverageStore.WriteCovHoles (ID, LogLevel) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType; PercentCov : real ) is
  begin
    CoverageStore.WriteCovHoles (ID, PercentCov) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType;  LogLevel : LogType;  PercentCov : real ) is
  begin
    CoverageStore.WriteCovHoles (ID, LogLevel, PercentCov) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType;  FileName : string;   OpenKind : File_Open_Kind := APPEND_MODE ) is
  begin
    CoverageStore.WriteCovHoles (ID, FileName, OpenKind) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
  begin
    CoverageStore.WriteCovHoles (ID, LogLevel, FileName, OpenKind) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType; FileName : string;   PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
  begin
    CoverageStore.WriteCovHoles (ID, FileName, PercentCov, OpenKind) ;
  end procedure WriteCovHoles ;

  procedure WriteCovHoles (ID : CoverageIDType; LogLevel : LogType;  FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
  begin
    CoverageStore.WriteCovHoles (ID, LogLevel, FileName, PercentCov, OpenKind) ;
  end procedure WriteCovHoles ;


  ------------------------------------------------------------
  -- /////////////////////////////////////////
  --  Writing Out RAW Coverage Bin Information
  --  Note that read supports merging of coverage models
  -- /////////////////////////////////////////
  ------------------------------------------------------------
  procedure ReadCovDb (ID : CoverageIDType; FileName : string; Merge : boolean := FALSE) is
  begin
    CoverageStore.ReadCovDb (ID, FileName, Merge) ;
  end procedure ReadCovDb ;

  procedure WriteCovDb (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
  begin
    CoverageStore.WriteCovDb (ID, FileName, OpenKind) ;
  end procedure WriteCovDb ;

  --     procedure WriteCovDb (ID : CoverageIDType) is

  ------------------------------------------------------------
  procedure WriteCovYaml (ID : CoverageIDType; FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
  ------------------------------------------------------------
  begin
    CoverageStore.WriteCovYaml (ID, FileName, OpenKind) ;
  end procedure WriteCovYaml ;


  ------------------------------------------------------------
  procedure WriteCovYaml (FileName : string := ""; OpenKind : File_Open_Kind := WRITE_MODE) is
  ------------------------------------------------------------
  begin
    CoverageStore.WriteCovYaml(FileName, GetCov, OpenKind) ;
  end procedure WriteCovYaml ;

  ------------------------------------------------------------
  procedure ReadCovYaml (variable ID : inout CoverageIDType; FileName : string := ""; Merge : boolean := FALSE) is
  ------------------------------------------------------------
  begin
    CoverageStore.ReadCovYaml(ID, FileName, Merge) ;
  end procedure ReadCovYaml ;

  ------------------------------------------------------------
  procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) is
  ------------------------------------------------------------
  begin
    CoverageStore.ReadCovYaml(FileName, Merge) ;
  end procedure ReadCovYaml ;

  ------------------------------------------------------------
  impure function GotCoverage return boolean is
  ------------------------------------------------------------
  begin
    return CoverageStore.GotCoverage ;
  end function GotCoverage ;

  ------------------------------------------------------------
  procedure RecordCovRequirements is
  ------------------------------------------------------------
  begin
    CoverageStore.RecordCovRequirements ;
  end procedure RecordCovRequirements ;

  ------------------------------------------------------------
  impure function GetCov (PercentCov : real ) return real is
  ------------------------------------------------------------
    variable ID : CoverageIDType ;
    variable ItemCovCount, ItemCovGoal   : integer ;
    variable TotalCovCount, TotalCovGoal : integer := 0;
    variable CovWeight : integer ;
    variable ScaledCovGoal, rTotalCovCount : real ;
  begin
    for i in 1 to CoverageStore.GetNumIDs loop
      ID := (ID => i) ;
      CoverageStore.GetTotalCovCountAndGoal(ID, ItemCovCount, ItemCovGoal) ;
      CovWeight     := GetCovWeight(ID) ;
      TotalCovCount := TotalCovCount + (ItemCovCount * CovWeight) ;
      TotalCovGoal  := TotalCovGoal  + (ItemCovGoal  * CovWeight) ;
    end loop ;
    ScaledCovGoal  := PercentCov * real(TotalCovGoal) / 100.0 ;
    rTotalCovCount := real(TotalCovCount) ;

    if rTotalCovCount >= ScaledCovGoal then
      return 100.0 ;
    elsif ScaledCovGoal > 0.0 then
      return (100.0 * rTotalCovCount) / ScaledCovGoal ;
    else
      return 0.0 ;
    end if;
  end function GetCov ;

  ------------------------------------------------------------
  impure function GetCov return real is
  ------------------------------------------------------------
  begin
    return GetCov (100.0) ;
  end function GetCov ;

  ------------------------------------------------------------
  procedure AffirmIfCovered is 
  ------------------------------------------------------------
--    constant TotalCov : real := GetCov(100.0) ; 
    variable TotalCov : real ; 
  begin
    TotalCov := GetCov(100.0) ; 
    CoverageStore.SetErrorIfNotCovered(Checked => TRUE) ; 
    AffirmIf(OSVVM_COVERAGE_ALERTLOG_ID, 
             TotalCov >= 100.0, "TotalCov = " & to_string(TotalCov, 2), "") ; 
  end procedure AffirmIfCovered ; 
  
  ------------------------------------------------------------
  procedure AlertIfNotCovered (Level : AlertType := ERROR) is 
  ------------------------------------------------------------
--    constant TotalCov : real := GetCov(100.0) ; 
    variable TotalCov : real ; 
  begin
    TotalCov := GetCov(100.0) ; 
    CoverageStore.SetErrorIfNotCovered(Checked => TRUE) ; 
    AlertIf(OSVVM_COVERAGE_ALERTLOG_ID, 
            TotalCov < 100.0, "TotalCov = " & to_string(TotalCov, 2), Level) ; 
  end procedure AlertIfNotCovered ; 

  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    variable Bin1       : inout CovPType ;
    variable Bin2       : inout CovPType ;
    variable ErrorCount : inout integer
  ) is
    variable NumBins1, NumBins2 : integer ;
    variable BinInfo1, BinInfo2 : CovBinBaseType ;
    variable BinVal1, BinVal2 : RangeArrayType(1 to Bin1.GetBinValLength) ;
    variable buf : line ;
--sig    variable iAlertLogID : AlertLogIDType ;
  begin
--sig    iAlertLogID := Bin1.GetAlertLogID ;

    NumBins1 := Bin1.GetNumBins ;
    NumBins2 := Bin2.GetNumBins ;

    if (NumBins1 /= NumBins2) then
      ErrorCount := ErrorCount + 1 ;
      print("CoveragePkg.CompareBins: CoverageModels " & Bin1.GetCovModelName & " and " & Bin2.GetCovModelName &
            " have different bin lengths") ;
      return ;
    end if ;

    for i in 1 to NumBins1 loop
      BinInfo1 := Bin1.GetBinInfo(i) ;
      BinInfo2 := Bin2.GetBinInfo(i) ;
      BinVal1  := Bin1.GetBinVal (i) ;
      BinVal2  := Bin2.GetBinVal (i) ;
      if BinInfo1 /= BinInfo2 or BinVal1 /= BinVal2 then
        write(buf, "%% Bin:" & to_string(i) & " miscompare." & LF) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin1: ") ;
        write(buf, BinVal1) ;
        write(buf, "   Action = " &  to_string(BinInfo1.action)) ;
        write(buf, "   Count = " &   to_string(BinInfo1.count)) ;
        write(buf, "   AtLeast = " & to_string(BinInfo1.AtLeast)) ;
        write(buf, "   Weight = " &  to_string(BinInfo1.Weight) & LF ) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin2: ") ;
        write(buf, BinVal2) ;
        write(buf, "   Action = " &  to_string(BinInfo2.action)) ;
        write(buf, "   Count = " &   to_string(BinInfo2.count)) ;
        write(buf, "   AtLeast = " & to_string(BinInfo2.AtLeast)) ;
        write(buf, "   Weight = " &  to_string(BinInfo2.Weight) & LF ) ;
        -- writeline(OUTPUT, buf) ;
        ErrorCount := ErrorCount + 1 ;
        writeline(buf) ;
        -- Alert(iAlertLogID, buf.all, ERROR) ;
        -- deallocate(buf) ;
      end if ;
    end loop ;
  end procedure CompareBins ;


  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    variable Bin1       : inout CovPType ;
    variable Bin2       : inout CovPType
  ) is
    variable ErrorCount : integer ;
    variable iAlertLogID : AlertLogIDType ;
  begin
    CompareBins(Bin1, Bin2, ErrorCount) ;
    iAlertLogID := Bin1.GetAlertLogID ;
    AffirmIfEqual(iAlertLogID, ErrorCount, 0, "CompareBins(Bin1, Bin2, ErrorCount) " & Bin1.GetCovModelName & " and " & Bin2.GetCovModelName & " ErrorCount:") ;
  end procedure CompareBins ;


  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    constant Bin1       : in    CoverageIDType ;
    constant Bin2       : in    CoverageIDType ;
    variable Valid      : out   Boolean
  ) is
    variable NumBins1, NumBins2 : integer ;
    variable BinInfo1, BinInfo2 : CovBinBaseType ;
    variable BinVal1, BinVal2 : RangeArrayType(1 to GetBinValLength(Bin1)) ;
    variable buf : line ;
--sig    variable iAlertLogID : AlertLogIDType ;
  begin
--sig    iAlertLogID := GetAlertLogID(Bin1) ;

    NumBins1 := GetNumBins(Bin1) ;
    NumBins2 := GetNumBins(Bin2) ;

    Valid := TRUE ;

    if (NumBins1 /= NumBins2) then
      Valid := FALSE ;
      print("CoveragePkg.CompareBins: CoverageModels " & GetCovModelName(Bin1) & " and " & GetCovModelName(Bin2) &
            " have different bin lengths") ;
      return ;
    end if ;

    for i in 1 to NumBins1 loop
      BinInfo1 := GetBinInfo(Bin1, i) ;
      BinInfo2 := GetBinInfo(Bin2, i) ;
      BinVal1  := GetBinVal (Bin1, i) ;
      BinVal2  := GetBinVal (Bin2, i) ;
      if BinInfo1 /= BinInfo2 or BinVal1 /= BinVal2 then
        write(buf, "%% Bin: " & to_string(i) & " miscompare." & LF) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin1: ") ;
        write(buf, BinVal1) ;
        write(buf, "   Action = " &  to_string(BinInfo1.action)) ;
        write(buf, "   Count = " &   to_string(BinInfo1.count)) ;
        write(buf, "   AtLeast = " & to_string(BinInfo1.AtLeast)) ;
        write(buf, "   Weight = " &  to_string(BinInfo1.Weight) & LF ) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin2: ") ;
        write(buf, BinVal2) ;
        write(buf, "   Action = " &  to_string(BinInfo2.action)) ;
        write(buf, "   Count = " &   to_string(BinInfo2.count)) ;
        write(buf, "   AtLeast = " & to_string(BinInfo2.AtLeast)) ;
        write(buf, "   Weight = " &  to_string(BinInfo2.Weight) ) ;  -- & LF
        -- writeline(OUTPUT, buf) ;
        Valid := FALSE ;
        writeline(buf) ;
        -- Alert(iAlertLogID, buf.all, ERROR) ;
        -- deallocate(buf) ;
      end if ;
    end loop ;
  end procedure CompareBins ;


  ------------------------------------------------------------
  -- Experimental.  Intended primarily for development.
  procedure CompareBins (
  ------------------------------------------------------------
    constant Bin1       : in    CoverageIDType ;
    constant Bin2       : in    CoverageIDType
  ) is
    variable Valid : boolean ;
    variable iAlertLogID : AlertLogIDType ;
  begin
    CompareBins(Bin1, Bin2, Valid) ;
    iAlertLogID := GetAlertLogID(Bin1) ;
    AffirmIf(iAlertLogID, Valid, "CompareBins(Bin1, Bin2) " & GetCovModelName(Bin1) & " and " & GetCovModelName(Bin2)) ;
  end procedure CompareBins ;

  ------------------------------------------------------------
  -- package local, Used by GenBin, IllegalBin, and IgnoreBin
  function MakeBin(
  -- Must be pure to allow initializing coverage models passed as generics.
  -- Impure implies the expression is not globally static.
  ------------------------------------------------------------
    Min, Max      : integer ;
    NumBin        : integer ;
    AtLeast       : integer ;
    Weight        : integer ;
    Action        : integer
  ) return CovBinType is
    variable iCovBin : CovBinType(1 to NumBin) ;
    variable TotalBins : integer ; -- either real or integer
--sig    variable rMax, rCurMin, rNumItemsInBin, rRemainingBins : real ; -- must be real
    variable iCurMin, iCurMax, NegMaxMinus1, RemainingBins, NumItemsInBin : integer ;
  begin
    if Min > Max then
      -- Similar to NULL ranges.  Only generate report warning.
      report "OSVVM.CoveragePkg.MakeBin (called by GenBin, IllegalBin, or IgnoreBin) MAX > MIN generated NULL_BIN"
        severity WARNING ;
      -- No Alerts. They make this impure.
      -- Alert(OSVVM_COVERAGE_ALERTLOG_ID, "CoveragePkg.MakeBin (called by GenBin, IllegalBin, IgnoreBin): Min must be <= Max", WARNING) ;
      return NULL_BIN ;

    elsif NumBin <= 0 then
      -- Similar to NULL ranges.  Only generate report warning.
      report "OSVVM.CoveragePkg.MakeBin (called by GenBin, IllegalBin, or IgnoreBin) NumBin <= 0 generated NULL_BIN"
        severity WARNING ;
      -- Alerts make this impure.
      -- Alert(OSVVM_COVERAGE_ALERTLOG_ID, "CoveragePkg.MakeBin (called by GenBin, IllegalBin, IgnoreBin): NumBin must be <= 0", WARNING) ;
      return NULL_BIN ;

    elsif NumBin = 1 or Min = Max then
      iCovBin(1) := (
        BinVal   => (1 => (Min, Max)),
        Action   => Action,
        Count    => 0,
        Weight   => Weight,
        AtLeast  => AtLeast
      ) ;
      return iCovBin(1 to 1) ;

    elsif Min >= integer'low/2 and Max <= integer'high/2 then 
      -- Do calculations in type integer
      iCurMin := Min ;
      NegMaxMinus1 := -Max - 1 ; 
      RemainingBins := - maximum(-NumBin, NegMaxMinus1 + Min) ; -- Keep addition in bounds of type integer
      TotalBins := RemainingBins ; 
      for i in iCovBin'range loop
        NumItemsInBin := ((iCurMin + NegMaxMinus1) / RemainingBins) ;  -- Keep addition in bounds of type integer
        iCurMax := iCurMin - NumItemsInBin - 1 ;  -- NumItemsInBin is negative
        iCovBin(i) := (
          BinVal   => (1 => (iCurMin, iCurMax)),
          Action   => Action,
          Count    => 0,
          Weight   => Weight,
          AtLeast  => AtLeast
        ) ;
        RemainingBins := RemainingBins - 1 ;
        iCurMin := iCurMax + 1 ;
        if RemainingBins = 1 then 
          iCovBin(i+1) := (
            BinVal   => (1 => (iCurMin, Max)),
            Action   => Action,
            Count    => 0,
            Weight   => Weight,
            AtLeast  => AtLeast
          ) ;
          exit ; 
        end if ; 
      end loop ;
      return iCovBin(1 to TotalBins) ;
    else
      iCurMin := Min ;
      NegMaxMinus1 := -Max - 1 ; 
      RemainingBins := NumBin ; 
      TotalBins := 0 ; 
      for i in iCovBin'range loop
        NumItemsInBin :=  iCurMin/RemainingBins + NegMaxMinus1/RemainingBins + ((iCurMin rem RemainingBins + NegMaxMinus1 rem RemainingBins) / RemainingBins) ;  -- handling for large numbers
        RemainingBins := RemainingBins - 1 ;
        iCurMax := iCurMin - NumItemsInBin - 1 ;  -- NumItemsInBin is negative
        next when iCurMax < iCurMin ;  -- NumBin/RemainingBins is too large, try again with a smaller value
        TotalBins := TotalBins + 1 ;
        iCovBin(TotalBins) := (
          BinVal   => (1 => (iCurMin, iCurMax)),
          Action   => Action,
          Count    => 0,
          Weight   => Weight,
          AtLeast  => AtLeast
        ) ;
        iCurMin := iCurMax + 1 ;
        if RemainingBins = 1 then 
          TotalBins := TotalBins + 1 ;
          iCovBin(TotalBins) := (
            BinVal   => (1 => (iCurMin, Max)),
            Action   => Action,
            Count    => 0,
            Weight   => Weight,
            AtLeast  => AtLeast
          ) ;
          exit ; 
        end if ; 
      end loop ;
      return iCovBin(1 to TotalBins) ;
    end if ; 
  end function MakeBin ;


  ------------------------------------------------------------
  -- package local, Used by GenBin, IllegalBin, and IgnoreBin
  function MakeBin(
  ------------------------------------------------------------
    A             : integer_vector ;
    AtLeast       : integer ;
    Weight        : integer ;
    Action        : integer
  ) return CovBinType is
    alias    NewA      : integer_vector(1 to A'length) is A ;
    variable iCovBin   : CovBinType(1 to A'length) ;
  begin

    if A'length <= 0 then
      -- Similar to NULL ranges.  Only generate report warning.
      report "OSVVM.CoveragePkg.MakeBin (called by GenBin, IllegalBin, or IgnoreBin) integer_vector length <= 0 generated NULL_BIN"
        severity WARNING ;
      -- Alerts make this impure.
      -- Alert(OSVVM_COVERAGE_ALERTLOG_ID, "CoveragePkg.MakeBin (GenBin, IllegalBin, IgnoreBin): integer_vector parameter must have values", WARNING) ;
      return NULL_BIN ;

    else
      for i in NewA'Range loop
        iCovBin(i) := (
--          BinVal   => (i => (NewA(i), NewA(i)) ),
          BinVal   => (1 => (NewA(i), NewA(i)) ),
          Action   => Action,
          Count    => 0,
          Weight   => Weight,
          AtLeast  => AtLeast
        ) ;
      end loop ;
      return iCovBin ;
    end if ;
  end function MakeBin ;

  ------------------------------------------------------------
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Weight        : integer ;
    Min, Max      : integer ;
    NumBin        : integer
  ) return CovBinType is
  begin
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => NumBin,
              AtLeast  => AtLeast,
              Weight   => Weight,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Min, Max      : integer ;
    NumBin        : integer
  ) return CovBinType is
  begin
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => NumBin,
              AtLeast  => AtLeast,
              Weight   => 1,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin( Min, Max, NumBin : integer ) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => NumBin,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin ( Min, Max : integer) return CovBinType is
  ------------------------------------------------------------
  begin
    -- create a separate CovBin for each value in the range Min to Max
    if Min < integer'low/2 or Max > integer'high/2 then 
      report LF & LF & "GenBin/IllegalBin/IgnoreBin(" & to_string_max(min) & ", " & to_string_max(max) & ")  is likely an error." & LF &
             "If the Max-Min+1 does not fit in an integer, you simulator may stop after these messages with a range constraint." & LF &
             "In the event your code does not have constraint issues, to avoid this message with large numbers specify the number of bins you want.  Such as:" & LF &
             "GenBin(" & to_string_max(min) & ", " & to_string_max(max) & ", 5)" & LF & LF  
        severity WARNING ;
    end if ; 

    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => Max - Min + 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin ( A : integer ) return CovBinType is
  ------------------------------------------------------------
  begin
    -- create a single CovBin for A.
    -- AtLeast and Weight = 1 (must use longer version to specify)
    return  MakeBin(
              Min      => A,
              Max      => A,
              NumBin   => 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin(
  ------------------------------------------------------------
    AtLeast       : integer ;
    Weight        : integer ;
    A             : integer_vector
  ) return CovBinType is
  begin
    return  MakeBin(
              A        => A,
              AtLeast  => AtLeast,
              Weight   => Weight,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin ( AtLeast : integer ;  A : integer_vector ) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              A        => A,
              AtLeast  => AtLeast,
              Weight   => 0,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function GenBin ( A : integer_vector ) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              A        => A,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_COUNT
            ) ;
  end function GenBin ;

  ------------------------------------------------------------
  function IllegalBin ( Min, Max, NumBin : integer ) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => NumBin,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_ILLEGAL
            ) ;
  end function IllegalBin ;

  ------------------------------------------------------------
  function IllegalBin ( Min, Max : integer ) return CovBinType is
  ------------------------------------------------------------
  begin
    -- default, generate one CovBin with the entire range of values
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_ILLEGAL
            ) ;
  end function IllegalBin ;

  ------------------------------------------------------------
  function IllegalBin ( A : integer ) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              Min      => A,
              Max      => A,
              NumBin   => 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_ILLEGAL
            ) ;
  end function IllegalBin ;

-- IgnoreBin should never have an AtLeast parameter
  ------------------------------------------------------------
  function IgnoreBin (Min, Max, NumBin : integer) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => NumBin,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_IGNORE
            ) ;
  end function IgnoreBin ;

  ------------------------------------------------------------
  function IgnoreBin (Min, Max : integer) return CovBinType is
  ------------------------------------------------------------
  begin
    -- default, generate one CovBin with the entire range of values
    return  MakeBin(
              Min      => Min,
              Max      => Max,
              NumBin   => 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_IGNORE
            ) ;
  end function IgnoreBin ;

  ------------------------------------------------------------
  function IgnoreBin (A : integer) return CovBinType is
  ------------------------------------------------------------
  begin
    return  MakeBin(
              Min      => A,
              Max      => A,
              NumBin   => 1,
              AtLeast  => 0,
              Weight   => 0,
              Action   => COV_IGNORE
            ) ;
  end function IgnoreBin ;

  ------------------------------------------------------------
  function GenCross(  -- 2
  -- Cross existing bins
  -- Use AddCross for adding values directly to coverage database
  -- Use GenCross for constants
  ------------------------------------------------------------
    AtLeast     : integer ;
    Weight      : integer ;
    Bin1, Bin2  : CovBinType
  ) return CovMatrix2Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix2Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(AtLeast : integer ; Bin1, Bin2 : CovBinType) return CovMatrix2Type is
  -- Cross existing bins  -- use AddCross instead
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(Bin1, Bin2 : CovBinType) return CovMatrix2Type is
  -- Cross existing bins  -- use AddCross instead
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 3
  ------------------------------------------------------------
    AtLeast           : integer ;
    Weight            : integer ;
    Bin1, Bin2, Bin3  : CovBinType
  ) return CovMatrix3Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix3Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3 : CovBinType ) return CovMatrix3Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3 : CovBinType ) return CovMatrix3Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 4
  ------------------------------------------------------------
    AtLeast                 : integer ;
    Weight                  : integer ;
    Bin1, Bin2, Bin3, Bin4  : CovBinType
  ) return CovMatrix4Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix4Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4 : CovBinType ) return CovMatrix4Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4 : CovBinType ) return CovMatrix4Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 5
  ------------------------------------------------------------
    AtLeast                       : integer ;
    Weight                        : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5  : CovBinType
  ) return CovMatrix5Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4, Bin5) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix5Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4, Bin5) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4, Bin5 : CovBinType ) return CovMatrix5Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4, Bin5) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5 : CovBinType ) return CovMatrix5Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4, Bin5) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 6
  ------------------------------------------------------------
    AtLeast                             : integer ;
    Weight                              : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6  : CovBinType
  ) return CovMatrix6Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4, Bin5, Bin6) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix6Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4, Bin5, Bin6 : CovBinType ) return CovMatrix6Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6 : CovBinType ) return CovMatrix6Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 7
  ------------------------------------------------------------
    AtLeast                                   : integer ;
    Weight                                    : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7  : CovBinType
  ) return CovMatrix7Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix7Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7 : CovBinType ) return CovMatrix7Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7 : CovBinType ) return CovMatrix7Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 8
  ------------------------------------------------------------
    AtLeast                                         : integer ;
    Weight                                          : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8  : CovBinType
  ) return CovMatrix8Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix8Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8 : CovBinType ) return CovMatrix8Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8 : CovBinType ) return CovMatrix8Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross(  -- 9
  ------------------------------------------------------------
    AtLeast                                               : integer ;
    Weight                                                : integer ;
    Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9  : CovBinType
  ) return CovMatrix9Type is
    constant BIN_LENS : integer_vector := BinLengths(Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9) ;
    constant NUM_NEW_BINS : integer := CalcNumCrossBins(BIN_LENS) ;
    variable BinIndex     : integer_vector(1 to BIN_LENS'length) := (others => 1) ;
    variable CrossBins    : CovBinType(BinIndex'range) ;
    variable Action       : integer ;
    variable iCovMatrix   : CovMatrix9Type(1 to NUM_NEW_BINS) ;
  begin
    for MatrixIndex in iCovMatrix'range loop
      CrossBins := ConcatenateBins(BinIndex, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9) ;
      Action       := MergeState(CrossBins) ;
      iCovMatrix(MatrixIndex).action  := Action ;
      iCovMatrix(MatrixIndex).count   := 0 ;
      iCovMatrix(MatrixIndex).BinVal  := MergeBinVal(CrossBins) ;
      iCovMatrix(MatrixIndex).AtLeast := MergeAtLeast( Action, AtLeast, CrossBins) ;
      iCovMatrix(MatrixIndex).Weight  := MergeWeight ( Action, Weight,  CrossBins) ;
      IncBinIndex( BinIndex, BIN_LENS ) ; -- increment right most one, then if overflow, increment next
    end loop ;
    return iCovMatrix ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( AtLeast : integer ; Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9 : CovBinType ) return CovMatrix9Type is
  ------------------------------------------------------------
  begin
    return GenCross(AtLeast, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9) ;
  end function GenCross ;

  ------------------------------------------------------------
  function GenCross( Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9 : CovBinType ) return CovMatrix9Type is
  ------------------------------------------------------------
  begin
    return GenCross(1, 1, Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9) ;
  end function GenCross ;

  ------------------------------------------------------------
  function to_integer ( B : boolean ) return integer is
  ------------------------------------------------------------
  begin
    if B then
      return 1 ;
    else
      return 0 ;
    end if ;
  end function to_integer ;

  ------------------------------------------------------------
  function CheckInteger_1_0 ( I : integer ) return boolean is
  -------------------------------------------------------------
  begin
    case I is
      when 0 | 1 =>   return TRUE ;
      when others =>  return FALSE ;
    end case ;
  end function CheckInteger_1_0 ;

  ------------------------------------------------------------
  function local_to_boolean ( I : integer ) return boolean is
  ------------------------------------------------------------
  begin
    case I is
      when 1 =>  return TRUE ;
      when 0 =>  return FALSE ;
      when others =>
        return FALSE ;
    end case ;
  end function local_to_boolean ;

  ------------------------------------------------------------
  function to_boolean ( I : integer ) return boolean is
  ------------------------------------------------------------
  begin
    if not CheckInteger_1_0(I) then
      report
        "CoveragePkg.to_boolean: invalid integer value: " & to_string(I) &
        " returning FALSE" severity WARNING ;
    end if ;

    return local_to_boolean(I) ;
  end function to_boolean ;

  ------------------------------------------------------------
  function to_integer ( SL : std_logic ) return integer is
  -------------------------------------------------------------
  begin
    case SL is
      when '1' | 'H' =>  return 1 ;
      when '0' | 'L' =>  return 0 ;
      when others    =>  return -1 ;
    end case ;
  end function to_integer ;

  ------------------------------------------------------------
  function local_to_std_logic ( I : integer ) return std_logic is
  -------------------------------------------------------------
  begin
    case I is
      when 1 =>       return '1' ;
      when 0 =>       return '0' ;
      when others =>  return 'X' ;
    end case ;
  end function local_to_std_logic ;

  ------------------------------------------------------------
  function to_std_logic ( I : integer ) return std_logic is
  -------------------------------------------------------------
  begin
    if not CheckInteger_1_0(I) then
      report
        "CoveragePkg.to_std_logic: invalid integer value: " & to_string(I) &
        " returning X" severity WARNING ;
    end if ;

    return local_to_std_logic(I) ;
  end function to_std_logic ;

  ------------------------------------------------------------
  function to_integer_vector ( BV : boolean_vector ) return integer_vector is
  ------------------------------------------------------------
    variable result : integer_vector(BV'range) ;
  begin
    for i in BV'range loop
      result(i) := to_integer(BV(i)) ;
    end loop ;
    return result ;
  end function to_integer_vector ;

  ------------------------------------------------------------
  function to_boolean_vector ( IV : integer_vector ) return boolean_vector is
  ------------------------------------------------------------
    variable result : boolean_vector(IV'range) ;
    variable HasError : boolean := FALSE ;
  begin
    for i in IV'range loop
      result(i) := local_to_boolean(IV(i)) ;
      if not CheckInteger_1_0(IV(i)) then
        HasError := TRUE ;
      end if ;
    end loop ;

    if HasError then
      report
        "CoveragePkg.to_boolean_vector: invalid integer value" &
        " returning FALSE" severity WARNING ;
    end if ;

    return result ;
  end function to_boolean_vector ;

  ------------------------------------------------------------
  function to_integer_vector ( SLV : std_logic_vector ) return integer_vector is
  -------------------------------------------------------------
    variable result : integer_vector(SLV'range) ;
  begin
    for i in SLV'range loop
      result(i) := to_integer(SLV(i)) ;
    end loop ;
    return result ;
  end function to_integer_vector ;

  ------------------------------------------------------------
  function to_std_logic_vector ( IV : integer_vector ) return std_logic_vector is
  -------------------------------------------------------------
    variable result : std_logic_vector(IV'range) ;
    variable HasError : boolean := FALSE ;
  begin
    for i in IV'range loop
      result(i) := local_to_std_logic(IV(i)) ;
      if not CheckInteger_1_0(IV(i)) then
        HasError := TRUE ;
      end if ;
    end loop ;

    if HasError then
      report
        "CoveragePkg.to_std_logic_vector: invalid integer value" &
        " returning FALSE" severity WARNING ;
    end if ;

    return result ;
  end function to_std_logic_vector ;
end package body CoveragePkg ;