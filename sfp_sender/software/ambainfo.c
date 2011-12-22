/*
 * $Date$
 * $Author$
 * $Revision$
 */

#include <types.h>


////////////////////////////////////////////////////////////
// print vendor
void print_vendor_device( uint8_t vendor, uint8_t device)
{
    switch( vendor)
    {
        case 0x01: putstr("gaisler  ");
            switch( device)
            {
                case 0x06: putstr("AHB/APB Bridge");                break;
                case 0x0c: putstr("Generic UART");                  break;
                case 0x0f: putstr("Dual-port AHB SRAM module");     break;
                case 0x11: putstr("Modular Timer Unit");            break;
                case 0x1a: putstr("General Purpose I/O port");      break;
                case 0x1d: putstr("GR 10/100 Mbit Ethernet MAC");   break;
                case 0x28: putstr("AMBA Wrapper for OC I2C-master");break;
                case 0x45: putstr("SPI Memory Controller");         break;
                case 0x61: putstr("VGA controller");                break;
                default  : putstr("unknown device");                break;
            }
            break;
        case 0x04: putstr("ESA      ");
            switch( device)
            {
                case 0x0f: putstr("Leon2 Memory Controller");       break;
                default  : putstr("unknown device");                break;
            }
            break;
        case 0x55: putstr("HZDR     ");
            switch( device)
            {
                case 0x01: putstr("ZPU AHB Wrapper");               break;
                case 0x02: putstr("ZPU Memory wrapper");            break;
                case 0x03: putstr("DCM phase shift control");       break;
                case 0x04: putstr("debug console");                 break;
                case 0x05: putstr("trigger generator");             break;
                case 0x06: putstr("beam position monitor");         break;
                case 0x07: putstr("debug buffer control");          break;
                case 0x08: putstr("EADOGS102 display driver");      break;
                case 0x09: putstr("debug tracer memory");           break;
                case 0x0a: putstr("differential current monitor");  break;
                default  : putstr("unknown device"); break;
            }
            break;
        default  : putstr("vendor?  "); break;
    }
}

////////////////////////////////////////////////////////////
// apb info
void apb_info( uint32_t* addr, uint8_t verbose)
{
    // identification register
    uint16_t  vendor;
    uint16_t  device;
    uint16_t  version;
    uint16_t  irq;
    uint32_t  dev_addr;

    uint32_t* config;
    uint32_t* idreg_addr;
    uint32_t  idreg_word;
    uint32_t* bar_addr;
    uint32_t  bar_word;

    uint32_t  apb_addr;
    uint32_t  apb_unit;
    
    config   = addr;
    apb_addr = (*config & 0xfff00000); // get apb address

    // we can have up to 512 slaves, but we scan only 16
    // to avoid double scans at the moment
    for (apb_unit = 0; apb_unit < 16; apb_unit++)
    {
        idreg_addr = (uint32_t*) (apb_addr | 0x000ff000 | (apb_unit << 3));
        idreg_word = *idreg_addr;
        bar_addr   = idreg_addr + 1;
        bar_word   = *bar_addr;
            
        dev_addr = apb_addr | ((bar_word & 0xfff00000) >> 12);
        vendor  = (idreg_word >> 24) & 0xff;
        device  = (idreg_word >> 12) & 0xfff;
        version = (idreg_word >>  5) & 0xf;
        irq     = (idreg_word >>  0) & 0x1f;
        
        if (vendor > 0)
        {
            putstr("  apbslv");
            fill( putint( apb_unit), 4);

            // print idreg word
            putstr("vend 0x"); fill( puthex( 8, vendor),  4);
            putstr("dev 0x");  fill( puthex(16, device),  6);
            putstr("ver ");    fill( putint( version), 4);
            putstr("irq ");    fill( putint( irq),     4);
            putstr("addr 0x");  fill( puthex(32, dev_addr),  10);
            if (verbose)
                print_vendor_device( vendor, device);
            putchar('\n');
        }
    }
}

void ahb_info( uint8_t verbose)
{
    uint16_t  vendor;
    uint16_t  device;
    uint16_t  version;
    uint16_t  irq;
              
    uint32_t  address;
    uint16_t  cp;
    uint16_t  mask;
    uint16_t  type;
              
    uint32_t  config_word;
    uint32_t  bar;
    uint32_t  ahb_unit;
              
    uint8_t   i;

    uint32_t* config_addr = (uint32_t*) 0xfffff000;
    uint32_t* bar_addr    = (uint32_t*) 0xfffff010;


    // check for 64 master and 64 slaves
    for (ahb_unit = 0; ahb_unit < 128; ahb_unit++)
    {
        config_addr = (uint32_t*) (0xfffff000 + (ahb_unit << 5));
        bar_addr    = (uint32_t*) config_addr + 4;

        config_word = *config_addr;

        vendor  = (config_word >> 24) & 0xff;
        device  = (config_word >> 12) & 0xfff;
        version = (config_word >>  5) & 0xf;
        irq     = (config_word >>  0) & 0x1f;

        if (vendor > 0)
        {
            if (ahb_unit < 64)
            {
                putstr("ahbmst");
                fill( putint( ahb_unit), 6);
            }
            else
            {
                putstr("ahbslv");
                fill( putint( ahb_unit - 64), 6);
            }

            // print config word
            putstr("vend 0x");  fill( puthex( 8, vendor),  4);
            putstr("dev 0x");   fill( puthex(16, device),  6);
            putstr("ver ");     fill( putint( version), 4);
            putstr("irq ");     fill( putint( irq),     4);
            putstr("addr 0x");  fill( puthex(32, *bar_addr & 0xfff00000),  10);
            if (verbose)
                print_vendor_device( vendor, device);
            putchar('\n');

            if ((vendor == 1) && (device == 6))
                apb_info( bar_addr, verbose);

            /*
            // check all 4 bank address registers
            for (i = 0; i < 4; i++)
            {
                bar         = *bar_addr;

                address = bar & 0xfff0000;
                cp      = (bar >> 16) & 0xf;
                mask    = (bar >>  4) & 0xfff;
                type    = (bar >>  0) & 0xf;

                // print bank address register
                putstr("address 0x");   fill( puthex( 32, address), 6);
                putstr("c/p 0x");       fill( puthex(  8, cp),      6);
                putstr("mask 0x");      fill( puthex( 16, mask),    6);
                putstr("type 0x");      fill( puthex(  8, type),    6);
                putchar('\n');

                bar_addr++;
            } // for i
            */

        } // vendor > 0
    } // for ahb_unit
}

