/*
 * Created on Nov 16, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package com.zylin.zpu.simulator.gdb;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.zylin.zpu.simulator.exceptions.BadPacketException;
import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.EndSessionException;
import com.zylin.zpu.simulator.exceptions.GDBServerException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;
import com.zylin.zpu.simulator.exceptions.NoAckException;
import com.zylin.zpu.simulator.exceptions.UnknownPacketException;


/** all packet related operations */
class Packet
{
	private final GDBServer server;
	
	Packet(GDBServer server)
	{
		this.server = server;
        reply=new StringBuffer();
	}
	
	void receive() throws IOException, GDBServerException, EndSessionException
	{
		int t;
		/* we spool until we see a $ */
		this.server.expect('$');
		
		StringBuffer packet=new StringBuffer();
	
		int cc=0;
		for (;;)
		{
			int t1;
			t1=this.server.read();
			t = t1;
			if (t==0x7d)
			{
				int t2;
				t2=this.server.read();
				/* the next char is escaped after a GDB specific scheme. See
				 * gdb/gdb/remote.c */
				t = t2;
				t^=0x20;
			} else
			{
				if (t=='#')
				{
					break;
				}
			}
			
			cc+=t;
			
			packet.append((char)t);
		}
		cc&=0xff;
		
		String checkSum;
		checkSum=""+(char)this.server.read()+(char)this.server.read();
		int readCheckSum;
		readCheckSum=Integer.parseInt(checkSum, 16);
		if (readCheckSum!=cc)
		{
			// error
			dumpHex(packet.toString());
			
			this.server.write("-".getBytes());
			throw new BadPacketException();
		} else
		{
			// ack
			this.server.write("+".getBytes());
		}
		
		cmd=packet.toString();
		this.server.print(GDBServer.PACKET, "Got " + number + ": #$" + cmd + "#" + checkSum); 
		origCmd=cmd;
	}
	
	void parseAndExecute() throws IOException, EndSessionException
	{
    	boolean silent=false;
	    try
		{
			if (checkPrefix("g"))
			{
				readRegisters();
			} else if (checkPrefix("?"))
			{
				querySignal();
			} else if (checkPrefix("s"))
			{
				doStep();
			} else if (checkPrefix("m"))
			{
				try
				{
					readMemory();
				} catch (CPUException e)
                {
                    silent=true; // happens all the time while hovering over variables in the GUI
                    throw e;
                }
			} else if (checkPrefix("c"))
			{
				continueExecution();
			} else if (checkPrefix("M"))
			{
				writeMemory();
			} else if (checkPrefix("z4"))
			{
				disableAccessWatchPoint();
			} else if (checkPrefix("Z4"))
			{
				enableAccessWatchPoint();
			} else if (checkPrefix("k"))
			{
				/* we must send a reply, but not wait for ack before we shut down
				   the connection.
				*/
			    server.alive=false;
			    reply("OK");
			} else
			{
				throw new UnknownPacketException();
			}
		} catch (UnknownPacketException e)
		{
			this.server.print(GDBServer.UNKNOWN, "Unknown packet: " + origCmd);
			// empty reply to unknown packets
		} catch (CPUException e)
        {
            if (!silent)
            {
                this.server.print(GDBServer.CPUEXCEPTION, "Exception handling GDB request");
                if (GDBServer.CPUEXCEPTION)
                {
                    e.printStackTrace();
                }
            }               
            reply("E01");
        } catch (GDBServerException e)
        {
            e.printStackTrace();
            reply("E01");
        }  catch (RuntimeException e)
		{
			e.printStackTrace();
			reply("E01");
		} 
	}

