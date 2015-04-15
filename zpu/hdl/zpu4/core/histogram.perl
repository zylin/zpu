#!/usr/bin/perl
##############################################################################
#
# Copyright (c) 2008 Salvador E. Tropea <salvador en inti gov ar>
# Copyright (c) 2008 Instituto Nacional de Tecnología Industrial
#
##############################################################################
#
# Target:           Any
# Language:         Perl
# Interpreter used: v5.6.1/v5.8.4
# Text editor:      SETEdit 0.5.5
#
##############################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA
#
##############################################################################
#
# Description: Takes a ZPU trace and does some raw stats about opcodes
# frequency and speed.
#
##############################################################################
#
# TODO
#
# A lot ...
#


# 0x40-0x460
# div y mod son especiales
@used=();
@clks=();

$line=1;
$startLine=1;
#$endLine=10000;
$endLine=-1;
$lastClk=0;
$lastOpcode=-1;
while (<>)
  {
   if ($_=~/^(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+)/)
     {
      $clk=hex($7);
      #print "$line\n";
      if ($line>=$startLine)
        {
         #print $_;
         $addr=hex($1);
         $opcode=hex($2);
         $sp=hex($3);
         $a=hex($4);
         $b=hex($5);
         if ($addr>=0x40 and $addr<0x460)
           {
            @used[$opcode+0x100]++;
            @clks[$lastOpcodeEmu]+=$clk-$lastClkEmu unless lastOpcodeEmu==-1;
            $lastOpcodeEmu=$opcode+0x100;
            $lastClkEmu=$clk;
           }
         else
           {
            @used[$opcode]++;
            @clks[$lastOpcode]+=$clk-$lastClk unless $lastOpcode==-1;
            #printf "%d+=%d\n",$lastOpcode,$clk-$lastClk;
            $lastOpcode=$opcode;
            $lastClk=$clk;
            $lastOpcodeEmu=-1;
            $lastClkEmu=$clk;
           }
        }
      else
        {
         $lastClk=$clk;
        }
      last if $line==$endLine;
      $line++;
     }
  }
@used[$lastOpcode]--;

$id=0;
# Cluster them
AddSimple('breakpoint',0);
# 1=shiftleft, invalid
AddSimple('pushsp',2);
# 3=pushint, invalid
AddSimple('poppc',4);
AddSimple('add',5);
AddSimple('and',6);
AddSimple('or',7);
AddSimple('load',8);
AddSimple('not',9);
AddSimple('flip',10);
AddSimple('nop',11);
AddSimple('store',12);
AddSimple('popsp',13);
# 14=compare, invalid
# 15=popint, invalid
AddSimpleRange('addsp',16,31);
# 32-63 emulate
AddSimpleRange('storesp',64,95);
AddSimpleRange('loadsp',96,127);
AddSimpleRange('im',128,255);

# 32 is the reset entry point
# 33 is the interrupt entry point
AddEmulate('loadh',34);
AddEmulate('storeh',35);
AddEmulate('lessthan',36);
AddEmulate('lessthanorequal',37);
AddEmulate('ulessthan',38);
AddEmulate('ulessthanorequal',39);
AddEmulate('swap',40); # unimplemented
AddEmulate('mult',41);
AddEmulate('lshiftright',42);
AddEmulate('ashiftleft',43);
AddEmulate('ashiftright',44);
AddEmulate('call',45);
AddEmulate('eq',46);
AddEmulate('neq',47);
AddEmulate('neg',48);
AddEmulate('sub',49);
AddEmulate('xor',50);
AddEmulate('loadb',51);
AddEmulate('storeb',52);
AddEmulate('div',53);
AddEmulate('mod',54);
AddEmulate('eqbranch',55);
AddEmulate('neqbranch',56);
AddEmulate('poppcrel',57);
AddEmulate('config',58);
AddEmulate('pushpc',59);
AddEmulate('syscall_emulate',60); # unimplemented
AddEmulate('pushspadd',61);
AddEmulate('halfmult',62); # unimplemented
AddEmulate('callpcrel',63);

$maxID=$id;
print "Total clocks: $lastClk\n";
print "Unsorted:\n\n";
for ($i=0; $i<$maxID; $i++)
   {
    $used=@used_noemu[$i];
    $clkm=0;
    $clkm=@clks_noemu[$i]/$used if $used;
    printf "%-20s %8d %6.2f\n",$names[$i],$used,$clkm;
    $by_times{$i}=$used;
    $by_clks{$i}=@clks_noemu[$i];
   }
print "Sorted by consumed clocks:\n\n";
foreach $key (sort { $by_clks{$b} <=> $by_clks{$a} } keys %by_clks)
   {
    printf "%5.2f %-20s %8d\n",$by_clks{$key}/$lastClk*100,$names[$key],$by_clks{$key};
   }


sub AddSimple
{
 my ($name, $opcode)=@_;

 $names[$id]=$name;
 @used_noemu[$id]=@used[$opcode];
 @used_emu[$id]=@used[$opcode+0x100];
 @used_both[$id]=@used[$opcode]+@used[$opcode+0x100];
 @clks_noemu[$id]=@clks[$opcode];
 @clks_emu[$id]=@clks[$opcode+0x100];
 @clks_both[$id]=@clks[$opcode]+@clks[$opcode+0x100];
 $id++;
}

sub AddEmulate
{
 my ($name, $opcode)=@_;

 $names[$id]=$name;
 @used_noemu[$id]=@used[$opcode];
 @used_emu[$id]=@used[$opcode+0x100];
 @used_both[$id]=@used[$opcode];
 @clks_noemu[$id]=@clks[$opcode];
 @clks_emu[$id]=@clks[$opcode+0x100];
 @clks_both[$id]=@clks[$opcode];
 $id++;
}

sub AddSimpleRange
{
 my ($name, $opStart, $opLast)=@_;
 my $i;

 $names[$id]=$name;
 for ($i=$opStart; $i<=$opLast; $i++)
    {
     @used_noemu[$id]+=@used[$i];
     @used_emu[$id]+=@used[$i+0x100];
     @used_both[$id]+=@used[$i]+@used[$i+0x100];
     @clks_noemu[$id]+=@clks[$i];
     @clks_emu[$id]+=@clks[$i+0x100];
     @clks_both[$id]+=@clks[$i]+@clks[$i+0x100];
    }
 $id++;
}


