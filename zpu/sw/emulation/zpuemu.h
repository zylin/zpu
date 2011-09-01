/* ZPU emulation library header
 *
 * (c) 2011, Martin Strubel <hackfin@section5.ch>
 *
 *
 */


#include <stdint.h>

#include "zpu-tap.h"
#include "tap.h"

#define REGISTER     uint32_t
#define ADDR         uint32_t

// #define LDST_32 4
// #define LDST_16 2
// #define LDST_8  1

#define REG_PC 0
#define REG_SP 1

struct _cpu;

typedef struct _cpu_context {
	struct _cpu *cpu;
	JTAG_CTRL    jtag;           // Pointer to used JTAG controller
	short        id;             // identification tag
	short        flags;          // Interrupt flag - did we Ctrl-C ?
	short        prev_state;     // CPU's previous' state (for change detect)
	// Dual core stuff
} CpuContext;

int zpu_emuinit(CpuContext *c, JTAG_CTRL jtag);
int zpu_getid(CpuContext *c, uint32_t *code);
int zpu_emulation(CpuContext *c, int which);
int zpu_resume(CpuContext *c, int step);
int zpu_setreg(CpuContext *c, int regno, REGISTER val);
int zpu_getreg(CpuContext *c, int regno, REGISTER *val);
int zpu_state(CpuContext *c, uint16_t *state);
int zpu_reset(CpuContext *c, int mode);
int zpu_getpc(CpuContext *c, REGISTER *pc);
void zpu_dumpstat(CpuContext *c);

int zpu_mem_read(CpuContext *c, ADDR addr, unsigned int count,
	unsigned char *b);
int zpu_mem_write(CpuContext *c, ADDR addr, unsigned int count,
	const unsigned char *b);

enum {
	LDST_32,
	LDST_16,
	LDST_8,
};
