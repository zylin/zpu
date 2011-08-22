/*
 * USI control 0		USICTL0
 * USI control 1		USICTL1
 * USI clock control	USICKCTL
 * USI bit counter		USICNT
 * USI shift register	USISR

                      +--------+ 
DVCC                  |1     14| DVSS
P1.0/TA0CLK/ACLK      |2     13| XIN/P2.6/TA0.1
P1.1/TA0.0            |3     12| XOUT/P2.7
P1.2/TA0.1            |4     11| TEST/SBWTCK
P1.3                  |5     10| #RST/NMI/SBWTDIO
P1.4/SMCLK/TCK        |6      9| P1.7/SDI/SDA/TDO/TDI
P1.5/TA0.0/SCLK/TMS   |7      8| P1.6/TA0.1/SDO/SCL/TDI/TCLK
                      +--------+


    Portbelegung
    P1.0
    P1.1
    P1.2
    P1.3
    P1.4  CS 
    P1.5  SCLK (UCLK1)
    P1.6  SDO  (SIMO1)
    P1.7  SDI  (SOMI1)
    P2.6
    P2.7
*/

#include <msp430g2231.h>

typedef unsigned char  u8;
typedef unsigned int  u16;

#define 	_BV(bit)   (1 << (bit))

#define  set_bit(a, bitv)                    ((a) |=   (bitv))
#define  clear_bit(a, bitv)                  ((a) &= ~ (bitv))
#define  bit_is_set(sfr, bitv)               (  (sfr) & (bitv))
#define  bit_is_clear(sfr, bitv)             (!((sfr) & (bitv)))
#define  loop_until_bit_is_set(sfr, bitv)    do { } while (bit_is_clear(sfr, bitv))
#define  loop_until_bit_is_clear(sfr, bitv)  do { } while (  bit_is_set(sfr, bitv))


// SPI port definitions              // Adjust the values for the chosen
#define SPI_PxSEL         P1SEL      // interfaces, according to the pin
#define SPI_PxDIR         P1DIR      // assignments indicated in the
#define SPI_PxIN          P1IN       // chosen MSP430 device datasheet.
#define SPI_PxOUT         P1OUT
#define SPI_SIMO          _BV(6)
#define SPI_SOMI          _BV(7)
#define SPI_UCLK          _BV(5)

#define SPI_CS            _BV(4)


void clk_init (void);
void wdt_init( void);
void spi_init (void);
u8 spi_xfer_byte( const u8 data);



void clk_init (void)
{
	// MCLK and SMCLK are sourced from DCOCLK.
	
#define CALDCO_16MHZ_         0x10F8    /* DCOCTL  Calibration Data for 16MHz */
#define CALBC1_16MHZ_         0x10F9    /* BCSCTL1 Calibration Data for 16MHz */
#define CALDCO_12MHZ_         0x10FA    /* DCOCTL  Calibration Data for 12MHz */
#define CALBC1_12MHZ_         0x10FB    /* BCSCTL1 Calibration Data for 12MHz */
#define CALDCO_8MHZ_          0x10FC    /* DCOCTL  Calibration Data for 8MHz */
#define CALBC1_8MHZ_          0x10FD    /* BCSCTL1 Calibration Data for 8MHz */	
	
	
	
	// we use SMCLK for SPI
	BCSCTL1 = CALBC1_1MHZ; 
	//DCOCTL = CALDCO_1MHZ;                    // SMCLK = DCO = 1MHz
	
	DCOCTL  = 0xe0;         // DCOx = 15
	BCSCTL1 = 0x0e;         // RSELx = 0
}


	
void wdt_init( void)
{
	WDTCTL = WDTPW + WDTHOLD;              // Watchdog Timer anhalten
}



void spi_init (void)
{

	
	USICTL0   = USIPE7 + USIPE6 + USIPE5 + USIMST + USIOE + USISWRST; // Port, SPI master
	USICTL1   = 0;                                                    // just to be sure
  	USICKCTL  = USIDIV0 + USISSEL_3 + USICKPL;                        // SCLK = SMCLK
  	USICTL0  &= ~USISWRST;                                            // USI released for operation

  	spi_xfer_byte( 0xff); // dummy write, see errata sheet
  	
  	// activate CS Port
  	set_bit( SPI_PxOUT, SPI_CS);
  	set_bit( SPI_PxDIR, SPI_CS);
}

u8 spi_xfer_byte( const u8 data)
{

	clear_bit( SPI_PxOUT, SPI_CS);
  	USISRL = data;
  	USICNT = 8;
	loop_until_bit_is_set( USICTL1, USIIFG);
	
  	set_bit( SPI_PxOUT, SPI_CS);
  	return ( USISRL);
	
}



void delay( u16 i) 
{
	do i--;
	while (i != 0);
}


int main(void)
{
	u16 value;
	
	clk_init();
	wdt_init();
	spi_init();
	
	
	value = 0x03;
	for (;;) 
	{
		spi_xfer_byte( value);
//		value += 2;
		value = (value >> 7) | (value << 1);
		
	 	delay( 60000);
	}
}
