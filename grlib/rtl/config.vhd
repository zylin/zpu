------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2012, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package: 	config
-- File:	config.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	GRLIB Global configuration package. Can be overriden
--		by local config packages in template designs.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package config is

-- AHBDW - AHB data with
--
-- Valid values are 32, 64, 128 and 256
--
-- The value here sets the width of the AMBA AHB data vectors for all
-- cores in the library.
--
constant CFG_AHBDW     : integer := 32;


-- CORE_ACDM - Enable AMBA Compliant Data Muxing in cores
--
-- Valid values are 0 and 1
--
-- 0: All GRLIB cores that use the ahbread* programs defined in the AMBA package
--    will read their data from the low part of the AHB data vector.
--
-- 1: All GRLIB cores that use the ahbread* programs defined in the AMBA package
--    will select valid data, as defined in the AMBA AHB standard, from the
--    AHB data vectors based on the address input. If a core uses a function
--    that does not have the address input, a failure will be asserted.
--
constant CFG_AHB_ACDM : integer := 0; 

constant grlib_debug_level : integer := 0; 
constant grlib_debug_mask  : integer := 0; 

end;
