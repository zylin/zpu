#ifndef PERIPHERIE_H
#define PERIPHERIE_H


// common types

typedef signed char         int8_t;
typedef unsigned char       uint8_t;
                            
typedef short               int16_t;
typedef unsigned short      uint16_t;
                            
typedef long                int32_t;
typedef unsigned long       uint32_t;

typedef long long           int64_t;
typedef unsigned long long  uint64_t;


// hardware types

typedef struct {
    volatile uint32_t in;       // 000
    volatile uint32_t out;      // 001
    volatile uint32_t dir;      // 010
    volatile uint32_t imask;    // 011
    volatile uint32_t level;    // 100
    volatile uint32_t edge;     // 101
    volatile uint32_t bypass;   // 110
} grgpio_t;


typedef struct {
    volatile uint32_t data;     // 000000
    volatile uint32_t status;   // 000001 rxfifo, txfifo, rxfull, txfull, rxhalffull, txhalffull, frame, parerr, ovf, break, thempty, tsempty, dready
    volatile uint32_t ctrl;     // 000010 
    volatile uint32_t scaler;   // 000011
//  volatile uint32_t txfifo;   // 000100
} apbuart_t;


typedef struct {
    volatile uint32_t val;
    volatile uint32_t rld;
    volatile uint32_t ctrl;
    volatile uint32_t unused;
} gptimer_element_t;

typedef struct {
    volatile uint32_t scaler;          // 00000
    volatile uint32_t scaler_reload;   // 00001
    volatile uint32_t config;          // 00010 ntimers, pirq
    volatile uint32_t unused;          // 00011
    struct gptimer_element_t e[8];
} gptimer_t;


// hardware units

apbuart_t *apbuart0 = (apbuart_t *) 0x80000100;
gptimer_t *gptimer0 = (gptimer_t *) 0x80000200;
gpio_t    *gpio0    = (gpio_t *)    0x80000800;

#endif PERIPHERIE_H
