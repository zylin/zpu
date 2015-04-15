#include <pkgconf/hal.h>
#include <cyg/hal/hal_if.h>
#include <pkgconf/system.h>
#include <pkgconf/isoinfra.h>
#include <pkgconf/net.h>
#include <pkgconf/httpd.h>
#include <cyg/httpd/httpd.h>
#include <pkgconf/kernel.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

static cyg_bool isUnsignedHex(char *string)
{
	int i = 0;
	for(i = 0; string[i] != '\0'; i++)
		if(!(	('0' <= string[i] && string[i] <= '9') ||
				('a' <= string[i] && string[i] <= 'f') ||
				('A' <= string[i] && string[i] <= 'F') ))
			return 0;
	return 1;
}

static cyg_bool net_test_mac_handler(FILE *client, char *filename, char *formdata, void *arg)
{
	char error_string[50]; 

	error_string[0] = '\0';

    if( formdata != NULL )
    {
		char *formlist[1];
		char *mac_string = NULL;
        /* Parse the data */
        cyg_formdata_parse( formdata, formlist, 1 );
        mac_string = cyg_formlist_find( formlist, "mac");
        if(mac_string != NULL)
        {
  
        	if(!isUnsignedHex(mac_string))
        	{
        		sprintf(error_string, "Please enter digits between 0-9 and a-f");
        	}
        	else if(strlen(mac_string) != 12)
        	{
        		sprintf(error_string, "Please enter a 12 digit MAC address");
        	}
        	else
        	{
        		char temp = '\0';
        		int fd = -1;
        		cyg_uint8 mac_addr[6];
        		error_string[0] = '\0';

        		temp = mac_string[2];
        		mac_string[2] = '\0';
        		mac_addr[0] = strtol(mac_string, NULL, 16);
				mac_string[2] = temp;
				
        		temp = mac_string[4];
        		mac_string[4] = '\0';
        		mac_addr[1] = strtol(mac_string, NULL, 16);
				mac_string[4] = temp;

        		temp = mac_string[6];
        		mac_string[6] = '\0';
        		mac_addr[2] = strtol(mac_string, NULL, 16);
				mac_string[6] = temp;

        		temp = mac_string[8];
        		mac_string[8] = '\0';
        		mac_addr[3] = strtol(mac_string, NULL, 16);
				mac_string[8] = temp;

        		temp = mac_string[10];
        		mac_string[10] = '\0';
        		mac_addr[4] = strtol(mac_string, NULL, 16);
				mac_string[10] = temp;

        		temp = mac_string[12];
        		mac_string[12] = '\0';
        		mac_addr[5] = strtol(mac_string, NULL, 16);
				mac_string[12] = temp;
				
				/*write it to flash*/
				fd = creat("/jffs2/mac", O_TRUNC | O_CREAT);
				if(fd < 0)
				{
					sprintf(error_string, "<font color=red>%n %s</font>", errno, strerror(errno) );
				}
				else
				{
					write(fd, mac_addr, 6);
					close(fd);
					fd = -1;
					//CYGACC_CALL_IF_RESET();
				}
			}
		}
	}
    
    html_begin(client);

    html_head(client,"Changing MAC Address", "");
    
    html_body_begin(client,"");
    {
    	fputs(error_string, client);
    	fputs("<br>\n", client);
    	html_form_begin( client, "/mac", "" );
    	{
    		fputs( "Enter the new mac address in the format xxxxxxxxxxxx ", client );
    		html_form_input( client, "mac", "mac", "", "");
    	}
    	html_form_end(client);
    }
    html_body_end(client);

    html_end(client);
    
    return 1;
}

CYG_HTTPD_TABLE_ENTRY( net_test_mac,
                       "/mac",
                       net_test_mac_handler,
                       NULL );
                       

static cyg_bool net_test_ip_handler(FILE *client, char *filename, char *formdata, void *arg)
{
	int fd = -1;
	char error_string[50]; 
	char error_string2[50];
	
	error_string[0] = '\0';
	error_string2[0] = '\0';
	if( formdata != NULL )
    {
		char *formlist[1];
		char *ip_string = NULL;
        /* Parse the data */
        cyg_formdata_parse( formdata, formlist, 1 );
        ip_string = cyg_formlist_find( formlist, "ip");
        if(ip_string != NULL)
        {
        	/*write it to flash*/
			fd = creat("/jffs2/ip", O_TRUNC | O_CREAT);
			if(fd < 0)
			{
				sprintf(error_string, "<font color=red>%n %s</font>", errno, strerror(errno) );
			}
			else
			{
				write(fd, ip_string, strlen(ip_string));
				close(fd);
				fd = -1;
			}
        }
    }
	html_begin(client);

	html_head(client,"Changing IP Address", "");

	html_body_begin(client,"");
	{
		char value[81];
		value[0] = '\0';
		fd = open("/jffs2/ip", O_RDONLY);
		if(fd < 0)
		{
			sprintf(error_string2, "<font color=red>%n %s</font>", errno, strerror(errno) );
		}
		else
		{
			int len = read(fd, value, 80);
			value[len] = '\0';
			close(fd);
			fd = -1;
		}
		fputs(error_string, client);
		fputs("<br>\n", client);
		fputs(error_string2, client);
		fputs("<br>\n", client);
		html_form_begin( client, "/ip", "" );
		{
			fputs( "Enter the new address in the following order: IP_mask_broadcast_gateway_server ", client );
			fputs("<br>\n", client);
			html_form_input( client, "ip", "ip", value, "");
		}
		html_form_end(client);
	}
	html_body_end(client);

	html_end(client);

	return 1;
}

CYG_HTTPD_TABLE_ENTRY( net_test_ip,
                       "/ip",
                       net_test_ip_handler,
                       NULL );

