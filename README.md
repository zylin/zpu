# zpu
The Zylin ZPU

The worlds smallest 32 bit CPU with GCC toolchain.

The ZPU is a small CPU in two ways: it takes up very little resources and the architecture itself is small. The latter can be important when learning about CPU architectures and implementing variations of the ZPU where aspects of CPU design is examined. In academia students can learn VHDL, CPU architecture in general and complete exercises in the course of a year.

The current ZPU instruction set and architecture has not changed for the last couple of years and can be considered quite stable. There is a lot of discussion about various modifications to the ZPU architecture in the zylin-zpu mailing list, but currently no actual modifications are planned as the improvements that have been identified are relatively slight(<30% performance/size improvement).

There are a handful of implementations of the ZPU. Most of these usually have some strong points and there is some movement in the direction of consolidating improvements into a few officially recommended ZPU implementations.

For those that are interested in the Zylin ZPU, I recommend joining up on the zylin-zpu mailing list and participating in the discussion there. The zylin-zpu is a friendly place where people of different skills, hardware, software, tools meet to exchange ideas about the ZPU and microprocessor architecture in general.

Sincerely,

Øyvind Harboe

Zylin AS


#Getting help - mailing list

The place to get help is the zylin-zpu mailing list: https://groups.google.com/d/forum/zylin-zpu

To join the list just send an email to zylin-zpu+subscribe@googlegroups.com

The former mailing list archive (till April 2015) is avalible here: http://zylin.com/pipermail/zylin-zpu_zylin.com/


#GCC

The repository for the GCC toolchain is only a small step away: https://github.com/zylin/zpugcc
