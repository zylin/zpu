/* ZPU emulation library
 *
 * (c) 2011, Martin Strubel <hackfin@section5.ch>
 *
 * Limited functionality: Only one core in chain supported.
 *
 */

// These headers must be implemented by the JTAG interface to your
// HW debug adapter
#include "jtag.h"
#include "jtag_intern.h"

#include "zpuemu.h"

#include "zpu-opcodes.h"
#include <stdio.h>


#define IRSIZE 4

static unsigned char
s_reg8[2];

static JtagRegister
ir_r = {
	.data = &s_reg8[1],
	.nbits = IRSIZE,
	.flags = JTAGREG_LSB
};

static JtagRegister
opcode_r = {
	.data = &s_reg8[0],
	.nbits = 8,
	.flags = JTAGREG_MSB
};

static unsigned char
s_reg16[2];

static JtagRegister
ctrl_r = {
	.data = &s_reg16[0],
	.nbits = 16,
	.flags = JTAGREG_MSB
};

static unsigned char
s_reg32[4];

static JtagRegister
data_r = {
	.data = &s_reg32[0],
	.nbits = 32,
	.flags = JTAGREG_MSB
};

void select_dr(CpuContext *c, uint8_t dr)
{
	jtag_goto_state(c->jtag, s_jtag_shift_ir);
	reg_set(&ir_r, 0, IRSIZE, dr);
	shift_generic(c->jtag, &ir_r, NULL, ir_r.nbits, UPDATE);
}

void shiftout32(CpuContext *c, REGISTER *r, int mode)
{
	jtag_flush(c->jtag);
	jtag_goto_state(c->jtag, s_jtag_shift_dr);
	shift_generic(c->jtag, &data_r, &data_r, data_r.nbits, mode);
	*r = reg_get(&data_r, 0, 32);
}

void shiftin16(CpuContext *c, REGISTER r, int mode)
{
	jtag_goto_state(c->jtag, s_jtag_shift_dr);
	reg_set(&ctrl_r, 0, 16, r);
	shift_generic(c->jtag, &ctrl_r, NULL, ctrl_r.nbits, mode);
}

void shiftout16(CpuContext *c, REGISTER *r, int mode)
{
	jtag_goto_state(c->jtag, s_jtag_shift_dr);
	shift_generic(c->jtag, &ctrl_r, &ctrl_r, ctrl_r.nbits, mode);
	*r = reg_get(&ctrl_r, 0, 16);
}

// Auxiliaries

static
void push_opcode(CpuContext *c, uint8_t opcode, int mode)
{
	opcode_r.data[0] = opcode;
	jtag_goto_state(c->jtag, s_jtag_shift_dr);
	shift_generic(c->jtag, &opcode_r, NULL, opcode_r.nbits, mode);
}

#if 0
static
void push_val16(CpuContext *c, uint16_t val)
{
	int i = 14;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC);
	push_opcode(c, OPCODE_NOP, EXEC);
}
#endif

static
void push_val32(CpuContext *c, uint32_t val)
{
	int i = 28;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC); i -= 7;
	push_opcode(c, OPCODE_IM | ((val >> i) & 0x7f), EXEC);
	push_opcode(c, OPCODE_NOP, EXEC);
}

static
uint32_t mem_read32(CpuContext *c, uint32_t addr)
{
	REGISTER r;
	int q = jtag_queue(c->jtag, 1);
	select_dr(c, TAP_EMUIR);
		push_opcode(c, OPCODE_PUSHSP, EXEC);
		push_val32(c, addr);
		push_opcode(c, OPCODE_LOAD, EXEC);
		push_opcode(c, OPCODE_NOP, EXEC);
	select_dr(c, TAP_EMUDATA);
		shiftout32(c, &r, UPDATE); // Execute Stack fixup
	select_dr(c, TAP_EMUIR);
		push_opcode(c, OPCODE_LOADSP | (LOADSP_INV ^ 0x01), EXEC);
		push_opcode(c, OPCODE_POPSP, EXEC);
		push_opcode(c, OPCODE_NOP, EXEC);
	jtag_queue(c->jtag, q);
	return r;
}

// Little read cache:
struct cache {
	ADDR addr;
	uint32_t val;
} g_cache = { 0xffffffff, 0 };

static
uint32_t mem_read32_cached(CpuContext *c, ADDR a)
{
	if (a != g_cache.addr) {
		g_cache.val = mem_read32(c, a);
		g_cache.addr = a;
		// printf("Read %08x\n", g_cache.val);
	}
	return g_cache.val;
}

