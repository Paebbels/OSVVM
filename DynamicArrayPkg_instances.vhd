--
--  File Name:         DynamicArrayPkg_instances.vhd
--  Design Unit Name:  Numerous instances of DynamicArrayGenericPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis          email:  jim@synthworks.com
--
--
--  Description:
--    Instances of DynamicArrayGenericPkg 
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.05    Initial.  
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

-- -----------------------------------------------
-- DynamicArrayPkg_IntV  - dynamic arrays of integer_vector 
--
package DynamicArrayPkg_IntV is new work.DynamicArrayGenericPkg 
  generic map (ArrayType => integer_vector ) ;

-- -----------------------------------------------
-- DynamicArrayPkg_slv  - dynamic arrays of std_logic_vector 
--
library ieee ; 
use ieee.std_logic_1164.all ;
package DynamicArrayPkg_slv is new work.DynamicArrayGenericPkg 
  generic map (ArrayType => std_logic_vector ) ;

