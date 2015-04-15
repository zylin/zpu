/** 
 * Handles TCP/IP communication between simulator and GDB
 */

package com.zylin.zpu.simulator.gdb;

import java.io.IOException;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.util.Iterator;

import com.zylin.zpu.simulator.Host;
import com.zylin.zpu.simulator.Sim;
import com.zylin.zpu.simulator.SimApp;
import com.zylin.zpu.simulator.exceptions.BadPacketException;
import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.EndSessionException;
import com.zylin.zpu.simulator.exceptions.GDBServerException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;
import com.zylin.zpu.simulator.exceptions.UnsupportedSyscallException;

public class GDBServer implements Host 
{
	/* logging filter */
	static final boolean UNKNOWN=false;
	static final boolean ALL=false;
	static final boolean CPUEXCEPTION = false;
	static protected boolean MINIMAL=true;
	static boolean PACKET=true;
	static boolean REPLY=true;
	static protected boolean IGNOREDEXCEPTIONS=false;
	
	
	
	protected Throwable packetException;
	protected Object packetReady=new Object();
	private Packet packet;
	boolean done;
	private Socket sc;
    public boolean alive;
    static private int sessionNr;
	private SimApp app;
    Sim simulator;
    
    public GDBServer(Sim simulator, SimApp app)
    {
        this.simulator=simulator;
    	this.app=app;
    }
    
	void print(boolean filter, String str)
	{
		if (filter)
		{
			System.out.println(str);
		}
	}
	
	/** infinite loop that waits for debug sessions to be initiated via TCP/IP */
	public void gdbServer() throws MemoryAccessException, IOException, GDBServerException, EndSessionException 
	{
		sc=app.serverSocket.accept();
		try
		{
			debugSession();
		} catch (IOException e)
		{
			// the session failed...
			if (IGNOREDEXCEPTIONS)
			{
				e.printStackTrace();
			}
		} catch (GDBServerException e)
		{
			// connect failed...
			if (IGNOREDEXCEPTIONS)
			{
				e.printStackTrace();
			}
		} catch (EndSessionException e)
		{
		} catch (Throwable e)
		{
			// some terrible unforseen failure.
			e.printStackTrace();
		} finally
		{
			sc.close();
		}
	}


	
	protected void sleepABit()
	{
		try
		{
			// just to avoid locking up the machine in a busy loop when
			// debugging the Simulator
			Thread.sleep(2000);
		} catch (InterruptedException e1)
		{
			e1.printStackTrace();
		}
	}

	private void debugSession() throws IOException, GDBServerException, EndSessionException, MemoryAccessException 
	{
		print(MINIMAL, "GDB server waiting for connection " + sessionNr++ + "...");

        try
        {
            sessionStarted();

            expect('+'); // connection ack.

            sessionLoop();
        } finally
        {
			print(MINIMAL, "Session ended");
        }
            
	}

	private void sessionStarted()
	{
		simulator.sessionStarted();
		print(MINIMAL, "Session started");
	}

	
	private void sessionLoop() throws IOException, EndSessionException
	{
		alive=true;
		while (alive)
		{
			try
			{
				/* wait for new packet to arrive and notify the packet execution thread... */
				packet=new Packet(this);
				packet.receive();
		
				// During execution we can receive an abort/suspend command...
				packet.parseAndExecute();
				
				if (!alive)
				    throw new EndSessionException();
			} catch (BadPacketException e)
			{
				// do nothing.
				if (IGNOREDEXCEPTIONS)
				{
					e.printStackTrace();
				}
				sleepABit();
			} catch (GDBServerException e)
			{
				if (IGNOREDEXCEPTIONS)
				{
					e.printStackTrace();
				}
				// continue processing packets
				sleepABit();
			}
		}
	}


	

	void expect(char nextChar) throws IOException, GDBServerException
	{
		int t = read();
		if (t!=nextChar)
		{
			throw new BadPacketException();
		}
	}

	int read() throws IOException
	{
		flush();
		int t=sc.getInputStream().read();
		if (t==-1)
			throw new IOException();
		return t;
	}

	/**
	 * @param value
	 * @return
	 */
	protected String printHex(int value)
	{
		return formatHex(value, "00000000");
	}

	/**
	 * @param value
	 * @param pad TODO
	 * @return
	 */
	protected String formatHex(int value, String pad)
	{
		String t=Integer.toHexString(value);
		if (t.length()>pad.length())
		{
			t=t.substring(0, pad.length());
		}
		return pad.substring(0, pad.length()-t.length())+t;
	}

	public void write(byte[] bytes) throws IOException
	{
		sc.getOutputStream().write(bytes);
	}

	void flush() throws IOException 
	{
		sc.getOutputStream().flush();
	}

    
    private boolean enterSyscall;


    
    /* handle all sorts of IO calls, etc. by sending them to the
     */
    public void syscall(Sim s) throws CPUException
    {
        simulator.suspend();
        enterSyscall=true;
    }


    protected void performSyscall() 
    {
        enterSyscall=false;
        try
        {
            int id;
            id=simulator.getArg(1);
            Packet syscall;
            syscall=new Packet(this);
            switch (id)
            {
            case Host.SYS_write:
                syscall.invokeSyscall("write", 3, "iii");
                break;
            case Host.SYS_read:
                syscall.invokeSyscall("read", 3, "iii");
                break;
            case Host.SYS_lseek:
                syscall.invokeSyscall("lseek", 3, "iii");
                break;
            case Host.SYS_open:
                syscall.invokeSyscall("open", 3, "sii");
                break;
            case Host.SYS_close:
                syscall.invokeSyscall("close", 1, "i");
                break;
            case Host.SYS_fstat:
                syscall.invokeSyscall("fstat", 2, "ii");
                break;
            case Host.SYS_stat:
                syscall.invokeSyscall("stat", 2, "si");
                break;
            case Host.SYS_isatty:
                syscall.invokeSyscall("isatty", 1, "i");
                break;
            case Host.SYS_unlink:
                syscall.invokeSyscall("unlink", 1, "s");
                break;
            default:
                simulator.suspend();
                throw new UnsupportedSyscallException();
            }
            simulator.cpuWriteLong(simulator.getArg(0), syscall.syscallErrno);
            simulator.cpuWriteLong(0, syscall.syscallRetval);
        } catch (CPUException e)
        {
            e.printStackTrace();
        } catch (IOException e)
        {
            e.printStackTrace();
        } catch (GDBServerException e)
        {
            e.printStackTrace();
        } catch (EndSessionException e)
        {
            e.printStackTrace();
        }
    }
    
    public boolean doneContinue()
    {
        if (!enterSyscall)
            return true;
        performSyscall();
        return false;
    }
    
    public int getSyscallArg(int i) throws CPUException
    {
        return simulator.getArg(i+2);
    }

    public void writeUART(int val)
    {
        System.out.print((char)val);
        System.out.flush();
        

        Packet p=new Packet(this);
        p.reply("O" + formatHex(val, "00"));
        p.sendReply();
        
        
    }
    public int readUART() throws CPUException
    {
        try
        {
            if (System.in.available()<=0)
            {
                throw new MemoryAccessException();
            }
            
            return System.in.read();
        } catch (IOException e)
        {
            e.printStackTrace();
        }
        return 0;
    }

    public int readFIFO()
    {
        try
        {
            return System.in.available()>0?0:1;
        } catch (IOException e)
        {
            e.printStackTrace();
        }
        return 1;
    }

	public void halted()
	{
		// TODO Auto-generated method stub
		
	}

	public void running()
	{
		// TODO Auto-generated method stub
		
	}
}
