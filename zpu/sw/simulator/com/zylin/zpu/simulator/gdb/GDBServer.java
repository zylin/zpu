/** 
 * Handles TCP/IP communication between simulator and GDB
 */

package com.zylin.zpu.simulator.gdb;

import java.io.IOException;
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
	static final boolean UNKNOWN=false;
	static final boolean ALL=false;
	static final boolean CPUEXCEPTION = false;
	static protected boolean MINIMAL=true;
	static boolean PACKET=false;
	static boolean REPLY=false;
	static protected boolean IGNOREDEXCEPTIONS=false;
	protected Throwable packetException;
	protected Object packetReady=new Object();
	private Packet packet;
	boolean done;
	private Thread asyncMessage;
	private Object listenBreak=new Object();
	private boolean listenForBreak;
	private boolean sleeping;
	private ByteBuffer readBuffer;
	private ByteBuffer writeBuffer;
	private SocketChannel sc;
	private Selector selectorRead;
	private Selector selectorWrite;
    public boolean alive;
    static private int sessionNr;
	private SimApp app;
	private boolean stopAsyncMessage;
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
		try
		{
			asyncMessage = new Thread(new Runnable()
			{
				public void run()
				{
					asyncMessage();
				}
			});
			asyncMessage.start();
			try
			{
				readBuffer = ByteBuffer.allocate(1);
				writeBuffer = ByteBuffer.allocate(128);
				debugSession();
			}
			finally
			{
				/* tell it to stop waiting for break chars and wake up the thread */
				stopAsyncMessage = true;
				synchronized(listenBreak)
				{
					listenBreak.notify();
				}
				
				try
				{
					asyncMessage.join();
				} catch (InterruptedException e3)
				{
					e3.printStackTrace();
				}
			}
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
		}
	}

	/**
	 * We have to wait for break, but as soon as the main thread wants to wait
	 * for packets again, we have to stop waiting for a break.
	 * 
	 * Tricky....
	 */
	private void asyncMessage()
	{
		for (;;)
		{
			synchronized(listenBreak)
			{
				if (stopAsyncMessage)
				{
					/* shutting down */
					return;
				}
				try
				{
					sleeping=true;
					listenBreak.notify();
					
					listenBreak.wait();
					sleeping=false;
					listenBreak.notify();
				} catch (InterruptedException e)
				{
					e.printStackTrace();
				}
				if (stopAsyncMessage)
				{
					/* shutting down */
					return;
				}
			}
			
			while (listenForBreak)
			{
				try
				{
					if (waitSelect(selectorRead, true))
					{
						int t = read();
						if (t == 0x03)
						{
							// We received a ctrl-c while processing a package,
							// this
							// would be a suspend
							simulator.suspend();
						} else
						{
							// ignore garbage. Shouldn't happen.
						}
					} else
					{
						// we've been awoken since we're ready to send 
						// the reply to the package...
//						int x=0;
					}
				} catch (IOException e)
				{
					// Perfectly normal. This would happen if the connection
					// is terminated.
				}
			}
		}
	}

	/** wait for read/write ready */
	private boolean waitSelect(Selector selector, boolean read) throws IOException
	{
		boolean gotit=false;
		
		selector.select(1000);
		if (!sc.isOpen())
		{
			throw new IOException("Channel closed");
		}
		if (!sc.isConnected())
		{
			throw new IOException("Channel not connected");
		}

		// Get list of selection keys with pending events
		Iterator it = selector.selectedKeys().iterator();
		// Process each key at a time
		while (it.hasNext())
		{
			// Get the selection key
			SelectionKey selKey = (SelectionKey) it.next();
			// Remove it from the list to indicate that it is being
			// processed
			it.remove();
			if (selKey.isValid() && 
					((read && selKey.isReadable()) || (!read && selKey.isWritable())))
			{
				gotit=true;
			}
			
		}
		return gotit;
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

		writeBuffer.clear();
		readBuffer.clear();


        selectorRead = Selector.open();
        try
        {
            selectorWrite = Selector.open();
            try
            {
				sc = app.channel.accept();
		        try
		        {
		        	sc.socket().setKeepAlive(true);
		            sc.configureBlocking(false);
		            sc.register(selectorRead, SelectionKey.OP_READ);
		            sc.register(selectorWrite, SelectionKey.OP_WRITE);
		
		            sessionStarted();
		
		            expect('+'); // connection ack.
		
		            sessionLoop();
		        } finally
		        {
		            sc.close();
		            
					print(MINIMAL, "Session ended");
		        }
            } finally
            {
                selectorWrite.close();
            }
        } finally
        {
            selectorRead.close();
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
		
				enterListenForCtrlC();
                
				try
				{
					// During execution we can receive an abort/suspend command...
					packet.parseAndExecute();
				} 
				finally
				{
					leaveListenForCtrlC();
				}
                
				packet.sendReply();
				
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

    private void enterListenForCtrlC()
    {
        setBreakListen(true);
    }

    private void leaveListenForCtrlC()
    {
        /* we don't want to wait for the select to time out as that would make
         * the protocol excruciatingly slow */
        setBreakListen(false);
        selectorRead.wakeup();
        synchronized(listenBreak)
        {
        	try
        	{
        		while (!sleeping)
        		{
        			listenBreak.notify();
        			listenBreak.wait();
        		}
        	} catch (InterruptedException e)
        	{
        		e.printStackTrace();
        	}
        }
    }

	private void setBreakListen(boolean state)
	{
		synchronized(listenBreak)
		{
			listenForBreak=state;
			listenBreak.notify();
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
		readBuffer.clear();
		for (;;)
		{
			int n;
			n = sc.read(readBuffer);
			if (n == 1)
			{
				break;
			}
			while (!waitSelect(selectorRead, true));
		}
		readBuffer.flip();
		int t = readBuffer.get(0);
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
		int i=0;
		while (i<bytes.length)
		{
			int len;
			
			while ((len=Math.min(bytes.length-i, writeBuffer.capacity()-writeBuffer.position()))==0)
			{
				flush();
			}
			
			writeBuffer.put(bytes, i, len);
			
			i+=len;
		}
	}

	void flush() throws IOException 
	{
		if (writeBuffer.position()>0)
		{
			writeBuffer.flip();
			int len=writeBuffer.limit();
	
			int j=0;
			while (j<len)
			{
				int t=sc.write(writeBuffer);
				
				if (t==0)
				{
					while (!waitSelect(selectorWrite, false));
				}
				j+=t;
			}
			writeBuffer.clear();
		}		
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
        leaveListenForCtrlC();
        try
        {
            performSyscall();
        } finally
        {
            enterListenForCtrlC();
        }
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
