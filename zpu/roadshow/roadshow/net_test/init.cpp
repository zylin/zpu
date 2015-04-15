#include <pkgconf/system.h>
#include <pkgconf/isoinfra.h>
#include <cyg/infra/diag.h> 
#include <cyg/io/file.h>

#if 0
externC int chdir(const char *);

/* ================================================================= */
/* Initialization object
 */

class NetTestInit
{
public:
    NetTestInit();
};

/* ----------------------------------------------------------------- */
/* Static initialization object instance. The constructor is
 * prioritized to run after any filesystem constructors.
 */
static NetTestInit netTestInitializer CYGBLD_ATTRIB_INIT_PRI(CYG_INIT_IO_FS + 1);

/* ----------------------------------------------------------------- */
/* Constructor, mounts the file system
 */

NetTestInit::NetTestInit()
{
	int err = 0;
	err = mount( "/dev/flash1", "/jffs2", "jffs2" );
	if(err < 0)
	{
		diag_printf("unable to mount jffs\n");
	}
	else
	{
		diag_printf("mounted jffs\n");
	}
	err = mount( "", "/ramfs", "ramfs" );
	if(err < 0)
	{
		diag_printf("unable to mount ramfs\n");
	}
	else
	{
		diag_printf("mounted ramfs\n");
	}
	chdir( "/ramfs" );
}
#endif
