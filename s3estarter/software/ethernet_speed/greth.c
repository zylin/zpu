/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY                        */
/*   Copyright (C) 2007 GAISLER RESEARCH                                     */
/*                                                                           */
/*   This program is free software; you can redistribute it and/or modify    */
/*   it under the terms of the GNU General Public License as published by    */
/*   the Free Software Foundation; either version 2 of the License, or       */
/*   (at your option) any later version.                                     */
/*                                                                           */
/*   See the file COPYING for the full details of the license.               */
/*****************************************************************************/

/* Changelog */
/* 2007-11-13: Simple Ethernet speed test added - Kristoffer Glembo */
/* 2007-11-13: GRETH BareC API added            - Kristoffer Glembo */

#include <stdlib.h>
//#include <time.h>       // clock
#include <string.h>         // memcpy
//#include <stdio.h>        // printf

#include <peripherie.h> 
#include <common.h>         // putchar_fp
#include <timer.h>          // libhal/timer.c/clocks
#include <uart.h>           // vga_clear, vga_putstr
#include "greth_api.h"

/* Set to 1 if using GRETH_GBIT, otherwise 0 */
#define GRETH_GBIT 0

/* Set to 10,100, or 1000 */
#define GRETH_SPEED 100

/* Set to 1 to run full duplex, 0 to run half duplex */
#define GRETH_FULLDUPLEX 1

#define GRETH_ADDR 0x80000c00

/* Destination MAC address */
#define DEST_MAC0  0x00
#define DEST_MAC1  0x1B
#define DEST_MAC2  0x21
#define DEST_MAC3  0x67
#define DEST_MAC4  0xB8
#define DEST_MAC5  0xB8

/* Source MAC address */
#define SRC_MAC0  0xDE
#define SRC_MAC1  0xAD
#define SRC_MAC2  0xBE
#define SRC_MAC3  0xEF
#define SRC_MAC4  0x00
#define SRC_MAC5  0x20 

struct greth_info greth;

int main(void) {

    unsigned long long i;
    unsigned long long packets;

    struct buf_st {
        unsigned char buf[1514];
    } __attribute((packed));
    typedef struct buf_st buf_t;

    buf_t   *buf_pt = (buf_t *) (0xA0000280);

    uint32_t time, time1, time2; 
    unsigned long long datasize;
    unsigned long long bitrate;

    uint32_t simulation_active;

    // check if on simulator or on hardware
    simulation_active = gpio0->iodata & (1<<31);
    
    // led debug init
    gpio0->iodir = 0x000000ff;

    vga_init();
    timer_init();
    uart_init();

    putchar_fp = (simulation_active) ? &debug_putchar : &combined_putchar;


    putstr("\f" __FILE__);
    if (simulation_active) 
    {
        putstr(" (on sim)\n");
    }
    else
    {
        putstr(" (on hardware)\n");
        putstr("compiled: " __DATE__ "  " __TIME__ "\n");
    }



    greth.regs = (greth_regs *) GRETH_ADDR;

    /* Dest. addr */
    buf_pt->buf[0] = DEST_MAC0;
    buf_pt->buf[1] = DEST_MAC1;
    buf_pt->buf[2] = DEST_MAC2;
    buf_pt->buf[3] = DEST_MAC3;
    buf_pt->buf[4] = DEST_MAC4;
    buf_pt->buf[5] = DEST_MAC5;

    /* Source addr */
    buf_pt->buf[6]  = SRC_MAC0;
    buf_pt->buf[7]  = SRC_MAC1;
    buf_pt->buf[8]  = SRC_MAC2;
    buf_pt->buf[9]  = SRC_MAC3;
    buf_pt->buf[10] = SRC_MAC4;
    buf_pt->buf[11] = SRC_MAC5;

    /* Length 1500 */
    buf_pt->buf[12] = 0x05;
    buf_pt->buf[13] = 0xDC;

    gpio0->ioout = 1;
    
    memcpy(greth.esa, &(buf_pt->buf[6]), 6);

    gpio0->ioout = 2;
    // one loop takes 1572 cycles (31.44 ns)
    // complete: 47.16 ms)
    if ( !(simulation_active))
    {
        for (i = 14; i < 1514; i++) {
            buf_pt->buf[i] = (unsigned char) i;
        }
    }

    gpio0->ioout = 3;
    greth_init( &greth);
    init_greth_tx( &greth);
   
    gpio0->ioout = 4;
    putstr("\nSending 1500 Mbyte of data to ");
    for (i=0; i<6; i++) {
        puthex(8, buf_pt->buf[i]);
        if (i != 5) putchar(':');
    }
    putchar('\n');

    packets = (simulation_active) ? 64 : 1024*1024; 
    //packets = 10 * 1024;
    putchar('('); putint( packets); putstr(" packets)\n\n");
    i   = 0;

    gpio0->ioout = 5;

    time1 = get_time();

    while (i < packets) {
        gpio0->ioout = 0xff & (i >> 8);
        // greth_tx() returns 1 if a free descriptor is found, otherwise 0 
        i += greth_tx(1514, &(buf_pt->buf[0]), &greth);
    }

    // wait until all descriptors are sent
    i   = 0;
    while (i <= MAX_DESC) {
        gpio0->ioout = 0xff & i;
        i += greth_checktx( &greth);
    }
    
    time2 = get_time();
    
    gpio0->ioout = 0xff;

    time = time1 - time2; // timer counts down
    putstr("Time    : "); putpfloat( time );
    putstr(" sec\n");
    
    datasize = (unsigned long long)packets*1500*8; // In bits 
    bitrate  = (unsigned long long)(datasize*1000)/time; // time is in milliseconds
    putstr("Bitrate : "); putint( (long) bitrate/(1024) ); // 1024 = k
    putstr(" kbps\n");

    return 0;
}

/*

Übertragungsrate beim Senden von 1500 Mbyte (1048576) Pakets:
Dauer: 130.529 Sekunden
Bitrate: 94523 kb/s

*/
