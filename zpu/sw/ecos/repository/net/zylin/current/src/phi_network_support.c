//==========================================================================
//
//      ph_network_support.c
//
//      Misc network support functions
//
//==========================================================================
//####ECOSGPLCOPYRIGHTBEGIN####
// -------------------------------------------
// This file is part of eCos, the Embedded Configurable Operating System.
// Copyright (C) 1998, 1999, 2000, 2001, 2002 Red Hat, Inc.
// Copyright (C) 2003 Andrew Lunn <andrew.lunn@ascom.ch>   
//
// eCos is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 or (at your option) any later version.
//
// eCos is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with eCos; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
//
// As a special exception, if other files instantiate templates or use macros
// or inline functions from this file, or you compile this file and link it
// with other works to produce a work based on this file, this file does not
// by itself cause the resulting work to be covered by the GNU General Public
// License. However the source code for this file must still be made available
// in accordance with section (3) of the GNU General Public License.
//
// This exception does not invalidate any other reasons why a work based on
// this file might be covered by the GNU General Public License.
//
// Alternative licenses for eCos may be arranged by contacting Red Hat, Inc.
// at http://sources.redhat.com/ecos/ecos-license/
// -------------------------------------------
//####ECOSGPLCOPYRIGHTEND####
//==========================================================================
//#####DESCRIPTIONBEGIN####
//
// Author(s):    gthomas
// Contributors: gthomas, sorin@netappi.com ("Sorin Babeanu"), hmt, jlarmour,
//               andrew.lunn@ascom.ch
// Date:         2000-01-10
// Purpose:      
// Description:  
//              
//
//####DESCRIPTIONEND####
//
//==========================================================================

// BOOTP support

#include <pkgconf/net.h>
#undef _KERNEL
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <net/if.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <net/route.h>

#include <cyg/infra/diag.h>
#include <cyg/kernel/kapi.h>

#include <stdio.h>    // for 'sprintf()'
#include <string.h>	  // for strncpy and strtok_r
#include <bootp.h>
#include <network.h>
#include <arpa/inet.h>

#ifdef CYGPKG_IO_PCMCIA
#include <cyg/io/eth/netdev.h>
#endif

#ifdef CYGPKG_NET_DHCP
#include <dhcp.h>
#endif

#ifdef CYGPKG_NS_DNS
#include <pkgconf/ns_dns.h>
#endif

#ifdef CYGHWR_NET_DRIVER_ETH0
//struct bootp eth0_bootp_data;
//cyg_bool_t   eth0_up = false;
//const char  *eth0_name = "eth0";
#endif
#ifdef CYGHWR_NET_DRIVER_ETH1
struct bootp eth1_bootp_data;
//cyg_bool_t   eth1_up = false;
//const char  *eth1_name = "eth1";
#endif

#define _string(s) #s
#define string(s) _string(s)

#ifndef CYGPKG_LIBC_STDIO
#define perror(s) diag_printf(#s ": %s\n", strerror(errno))
#endif


static int hasIP(char *ip, char *mask, char *broadcast, char *gateway, char *server)
{
	int retVal = false;
	int len = -1;
	char buf[81];
	char *ptr1 = NULL;
	char *token = NULL;
	
	if(ip == NULL)
		return 0;
	
	//try to open ip file
	int fd = open("/jffs2/ip", O_RDONLY);
	if(fd < 0)
	{
		ip[0] = '\0';
		return 0;
	}
	//return ip address
	if( (len = read(fd, buf, 80)) > 0)
	{
		buf[len] = '\0';
		//get IP
		token = strtok_r(buf, "_", &ptr1);
		if(token != NULL)
			strncpy(ip, token, 15);
		else
		{
			close(fd);
			return 0;
		}
		//get MASK
		token = strtok_r(NULL, "_", &ptr1);
		if(token != NULL)
			strncpy(mask, token, 15);
		else
		{
			close(fd);
			return 0;
		}
		//get broadcast
		token = strtok_r(NULL, "_", &ptr1);
		if(token != NULL)
			strncpy(broadcast, token, 15);
		else
		{
			close(fd);
			return 0;
		}
		//get gateway
		token = strtok_r(NULL, "_", &ptr1);
		if(token != NULL)
			strncpy(gateway, token, 15);
		else
		{
			close(fd);
			return 0;
		}
		//get server
		token = strtok_r(NULL, "_", &ptr1);
		if(token != NULL)
			strncpy(server, token, 15);
		else
		{
			close(fd);
			return 0;
		}
		
		retVal = 1;
	}
	else
	{
		retVal = 0;
		ip[0] = '\0';
	}
	return retVal;
}

