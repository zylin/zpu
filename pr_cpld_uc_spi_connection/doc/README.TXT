IO-Erweiterung per SPI

realisiert mittels Schieberegister
variable Anzahl von IOs


Realisierung des SPI-Slave-Schieberegisters auf einem CPLD
Ansterurung mittel µController
    hier: MSP430G2231
    Features: 2kB Flash, 128B RAM, 10-Bit SAR AD, USI (SPI/IIC)

    Pinbelegung
    SCLK P1.5
    SDO  P1.6
    SDI  P1.7

angepasste Version für CPLD (asynchron und ohne Eingänge)
alle SPI-Frequenzen arbeiten erwartungsgemäß
Update (8 Bit) bei 14 MHz dauert ca. 2.4µs = 3.3 MBit/s
