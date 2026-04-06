#  File Name:         osvvm.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to compile the OSVVM library  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#     7/2024   2024.07    Added signed, unsigned, and integer_vector scoreboards 
#     3/2024   2024.03    Updated to handle Xilinx issues 
#     5/2023   2023.05    Added BurstCoveragePkg 
#     4/2023   2023.04    Updated handling of OsvvmScriptSettingsPkg since it 
#                         is now two pieces with deferred constants
#     1/2023   2023.01    Added OsvvmScriptSettingsPkg and script to create it.
#     8/2022   2022.08    Added MemorySupportPkg and MemoryGenericPkg
#    10/2021   2021.10    Added ReportPkg
#     6/2021   2021.06    Updated for release
#     1/2020   2020.01    Updated Licenses to Apache
#    11/2016   2016.11    Compile Script for OSVVM
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2016 - 2025 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  

library osvvm

analyze IfElsePkg.vhd
analyze OsvvmTypesPkg.vhd

# Analyze package declarations
analyze OsvvmScriptSettingsPkg.vhd    ; # package declaration.  See end for package body
analyze OsvvmSettingsPkg.vhd
# if {!$::osvvm::ToolSupportsDeferredConstants}  {
#   # Compile early in tools that do not support deferred constants
#   include OsvvmVhdlSettings.pro
# }
include OsvvmVhdlSettings.pro

if {$::osvvm::ToolName ne "XSIM"}  {
  analyze TextUtilPkg.vhd
} else {
  analyze deprecated/TextUtilPkg_xilinx.vhd
}

analyze FileUtilPkg.vhd
analyze ResolutionPkg.vhd
analyze NamePkg.vhd
analyze OsvvmGlobalPkg.vhd

# Compile CoverageVendorApiPkg_***.vhd appropriate for the simulator
analyze CoverageVendorApiPkg_${::osvvm::FunctionalCoverageIntegratedInSimulator}.vhd

analyze TranscriptPkg.vhd

if {$::osvvm::VhdlVersion >= 2019}  {
  analyze LanguageSupport2019Pkg.vhd
} else {
  analyze deprecated/LanguageSupport2019Pkg_c.vhd
}

if {$::osvvm::Supports2019FilePath && $::osvvm::VhdlVersion >= 2019} {
  analyze FileLinePathPkg.vhd
} else {
  analyze deprecated/FileLinePathPkg_c.vhd
}

if {$::osvvm::Supports2019AssertApi  && $::osvvm::VhdlVersion >= 2019} {
  analyze AssertApiPkg.vhd
} else {
  analyze deprecated/AssertApiPkg_c.vhd
}


analyze AlertLogPkg.vhd

analyze IdFifoPtypePkg.vhd 

if {$::osvvm::ToolName ne "XSIM"}  {
  analyze TbUtilPkg.vhd
} else {
  analyze deprecated/TbUtilPkg_xilinx.vhd
}

analyze NameStorePkg.vhd

analyze MessageListPkg.vhd
# PT based MessagePkg replaced by List based MessageListPkg
# analyze MessagePkg.vhd      
analyze SortListPkg_int.vhd
analyze RandomBasePkg.vhd [NoNullRangeWarning]
analyze RandomPkg.vhd [NoNullRangeWarning]
# RandomProcedurePkg is a temporary and is used by CoveragePkg
# Likely will be replaced when VHDL-2019 support is good.
analyze RandomProcedurePkg.vhd
analyze CoveragePkg.vhd [NoNullRangeWarning]
analyze CoveragePtPkg.vhd 
analyze DelayCoveragePkg.vhd

if {[string compare $::osvvm::ClockResetVersion "2024.05"] == 1}  {
  analyze ClockResetPkg.vhd
} else {
  analyze deprecated/ClockResetPkg_2024_05.vhd
}

analyze ResizePkg.vhd

if {$::osvvm::ToolName eq "NVC"}  { 
  analyze DynamicArrayGenericPkg.vhd 
  analyze DynamicArrayPkg_instances.vhd
} else {
  analyze deprecated/DynamicArrayPkg_IntV_c.vhd 
  analyze deprecated/DynamicArrayPkg_slv_c.vhd 
}

if {$::osvvm::ToolSupportsGenericPackages}  {
  if {$::osvvm::ToolName ne "XSIM"}  {
    analyze ScoreboardGenericPkg.vhd
    analyze ScoreboardPkg_IntV.vhd
  } else {
    analyze deprecated/ScoreboardGenericPkg_pure.vhd
    analyze deprecated/ScoreboardPkg_IntV_c.vhd    ; # works around mapping issue and provides a compatible package.
  }
  analyze ScoreboardPkg_slv.vhd
  analyze ScoreboardPkg_int.vhd
  analyze ScoreboardPkg_signed.vhd
  analyze ScoreboardPkg_unsigned.vhd
#  analyze ScoreboardPkg_IntV.vhd      ; # do not analyze with XSIM.
} else {
  analyze deprecated/ScoreboardPkg_slv_c.vhd
  analyze deprecated/ScoreboardPkg_int_c.vhd
  analyze deprecated/ScoreboardPkg_signed_c.vhd
  analyze deprecated/ScoreboardPkg_unsigned_c.vhd
  analyze deprecated/ScoreboardPkg_IntV_c.vhd
}

analyze MemorySupportPkg.vhd
if {$::osvvm::ToolSupportsGenericPackages}  {
#  analyze MemoryGenericPkg.vhd
  if {$::osvvm::ToolName ne "XSIM"}  {
    analyze MemoryGenericPkg.vhd
  } else {
    analyze deprecated/MemoryGenericPkg_xilinx.vhd
  }
  analyze MemoryPkg.vhd
} else {
  analyze deprecated/MemoryPkg_c.vhd
  analyze deprecated/MemoryPkg_orig_c.vhd
}

analyze ReportPkg.vhd

if {$::osvvm::VhdlVersion >= 2019 && $::osvvm::Supports2019ImpureFunctions}  {
  analyze RandomPkg2019.vhd [NoNullRangeWarning]
} else {
  analyze  deprecated/RandomPkg2019_c.vhd
}

analyze OsvvmContext.vhd 


# if {$::osvvm::ToolSupportsDeferredConstants}  {
#   include OsvvmVhdlSettings.pro
# }

