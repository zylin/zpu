
package com.zylin.zpu.simulator;

import com.zylin.zpu.simulator.exceptions.CPUException;

public interface Host
{
	/** generic file io error */
	public final static int  EIO =    5;
	
    public final static int  SYS_read=    4;
    public final static int  SYS_write=   5;
	public final static int  SYS_argv   = 13;
	public final static int SYS_exit=1;
	public final static int  SYS_open=    2;
	public final static int  SYS_close=   3;
	public final static int  SYS_lseek =  6;
	public final static int  SYS_unlink = 7;
	public final static int  SYS_getpid = 8;
	public final static int  SYS_kill  =  9;
	public final static int  SYS_fstat =      10;
	/*final static int  SYS_sbrk  11 - not currently a system call, but reserved.  */
	/* ARGV support.  */
	public final static int  SYS_argvlen= 12;
	/* These are extras added for one reason or another.  */
	public final static int  SYS_chdir  =  14;
	public final static int  SYS_stat   =  15;
	public final static int  SYS_chmod  =  16;
	public final static int  SYS_utime  =  17;
	public final static int  SYS_time   =  18;
	public final static int  SYS_gettimeofday =19;
	public final static int  SYS_times  =  20;
	public final static int  SYS_link   =  21;
	public final static int  SYS_ftruncate=3000;
	public final static int  SYS_isatty=3001;
    public void syscall(Sim s) throws CPUException;
    boolean doneContinue();
    public void writeUART(int val);
    public int readUART() throws CPUException;
    public int readFIFO();
    /** notification that the CPU is halted */
	public void halted();
	/** notification that the CPU is running */
	public void running();
    
}
