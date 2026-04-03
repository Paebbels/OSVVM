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
--    05/2026   2026.05    Initial.   
--                         Restructure CoveragePType to call CoveragePkg Singleton.
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
use work.RandomBasePkg.all ;
use work.RandomProcedurePkg.all ;
use work.RandomPkg.all ;
use work.NamePkg.all ;
use work.NameStorePkg.all ;
use work.MessageListPkg.all ;
use work.OsvvmGlobalPkg.all ;
use work.CoverageVendorApiPkg.all ;
use work.LanguageSupport2019Pkg.all ;
use work.CoveragePkg.all ; 

package CoveragePtPkg is

  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------
  type CovPType is protected
    -- Fetch ID so can do ID based operations too
    impure function GetCoverageID return CoverageIDType ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    --  Writing Out RAW Coverage Bin Information
    --  Note that read supports merging of coverage models
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) ;
    procedure FileCloseWriteBin ;
    procedure PrintToCovFile(S : string) ;

    procedure SetReportOptions (
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
  -- /////////////////////////////////////////
  -- Compatibility Methods - Allows CoveragePkg to Work as a PT still
  -- /////////////////////////////////////////
  -- /////////////////////////////////////////
  ------------------------------------------------------------
    procedure       SetName    (Name : String) ;
    impure function SetName    (Name : String) return string ;
    impure function GetName return String ;
    impure function GetCovModelName return String ;
    impure function GetNamePlus(prefix, suffix : string) return String ;
    procedure       DeallocateName ;    -- clear name

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
    procedure Deallocate ;

    ------------------------------------------------------------
    --  Recording and Clearing Coverage
    procedure ICoverLast ;
    procedure ICover( CovPoint : integer) ;
    procedure ICover( CovPoint : integer_vector) ;
    procedure TCover( A : integer) ;
    impure function FindBinIndex(CoverPoint : integer_vector; StartingIndex : integer := 1) return integer ;

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

    ------------------------------------------------------------
    -- The return value may change as the package evolves
    -- Get all bin information except the BinVal (since it is sized)
    impure function GetBinInfo ( BinIndex : integer ) return CovBinBaseType ;
    impure function GetBinValLength return integer ;
    impure function GetBinName ( BinIndex : integer; DefaultName : string := "" ) return string ;

    ------------------------------------------------------------
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

    ------------------------------------------------------------
    procedure DumpBin (LogLevel : LogType := DEBUG) ;  -- Development only

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType := ALWAYS ) ;
    procedure WriteCovHoles ( PercentCov : real ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  PercentCov : real ) ;
    procedure WriteCovHoles ( FileName : string;   OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( FileName : string;   PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure WriteCovHoles ( LogLevel : LogType;  FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) ;

    ------------------------------------------------------------
    procedure WriteCovDb (FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) ;
    procedure ReadCovDb (FileName : string; Merge : boolean := FALSE) ;
    procedure WriteCovYaml (FileName : string := ""; Coverage : real ; OpenKind : File_Open_Kind := WRITE_MODE) ;
    procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) ;

------------------------------------------------------------
--  Remaining are Deprecated
--
/*
    -- Deprecated/Subsumed by versions with PercentCov Parameter (rather than AtLeast value)
    impure function RandCovPoint  (AtLeast : integer ) return integer ;
    impure function RandCovPoint  (AtLeast : integer ) return integer_vector ;
    impure function RandCovBinVal (AtLeast : integer ) return RangeArrayType ;
    impure function RandCovHole   (AtLeast : integer ) return RangeArrayType ;
    impure function CountCovHoles (AtLeast : integer ) return integer ;
    impure function IsCovered     (AtLeast : integer ) return boolean ;
    impure function GetHoleBinVal (ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType ;
    impure function GetCovHole    (ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType ;

    ------------------------------------------------------------
    procedure       WriteCovHoles (AtLeast : integer ) ;
    procedure       WriteCovHoles (LogLevel : LogType;    AtLeast : integer ) ;
    procedure       WriteCovHoles (FileName : string;     AtLeast : integer;  OpenKind : File_Open_Kind := APPEND_MODE ) ;
    procedure       WriteCovHoles (LogLevel : LogType;    FileName : string;  AtLeast  : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) ;
 */
    ------------------------------------------------------------
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

    ------------------------------------------------------------
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

end package CoveragePtPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

package body CoveragePtPkg is

  ------------------------------------------------------------------------------------------
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CovPType  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ------------------------------------------------------------------------------------------
  type CovPType is protected body
    file OsvvmCoverageWriteBinFile : text ;
    variable WriteBinFileInit : boolean := FALSE ;

    constant INIT_COVERAGE_ID : CoverageIDType := (ID => integer'right) ; 
    variable CoverageID       : CoverageIDType := INIT_COVERAGE_ID ; 

    -----------------------------------------------------------
    procedure CheckCoverageID  is
    ------------------------------------------------------------
    begin
      if CoverageID = INIT_COVERAGE_ID then
        CoverageID := NewID("COV_SharedVariable") ; 
      end if ; 
    end procedure CheckCoverageID ;

    -----------------------------------------------------------
    impure function GetCoverageID return CoverageIDType is
    ------------------------------------------------------------
    begin
      return CoverageID ; 
    end function GetCoverageID ;

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- These apply to all coverage models 
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure FileOpenWriteBin (FileName : string; OpenKind : File_Open_Kind ) is
    ------------------------------------------------------------
    begin
      work.CoveragePkg.FileOpenWriteBin(FileName, OpenKind) ;
    end procedure FileOpenWriteBin ;

    ------------------------------------------------------------
    procedure FileCloseWriteBin is
    ------------------------------------------------------------
    begin
      work.CoveragePkg.FileCloseWriteBin ;
    end procedure FileCloseWriteBin ;

    ------------------------------------------------------------
    procedure PrintToCovFile(S : string) is
    ------------------------------------------------------------
    begin
      work.CoveragePkg.PrintToCovFile(S) ; 
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
      work.CoveragePkg.SetReportOptions(
        WritePassFail, WriteBinInfo, WriteCount, WriteAnyIllegal, WritePrefix, PassName, FailName
      ) ;
    end procedure SetReportOptions ; 

    ------------------------------------------------------------
    procedure ResetReportOptions is
    ------------------------------------------------------------
    begin
      work.CoveragePkg.ResetReportOptions ;
    end procedure ResetReportOptions ; 

    ------------------------------------------------------------
    -- /////////////////////////////////////////
    -- These apply to a specific coverage model 
    -- /////////////////////////////////////////
    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetName (Name : String) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetName(CoverageID, Name) ;
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
      CheckCoverageID ;
      return GetName(CoverageID) ;
    end function GetName ;

    ------------------------------------------------------------
    impure function GetCovModelName return String is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetCovModelName(CoverageID) ;
    end function GetCovModelName ;

    ------------------------------------------------------------
    impure function GetNamePlus(prefix, suffix : string) return String is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetNamePlus(CoverageID, prefix, suffix) ;
    end function GetNamePlus ;

    ------------------------------------------------------------
    procedure DeallocateName is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      DeallocateName(CoverageID) ;
    end procedure DeallocateName ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetMessage (Message : String) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetMessage(CoverageID, Message) ;
    end procedure SetMessage ;

    ------------------------------------------------------------
    procedure DeallocateMessage is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      DeallocateMessage(CoverageID) ;
    end procedure DeallocateMessage ;

    ------------------------------------------------------------
    procedure SetCovTarget (Percent : real) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetCovTarget(CoverageID, Percent) ;
    end procedure SetCovTarget ;

    ------------------------------------------------------------
    impure function GetCovTarget return real is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetCovTarget(CoverageID) ;
    end function GetCovTarget ;

    ------------------------------------------------------------
    procedure SetThresholding (A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetThresholding(CoverageID, A) ;
    end procedure SetThresholding ;

    ------------------------------------------------------------
    procedure SetCovThreshold (Percent : real) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetCovThreshold(CoverageID, Percent) ;
    end procedure SetCovThreshold ;

    ------------------------------------------------------------
    procedure SetMerging (A : boolean := TRUE ) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetMerging(CoverageID, A) ;
    end procedure SetMerging ;

    ------------------------------------------------------------
    procedure SetCountMode (A : CountModeType) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetCountMode(CoverageID, A) ;
    end procedure SetCountMode ;

    ------------------------------------------------------------
    procedure SetIllegalMode (A : IllegalModeType) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetIllegalMode(CoverageID, A) ;
    end procedure SetIllegalMode ;

    ------------------------------------------------------------
    procedure SetWeightMode (A : WeightModeType;  Scale : real := 1.0) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetWeightMode(CoverageID, A, Scale) ;
    end procedure SetWeightMode ;

    ------------------------------------------------------------
    procedure SetNextPointMode (A : NextPointModeType) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetNextPointMode(CoverageID, A) ;
    end procedure SetNextPointMode ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetAlertLogID (A : AlertLogIDType) is
    ------------------------------------------------------------
    begin
--!! not currently on the singleton interface
 --     CheckCoverageID ; 
 --     SetAlertLogID(CoverageID, A) ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    procedure SetAlertLogID(Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID ; CreateHierarchy : Boolean := TRUE) is
    ------------------------------------------------------------
--      constant SeedInit : boolean := CovStructPtr(CoverageID.ID).RvSeedInit ;
    begin
--!! not currently on the singleton interface
--      SetAlertLogID(CoverageID, Name, ParentID, CreateHierarchy) ;
--      if not SeedInit then
--        InitSeed(CoverageID, Name) ;
--      end if ;
    end procedure SetAlertLogID ;

    ------------------------------------------------------------
    impure function GetAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetAlertLogID(CoverageID) ;
    end function GetAlertLogID ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure InitSeed (S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      InitSeed(CoverageID, S, UseNewSeedMethods) ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    impure function InitSeed (S : string;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) return string is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return InitSeed(CoverageID, S, UseNewSeedMethods) ;
    end function InitSeed ;

    ------------------------------------------------------------
    procedure InitSeed (I : integer;  UseNewSeedMethods : boolean := COVERAGE_USE_NEW_SEED_METHODS) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      InitSeed(CoverageID, I, UseNewSeedMethods) ;
    end procedure InitSeed ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetSeed (RandomSeedIn : RandomSeedType ) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetSeed(CoverageID, RandomSeedIn) ;
    end procedure SetSeed ;

    ------------------------------------------------------------
    impure function GetSeed return RandomSeedType is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetSeed(CoverageID) ;
    end function GetSeed ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure SetBinSize (NewNumBins : integer) is
    -- Sets a CovBin to a particular size
    -- Use for small bins to save space or large bins to
    -- suppress the resize and copy as a CovBin autosizes.
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetBinSize(CoverageID, NewNumBins) ;
    end procedure SetBinSize ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure AddBins (
    ------------------------------------------------------------
      Name    : String ;
      AtLeast : integer ;
      Weight  : integer ;
      CovBin  : CovBinType
    ) is
    begin
      CheckCoverageID ;
      AddBins(CoverageID, Name, AtLeast, Weight, CovBin) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( Name : String ; AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins(Name, AtLeast, 1, CovBin) ; -- Call previous one
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (Name : String ;  CovBin : CovBinType) is
    ------------------------------------------------------------
    begin
      AddBins(Name, 1, 1, CovBin) ;  -- Call first one
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( AtLeast : integer ; Weight  : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins("", AtLeast, Weight, CovBin) ;  -- Call first one
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( AtLeast : integer ; CovBin : CovBinType ) is
    ------------------------------------------------------------
    begin
      AddBins("", AtLeast, 1, CovBin) ;  -- Call first one
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins ( CovBin : CovBinType  ) is
    ------------------------------------------------------------
    begin
      AddBins("", 1, 1, CovBin) ;  -- Call first one
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
      CheckCoverageID ;
      AddCross(CoverageID, Name, AtLeast, Weight,
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
      -- Call previous one
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
      -- Call first one
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
      -- Call first one
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
      -- Call first one
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
      -- Call first one
      AddCross("", 1, 1,
           Bin1, Bin2, Bin3, Bin4, Bin5, Bin6, Bin7, Bin8, Bin9, Bin10, Bin11,
           Bin12, Bin13, Bin14, Bin15, Bin16, Bin17, Bin18, Bin19, Bin20
        ) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    -- These support usage of cross coverage constants
    -- Also support the older AddCross(GenCross(...)) methodology
    -- which has been replaced by AddCross
    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix2Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix3Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix4Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix5Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix6Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix7Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix8Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    procedure AddCross (CovBin : CovMatrix9Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddCross ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure Deallocate is
    ------------------------------------------------------------
    begin
      ResetReportOptions ;
      Deallocate(CoverageID) ;
    end procedure deallocate ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure ICoverLast is
    ------------------------------------------------------------
    begin
      ICoverLast(CoverageID) ;
    end procedure ICoverLast ;

    ------------------------------------------------------------
    procedure ICover ( CovPoint : integer) is
    ------------------------------------------------------------
    begin
      ICover(CoverageID, (1=> CovPoint)) ;
    end procedure ICover ;

    ------------------------------------------------------------
    procedure ICover( CovPoint : integer_vector) is
    ------------------------------------------------------------
    begin
      ICover(CoverageID, CovPoint) ;
     end procedure ICover ;

    ------------------------------------------------------------
    procedure TCover ( A : integer) is
    ------------------------------------------------------------
    begin
      TCover(CoverageID, A) ;
    end procedure TCover ;

    ------------------------------------------------------------
    impure function FindBinIndex(
    ------------------------------------------------------------
      CoverPoint       : integer_vector ; 
      StartingIndex  : integer := 1
    ) return integer is
    begin
      return FindBinIndex(CoverageID, CoverPoint, StartingIndex) ;
    end function FindBinIndex ;

    ------------------------------------------------------------
    procedure ClearCov is
    ------------------------------------------------------------
    begin
      ClearCov(CoverageID) ;
    end procedure ClearCov ;

    ------------------------------------------------------------
    -- deprecated
    procedure SetCovZero is
    ------------------------------------------------------------
    begin
      ClearCov(CoverageID) ;
    end procedure SetCovZero ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    impure function IsCovered ( PercentCov : real ) return boolean is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return IsCovered(CoverageID, PercentCov) ;
    end function IsCovered ;

    ------------------------------------------------------------
    impure function IsCovered return boolean is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return IsCovered(CoverageID) ;
    end function IsCovered ;

     ------------------------------------------------------------
    impure function IsInitialized return boolean is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return IsInitialized(CoverageID) ;
    end function IsInitialized ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    impure function GetItemCount return integer is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetItemCount(CoverageID) ;
    end function GetItemCount ;

    ------------------------------------------------------------
    impure function GetCov ( PercentCov : real ) return real is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetCov(CoverageID, PercentCov) ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetCov return real is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetCov(CoverageID ) ;
    end function GetCov ;

    ------------------------------------------------------------
    impure function GetTotalCovCount ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovCount(CoverageID, PercentCov) ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovCount return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovCount(CoverageID) ;
    end function GetTotalCovCount ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovGoal(CoverageID, PercentCov) ;
    end function GetTotalCovGoal ;

    ------------------------------------------------------------
    impure function GetTotalCovGoal return integer is
    ------------------------------------------------------------
    begin
      return GetTotalCovGoal(CoverageID) ;
    end function GetTotalCovGoal ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    impure function GetMinCov return real is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetMinCov(CoverageID) ;
    end function GetMinCov ;

    ------------------------------------------------------------
    impure function GetMinCount return integer is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetMinCount (CoverageID);
    end function GetMinCount ;

    ------------------------------------------------------------
    impure function GetMaxCov return real is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetMaxCov(CoverageID) ;
    end function GetMaxCov ;

    ------------------------------------------------------------
    impure function GetMaxCount return integer is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      return GetMaxCount(CoverageID);
    end function GetMaxCount ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    impure function CountCovHoles ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return CountCovHoles(CoverageID, PercentCov) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    impure function CountCovHoles return integer is
    ------------------------------------------------------------
    begin
      return CountCovHoles(CoverageID) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    -- Return Points
    ------------------------------------------------------------
    impure function GetPoint ( BinIndex : integer ) return integer is
    ------------------------------------------------------------
    begin
      return     GetPoint(CoverageID, BinIndex) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetPoint ( BinIndex : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetPoint(CoverageID, BinIndex) ;
    end function GetPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID, PercentCov) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetRandPoint ( PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID, PercentCov) ;
    end function GetRandPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetIncPoint(CoverageID) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetIncPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetIncPoint(CoverageID) ;
    end function GetIncPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetMinPoint(CoverageID) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMinPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetMinPoint(CoverageID) ;
    end function GetMinPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetMaxPoint(CoverageID) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetMaxPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetMaxPoint(CoverageID) ;
    end function GetMaxPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(CoverageID) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(CoverageID) ;
    end function GetNextPoint ;

    ------------------------------------------------------------
    impure function GetNextPoint (Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(CoverageID, Mode) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    impure function GetNextPoint (Mode : NextPointModeType) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetNextPoint(CoverageID, Mode) ;
    end function GetNextPoint;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint ( PercentCov : real ) return integer is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID, PercentCov) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- deprecated, see GetRandPoint
    impure function RandCovPoint ( PercentCov : real ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     GetRandPoint(CoverageID, PercentCov) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Return BinVals
    ------------------------------------------------------------
    impure function GetBinVal ( BinIndex : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetBinVal(CoverageID, BinIndex) ;
    end function GetBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetRandBinVal(CoverageID, PercentCov) ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetRandBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetRandBinVal(CoverageID) ;  -- GetBinVal
    end function GetRandBinVal ;

    ------------------------------------------------------------
    impure function GetLastBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetLastBinVal(CoverageID) ;
    end function GetLastBinVal ;

    ------------------------------------------------------------
    impure function GetIncBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetIncBinVal( CoverageID ) ;
    end function GetIncBinVal ;

    ------------------------------------------------------------
    impure function GetMinBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetMinBinVal( CoverageID ) ;
    end function GetMinBinVal ;

    ------------------------------------------------------------
    impure function GetMaxBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      -- use global coverage target
      return GetMaxBinVal( CoverageID ) ;
    end function GetMaxBinVal ;

    ------------------------------------------------------------
    impure function GetNextBinVal return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetNextBinVal (CoverageID) ;
    end function GetNextBinVal ;

    ------------------------------------------------------------
    impure function GetNextBinVal (Mode : NextPointModeType) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetNextBinVal (CoverageID, Mode) ;
    end function GetNextBinVal;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( ReqHoleNum : integer ; PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(CoverageID, ReqHoleNum, PercentCov) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( PercentCov : real  ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(CoverageID, 1, PercentCov) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    impure function GetHoleBinVal ( ReqHoleNum : integer := 1 ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal(CoverageID, ReqHoleNum) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal  return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetRandBinVal(CoverageID) ;  -- GetBinVal
    end function RandCovBinVal ;

    ------------------------------------------------------------
    -- deprecated, see GetRandBinVal
    impure function RandCovBinVal ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetRandBinVal(CoverageID, PercentCov) ;  -- GetBinVal
    end function RandCovBinVal ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Return Index Values
    ------------------------------------------------------------
    impure function GetNumBins return integer is
    ------------------------------------------------------------
    begin
      return GetNumBins(CoverageID) ;
    end function GetNumBins ;

    ------------------------------------------------------------
    impure function GetRandIndex return integer is
    ------------------------------------------------------------
    begin
      return GetRandIndex(CoverageID) ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetRandIndex ( CovTargetPercent : real ) return integer is
    ------------------------------------------------------------
    begin
      return GetRandIndex(CoverageID, CovTargetPercent) ;
    end function GetRandIndex ;

    ------------------------------------------------------------
    impure function GetLastIndex return integer is
    ------------------------------------------------------------
    begin
      return GetLastIndex(CoverageID) ;
    end function GetLastIndex ;

    ------------------------------------------------------------
    impure function GetIncIndex return integer is
    ------------------------------------------------------------
    begin
      return GetIncIndex(CoverageID) ;
    end function GetIncIndex ;

    ------------------------------------------------------------
    impure function GetMinIndex return integer is
    ------------------------------------------------------------
    begin
      return GetMinIndex(CoverageID) ;
    end function GetMinIndex ;

    ------------------------------------------------------------
    impure function GetMaxIndex return integer is
    ------------------------------------------------------------
    begin
      return GetMaxIndex(CoverageID) ;
    end function GetMaxIndex ;

    ------------------------------------------------------------
    impure function GetNextIndex return integer is
    ------------------------------------------------------------
    begin
      return GetNextIndex(CoverageID) ;
    end function GetNextIndex ;

    ------------------------------------------------------------
    impure function GetNextIndex (Mode : NextPointModeType) return integer is
    ------------------------------------------------------------
    begin
      return GetNextIndex(CoverageID, Mode) ;
    end function GetNextIndex;

    ------------------------------------------------------------
    -- ------------------------------------------------------------
    -- Intended as a stand in until we get a more general GetBin
    impure function GetBinInfo ( BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBinInfo(CoverageID, BinIndex) ;
    end function GetBinInfo ;

    -- ------------------------------------------------------------
    -- Intended as a stand in until we get a more general GetBin
    impure function GetBinValLength return integer is
    -- ------------------------------------------------------------
    begin
      return     GetBinValLength(CoverageID) ;
    end function GetBinValLength ;

    -- ------------------------------------------------------------
    impure function GetBinName ( BinIndex : integer; DefaultName : string := "" ) return string is
    -- ------------------------------------------------------------
    begin
      return GetBinName(CoverageID, BinIndex, DefaultName) ;
    end function GetBinName;

-- Eventually the multiple GetBin functions will be replaced by a
-- a single GetBin that returns CovBinBaseType with BinVal as an
-- unconstrained element
    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovBinBaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix2BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix3BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix4BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix5BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix6BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix7BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix8BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    -- ------------------------------------------------------------
    impure function GetBin ( BinIndex : integer ) return CovMatrix9BaseType is
    -- ------------------------------------------------------------
    begin
      return     GetBin(CoverageID, BinIndex) ;
    end function GetBin ;

    ------------------------------------------------------------
    impure function GetErrorCount return integer is
    ------------------------------------------------------------
    begin
      return GetErrorCount(CoverageID) ;
    end function GetErrorCount ;

    ------------------------------------------------------------
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
    begin
      SetReportOptions (
        WritePassFail   => WritePassFail,
        WriteBinInfo    => WriteBinInfo,
        WriteCount      => WriteCount,
        WriteAnyIllegal => WriteAnyIllegal,
        WritePrefix     => WritePrefix,
        PassName        => PassName,
        FailName        => FailName
      ) ;
      WriteBin (ID => CoverageID) ;
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
      SetReportOptions (
        WritePassFail   => WritePassFail,
        WriteBinInfo    => WriteBinInfo,
        WriteCount      => WriteCount,
        WriteAnyIllegal => WriteAnyIllegal,
        WritePrefix     => WritePrefix,
        PassName        => PassName,
        FailName        => FailName
      ) ;
      WriteBin (ID => CoverageID, LogLevel => LogLevel) ;
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
    begin
      SetReportOptions (
        WritePassFail   => WritePassFail,
        WriteBinInfo    => WriteBinInfo,
        WriteCount      => WriteCount,
        WriteAnyIllegal => WriteAnyIllegal,
        WritePrefix     => WritePrefix,
        PassName        => PassName,
        FailName        => FailName
      ) ;
      WriteBin (
        ID        => CoverageID, 
        FileName  => FileName, 
        OpenKind  => OpenKind
      ) ;
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
      SetReportOptions (
        WritePassFail   => WritePassFail,
        WriteBinInfo    => WriteBinInfo,
        WriteCount      => WriteCount,
        WriteAnyIllegal => WriteAnyIllegal,
        WritePrefix     => WritePrefix,
        PassName        => PassName,
        FailName        => FailName
      ) ;
      WriteBin (
        ID        => CoverageID, 
        LogLevel  => LogLevel, 
        FileName  => FileName, 
        OpenKind  => OpenKind
      ) ;
    end procedure WriteBin ;  -- With LogLevel

    ------------------------------------------------------------
    procedure DumpBin (LogLevel : LogType := DEBUG) is
    ------------------------------------------------------------
    begin
      DumpBin (CoverageID, LogLevel) ;
    end procedure DumpBin ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType := ALWAYS ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( PercentCov : real ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, PercentCov) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; PercentCov : real ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel, PercentCov) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, FileName, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel, FileName, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, FileName, PercentCov, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  PercentCov : real ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel, FileName, PercentCov, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    procedure WriteCovDb (FileName : string; OpenKind : File_Open_Kind := WRITE_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovDb (CoverageID, FileName, OpenKind) ;
    end procedure WriteCovDb ;

    ------------------------------------------------------------
    procedure ReadCovDb (FileName : string; Merge : boolean := FALSE) is
    ------------------------------------------------------------
    begin
      ReadCovDb (CoverageID, FileName, Merge) ;
    end procedure ReadCovDb ;

    ------------------------------------------------------------
    procedure WriteCovYaml (FileName : string := ""; Coverage : real ; OpenKind : File_Open_Kind := WRITE_MODE) is
    ------------------------------------------------------------
    begin
      WriteCovYaml (CoverageID, FileName, OpenKind) ;
    end procedure WriteCovYaml ;

    ------------------------------------------------------------
    procedure ReadCovYaml  (FileName : string := ""; Merge : boolean := FALSE) is
    ------------------------------------------------------------
    begin
      ReadCovYaml (CoverageID, FileName, Merge) ;
    end procedure ReadCovYaml ;

-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- Deprecated / Subsumed by versions with PercentCov Parameter
-- Maintained for backward compatibility only and
-- may be removed in the future.
-- ------------------------------------------------------------
/*
    ------------------------------------------------------------
    -- Deprecated/Subsumed by versions with PercentCov Parameter (rather than AtLeast value)
    impure function RandCovPoint (AtLeast : integer ) return integer is
    ------------------------------------------------------------
    begin
      return RandCovPoint(CoverageID, AtLeast) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    impure function RandCovPoint (AtLeast : integer ) return integer_vector is
    ------------------------------------------------------------
    begin
      return     RandCovPoint(CoverageID, AtLeast) ;
    end function RandCovPoint ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function RandCovBinVal (AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     RandCovBinVal(CoverageID, AtLeast) ;
    end function RandCovBinVal ;

    ------------------------------------------------------------
    -- Deprecated+  New versions use PercentCov.  Name change.
    impure function RandCovHole (AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     RandCovHole(CoverageID, AtLeast) ;
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function CountCovHoles ( AtLeast : integer ) return integer is
    ------------------------------------------------------------
    begin
      return     CountCovHoles (CoverageID, AtLeast) ;
    end function CountCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function IsCovered ( AtLeast : integer ) return boolean is
    ------------------------------------------------------------
    begin
      return     IsCovered(CoverageID, AtLeast) ;
    end function IsCovered ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov
    impure function GetHoleBinVal ( ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetHoleBinVal (CoverageID, ReqHoleNum, AtLeast) ;
    end function GetHoleBinVal ;

    ------------------------------------------------------------
    -- Deprecated+.  New versions use PercentCov.  Name Change.
    impure function GetCovHole ( ReqHoleNum : integer ; AtLeast : integer ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return     GetCovHole(CoverageID, ReqHoleNum, AtLeast) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, AtLeast) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( LogLevel : LogType ; AtLeast : integer ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel, AtLeast) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, FileName, AtLeast, OpenKind) ;
    end procedure WriteCovHoles ;

    ------------------------------------------------------------
    -- Deprecated.  New versions use PercentCov.
    procedure WriteCovHoles ( LogLevel : LogType ; FileName : string;  AtLeast : integer ; OpenKind : File_Open_Kind := APPEND_MODE ) is
    ------------------------------------------------------------
    begin
      WriteCovHoles(CoverageID, LogLevel, FileName, AtLeast, OpenKind) ;
    end procedure WriteCovHoles ;
 */
--------------------------------------------------------------
--------------------------------------------------------------
-- Deprecated.  Due to name changes to promote greater consistency
-- Maintained for backward compatibility - but only for PT version
-- Not available in Data Structure
-- ------------------------------------------------------------

    ------------------------------------------------------------
    -- Deprecated.  Replaced by SetMessage with multi-line support
    procedure SetItemName (ItemNameIn : String) is
    ------------------------------------------------------------
    begin
      CheckCoverageID ;
      SetMessage(CoverageID, ItemNameIn) ;
    end procedure SetItemName ;

    ------------------------------------------------------------
    impure function CovBinErrCnt return integer is
    -- Deprecated.  Name changed to ErrorCount for package to package consistency
    ------------------------------------------------------------
    begin
      return GetErrorCount(CoverageID) ;
    end function CovBinErrCnt ;

    ------------------------------------------------------------
    -- Deprecated.  Same as RandCovBinVal
    impure function RandCovHole ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return RandCovBinVal(CoverageID, PercentCov)  ;
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as RandCovBinVal
    impure function RandCovHole return RangeArrayType is
    ------------------------------------------------------------
    begin
      return RandCovBinVal(CoverageID)  ;
    end function RandCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( ReqHoleNum : integer ; PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(CoverageID, ReqHoleNum, PercentCov) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( PercentCov : real ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(CoverageID, PercentCov) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetHoleBinVal
    impure function GetCovHole ( ReqHoleNum : integer := 1 ) return RangeArrayType is
    ------------------------------------------------------------
    begin
      return GetHoleBinVal(CoverageID, ReqHoleNum) ;
    end function GetCovHole ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetMinCount
    impure function GetMinCov return integer is
    ------------------------------------------------------------
    begin
      return GetMinCount(CoverageID) ;
    end function GetMinCov ;

    ------------------------------------------------------------
    -- Deprecated.  Same as GetMaxCount
    impure function GetMaxCov return integer is
    ------------------------------------------------------------
    begin
      return GetMaxCount(CoverageID) ;
    end function GetMaxCov ;

    ------------------------------------------------------------
    -- Deprecated.  Use AddCross Instead.
    procedure AddBins (CovBin : CovMatrix2Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix3Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix4Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix5Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix6Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix7Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix8Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

    ------------------------------------------------------------
    procedure AddBins (CovBin : CovMatrix9Type ; Name : String := "") is
    ------------------------------------------------------------
    begin
      AddCross(CoverageID, CovBin, Name) ;
    end procedure AddBins ;

  end protected body CovPType ;

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
  ) is
    variable NumBins1, NumBins2 : integer ;
    variable BinInfo1, BinInfo2 : CovBinBaseType ;
    variable BinVal1, BinVal2 : RangeArrayType(1 to Bin1.GetBinValLength) ;
    variable buf : line ;
--    variable iAlertLogID : AlertLogIDType ;
  begin
--    iAlertLogID := Bin1.GetAlertLogID ;
    
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
      BinVal1  := Bin1.GetBinVal(i) ;
      BinVal2  := Bin2.GetBinVal(i) ;
      if BinInfo1 /= BinInfo2 or BinVal1 /= BinVal2 then
        write(buf, "%% Bin:" & integer'image(i) & " miscompare." & LF) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin1: ") ;
        write(buf, BinVal1) ;
        write(buf, "   Action = " & integer'image(BinInfo1.action)) ;
        write(buf, "   Count = " & integer'image(BinInfo1.count)) ;
        write(buf, "   AtLeast = " & integer'image(BinInfo1.AtLeast)) ;
        write(buf, "   Weight = " & integer'image(BinInfo1.Weight) & LF ) ;
        -- writeline(OUTPUT, buf) ;
        swrite(buf, "%% Bin2: ") ;
        write(buf, BinVal2) ;
        write(buf, "   Action = " & integer'image(BinInfo2.action)) ;
        write(buf, "   Count = " & integer'image(BinInfo2.count)) ;
        write(buf, "   AtLeast = " & integer'image(BinInfo2.AtLeast)) ;
        write(buf, "   Weight = " & integer'image(BinInfo2.Weight) & LF ) ;
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
    AlertIf(ErrorCount /= 0, "CoveragePkg.CompareBins: CoverageModels " & Bin1.GetCovModelName & " and " & Bin2.GetCovModelName & " are not the same.") ; 
  end procedure CompareBins ; 

end package body CoveragePtPkg ;