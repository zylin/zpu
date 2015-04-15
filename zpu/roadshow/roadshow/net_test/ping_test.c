//==========================================================================
//
//      tests/ping_test.c
//
//      Simple test of PING (ICMP) and networking support
//
//==========================================================================
//####BSDCOPYRIGHTBEGIN####
//
// -------------------------------------------
//
// Portions of this software may have been derived from OpenBSD or other sources,
// and are covered by the appropriate copyright disclaimers included herein.
//
// -------------------------------------------
//
//####BSDCOPYRIGHTEND####
//==========================================================================
//#####DESCRIPTIONBEGIN####
//
// Author(s):    gthomas
// Contributors: gthomas, andrew.lunn@ascom.ch
// Date:         2000-01-10
// Purpose:      
// Description:  
//              
//
//####DESCRIPTIONEND####
//
//==========================================================================

// PING test code

#include <network.h>
#include <cyg/hal/hal_if.h>
#include <stdio.h>
#include <cyg/fileio/fileio.h>
#include <unistd.h>
#include <pkgconf/system.h>
#include <pkgconf/net.h>
#include <cyg/io/file.h>
#include <cyg/infra/testcase.h>
#include CYGDAT_DEVS_ETH_OPENCORES_ETHERMAC_CFG

#ifdef CYGBLD_DEVS_ETH_DEVICE_H    // Get the device config if it exists
#include CYGBLD_DEVS_ETH_DEVICE_H  // May provide CYGTST_DEVS_ETH_TEST_NET_REALTIME
#endif

#ifdef CYGPKG_NET_TESTS_USE_RT_TEST_HARNESS // do we use the rt test?
# ifdef CYGTST_DEVS_ETH_TEST_NET_REALTIME // Get the test ancilla if it exists
#  include CYGTST_DEVS_ETH_TEST_NET_REALTIME
# endif
#endif

// Fill in the blanks if necessary
#ifndef TNR_OFF
# define TNR_OFF()
#endif
#ifndef TNR_ON
# define TNR_ON()
#endif
#ifndef TNR_INIT
# define TNR_INIT()
#endif
#ifndef TNR_PRINT_ACTIVITY
# define TNR_PRINT_ACTIVITY()
#endif

#include <cyg/io/io.h>

#include <network.h>
#include <tftp_support.h>

#include <sys/types.h> //directory
#include <dirent.h>

