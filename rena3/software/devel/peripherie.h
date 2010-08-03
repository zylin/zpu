#ifndef PERIPHERIE_H
#define PERIPHERIE_H

////////////////////
// common types

typedef signed char         int8_t;
typedef unsigned char       uint8_t;
                            
typedef short               int16_t;
typedef unsigned short      uint16_t;
                            
typedef long                int32_t;
typedef unsigned long       uint32_t;

typedef long long           int64_t;
typedef unsigned long long  uint64_t;


////////////////////
// hardware types

// gpio
typedef struct {
    volatile uint32_t in;       // 000
    volatile uint32_t out;      // 001
    volatile uint32_t dir;      // 010, for bidir port bits
    volatile uint32_t imask;    // 011
    volatile uint32_t level;    // 100
    volatile uint32_t edge;     // 101
    volatile uint32_t bypass;   // 110
} grgpio_t;


// uart
typedef struct {
    volatile uint32_t data;     // 000000
    volatile uint32_t status;   // 000001 rxfifo, txfifo, rxfull, txfull, rxhalffull, txhalffull, frame, parerr, ovf, break, thempty, tsempty, dready
    volatile uint32_t ctrl;     // 000010 
    volatile uint32_t scaler;   // 000011
//  volatile uint32_t txfifo;   // 000100
} apbuart_t;


// timer (grip.pdf p. 279)

#define TIMER_ENABLE                (1<<0)
#define TIMER_RESTART               (1<<1)
#define TIMER_LOAD                  (1<<2)
#define TIMER_INT_ENABLE            (1<<3)
#define TIMER_INT_PENDING           (1<<4)
#define TIMER_CHAIN                 (1<<5)
#define TIMER_DEBUG_HALT            (1<<6)
typedef struct {
    volatile uint32_t value;
    volatile uint32_t reload;
    volatile uint32_t ctrl;
    volatile uint32_t unused;
} gptimer_element_t;

#define TIMER_CONFIG_DISABLE_FREEZE (1<<8)
typedef struct {
    volatile uint32_t scaler;          // 00000
    volatile uint32_t scaler_reload;   // 00001
    volatile uint32_t config;          // 00010 ntimers, pirq
    volatile uint32_t unused;          // 00011
    gptimer_element_t e[8];
} gptimer_t;

void msleep(uint32_t msec);
void nsleep(uint32_t nsec);
void init_timer_prescaler();


////////////////////
// hardware units

#define F_CPU (50000000)
// set min prescaler to ntimers+1
#define TIMER_PRESCALER (8)

apbuart_t *uart0  = (apbuart_t *) 0x80000100;
gptimer_t *timer0 = (gptimer_t *) 0x80000200;
grgpio_t  *gpio0  = (grgpio_t *)  0x80000800;

#endif // PERIPHERIE_H
