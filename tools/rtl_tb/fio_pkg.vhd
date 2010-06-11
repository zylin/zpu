----  $Id: PCK_FIO_1993.vhd,v 1.7 2001/10/04 16:48:12 jand Exp $
----
----  PCK_FIO: a VHDL package for C-style formatted file output
----  Copyright (C) 1995, 2001 Easics NV 
----
----  This library is free software; you can redistribute it and/or
----  modify it under the terms of the GNU Lesser General Public
----  License as published by the Free Software Foundation; either
----  version 2.1 of the License, or (at your option) any later version.
----
----  This library is distributed in the hope that it will be useful,
----  but WITHOUT ANY WARRANTY; without even the implied warranty of
----  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
----  Lesser General Public License for more details.
----
----  You should have received a copy of the GNU Lesser General Public
----  License along with this library; if not, write to the Free Software
----  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
---- 
----  For suggestions, bug reports, enhancement requests, and info about  
----  our design services, you can contact us at the following address: 
----     http://www.easics.com
----     Easics NV, Interleuvenlaan 86, B-3001 Leuven, Belgium
----     tel.: +32 16 395 600   fax : +32 16 395 619 
----     e-mail: jand@easics.be (Jan Decaluwe)
----


use STD.TEXTIO.all;

library IEEE;
use IEEE.std_logic_1164.all;
-- signed/unsigned definition: use either std_logic_arith or numeric_std
-- use IEEE.std_logic_arith.all; -- the Synopsys one
use IEEE.numeric_std.all;

package fio_pkg is

   
  -- prefix string for hex output
  -- VHDL style:    "X"""
  -- Verilog style: "h'"
  -- C style:       "0x"
  constant FIO_h_PRE:  string := "0x";

  -- postfix string for hex output
  -- VHDL style:    """"
  constant FIO_h_POST: string := "";

  -- prefix string for bit vector output
  -- VHDL style:    "B"""
  -- Verilog style: "b'"
  constant FIO_bv_PRE:  string := "";

  -- postfix string for bit vector output
  -- VHDL style:    """"
  constant FIO_bv_POST: string := "";

  -- prefix string for bit output
  -- VHDL style:    "'"
  -- Verilog style: "b'"
  constant FIO_b_PRE:  string := "";

  -- postfix string for bit output
  -- VHDL style:    "'"
  constant FIO_b_POST: string := "";

  -- digit width for the string representation of integers
  constant FIO_d_WIDTH: integer := 10; 

  -- bit width for the string representation of integers
  constant FIO_b_WIDTH: integer := 32;

  -- definition of the NIL string (default value for fprint arguments)
  -- fprint stops consuming arguments at the first NIL argument 
  constant FIO_NIL: string := "\";
  
  procedure fprint
  	     (file F:  text;
	      L:       inout line; 
	      Format:  in    string;  
	      A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
	      A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
	      A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
	      A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL
	     );

  function fo (Arg: unsigned)          return string;
  function fo (Arg: signed)            return string;
  function fo (Arg: std_logic_vector)  return string;
  function fo (Arg: std_ulogic_vector) return string;
  function fo (Arg: bit_vector)        return string;
  function fo (Arg: integer)           return string;
  function fo (Arg: std_ulogic)        return string;
  function fo (Arg: bit)               return string;
  function fo (Arg: boolean)           return string; 
  function fo (Arg: character)         return string;
  function fo (Arg: string)            return string;
  function fo (Arg: time)              return string;

  procedure FIO_FormatExpand (FMT:          inout line; 
			      Format:       in    string; 
			      StartPointer: in    positive);

end fio_pkg;