uint8_t mem_read8(CpuContext *c, ADDR a)
{
	uint32_t v;
	int shift = (3 - (a & 0x3)) << 3;
	a &= ~0x3;
	// printf("shift: %d\n", shift);
	v = mem_read32_cached(c, a) >> shift;
	return v;
}

uint16_t mem_read16(CpuContext *c, ADDR a)
{
	uint32_t v;
	int shift = (2 - (a & 0x2)) << 3;
	a &= ~0x3;
	// printf("shift: %d\n", shift);
	v = mem_read32_cached(c, a) >> shift;
	return v;
}

void mem_write32(CpuContext*c, uint32_t addr, uint32_t val)
{
	// Invalidate cache, when we're writing to the same addr:
	if (g_cache.addr == (addr)) {
		g_cache.addr = 0xffffffff;
	}
	select_dr(c, TAP_EMUIR);
		push_opcode(c, OPCODE_PUSHSP, EXEC);
		push_val32(c, val);
		push_val32(c, addr); // Address
		push_opcode(c, OPCODE_STORE, EXEC);
		push_opcode(c, OPCODE_LOADSP | (LOADSP_INV ^ 0x00), EXEC);
		push_opcode(c, OPCODE_POPSP, EXEC);
		push_opcode(c, OPCODE_NOP, UPDATE);
}


void mem_write16(CpuContext*c, uint32_t addr, uint16_t val)
{
	int shift = (2 - (addr & 0x2)) << 3;
	uint32_t v;

	addr &= ~0x3;
	v = mem_read32_cached(c, addr);

	v = (v & ~(0xffff << shift)) | (val << shift);
	mem_write32(c, addr, v);
}

void mem_write8(CpuContext *c, uint32_t addr, uint8_t val)
{
	int shift = (3 - (addr & 0x3)) << 3;
	uint32_t v;

	addr &= ~0x3;
	v = mem_read32_cached(c, addr);

	v = (v & ~(0xff << shift)) | (val << shift);
	mem_write32(c, addr, v);
}

int enter_emulation(CpuContext *c)
{
	REGISTER r;

	g_cache.addr = 0xffffffff; // Invalidate cache

	// puts(">>> Enter emulation");
	select_dr(c, TAP_EMUCTRL);
	r = EMUREQ;
	shiftin16(c, r, UPDATE);

	return 0;
}

int leave_emulation(CpuContext *c)
{
	int error = 0;

	// Turn off emulation bit
	select_dr(c, TAP_EMUCTRL);
	shiftin16(c, 0, UPDATE);

	// Run some emulated opcodes:
	// Return from emulation:
	select_dr(c, TAP_EMUIR);
	push_opcode(c, OPCODE_EMULEAVE, EXEC);
	return error;
}

////////////////////////////////////////////////////////////////////////////
// API calls

int zpu_emuinit(CpuContext *c, CONTROLLER jtag)
{
	c->jtag = jtag;
	return 0;
}

int zpu_getid(CpuContext *c, uint32_t *code)
{
	select_dr(c, TAP_IDCODE);
	shiftout32(c, code, UPDATE);
	return 0;
}

int zpu_resume(CpuContext *c, int step)
{
	jtag_flush(c->jtag);
	if (step) {
		select_dr(c, TAP_EMUCTRL);
		shiftin16(c, EMUREQ, UPDATE);
		select_dr(c, TAP_EMUIR);
		push_opcode(c, OPCODE_EMULEAVE, EXEC);
	} else {
		leave_emulation(c);
	}
	return 0;
}

int zpu_emulation(CpuContext *c, int which)
{
	// FIXME: for multicore, this needs to change.
	jtag_flush(c->jtag);
	if (which) {
		enter_emulation(c);
	} else {
		leave_emulation(c);
	}
	return 0;
}

int zpu_state(CpuContext *c, uint16_t *state)
{
	REGISTER r;
	int error = 0;

	select_dr(c, TAP_EMUSTAT);
	shiftout16(c, &r, UPDATE);
	*state = r;
	return error;
}

int zpu_reset(CpuContext *c, int mode)
{
	// TODO: Implement system control register on zealot
	return 0;
}

int zpu_setreg(CpuContext *c, int regno, REGISTER val)
{
	switch (regno) {
		case REG_PC:
			select_dr(c, TAP_EMUIR);
				push_val32(c, val);
				push_opcode(c, OPCODE_POPPC, EXEC);
			break;
		case REG_SP:
			select_dr(c, TAP_EMUIR);
				push_val32(c, val);
				push_opcode(c, OPCODE_POPSP, EXEC);
			break;
		default: return -1;
	}
	return 0;
}

