
package com.zylin.zpu.simulator;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.LineNumberReader;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.GDBServerException;
import com.zylin.zpu.simulator.exceptions.TraceException;

public class FileTracer implements Tracer
{
    private LineNumberReader file;
    private boolean trigger;
    private boolean resync;
    private Simulator simulator;
    private String line;
    private boolean ignore;
    
    static class Trace
    {
    	int pc;
    	int opcode;
    	int sp;
    	int stackA;
    	int stackB;
    	int intSp;
    	long cycle;
		public boolean undefinedStackA;
		public boolean undefinedStackB;
		public boolean undefinedIntSp;
		public void print()
		{
			System.err.println(Integer.toHexString(pc)+ " " +
			       		Integer.toHexString(opcode) + " " +
			                Integer.toHexString(sp) + " " + 
			                Integer.toHexString(stackA) + " " + 
			                Integer.toHexString(stackB) + " " + 
			                intSp + " " +
			                cycle);
			
		}
    };
    private Trace[] trace= new Trace[100];
    private int current;
	private String fileName;
	private boolean metEnd;
    

    public FileTracer(Simulator sim, String string)
    {
        simulator=sim;
        fileName=string;

        resync=true;
       
        
        for (int i=0; i<trace.length; i++)
        {
        	trace[i]=new Trace();
        }
        findNextTrigger();
    }

    LineNumberReader getFile()
    {
    	if (file==null)
    	{
    		try
			{
				file=new LineNumberReader(new java.io.FileReader(fileName));
			} catch (FileNotFoundException e)
			{
				throw new RuntimeException(e);
			}
    	}
    	return file;
    }


    private void findNextTrigger() throws TraceException
    {
        trigger=false;
        try
        {
            for (;;)
            {
                line=getFile().readLine();
                if (line==null)
                {
                	metEnd=true;
                    System.err.println("================== End of trace file ======================");
                    break;
                }
                if (line.matches("^\\s*\\#.*$"))
                {
                    /* this was a comment*/
                    continue;
                }
                if (line.matches("^\\s*$"))
                {
                    /* all whitespace */
                    continue;
                }
                String[] val=line.split(" ");
                
                try
                {
                	Trace t=trace[current];
                    t.pc=(int) parseInt(val[0]);
                    t.opcode=(int) parseInt(val[1]);
                    t.sp=(int) parseInt(val[2]);
                    try
                    {
                    	t.undefinedStackA=false;
                    	t.stackA=(int) parseInt(val[3]);
                    } catch (NumberFormatException e)
                    {
                    	t.undefinedStackA=true;
                    	t.stackB=0;
                    }

                    try
                    {
                    	t.undefinedStackB=false;
                    	t.stackB=(int) parseInt(val[4]);
                    } catch (NumberFormatException e)
                    {
                    	t.undefinedStackB=true;
                    	t.stackB=0;
                    }
                    try
                    {
                    	t.undefinedIntSp=false;
                    	t.intSp=(int) parseInt(val[5]);
                    } catch (NumberFormatException e)
                    {
                    	t.undefinedIntSp=true;
                    	t.intSp=0;
                    }
                   	t.cycle=parseInt(val[6]);
                    trigger=true;
                    break;
                } catch (NumberFormatException e)
                {
                    /* skip this line. */
                    e.printStackTrace();
                }
            }
        } catch (IOException e)
        {
            throw new TraceException(e);
        } 
        
    }

    private long parseInt(String string2) throws TraceException
    {
        String string = string2;
        if (!string.startsWith("0x"))
        {
            throw new TraceException(new Exception("Trace file pasing error line " + getFile().getLineNumber()));
        }
        return Long.parseLong(string.substring(2), 16);
    }

    public void instructionEvent() throws GDBServerException
    {
    	if (metEnd)
    	{
    		metEnd=false;
    		throw new TraceException();
    	}
        if (resync&&trigger)
        {
            if (match())
            {
                /* we have to wait for the first instruction in the trace to be matched */
            	System.out.println("First matching instruction found!");
                resync=false;
            }
        } 

        if (!resync&&trigger)
        {
        	
            boolean m=match();
            recordCurrent();
            current=(current+1)%trace.length;

            if (!m)
            {
                System.err.println("Trace file mismatch");
                dumpTraceBack();
                System.err.print("Expected by Java simulator: \n");
                simulator.printState(this);
                System.err.print("Actual from ModelSim: ");
                System.err.println(line);
                // we now have to ignore this match.
                ignore=true;
                throw new TraceException();
            }
        } else
        {
            recordCurrent();
            current=(current+1)%trace.length;
        }
    }

	public void dumpTraceBack()
	{
		System.err.println("Expected");
		System.err.println("PC SP topOfStack");
		for (int i=0; i<trace.length; i++)
		{
		    trace[(i+current)%trace.length].print();
		}
	}

	private void recordCurrent()
    {
        recordState(trace[current]);
    }

	private void recordState(Trace trace3)
	{
		trace3.pc=simulator.getPc();
        trace3.sp=simulator.getSp();
        trace3.opcode=simulator.getOpcode();
        try
        {
            trace3.stackA=simulator.cpuReadLong(simulator.getSp());
            trace3.stackB=simulator.cpuReadLong(simulator.getSp()+4);
            trace3.intSp=simulator.getIntSp();
           // trace[current].cycle=expectetdCycle();
        } catch (CPUException e1)
        {
            e1.printStackTrace();
        }
	}

   
    
    boolean match() throws GDBServerException
    {
        if (ignore)
            return true;
        
        return simulator.checkMatch(trace[current]);
    }

	public void commit()
    {
        try
        {
            if (!resync&&trigger)
            {
                ignore=false;
                findNextTrigger();
            }
        } 
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }

    public void setSp(int sp)
    {
    }

	public boolean onInterrupt()
	{
		if (trace[current].pc==0x20)
			return true;
		else
			return false;
	}

	public boolean simInterrupt()
	{
		return true;
	}
}
