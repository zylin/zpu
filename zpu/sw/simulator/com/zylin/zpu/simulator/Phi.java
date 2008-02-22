
package com.zylin.zpu.simulator;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;

public class Phi extends Simulator
{
	@Override
	protected long getSampleOffset()
	{
		 
		return super.getSampleOffset()-(0x5e7b2-0x0005E7C0);
	}


	public static void main(String[] args)
	{
        new SimApp(new SimFactory()
        {
        	public Simulator create()
        	{
        		return new Phi();
        	}
        }).run(args);
	}
    

    protected int getIO()
    {
        return 0x08000000;
    }



    protected int ioRead(int addr) throws CPUException
    {
        switch (addr)
        {
        
        case 0x080a0020:
        	return interrupt?0:1; // interrupt mask

        	
        
            /* FIFO empty? bit 0, FIFO full bit 1(never the case) */
            case 0x080a000c:
            	return 0x100; // buffer ready. 
                
            case 0x080a0014:
            case 0x080a0018:
            return readSampledTimer(addr, 0x080a0014);

            case 0x080a0030:
            	return timerPending?1:0;
            case 0x080a0038:
            	return (int)(timerInterval-1-((cycles-lastTimer)%timerInterval));

            
        	default:
        		throw new MemoryAccessException();
        }
    }



    protected void ioWrite(int addr, int val) throws MemoryAccessException
    {
        switch (addr)
        {
        case 0x080a0020:
        	interrupt=(val&1)==0;
        	return;
        case 0x080a002c:
        	timer=(val&0x1)!=0;
        	break;
        case 0x080a0030:
        	if ((val&0x1)!=0)
        	{
        		timerPending=false;
        	}
        	if ((val&0x2)!=0)
        	{
        		lastTimer=cycles;
        	}
        	break;
        case 0x080a0034:
        	timerInterval=val;
        	return;
        	
            case 0x080a0014:
                writeTimerSampleReg(val);
            case 0x080a000c:
                syscall.writeUART(val);
                break;
        	default:
                throw new MemoryAccessException();
        }
    }

    public Phi() throws CPUException
    {
    }

    protected boolean emulateConfig()
    {
        return true;
    }

    protected int getStartStack()
    {
        return getRAMSIZE()-8;
    }

    protected int getRAMSIZE()
    {
        return 32*1024*1024;
    }


	protected int getIOSIZE()
	{
		return 0x100000;
	}

}
