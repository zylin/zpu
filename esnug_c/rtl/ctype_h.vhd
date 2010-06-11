-- File: ctype_h.vhd
-- Version: 3.0  (June 6, 2004)
-- Source: http://bear.ces.cwru.edu/vhdl
-- Date: June 6, 2004 (Copyright)
-- Author: Francis G. Wolff   Email: fxw12@po.cwru.edu
-- Author: Michael J. Knieser Email: mjknieser@knieser.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 1, or (at your option)
-- any later version: http://www.gnu.org/licenses/gpl.html
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
-- 

library STD;
use     STD.textio.all;
library IEEE;
use     IEEE.std_logic_1164.all;

package ctype_h is
  function  isalpha(c: character)  return boolean;
  function  isupper(c: character)  return boolean;
  function  islower(c: character)  return boolean;
  function  isdigit(c: character)  return boolean;
  function  isxdigit(c: character) return boolean;
  function  isalnum(c: character)  return boolean;
  function  isspace(c: character)  return boolean;
  function  ispunct(c: character)  return boolean;
  function  isprint(c: character)  return boolean;
  function  isgraph(c: character)  return boolean;
  function  iscntrl(c: character)  return boolean;
  function  isascii(c: character)  return boolean;
  function  tolower(c: character)  return character;
  function  toupper(c: character)  return character;


  --This implementation was done to use the VHDL simulator efficiently
  --and minimize number of boolean type arrays

  type        tarray is array(0 to 255) of integer;
  constant t: tarray:=( 
     2,   2,   2,   2,   2,   2,   2,   2,   2,11*2,11*2,11*2,11*2,11*2,   2,   2, --0x00
     2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2, --0x10
    11,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17, --0x20
  13*3,13*3,13*3,13*3,13*3,13*3,13*3,13*3,13*3,13*3,  17,  17,  17,  17,  17,  17, --0x30
    17, 5*3, 5*3, 5*3, 5*3, 5*3, 5*3, 5*3, 5*3, 5*3, 5*3,   5,   5,   5,   5,   5, --0x40
     5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,  17,  17,  17,  17,  17, --0x50
    17, 7*3, 7*3, 7*3, 7*3, 7*3, 7*3, 7*3, 7*3, 7*3, 7*3,   7,   7,   7,   7,   7, --0x60
     7,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,  17,  17,  17,  17,   2, --0x70
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0x80
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0x90
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0xa0
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0xb0
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0xc0
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0xd0
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, --0xe0
     1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1);--0xf0
   
end ctype_h;

package body ctype_h is

  function  isalpha(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 5 = 0 OR t(character'pos(c)) mod 7 = 0;
  end isalpha;

  function  isupper(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 5 = 0;
  end isupper;

  function  islower(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 7 = 0;
  end islower;

  function  isdigit(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 13 = 0;
  end isdigit;

  function  isxdigit(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 3 = 0;
  end isxdigit;

  function  isalnum(c: character) return boolean is
  begin
    return t(character'pos(c)) mod  3 = 0
        OR t(character'pos(c)) mod  5 = 0
        OR t(character'pos(c)) mod  7 = 0;
  end isalnum;

  function  isspace(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 11 = 0;
  end isspace;

  function  ispunct(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 17 = 0;
  end ispunct;

  function  isprint(c: character) return boolean is
  begin
    return t(character'pos(c)) mod  3 = 0
        OR t(character'pos(c)) mod  5 = 0
        OR t(character'pos(c)) mod  7 = 0
        OR t(character'pos(c)) mod 17 = 0
        OR c=' ';
  end isprint;

  function  isgraph(c: character) return boolean is
  begin
    return t(character'pos(c)) mod  3 = 0
        OR t(character'pos(c)) mod  5 = 0
        OR t(character'pos(c)) mod  7 = 0
        OR t(character'pos(c)) mod 17 = 0;
  end isgraph;

  function  iscntrl(c: character) return boolean is
  begin
    return t(character'pos(c)) mod 2 = 0;
  end iscntrl;

  function  isascii(c: character) return boolean is
  begin
    return character'pos(c) >= 0 and character'pos(c)<=127;
  end isascii;

  function  tolower(c: character) return character is
  begin
    if character'pos(c)>=65 AND character'pos(c)<=90 then
      return character'val(character'pos(c)+32);
    else
      return c;
    end if;
  end tolower;

  function  toupper(c: character) return character is
  begin
    if character'pos(c)>=97 AND character'pos(c)<=122 then
      return character'val(character'pos(c)-32);
    else
      return c;
    end if;
  end toupper;

end ctype_h;