int zpu_getreg(CpuContext *c, int regno, REGISTER *val)
{
	REGISTER r;
	int q = jtag_queue(c->jtag, 1);
	switch (regno) {
		case REG_PC:
			// XXX needed to update dbg_o.<signal>:
			select_dr(c, TAP_EMUIR); // XXX
				push_opcode(c, OPCODE_NOP, EXEC); // XXX
			select_dr(c, TAP_DBGPC);
			shiftout32(c, &r, UPDATE);
			break;
		case REG_SP:
			select_dr(c, TAP_EMUIR);
				push_opcode(c, OPCODE_PUSHSP, EXEC);
				// XXX needed to update dbg_o.<signal>:
				push_opcode(c, OPCODE_NOP, EXEC); // XXX
				push_opcode(c, OPCODE_POPSP, UPDATE); // queue, exec later
			select_dr(c, TAP_EMUDATA);
			shiftout32(c, &r, EXEC); // (here)
			break;
		default: return -1;
	}
	*val = r;
	jtag_queue(c->jtag, q);
	return 0;
}

void zpu_dumpstat(CpuContext *c)
{
	REGISTER r;

	select_dr(c, TAP_EMUSTAT);
	shiftout16(c, &r, UPDATE);
	printf("EMUSTAT: %04x -", r & 0xffff);
	if (r) {
		if (r & ZPU_IDIM)    printf(" [IDIM]");
		if (r & ZPU_INRESET) printf(" [RESET]");
		if (r & ZPU_BREAK)   printf(" [BREAK]");
		if (r & EMUACK)      printf(" [EMUACK]");
		if (r & EMURDY)      printf(" [EMURDY]");
		if (r & ZPU_MEMBUSY) printf(" [MEM_BUSY]");
	}
	printf("\n");
	select_dr(c, TAP_COUNT1);
	shiftout32(c, &r, UPDATE);
	printf("COUNT1: %012d\n", r);
	select_dr(c, TAP_COUNT2);
	shiftout16(c, &r, UPDATE);
	printf("COUNT2: %08d\n", r);
}

int guess_access(ADDR addr, unsigned int *count)
{
	int sizecode;
	// I/O space wants to be addressed long word wise:
	if (addr >= 0x80080000 && *count == 4) {
		*count = 1;
		return LDST_32;
	}
	// if we have even addresses and even count, we can 
	// use word size transfers instead of byte wise.
	switch (addr % 4) {
	case 0:
		switch (*count % 4) {
			case 0:
				sizecode = LDST_32;
				*count /= 4;
				break;
			case 2:
				sizecode = LDST_16;
				*count /= 2;
				break;
			default:
				sizecode = LDST_8;
				break;
		}
		break;
	case 2:
		if (*count % 2 == 0) {
				sizecode = LDST_16;
				*count /= 2;
		} else {
				sizecode = LDST_8;
		}
		break;
	default:
		sizecode = LDST_8;
	}
	return sizecode;
}


int zpu_mem_read(CpuContext *c, ADDR addr, unsigned int count,
	unsigned char *buf)
{
	int sz;
	uint32_t v;
	int q = jtag_queue(c->jtag, 1);

	sz = guess_access(addr, &count);

	switch (sz) {
		case LDST_8:
			while (count--) {
				*buf++ = mem_read8(c, addr++);
			}
			break;
		case LDST_16:
			while (count--) {
				v = mem_read16(c, addr); addr += 2;
				buf[1] = v; v >>= 8;
				buf[0] = v;
				buf += 2;
			}
			break;
		case LDST_32:
			while (count--) {
				v = mem_read32(c, addr); addr += 4;
				buf[3] = v; v >>= 8;
				buf[2] = v; v >>= 8;
				buf[1] = v; v >>= 8;
				buf[0] = v;
				buf += 4;
			}
			break;
	}
	jtag_flush(c->jtag);
	jtag_queue(c->jtag, q);
	return 0;
}

int zpu_mem_write(CpuContext *c, ADDR addr, unsigned int count,
	const unsigned char *buf)
{
	int sz;
	uint32_t v;
	int q = jtag_queue(c->jtag, 1);

	sz = guess_access(addr, &count);

	switch (sz) {
		case LDST_8:
			// XXX: Could be optimized further
			while (count--) {
				v = *buf++;
				mem_write8(c, addr, v); addr++;
			}
			break;
		case LDST_16:
			while (count--) {
				v = (buf[0] << 8) | buf[1];
				mem_write16(c, addr, v);
				addr += 2; buf += 2;
			}
			break;
		case LDST_32:
			while (count--) {
				v = (buf[0] << 24) | (buf[1] << 16) | (buf[2] << 8) | buf[3];
				mem_write32(c, addr, v);
				addr += 4; buf += 4;
			}
			break;
	}
	jtag_flush(c->jtag);
	jtag_queue(c->jtag, q);
	return 0;
}
