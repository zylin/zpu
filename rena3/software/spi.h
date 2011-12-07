/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
 * $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
 * $Author: lange $
 * $Revision: 659 $
 */

#ifndef SPI_H
#define SPI_H

#include <types.h>


// spi
#define SPI_CAPABILITY_REVISION             (0)
#define SPI_CAPABILITY_FIFODEPTH            (8)
#define SPI_CAPABILITY_SLAVE_SELECT_ENABLE  (16)
#define SPI_CAPABILITY_ASLEA                (17)
#define SPI_CAPABILITY_AMODE                (18)
#define SPI_CAPABILITY_TWEN                 (19)
#define SPI_CAPABILITY_MAXWLEN              (20)
#define SPI_CAPABILITY_SSSZ                 (24)

#define SPI_MODE_AMEN                       (31)
#define SPI_MODE_LOOP                       (30)
#define SPI_MODE_CPOL                       (29)
#define SPI_MODE_CPHA                       (28)
#define SPI_MODE_DIV16                      (27)
#define SPI_MODE_REV                        (26)
#define SPI_MODE_MS                         (25)
#define SPI_MODE_EN                         (24)
#define SPI_MODE_LEN                        (20)
#define SPI_MODE_PM                         (16)
#define SPI_MODE_TW                         (15)
#define SPI_MODE_ASEL                       (14)
#define SPI_MODE_FACT                       (13)
#define SPI_MODE_OD                         (12)
#define SPI_MODE_CG                         (7)
#define SPI_MODE_ASELDEL                    (5)
#define SPI_MODE_TAC                        (4)

#define SPI_EVENT_TIP                       (1<<31)
#define SPI_EVENT_LT                        (1<<14)
#define SPI_EVENT_OV                        (1<<12)
#define SPI_EVENT_UN                        (1<<11)
#define SPI_EVENT_MME                       (1<<10)
#define SPI_EVENT_NE                        (1<<9)
#define SPI_EVENT_NF                        (1<<8)
typedef struct {
    volatile uint32_t capability;              // 0x00
    volatile uint32_t reserved_0;              // 0x04
    volatile uint32_t reserved_1;              // 0x08
    volatile uint32_t reserved_2;              // 0x0C
    volatile uint32_t reserved_3;              // 0x10
    volatile uint32_t reserved_4;              // 0x14
    volatile uint32_t reserved_5;              // 0x18
    volatile uint32_t reserved_6;              // 0x1C
    volatile uint32_t mode;                    // 0x20
    volatile uint32_t event;                   // 0x24
    volatile uint32_t mask;                    // 0x28
    volatile uint32_t command;                 // 0x2C
    volatile uint32_t transmit;                // 0x30
    volatile uint32_t receive;                 // 0x34
    volatile uint32_t slave_select;            // 0x38
    volatile uint32_t automatic_slave_select;  // 0x3C
    volatile uint32_t am_configuration;        // 0x40
    volatile uint32_t am_period;               // 0x44
} spi_t;
    
/*    
    DIV16 = 0:
    sck_frequency = bus_frequency / (4 -( 2 * FACT)) * (PM +1)



    FACT = 0, DIV16 = 0
    sck_frequency = bus_frequency / (4 * (PM + 1))

    FACT = 0, DIV16 = 1
    sck_frequency = bus_frequency / ( 16 * 4 * (PM + 1))

    FACT = 1, DIV16 = 0
    sck_frequency = bus_frequency / (2 * (PM + 1))

    FACT = 1, DIV16 = 1
    sck_frequency = bus_frequency / ( 16 * 2 * (PM + 1))
*/

#define SPI_FACT      (0)
#define SPI_DIV16     (0)
#define SPI_PRESCALER (2)

#define SPI_WORDLEN   (8-1)

void     spi_init( void);
void     spi_send( uint8_t value);
void     spi_send_raw( uint32_t value);
uint32_t spi_receive( void);
void     spi_info( void);

extern spi_t         *spi0;

#endif // SPI_H