//for serial
cyg_io_handle_t handle; 
extern int               inet_aton __P((const char *, struct in_addr *));
#ifndef CYGPKG_LIBC_STDIO
#define perror(s) diag_printf(#s ": %s\n", strerror(errno))
#endif
#define SHOW_RESULT( _fn, _res ) \
diag_printf("<FAIL>: " #_fn "() returned %ld %s\n", (long)_res, _res<0?strerror(errno):"");

/*
#define STACK_SIZE (CYGNUM_HAL_STACK_SIZE_TYPICAL + 0x1000)
static char stack[STACK_SIZE];
static cyg_thread thread_data;
static cyg_handle_t thread_handle;
*/


/* NB!!! must be divisible by 8 */
#define NUM_PINGS 	8192
#define MAX_PACKET 	16384
#define MIN_PACKET  64
#define MAX_SEND   	(IP_MAXPACKET - 100)

#define PACKET_ADD  ((MAX_SEND - MIN_PACKET)/NUM_PINGS)
#define nPACKET_ADD  1 

static unsigned char pkt1[MAX_PACKET], pkt2[MAX_PACKET];

#define UNIQUEID 0x1234
/* we write this much to jffs2 in each go.
 * 
 * DANGER!!! JFFS2 memory consumption is proportional to the # of write operations,
 * so reducing this size will make the bootloader run out of memory.
 */
#define IOSIZE  16384  
void
pexit(char *s)
{
    CYG_TEST_FAIL_FINISH(s);
}

// Compute INET checksum
int
inet_cksum(u_short *addr, int len)
{
    register int nleft = len;
    register u_short *w = addr;
    register u_short answer;
    register u_int sum = 0;
    u_short odd_byte = 0;

    /*
     *  Our algorithm is simple, using a 32 bit accumulator (sum),
     *  we add sequential 16 bit words to it, and at the end, fold
     *  back all the carry bits from the top 16 bits into the lower
     *  16 bits.
     */
    while( nleft > 1 )  {
    	cyg_uint32 t=*w++;
        sum += t;
        nleft -= 2;
    }

    /* mop up an odd byte, if necessary */
    if( nleft == 1 ) {
        *(u_char *)(&odd_byte) = *(u_char *)w;
        sum += odd_byte;
    }

    /*
     * add back carry outs from top 16 bits to low 16 bits
     */
    sum = (sum >> 16) + (sum & 0x0000ffff); /* add hi 16 to low 16 */
    sum += (sum >> 16);                     /* add carry */
    answer = ~sum;                          /* truncate to 16 bits */
    return (answer);
}

static int
show_icmp(unsigned char *pkt, int len, 
          struct sockaddr_in *from, struct sockaddr_in *to)
{
	char buffer[100];
	cyg_uint32 buffer_index = 0;
    cyg_tick_count_t tp, tv;
    struct ip *ip;
    struct icmp *icmp;
    tv = cyg_current_time();
    ip = (struct ip *)pkt;
    if ((len < (int)sizeof(*ip)) || ip->ip_v != IPVERSION) 
    {
    	buffer[0] = '\0';
        snprintf(buffer, 99, "%s: Short packet or not IP! - Len: %d, Version: %d\r\n", 
                    inet_ntoa(from->sin_addr), len, ip->ip_v);
        buffer_index = strlen(buffer);
        cyg_io_write(handle, buffer, &buffer_index);
        return 0;
    }
    icmp = (struct icmp *)(pkt + sizeof(*ip));
    len -= (sizeof(*ip) + 8);
    tp = *((cyg_tick_count_t *)&icmp->icmp_data);
    if (icmp->icmp_type != ICMP_ECHOREPLY) 
    {
    	buffer[0] = '\0';
        snprintf(buffer, 99, "%s: Invalid ICMP - type: %d\r\n", 
                    inet_ntoa(from->sin_addr), icmp->icmp_type);
        buffer_index = strlen(buffer);
        cyg_io_write(handle, buffer, &buffer_index);
        return 0;
    }
    if (icmp->icmp_id != UNIQUEID) 
    {
    	buffer[0] = '\0';
        snprintf(buffer, 99, "%s: ICMP received for wrong id - sent: %x, recvd: %x\r\n", 
                    inet_ntoa(from->sin_addr), UNIQUEID, icmp->icmp_id);
        buffer_index = strlen(buffer);
        cyg_io_write(handle, buffer, &buffer_index);
    }
//    printf("%d bytes from %s: ", len, inet_ntoa(from->sin_addr));
//    printf("icmp_seq=%d", icmp->icmp_seq);
    int t=(int)(tv-tp);
	t*=10;
//    printf(", time=%d ms\n", t);
    return (from->sin_addr.s_addr == to->sin_addr.s_addr);
}

static void
ping_host(int s, struct sockaddr_in *host)
{
	char buffer[100];
	cyg_uint32 buffer_index = 0;
    struct icmp *icmp = (struct icmp *)pkt1;
    int icmp_len = MIN_PACKET;
    int seq = 0, ok_recv = 0, bogus_recv = 0;
    cyg_tick_count_t *tp;
    long *dp;
    struct sockaddr_in from;
    int len;
    socklen_t fromlen;
	
    ok_recv = 0;
    bogus_recv = 0;
    snprintf(buffer, 99, "PING server %s\r\n", inet_ntoa(host->sin_addr));
    buffer_index = strlen(buffer);
    cyg_io_write(handle, buffer, &buffer_index);
    
    
    for (seq = 0;  seq < NUM_PINGS;  seq++, icmp_len += PACKET_ADD ) 
    {
    	cyg_thread_delay(50);
        TNR_ON();
        
        memset(pkt1, 0, sizeof(pkt1)); // make sure we start each time w/same situation...
        // Build ICMP packet
        icmp->icmp_type = ICMP_ECHO;
        icmp->icmp_code = 0;
        icmp->icmp_cksum = 0;
        icmp->icmp_seq = seq;
        icmp->icmp_id = 0x1234;
        // Set up ping data
        tp = (cyg_tick_count_t *)&icmp->icmp_data;
		memset(tp, 0xff, icmp_len); // try to fish out bit 1 force to 0.
        *tp++ = cyg_current_time();
        tp++;
        dp = (long *)tp;

        // Add checksum
        icmp->icmp_cksum = inet_cksum( (u_short *)icmp, icmp_len+8);
        // Send it off
        if (sendto(s, icmp, icmp_len+8, 0, (struct sockaddr *)host, sizeof(*host)) < 0) {
            TNR_OFF();
            perror("sendto");
            continue;
        }
        // Wait for a response
        fromlen = sizeof(from);
        len = recvfrom(s, pkt2, sizeof(pkt2), 0, (struct sockaddr *)&from, &fromlen);
        TNR_OFF();
        if (len < 0) {
            perror("recvfrom");
            inet_cksum( (u_short *)icmp, icmp_len+8);
            icmp_len = MIN_PACKET - PACKET_ADD; // just in case - long routes
        } else {
            if (show_icmp(pkt2, len, &from, host)) {
                ok_recv++;
            } else {
                bogus_recv++;
            }
        }
    }
    TNR_OFF();
    snprintf(buffer, 99, "Sent %d packets, received %d OK, %d bad\r\n", NUM_PINGS, ok_recv, bogus_recv);
    buffer_index = strlen(buffer);
    cyg_io_write(handle, buffer, &buffer_index);
}

#ifdef CYGPKG_PROFILE_GPROF
#include <cyg/profile/profile.h>

extern char _stext, _etext;  // Defined by the linker

static void
start_profile(void)
{
    // This starts up the system-wide profiling, gathering
    // profile information on all of the code, with a 16 byte
    // "bucket" size, at a rate of 100us/profile hit.
    // Note: a bucket size of 16 will give pretty good function
    //       resolution.  Much smaller and the buffer becomes
    //       much too large for very little gain.
    // Note: a timer period of 100us is also a reasonable
    //       compromise.  Any smaller and the overhead of 
    //       handling the timter (profile) interrupt could
    //       swamp the system.  A fast processor might get
    //       by with a smaller value, but a slow one could
    //       even be swamped by this value.  If the value is
    //       too large, the usefulness of the profile is reduced.
    
    // no more interrupts than 1/10ms.
    //profile_on(&_stext, &_etext, 16, 10000); // DRAM
    //profile_on((void *)0x2000000, (void *)0x4000000, 32, 10000); // DRAM
    //profile_on((void *)0, (void *)0x40000, 16, 10000); // SRAM
    //profile_on(0, &_etext, 32, 10000); // SRAM & DRAM
}
#endif

static void
ping_test(struct bootp *bp)
{
    struct protoent *p;
    struct timeval tv;
    struct sockaddr_in host;
    int s;
    
	p = getprotobyname("icmp");
    if (p == NULL) 
    {
        pexit("getprotobyname");
        return;
    }
    s = socket(AF_INET, SOCK_RAW, p->p_proto);
    if (s < 0) {
        pexit("socket");
        return;
    }
    tv.tv_sec = 4;
    tv.tv_usec = 0;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

	// default is 8192 bytes which is not big enough for our ping tests...
    int sndsize=70000;
    setsockopt(s, SOL_SOCKET, SO_RCVBUF, (char *)&sndsize,
                                 (int)sizeof(sndsize));
    sndsize=70000;
    setsockopt(s, SOL_SOCKET, SO_SNDBUF, (char *)&sndsize,
                                 (int)sizeof(sndsize));

    // Set up host address
    host.sin_family = AF_INET;
    host.sin_len = sizeof(host);
    inet_aton("10.0.0.9", &(host.sin_addr)); // edgarpc dev machine
//    inet_aton("10.0.0.1", &host.sin_addr); // cisco router
    host.sin_port = 0;
    ping_host(s, &host);
}

void done_test()
{
}

void 
net_test(void)
{

	Cyg_ErrNo err;
    diag_printf("Start PING test\r\n");
    TNR_INIT();
   
    err = cyg_io_lookup("/dev/ser0", &handle);
    if(err != ENOERR)
    {
    	diag_printf("cannot open serial /dev/ser0");
    	return;
    }
    printf("Testing stdout...\r\n");

#ifdef CYGHWR_NET_DRIVER_ETH0
    if (eth0_up) {
        ping_test(&eth0_bootp_data);
    }
#endif
#ifdef CYGHWR_NET_DRIVER_ETH1
    if (eth1_up) {
        ping_test(&eth1_bootp_data);
    }
#endif
    TNR_PRINT_ACTIVITY();
    CYG_TEST_PASS_FINISH("Ping test OK");
    done_test();
}


int getFileName(const char *extension, char *fileName)
{
	int found = 0;
	DIR* ramfs = opendir("/ramfs");
	if(ramfs == NULL)
	{
		diag_printf("cannot open /ramfs\n");
		return found;
	}
	while(1)
	{
		struct dirent *entry = readdir( ramfs );
		int len = 0;
		if( entry == NULL )
			break;
        len = strlen(entry->d_name);
        if(len > 4 && entry->d_name[len - 4] == '.' &&
        			  entry->d_name[len - 3] == 'p' &&
        			  entry->d_name[len - 2] == 'h' &&
        			  entry->d_name[len - 1] == 'i')
	  	{
	  		found = 1;
	  		strcpy(fileName, "/ramfs/");
	  		strcat(fileName, entry->d_name);
	  	}
	}
	closedir(ramfs);
	ramfs = NULL;
	return found;
}

static char buf[IOSIZE];

static int copyfile( char *name2, char *name1 )
{

    int err = 0;
    int fd1 = -1, fd2 = -1;
    ssize_t done = 0, wrote = 0, current = 0;

    diag_printf(" copy file %s -> %s\n",name2,name1);
   
    fd1 = creat(name1, O_TRUNC | O_CREAT);
    if( fd1 < 0 ) 
    {
    	SHOW_RESULT( creat, fd1 );
    	diag_printf(" %s", name1);
    	return -1;
    }

    fd2 = open( name2, O_RDONLY );
    if( fd2 < 0 ) 
    {
    	SHOW_RESULT( open, fd2 );
    	diag_printf(" %s", name2);
    	return -1;
    }
    
    for(;;)
    {
        done = read( fd2, buf, IOSIZE );
        if( done < 0 ) 
        {
        	SHOW_RESULT( read, done );
	    	return -1;
	    }

        if( done == 0 ) break;

        wrote = write( fd1, buf, done );
        if( wrote != done ) 
        {
        	SHOW_RESULT( write, wrote );
	    	return -1;
	    }
	    
		current += wrote;
        if( wrote != done ) break;
    }
	diag_printf("wrote %d\n", current);
    err = close( fd1 );
    if( err < 0 )
    {
    	 SHOW_RESULT( close, err );
    	 diag_printf(" %s", name1);
    	return -1;
    }

    err = close( fd2 );
    if( err < 0 ) 
    {
    	SHOW_RESULT( close, err );
    	diag_printf(" %s", name2);
    	return -1;
    }
	return 0;
}

int isCompleted(const char *fileName)
{
    int err = access( fileName, W_OK );
    int fd = 0;
    char readyBuffer[5];
    if( err < 0 && errno != EACCES )
    {
    	SHOW_RESULT( access, err );
    	return 0;
    }
    fd = open(fileName, O_RDONLY);
    if(fd < 0)
    {
    	SHOW_RESULT( open, errno );
    	return 0;
    }
    err = lseek(fd, -5, SEEK_END);
    if(err < 0)
    {
    	SHOW_RESULT( lseek, err );
    	close(fd);
    	return 0;
    }
    err = read(fd, readyBuffer, 4);
    if(err < 0)
    {
    	SHOW_RESULT( read, err );
    	close(fd);
    	return 0;
    }
    readyBuffer[4] = '\0';
    if(strncmp(readyBuffer, "Done", 4) != 0)
    {
    	//diag_printf("Coudn't read \"Done\" at the end of the firmware file %s\n", readyBuffer);
    	close(fd);
    	return 0;
    }
    close(fd);
    diag_printf("found!\n");
    return 1;
}

static void ramfs_polling(cyg_addrword_t data)
{
	char fileName[100];
	int found = 0;
	while(1)
	{
		cyg_thread_delay(100);
		//scan the file system for a new .phi file
		found = getFileName("phi", fileName);
		if(found)
		{
			//check if the file has been transfered
			if(isCompleted(fileName))
			{
				//move the file to flash
				unlink("/jffs2/firmware.bin");
				copyfile(fileName, "/jffs2/firmware.bin");
				diag_printf("firmware file copied to jffs2\n");
				unlink(fileName);
				diag_printf("unmounting /jffs\n");
				umount("/jffs2");
				diag_printf("Resetting...\n");
//				CYGACC_CALL_IF_RESET();
			}
		}
	}
}

static unsigned char ramfs_polling_stack[CYGNUM_HAL_STACK_SIZE_TYPICAL];
static cyg_handle_t ramfs_polling_handle;
static cyg_thread   ramfs_polling_thread;

void start_ramfs_polling()
{

	cyg_thread_create(10, &ramfs_polling, 0, "ramfs_polling",
                      ramfs_polling_stack, CYGNUM_HAL_STACK_SIZE_TYPICAL,
                      &ramfs_polling_handle, &ramfs_polling_thread);
	cyg_thread_resume(ramfs_polling_handle);   
}

struct tftpd_fileops fileops = {open, 
								close, 
								write, 
								read};

externC void phi_init_all_network_interfaces();

int main(int argc, char **argv)
{
	diag_printf("Entered net_test main()\n");
	
	int server_id = 0;

	init_all_network_interfaces();
	


	int i=0;
	while(1)
	{
		cyg_thread_delay(500);
//		net_test();
		diag_printf("sleeping... %d\n", i++);
	}
	return 0;
}