	private void checkEmpty() throws GDBServerException
	{
		if (cmd.length()>0)
		{
			throw new GDBServerException();
		}
	}
	private void dumpHex(String arrayList2)
	{
		for (int i=0; i<arrayList2.length(); i++)
		{
			System.out.println(this.server.formatHex(arrayList2.charAt(i), "00"));
		}
	}
	/**
	 * @param packetString
	 * @param string
	 * @return
	 */
	private boolean checkPrefix(String string)
	{
		if (cmd.length() < string.length())
		{
			return false;
		} else
		{
			return cmd.substring(0, string.length()).equals(string);
		}
	}
	/**
	 * @throws GDBServerException
	 * @throws MemoryAccessException
	 * 
	 */
	private void continueExecution() throws GDBServerException
	{
		extractString("c");
		try
		{
			if (!isEmpty())
			{
				int pc=extractInteger();
				this.server.simulator.setPc(pc);
			}
			checkEmpty();
			this.server.simulator.cont();
		} catch (MemoryAccessException e)
		{
			if (GDBServer.IGNOREDEXCEPTIONS)
			{
				e.printStackTrace();
			}
		}
		reply("S05");
	}
	private void doStep()
	{
		this.server.simulator.step();
		reply("S05");
	}
	protected int extractInteger() throws GDBServerException
	{
		String number;
		Pattern p=Pattern.compile("(\\-?[0-9a-fA-F]+)");
		Matcher m = p.matcher(cmd);
		if (!m.find())
		{
			throw new GDBServerException();
		}
		number=m.group();
		extractString(number);
		
		try
		{
			return (int)Long.parseLong(number, 16);
		} catch (NumberFormatException e)
		{
			throw new GDBServerException(e);
		}
	}
	/**
	 * @param string
	 * @throws GDBServerException
	 */
	private void extractString(String string) throws GDBServerException
	{
		if (!checkPrefix(string))
		{
			throw new GDBServerException();
		}
		stripStart(string.length());
	}
	/**
	 * @throws GDBServerException
	 * 
	 */
	private void readMemory() throws CPUException, GDBServerException
	{
		extractString("m");
		int address=extractInteger();
		extractString(",");
		int length=extractInteger();
		checkEmpty();
		
		for (int i=0; i<length; i++)
		{
			reply(this.server.formatHex(this.server.simulator.readByte(address+i), "00"));
		}
	}
	/**
	 * 
	 */
	private void readRegisters()  throws CPUException
	{
		for (int i=0; i<this.server.simulator.getREGNUM(); i++)
		{
			reply(this.server.printHex(this.server.simulator.getReg(i))); 
		}
	}
	private void writeMemory() throws GDBServerException, MemoryAccessException
	{
		extractString("M");
		int address=extractInteger();
		extractString(",");
		int length=extractInteger();
		extractString(":");
		
		for (int i=0; i<length; i++)
		{
			String t;
			t=cmd.substring(i*2, i*2+2);
			int val;
			val=Integer.parseInt(t, 16);
			this.server.simulator.writeByte(address+i, val);
		}
		reply("OK");
		
	}
	
	private void enableAccessWatchPoint() throws GDBServerException, CPUException 
	{
		extractString("Z4");
		extractString(",");
		int address=extractInteger();
		extractString(",");
		int length=extractInteger();
		checkEmpty();
		server.simulator.enableAccessWatchPoint(address, length);
		
		reply("OK");
	}

	private void disableAccessWatchPoint() throws GDBServerException, CPUException 
	{
		extractString("z4");
		extractString(",");
		int address=extractInteger();
		extractString(",");
		int length=extractInteger();
		checkEmpty();
		server.simulator.disableAccessWatchPoint(address, length);
		
		reply("OK");
	}

	
	private void stripStart(int length)
	{
		cmd=cmd.substring(length);
	}
	private boolean isEmpty() 
	{
		return cmd.length()==0;
	}
	/**
	 * @param string
	 */
	protected void reply(String string)
	{
		reply.append(string);
	}
	void sendReply() throws IOException, NoAckException
	{
		// a bit easier to debug if we can see the entire string.
		StringBuffer buffer = new StringBuffer();
		buffer.append("$");
		number++;
		String replyString = reply.toString();
		buffer.append(replyString);
		byte[] data = replyString.toString().getBytes();
		int csum = 0;
		for (int i = 0; i < data.length; i++)
		{
			csum += data[i];
		}
		csum &= 0xff;
		buffer.append("#");
		String t = Integer.toHexString(csum);
		if (t.length() == 1)
		{
			t = "0" + t;
		}
		buffer.append(t);
		this.server.print(GDBServer.REPLY, "Reply " + number + " : " + buffer.toString());
		this.server.write(buffer.toString().getBytes());
		
		if (server.alive)
		{
			/* check for ack. */
			int ack = (char)this.server.read();
			if (ack == '+')
			{
				return;
			}
			this.server.print(GDBServer.MINIMAL, "Retry");
			
			throw new NoAckException();
		}
	}
	
	private void querySignal()
	{
		// SIGINT
		//	reply("S02");
		reply("S05");
	}
	protected String cmd;
	private int number;
	private StringBuffer reply;
	private String origCmd;
    int syscallErrno;
    int syscallRetval;


    
    void invokeSyscall(String string, int argNum, String types) throws IOException, NoAckException, GDBServerException, EndSessionException, CPUException
    {
        string="F"+string;
        
        int j=0;
        for (int i=0; i<argNum; i++)
        {
            string+=",";
            string+=Integer.toHexString(server.getSyscallArg(j));
            j++;
            if (types.charAt(i)=='s')
            {
                string+="/" + Integer.toHexString(server.getSyscallArg(j));
                j++;
            }
        }

        reply(string);
        sendReply();
        for (;;)
        {
            Packet packet=new Packet(server);
            packet.receive();
            if (packet.checkPrefix("F"))
            {
                /* this is the reply we are waiting for */
                packet.extractString("F");
                syscallRetval=packet.extractInteger();
                syscallErrno=0;
                if (packet.checkPrefix(","))
                {
                    /* errno is optional */
                    packet.extractString(",");
                    syscallErrno = packet.extractInteger();
                }
                break;
            } else
            {
                /* something else... */
                try
                {
                    packet.parseAndExecute();
                    packet.sendReply();
                } catch (IOException e)
                {
                    e.printStackTrace();
                } catch (EndSessionException e)
                {
                    e.printStackTrace();
                } catch (RuntimeException e)
                {
                    e.printStackTrace();
                }
            }
        }
    }
}