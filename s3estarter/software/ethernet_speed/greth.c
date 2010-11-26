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
#include <string.h>     // memcpy
//#include <stdio.h>      // printf

#include <peripherie.h> 
#include <../libhal/timer.h> // libhal/timer.c/clocks
#include <uart.h>          // vga_clear, vga_putstr
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
    unsigned char buf[1514];
    uint32_t t1, t2; 
    //clock_t  t1, t2;
    unsigned long long datasize;
    //double time, bitrate;
    uint32_t time;
    double bitrate;

    // led debug init
    gpio0->iodir = 0x000000ff;
    //vga_clear();
    uart_init();

    greth.regs = (greth_regs *) GRETH_ADDR;

    /* Dest. addr */
    buf[0] = DEST_MAC0;
    buf[1] = DEST_MAC1;
    buf[2] = DEST_MAC2;
    buf[3] = DEST_MAC3;
    buf[4] = DEST_MAC4;
    buf[5] = DEST_MAC5;

    /* Source addr */
    buf[6]  = SRC_MAC0;
    buf[7]  = SRC_MAC1;
    buf[8]  = SRC_MAC2;
    buf[9]  = SRC_MAC3;
    buf[10] = SRC_MAC4;
    buf[11] = SRC_MAC5;

    /* Length 1500 */
    buf[12] = 0x05;
    buf[13] = 0xDC;

    memcpy(greth.esa, &buf[6], 6);

    gpio0->ioout = 2;
    // one loop takes 1572 cycles (31.44 ns)
    // complete: 47.16 ms)
    for (i = 14; i < 1514; i++) {
        buf[i] = (unsigned char) i;
    }

    gpio0->ioout = 3;
    greth_init(&greth);
   
    gpio0->ioout = 4;
    uart_putstr("\nSending 1500 Mbyte of data to ");
    for (i=0; i<6; i++) {
        uart_puthex(8, buf[i]);
        if (i != 5) uart_putchar(':');
    }
    uart_putchar('\n');

    t1 = clocks(); //clock();

    while(i < (unsigned long long) 1024*1024) {
        gpio0->ioout = (unsigned char) greth.txpnt & 0xff;

        // greth_tx() returns 1 if a free descriptor is found, otherwise 0 
        i += greth_tx(1514, buf, &greth);

    }
    t2 = clocks(); //clock();

    //time = (double)(t2 - t1)/CLOCKS_PER_SECOND;
    time = (t2 - t1);
    uart_putstr("\nTime: ");
    uart_putint( time);
    uart_putchar('\n');

    /*
    // size: 44138    next block: 408
    datasize = (unsigned long long)1024*1024*1500*8; // In bits 
    bitrate = (double) datasize/time;
    printf("Bitrate: %f Mbps\n", bitrate/(1024*1024));
    
    // size: 44546
    */
    return 0;
}