//
// Initialize network interface[s] using BOOTP/DHCP
//
void
phi_init_all_network_interfaces(void)
{
    static volatile int in_init_all_network_interfaces = 0;

#ifdef CYGOPT_NET_IPV6_ROUTING_THREAD
    int rs_wait = 40;
#endif

    cyg_scheduler_lock();
    while ( in_init_all_network_interfaces ) {
        // Another thread is doing this...
        cyg_scheduler_unlock();
        cyg_thread_delay( 10 );
        cyg_scheduler_lock();
    }
    in_init_all_network_interfaces = 1;
    cyg_scheduler_unlock();

#ifdef CYGHWR_NET_DRIVER_ETH0
    if ( ! eth0_up ) { // Make this call idempotent
		char ip[16], mask[16], broadcast[16], gateway[16], server[16];
		if(!hasIP(ip, mask, broadcast, gateway, server))
		{
	        // Perform a complete initialization, using BOOTP/DHCP
	        eth0_up = true;
	        eth0_dhcpstate = 0; // Says that initialization is external to dhcp
	        if (do_dhcp(eth0_name, &eth0_bootp_data, &eth0_dhcpstate, &eth0_lease))
//	        { 
//		        if (do_bootp(eth0_name, &eth0_bootp_data)) 
        		{
		            show_bootp(eth0_name, &eth0_bootp_data);
        		} else {
		            diag_printf("BOOTP/DHCP failed on eth0\n");
        		    eth0_up = false;
        		}
//	        }
		}
		else
		{

	        eth0_up = true;
	        build_bootp_record(&eth0_bootp_data,
                           eth0_name,
                           ip,
                           mask,
                           broadcast,
                           gateway,
                           server);
	        show_bootp(eth0_name, &eth0_bootp_data);
		}
    }
#endif // CYGHWR_NET_DRIVER_ETH0
#ifdef CYGHWR_NET_DRIVER_ETH1
    if ( ! eth1_up ) { // Make this call idempotent
#ifdef CYGHWR_NET_DRIVER_ETH1_BOOTP
        // Perform a complete initialization, using BOOTP/DHCP
        eth1_up = true;
#ifdef CYGHWR_NET_DRIVER_ETH1_DHCP
        eth1_dhcpstate = 0; // Says that initialization is external to dhcp
        if (do_dhcp(eth1_name, &eth1_bootp_data, &eth1_dhcpstate, &eth1_lease)) 
#else
#ifdef CYGPKG_NET_DHCP
        eth1_dhcpstate = DHCPSTATE_BOOTP_FALLBACK;
        // so the dhcp machine does no harm if called
#endif
        if (do_bootp(eth1_name, &eth1_bootp_data))
#endif
        {
#ifdef CYGHWR_NET_DRIVER_ETH1_BOOTP_SHOW
            show_bootp(eth1_name, &eth1_bootp_data);
#endif
        } else {
            diag_printf("BOOTP/DHCP failed on eth1\n");
            eth1_up = false;
        }
#elif defined(CYGHWR_NET_DRIVER_ETH1_ADDRS_IP)
        eth1_up = true;
        build_bootp_record(&eth1_bootp_data,
                           eth1_name,
                           string(CYGHWR_NET_DRIVER_ETH1_ADDRS_IP),
                           string(CYGHWR_NET_DRIVER_ETH1_ADDRS_NETMASK),
                           string(CYGHWR_NET_DRIVER_ETH1_ADDRS_BROADCAST),
                           string(CYGHWR_NET_DRIVER_ETH1_ADDRS_GATEWAY),
                           string(CYGHWR_NET_DRIVER_ETH1_ADDRS_SERVER));
        show_bootp(eth1_name, &eth1_bootp_data);
#endif
    }
#endif // CYGHWR_NET_DRIVER_ETH1
#ifdef CYGHWR_NET_DRIVER_ETH0
#ifndef CYGHWR_NET_DRIVER_ETH0_MANUAL
    if (eth0_up) {
        if (!init_net(eth0_name, &eth0_bootp_data)) {
            diag_printf("Network initialization failed for eth0\n");
            eth0_up = false;
        }
#ifdef CYGHWR_NET_DRIVER_ETH0_IPV6_PREFIX
        if (!init_net_IPv6(eth0_name, &eth0_bootp_data, 
                           string(CYGHWR_NET_DRIVER_ETH0_IPV6_PREFIX))) {
            diag_printf("Static IPv6 network initialization failed for eth0\n");
            eth0_up = false;  // ???
        }
#endif
    }
#endif
#endif
#ifdef CYGHWR_NET_DRIVER_ETH1
#ifndef CYGHWR_NET_DRIVER_ETH1_MANUAL
    if (eth1_up) {
        if (!init_net(eth1_name, &eth1_bootp_data)) {
            diag_printf("Network initialization failed for eth1\n");
            eth1_up = false;
        }
#ifdef CYGHWR_NET_DRIVER_ETH1_IPV6_PREFIX
        if (!init_net_IPv6(eth1_name, &eth1_bootp_data, 
                           string(CYGHWR_NET_DRIVER_ETH1_IPV6_PREFIX))) {
            diag_printf("Static IPv6 network initialization failed for eth1\n");
            eth1_up = false; // ???
        }
#endif
    }
#endif
#endif

#ifdef CYGPKG_NET_NLOOP
#if 0 < CYGPKG_NET_NLOOP
    {
        static int loop_init = 0;
        int i;
        if ( 0 == loop_init++ )
            for ( i = 0; i < CYGPKG_NET_NLOOP; i++ )
                init_loopback_interface( i );
    }
#endif
#endif

#ifdef CYGOPT_NET_DHCP_DHCP_THREAD
    dhcp_start_dhcp_mgt_thread();
#endif

#ifdef CYGOPT_NET_IPV6_ROUTING_THREAD
    ipv6_start_routing_thread();

    // Wait for router solicit process to happen.
    while (rs_wait-- && !cyg_net_get_ipv6_advrouter(NULL)) {
      cyg_thread_delay(10);
    }
    if (rs_wait == 0 ) {
      diag_printf("No router solicit received\n");
    } else {
      // Give Duplicate Address Detection time to work
      cyg_thread_delay(200);
    }
#endif

#ifdef CYGDAT_NS_DNS_DEFAULT_SERVER
      cyg_dns_res_start(string(CYGDAT_NS_DNS_DEFAULT_SERVER));
#endif

#ifdef CYGDAT_NS_DNS_DOMAINNAME_NAME
#define _NAME string(CYGDAT_NS_DNS_DOMAINNAME_NAME)
    {
      const char buf[] = _NAME;
      int len = strlen(_NAME);
      
      setdomainname(buf,len);
    }
#endif
    // Open the monitor to other threads.
    in_init_all_network_interfaces = 0;

}

// EOF phi_network_support.c
