/** \file zpu-opcodes.h
 *
 * Basic ZPU opcode definitions
 *
 * 2011, <hackfin@section5.ch>
 *
 */

/** This is also the opcode for leaving emulation */
#define OPCODE_BREAK          0x00

/* ZPU basic opcodes that are supported by emulation */

#define OPCODE_IM             0x80
#define OPCODE_NOP            0x0b
#define OPCODE_LOAD           0x08
#define OPCODE_STORE          0x0c
#define OPCODE_LOADSP         0x60
// Dunno why, but this bit wants to be inverted in the offset field:
#	define LOADSP_INV         0x10
#define OPCODE_PUSHSP         0x02
#define OPCODE_POPSP          0x0d
#define OPCODE_POPPC          0x04

/* Special opcode: Leave emulation */
#define OPCODE_EMULEAVE       OPCODE_BREAK
