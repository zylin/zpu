package com.zylin.zpu.simulator;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import com.zylin.zpu.simulator.FileTracer.Trace;
import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.DebuggerBreakpointException;
import com.zylin.zpu.simulator.exceptions.EndSessionException;
import com.zylin.zpu.simulator.exceptions.GDBServerException;
import com.zylin.zpu.simulator.exceptions.HardwareWatchPointException;
import com.zylin.zpu.simulator.exceptions.IllegalInstructionException;
import com.zylin.zpu.simulator.exceptions.InterruptException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;

public class Simulator implements ZPU, Machine, Sim 
{
	
    int minStack;

    /** 
	 * the feeble version of the CPU, e.g. only implements
	 * 11 instructions. 
     * 
     * For debugging purposes it is useful to enable/disable
     * each instruction
	 */
    boolean feeble[]=new boolean[256];
	    
	private long opcodeHistogram[]=new long[256];
	private long opcodeHistogramCycles[]=new long[256];
	private long opcodePairHistogram[]=new long[256*256];
	private long opcodePairHistogramCycles[]=new long[256*256];
	
	/** weee! constants are 32 bit by default, so we need to assign a 64 bit
	 * integer in this matter.
	 */
	private static final long INTMASK = Long.parseLong("ffffffff", 16);
	
    final static int PUSHPC=59;
	final static int OR=7;
	final static int NOT=9;
	final static int LOAD=8;
	final static int STORE=12;
	final static int POPPC=4;
	final static int FLIP=10;

	final static int ADD=5;
	final static int PUSHSP=2;
	final static int POPSP=13;
	final static int NOP=11;
	final static int AND=6;
	final static int ADDSP=16;

    final static int EMULATE=32;
	final static int LOADH=34;
	final static int STOREH=35;
	final static int LESSTHAN=36;
	final static int LESSTHANOREQUAL=37;
	final static int ULESSTHAN=38;
	final static int ULESSTHANOREQUAL=39;
    final static int SWAP=40;
    final static int MULT=41;
	final static int LSHIFTRIGHT=42;
	final static int ASHIFTLEFT=43;
    final static int ASHIFTRIGHT=44;
    final static int CALL=45;
    final static int EQ=46;
	final static int NEQ=47;
    final static int NEG=48;
    final static int SUB=49;
	final static int XOR=50;
    final static int LOADB=51;
    final static int STOREB=52;
    final static int DIV=53;
    final static int MOD=54;
    final static int EQBRANCH=55;
    final static int NEQBRANCH=56;
    final static int POPPCREL=57;
    final static int CONFIG=58;
    final static int SYSCALL=60;
    final static int PUSHSPADD=61;
    final static int MULT16X16=62;
    final static int CALLPCREL=63;
    final static int STORESP=64;
    final static int LOADSP=64+32;
        
	int[] memory;
	boolean[] validMemory;
	protected long cycles;
	protected int instructionCount;
	private int sp;
	private int pc;
	protected boolean breakNext;
	
	/* halting synchronization object */
	protected Object halt = new Object();
	
	private int IOSIZE=getIOSIZE();
	protected int getIOSIZE()
	{
		return 32768;
	}
	long prevCycles;
	private static final int VECTORSIZE = 0x20;
	private static final int VECTOR_RESET = 0;
	private static final int VECTOR_INTERRUPT = 1;
	private boolean hitVector;
	private static final int VECTORBASE = 0x0;
	private int nextVector;
	protected long lastTimer;
	protected boolean timer;
	private boolean powerdown;
    private boolean decodeMask;

    private static final int ZETA = 1;

    private static final int ABEL = 0;

    private int startStack;

    protected Host syscall;

	private long[] emulateOpcodeHistogram= new long[256];

	private long[] emulateOpcodeHistogramCycles=new long[256];

	private long emulateCycles;;

	public Simulator() throws CPUException
	{
	}
	
	
	public void run() throws CPUException
	{
		syscall.running();
		
		try
		{
            
			instructionLoop();
			
			
		}  catch (EndSessionException e)
		{
			/* done */
		} finally
		{
		}
		dumpInfo();
        
        System.err.println("Stack usage: " + (startStack-minStack));
	}

	private void dumpInfo() 
	{
		dumpOpcodeHistogram();
        
		//printMemoryHistorgram();
	}


    private void dumpOpcodeHistogram()
    {
        System.out.println("Opcode histogram");
        dumpHistogram(opcodeHistogram, opcodeHistogramCycles);
        System.out.println("Emulate histogram");
        dumpHistogram(emulateOpcodeHistogram, emulateOpcodeHistogramCycles);
        System.out.println("Pair histogram");
        dumpHistogram(opcodePairHistogram, opcodePairHistogramCycles);
        
        
        dumpGmon();
        
        System.out.println("Grouping of LOADSP/STORESP/IM");
        printRange(64, 96);
        printRange(96, 128);
        printRange(128, 256);
//      printRange(64, 65);
//        printRange(65, 66);
//        printRange(66, 64+32);
//        printRange(96, 97);
//        printRange(97, 98);
//        printRange(98, 96+32);
//        printRange(128, 129);
//        printRange(129, 130);
//        printRange(130, 131);
//        printRange(131, 132);
//        printRange(132, 133);
//        printRange(252, 253);
//        printRange(253, 254);
//        printRange(254, 255);
//        printRange(255, 256);
    }



//    #define	GMON_MAGIC	"gmon"	/* magic cookie */
//    #define GMON_VERSION	1	/* version number */
//
//    /*
//     * Raw header as it appears on file (without padding):
//     */
//    struct gmon_hdr
//    {
//        char cookie[4];
//        char version[4];    // a cyg_uint32, target-side endianness
//        char spare[3 * 4];
//    };
//
//    /* types of records in this file: */
//    typedef enum
//    {
//        GMON_TAG_TIME_HIST = 0, GMON_TAG_CG_ARC = 1, GMON_TAG_BB_COUNT = 2
//    }
//    GMON_Record_Tag;
//
//    /* The histogram tag is followed by this header, and then an array of       */
//    /* cyg_uint16's for the actual counts.                                      */
//
//    struct gmon_hist_hdr
//    {
//        /* host-side gprof adapts to sizeof(void*) and endianness.              */
//        /* It is assumed that the compiler does not insert padding around the   */
//        /* cyg_uint32's or the char arrays.                                     */
//        void*       low_pc;             /* base pc address of sample buffer     */
//        void*       high_pc;            /* max pc address of sampled buffer     */
//        cyg_uint32  hist_size;          /* size of sample buffer                */
//        cyg_uint32  prof_rate;          /* profiling clock rate                 */
//        char        dimen[15];			/* phys. dim., usually "seconds"        */
//        char        dimen_abbrev;		/* usually 's' for "seconds"            */
//    };
//
//    /* An arc tag is followed by a single arc record. self_pc corresponds to    */
//    /* the location of an mcount() call, at the start of a function. from_pc    */
//    /* corresponds to the return address, i.e. where the function was called    */
//    /* from. count is the number of calls.                                      */
//
//    struct gmon_cg_arc_record
//    {
//        void*       from_pc;            /* address within caller's body         */
//        void*       self_pc;        	/* address within callee's body         */
//        cyg_uint32  count;              /* number of arc traversals             */
//    };
//
//    /* In theory gprof can also process basic block counts, as per the          */
//    /* compiler's -fprofile-arcs flag. The compiler-generated basic block       */
//    /* structure should contain a table of addresses and a table of counts,     */
//    /* and the compiled code updates those counts. Current versions of the      */
//    /* compiler (~3.2.1) do not output the table of addresses, and without      */
//    /* that table gprof cannot process the counts. Possibly gprof should read   */
//    /* in the .bb and .bbg files generated for gcov processing, but that does   */
//    /* not happen at the moment.                                                */
//    /*                                                                          */
//    /* So for now gmon.out does not contain basic block counts and gprof        */
//    /* operations that depend on it, e.g. --annotated-source, won't work.       */
    
    /**
     * Write gmon.out file.
     **/
	private void dumpGmon()
	{
		if (memory==null)
			return;
		try
		{
		ByteArrayOutputStream b=new ByteArrayOutputStream();
		

//	    /*
//	     * Raw header as it appears on file (without padding):
//	     */
//	    struct gmon_hdr
//	    {
//	        char cookie[4];
//	        char version[4];    // a cyg_uint32, target-side endianness
//	        char spare[3 * 4];
//	    };
//	    #define	GMON_MAGIC	"gmon"	/* magic cookie */
//	    #define GMON_VERSION	1	/* version number */

//		   dump   binary memory gmon.out &profile_gmon_hdr ((char*)&profile_gmon_hdr + sizeof(struct gmon_hdr))
			b.write("gmon".getBytes());
			writeLong(b, 1); // version
			b.write(new byte[3*4]); // spare
			
//		    GMON_TAG_TIME_HIST = 0, GMON_TAG_CG_ARC = 1, GMON_TAG_BB_COUNT = 2

//			   append binary memory gmon.out &profile_tags[0] &profile_tags[1]
			b.write(new byte[]{0}); // GMON_TAG_TIME_HIST 


//			
//		    // The gprof documentation claims that this should be the size in
//		    // bytes. The implementation treats it as a count.
//		    profile_hist_hdr.hist_size  = (cyg_uint32) ((text_size + bucket_size - 1) / bucket_size);
//		    profile_hist_hdr.low_pc     = _start;
//		    profile_hist_hdr.high_pc    = (void*)((cyg_uint8*)_end - 1);
//		    // The prof_rate is the frequency in hz. The resolution argument is
//		    // an interval in microseconds.
//		    profile_hist_hdr.prof_rate  = 1000000 / resolution;
//		        
//		    // Now allocate a buffer for the histogram data.
//		    profile_hist_data = (cyg_uint16*) malloc(profile_hist_hdr.hist_size * sizeof(cyg_uint16));
//		    if ((cyg_uint16*)0 == profile_hist_data) {
//		        diag_printf("profile_on(): cannot allocate histogram buffer - ignored\n");
//		        return;
//		    }
//		    memset(profile_hist_data, 0, profile_hist_hdr.hist_size * sizeof(cyg_uint16));
			

			
//		    struct gmon_hist_hdr
//		    {
//		        /* host-side gprof adapts to sizeof(void*) and endianness.              */
//		        /* It is assumed that the compiler does not insert padding around the   */
//		        /* cyg_uint32's or the char arrays.                                     */
//		        void*       low_pc;             /* base pc address of sample buffer     */
//		        void*       high_pc;            /* max pc address of sampled buffer     */
//		        cyg_uint32  hist_size;          /* size of sample buffer                */
//		        cyg_uint32  prof_rate;          /* profiling clock rate                 */
//		        char        dimen[15];			/* phys. dim., usually "seconds"        */
//		        char        dimen_abbrev;		/* usually 's' for "seconds"            */
//		    };
			

			// maximum 65536 buckets.
			int length=memory.length*4;
			if (length > 60000)
			{
				length=60000;
			}
			int buckets[]=new int[length];
			for (long i=0; i<profile.length;i++)
			{
				buckets[(int)((i*(((long)buckets.length)-1))/(((long)profile.length)-1))]+=profile[(int)i];
			}
			
			
			
			//			   append binary memory gmon.out &profile_hist_hdr ((char*)&profile_hist_hdr + sizeof(struct gmon_hist_hdr))
			writeLong(b, 0); 					// low_pc
			writeLong(b, memory.length*4);		// high_pc
			writeLong(b, buckets.length);		// # of samples
			writeLong(b, 64000000); 			// 64MHz
			b.write("seconds".getBytes());
			b.write(new byte[15-"seconds".length()]);
			b.write("s".getBytes());
			
			
			
//			   append binary memory gmon.out profile_hist_data (profile_hist_data + profile_hist_hdr.hist_size)
			for (int i=0; i<buckets.length;i++)
			{
				int val;
				val=buckets[i];
				if (val>65535)
				{
					val=65535;
				}
				writeShort(b, val);
			}
			
			OutputStream o=new FileOutputStream("gmon.out");
			b.writeTo(o);
			o.flush();
			o.close();
			
		} catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

		
	}


	private void writeLong(ByteArrayOutputStream b, int i) throws IOException
	{
		int val=i;
		b.write(new byte[]{(byte)((val>>24)&0xff),
				(byte)((val>>16)&0xff),
				(byte)((val>>8)&0xff),
				(byte)((val>>0)&0xff)});
	}


	private void writeShort(ByteArrayOutputStream b, int i) throws IOException
	{
		int val=i;
		b.write(new byte[]{	(byte)((val>>8)&0xff),
				(byte)((val>>0)&0xff)});
	}


	private void dumpHistogram(long[] ms, long[] ms2)
	{
		List<OpcodeSample> l=new LinkedList();
        
        totalCycles = 0;
		for (int i=0; i<256; i++)
		{
			totalCycles+=opcodeHistogramCycles[i];
		}
		for (int i=0; i<ms.length; i++)
		{
			final int j=i;
			l.add(new OpcodeSample(j, ms2[j]));
		}
        Collections.sort(l, new Comparator()
        {

			public int compare(Object arg0, Object arg1)
			{
				OpcodeSample a=(OpcodeSample) arg0, b=(OpcodeSample) arg1;
				if (a.count<b.count)
				{
					return 1;
				} else if (a.count==b.count)
				{
					return 0;
				} else
				{
					return -1;
				}
			}
        });
        
        for (int i=0; i<ms.length; i++)
		{
        	if (totalCycles==0)
        		break;
			double d = ((double)l.get(i).count/((double)totalCycles));
			if (d<0.005)
				break;
			double cycPerIns = ((double)ms2[l.get(i).j]/((double)ms[l.get(i).j]));
			System.out.println("0x"+ Integer.toHexString(l.get(i).j) + " " + d + " " + l.get(i).count + " " + cycPerIns );
		}
	}


    private void printRange(int from, int to)
    {
        int totalLoadSP=0;
        for (int i=from; i<to; i++)
        {
            totalLoadSP+=opcodeHistogram[i];
        }
        
 		double d = ((double)totalLoadSP/((double)totalCycles));
         
        System.out.println(""+ from + " " + d + " " + totalLoadSP);
    }


//    private void printMemoryHistorgram()
//    {
//        Arrays.sort(profile, new Comparator()
//                {
//                    public int compare(Object o1, Object o2)
//                    {
//                        return (int)(((Profile)o2).counter-
//                                ((Profile)o1).counter);
//                    }
//                });
//        System.err.println("Profiling information");
//        for (int i=0; i<1000; i++)
//        {
//            if (profile[i].counter==0)
//            {
//                break;
//            }
//            System.err.println("0x"+Integer.toHexString(profile[i].address)+ " " + profile[i].counter);
//        }
//    }


	/**
	 * notify everybody that we are powering down
	 */
	public void shutdown()
	{
		powerdown=true;
		/* wake up */
		synchronized(halt)
		{
			halt.notify();
		}
	}


	/**
	 * This method can be invoked in two cases:
	 * 
	 * a) while the CPU is running on the simulator thread
	 * b) while the CPU is halted from other threads
	 */
	protected void resetHardwareInternal() throws CPUException
	{
		interrupt=false;
		timer=false;
		lastTimer=0;
		hitVector=false;
		instructionCount=0;
		for (int i=0; i<memory.length; i++)
        {
        	memory[i]=0;
        }
		
		setPcToVector(VECTOR_RESET); // starting address
        startStack=getStartStack();
        minStack=startStack;
		changeSp(startStack);
		
        intSp=0;

	}


	private void instructionLoop() throws EndSessionException, CPUException
	{
        /* wait for connection.... */
        for (;;)
        {
            try
            {

                /*
                 * execute an instruction.
                 * 
                 * If an exception happens while executing the instruction,
                 * invoke the approperiate exception vector.
                 * 
                 * If a second exception occurs while invoking the
                 * exception(i.e. before the first instruction of the vector
                 * is executed), invoke the reboot exception.
                 */
                executeInstruction();
            } catch (DebuggerBreakpointException e1)
            {
                suspend();
            } catch (InterruptException e1)
            {
                armVector(VECTOR_INTERRUPT);
            } catch (IllegalInstructionException e1)
            {
                suspend();
            } catch (MemoryAccessException e1)
            {
                suspend();
            } catch (CPUException e)
            {
                suspend();
            } catch (GDBServerException e)
            {
                suspend();
            }  catch (IOException e)
            {
                e.printStackTrace();
                suspend();
            } catch (RuntimeException e)
            {
                e.printStackTrace();
                suspend();
            } finally
            {
                checkCommit();
            } 
        }
	}


	private void armVector(int vector) 
	{
		// for now we always break as soon as we hit a vector
		if (vector!=VECTOR_INTERRUPT)
		{
		//	print(MINIMAL, "Vector " + vector + " armed at PC: " + formatHex(pc, "00000000"));
			suspend();
		}
		hitVector=true;
		nextVector=vector;
	}

	private void checkVector() throws CPUException
	{
		if (hitVector)
		{
			hitVector=false;
			invokeVector(nextVector);
		}
	}


	private void invokeVector(int vector) throws CPUException 
	{
		push(pc);
		setPcToVector(vector);
	}

	private void setPcToVector(int vector) throws MemoryAccessException
	{
		setPc(VECTORSIZE*vector+VECTORBASE);
	}

	private void executeInstruction() throws CPUException, EndSessionException, GDBServerException, IOException
	{
        for (;;)
        {
            checkHalt();
            
            /* jump to any armed vector */
            checkVector();

            checkInterrupts();
            
            tracer.instructionEvent();

            
            
            
            
            commit = false;
            savedSp=getSp();
            savedPc=pc;
            savedDecodeMask=decodeMask;
            touchedPc=false;
            
            instruction=cpuReadByte(pc);
            // electrons perish each time we attempt an instruction
            tick();
            
            if (((instruction&0x80)!=0))
            {
                int t=((instruction<<(32-7)))>>(32-7);
                
                if (decodeMask)
                {
                    int a;
                    a=(popIntStack()<<7)|(t&0x7f);
                    pushIntStack(a);
                } else
                {
                    pushIntStack(t);
                }
                decodeMask=true;
            } else
            {
                decodeMask = false;
                if (isAddSP(instruction))
                {
                    int offset=instruction - ADDSP;
                    int valAddr=sp+offset*4;
                    int a = popIntStack();
                    pushIntStack(cpuReadLong(valAddr) + a);
                } else if ((instruction >= LOADSP) && (instruction < LOADSP + 32))
                {
                    int addr;
                    addr = getSp();
                    int offset=(instruction - LOADSP)^0x10;
                    addr += 4 * offset;
                    pushIntStack(cpuReadLong(addr));
                } else if (isStoreSP(instruction))
                {
                    int addr;
                    addr = getSp();
                    int offset=(instruction - STORESP)^0x10;
                    addr += 4 * offset;

                    cpuWriteLong(addr, popIntStack());
                } else
                {
                    int addr;
                    int val;
                    switch (instruction)
                    {
                    case 0:
                        throw new DebuggerBreakpointException();
    
                    case PUSHPC:
                        pushIntStack(pc);
                        break;
                    case OR:
                        pushIntStack(popIntStack() | popIntStack());
                        break;
                    case NOT:
                        pushIntStack(popIntStack() ^ 0xffffffff);
                        break;
                    case LOAD:
                        pushIntStack(cpuReadLong(popIntStack()));
                        break;
                    case PUSHSPADD:
                        if (feeble[PUSHSPADD])
                        {
                            emulate();
                        } else
                        {
                            int a;
                            int b;
                            a=sp;
                            b=popIntStack()*4;
                            pushIntStack(a+b);
                        }
                        break;
                    case STORE:
                        addr = popIntOrExt();
                        val = popIntOrExt();
                        cpuWriteLong(addr, val);
                        break;
                    case POPPC:
                    {
                    	// NB!!!! does NOT flush internal stack
                    	int a;
                        if (intSp>0)
                        {
                        	a=popIntStack();
                        } else
                        {
                        	a=pop();
                        }
                        
                        if ((sp>=emulateSp)&&(emulateInProgress))
                        {
                        	emulateInProgress=false;
                        	/* we returned from an emulate instruction */
                        	emulateOpcodeHistogram[emulateOpcode]++;
                        	emulateOpcodeHistogramCycles[emulateOpcode]+=cycles-emulateCycles;
                        }
                        
                        setPc(a);
                        break;
                    }
                    case POPPCREL:
                        if (feeble[POPPCREL])
                        {
                            emulate();
                        } else
                        {
                        	setPc(popIntStack()+getPc());
                        }
                        break;
                    case FLIP:
                        pushIntStack(flip(popIntStack()));
                        break;
                    case ADD:
                        pushIntStack(popIntStack() + popIntStack());
                        break;
                    case SUB:
                        if (feeble[SUB])
                        {
                            emulate();
                        } else
                        {
                            int a=popIntStack();
                            int b=popIntStack();
                            pushIntStack(b-a);
                        }
                        break;
                    case PUSHSP:
                        pushIntStack(getSp());
                        break;
                    case POPSP:
                        changeSp(popIntStack());
                    	intSp=0;	// flush internal stack
                        break;
                    case NOP:
                        break;
                    case AND:
                        pushIntStack(popIntStack() & popIntStack());
                        break;
                    case XOR:
                        if (feeble[XOR])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack(popIntStack() ^ popIntStack());
                        }
                        break;
                    case LOADB:
                        if (feeble[LOADB])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack(cpuReadByte(popIntStack()));
                        }
                        break;
                    case STOREB:
                        if (feeble[STOREB])
                        {
                            emulate();
                        } else
                        {
                            addr = popIntStack();
                            val = popIntStack();
                            cpuWriteByte(addr, val);
                        }
                        break;
                    case LOADH:
                        if (feeble[LOADH])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack(cpuReadWord(popIntStack()));
                        }
                        break;
                    case STOREH:
                        if (feeble[STOREH])
                        {
                            emulate();
                        } else
                        {
                            addr = popIntStack();
                            val = popIntStack();
                            cpuWriteWord(addr, val);
                        }
                        break;
                    case LESSTHAN:
                        if (feeble[LESSTHAN])
                        {
                            emulate();
                        } else
                        {
                            int a;
                            int b;
                            a = popIntStack();
                            b = popIntStack();
                            pushIntStack((a < b) ? 1 : 0);
                        }
                        break;
                    case LESSTHANOREQUAL:
                        if (feeble[LESSTHANOREQUAL])
                        {
                            emulate();
                        } else
                        {
                            int a;
                            int b;
                            a = popIntStack();
                            b = popIntStack();
                            pushIntStack((a <= b) ? 1 : 0);
                        }
                        break;
                    case ULESSTHAN:
                        if (feeble[ULESSTHAN])
                        {
                            emulate();
                        } else
                        {
                            long a;
                            long b;
                            a = ((long) popIntStack()) & INTMASK;
                            b = ((long) popIntStack()) & INTMASK;
                            pushIntStack((a < b) ? 1 : 0);
                        }
                        break;
                    case ULESSTHANOREQUAL:
                        if (feeble[ULESSTHANOREQUAL])
                        {
                            emulate();
                        } else
                        {
                            long a;
                            long b;
                            a = ((long) popIntStack()) & INTMASK;
                            b = ((long) popIntStack()) & INTMASK;
                            pushIntStack((a <= b) ? 1 : 0);
                        }
                        break;
    
                    case SWAP:
//                      if (feeble[SWAP])
//                      {
//                          emulate();
//                      } else
                      {
                          int swapVal=popIntStack();;
                          pushIntStack(((swapVal >>16)&0xffff)|(swapVal<<16));
                      }
                      break;
                    case MULT16X16:
//                      if (feeble[SWAP])
//                      {
//                          emulate();
//                      } else
                      {
                        int a=popIntStack();
                        int b=popIntStack();
                        pushIntStack((a&0xffff)*(b&0xffff));
                      }
                      break;
                    case EQBRANCH:
                        if (feeble[EQBRANCH])
                        {
                            emulate();
                        } else
                        {
                            int compare;
                            int target;
                            target = popIntStack() + pc;
                            compare = popIntStack();
                            if (compare == 0)
                            {
                                setPc(target);
                            } else
                            {
                                setPc(pc + 1);
                            }
                        }
                        break;
    
                    case NEQBRANCH:
                        if (feeble[NEQBRANCH])
                        {
                            emulate();
                        } else
                        {
                            int compare;
                            int target;
                            target = popIntStack() + pc;
                            compare = popIntStack();
                            if (compare != 0)
                            {
                                setPc(target);
                            } else
                            {
                                setPc(pc + 1);
                            }
                        }
                        break;
    
                    case MULT:
                        if (feeble[MULT])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack(popIntStack() * popIntStack());
                        }
                        break;
                    case DIV:
                        if (feeble[DIV])
                        {
                            emulate();
                        } else
                        {
                            int a;
                            int b;
                            a = popIntStack();
                            b = popIntStack();
                            if (b == 0)
                            {
                                throw new CPUException();
                            }
                            pushIntStack(a / b);
                        }
                        break;
                    case MOD:
                        if (feeble[MOD])
                        {
                            emulate();
                        } else
                        {
                            int a;
                            int b;
                            a = popIntStack();
                            b = popIntStack();
                            if (b == 0)
                            {
                                throw new CPUException();
                            }
                            pushIntStack(a % b);
                        }
                        break;
    
                    case LSHIFTRIGHT:
                        if (feeble[LSHIFTRIGHT])
                        {
                            emulate();
                        } else
                        {
                            long shift;
                            long valX;
                            int t;
                            shift = ((long) popIntStack()) & INTMASK;
                            valX = ((long) popIntStack()) & INTMASK;
                            t = (int) (valX >> (shift & 0x3f));
                            pushIntStack(t);
                        }
                        break;
    
                    case ASHIFTLEFT:
                        if (feeble[ASHIFTLEFT])
                        {
                            emulate();
                        } else
                        {
                            long shift;
                            long valX;
                            shift = ((long) popIntStack()) & INTMASK;
                            valX = ((long) popIntStack()) & INTMASK;
                            int t = (int) (valX << (shift & 0x3f));
                            pushIntStack(t);
                        }
                        break;
    
                    case ASHIFTRIGHT:
                        if (feeble[ASHIFTRIGHT])
                        {
                            emulate();
                        } else
                        {
                            long shift;
                            int valX;
                            shift = ((long) popIntStack()) & INTMASK;
                            valX = popIntStack();
                            int t = valX >> (shift & 0x3f);
                            pushIntStack(t);
                        }
                        break;
    
                    case CALL:
                        if (feeble[CALL])
                        {
                            emulate();
                        } else
                        {
                        	intSp=0;	// flush internal stack
                            int address = pop();
                            push(pc + 1);
                            setPc(address);
                        }
                        break;
                    case CALLPCREL:
                        if (feeble[CALLPCREL])
                        {
                            emulate();
                        } else
                        {
                        	intSp=0;	// flush internal stack
                            int address = pop();
                            push(pc + 1);
                            setPc(address+pc);
                        }
                        break;
    
                    case EQ:
                        if (feeble[EQ])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack((popIntStack() == popIntStack()) ? 1 : 0);
                        }
                        break;
    
                    case NEQ:
                        if (feeble[NEQ])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack((popIntStack() != popIntStack()) ? 1 : 0);
                        }
                        break;
    
                    case NEG:
                        if (feeble[NEG])
                        {
                            emulate();
                        } else
                        {
                            pushIntStack(-popIntStack());
                        }
                        break;
    
                        
                        case CONFIG:
                        if (emulateConfig())
                        {
                            emulate();
                            cpu=ABEL;
                        } else
                        {
                            cpu = popIntStack();
                        }
                        switch (cpu)
                        {
                        case ABEL:
                            System.err.println("ZPU feeble instruction set");
                            for (int i = 0; i < feeble.length; i++)
                            {
                                feeble[i] = true;
                            }

                            setFeeble(); 
                            
                            break;
                        case ZETA:
                            System.err.println("ZPU full instruction set");
                            for (int i = 0; i < feeble.length; i++)
                            {
                                feeble[i] = false;
                            }
                            break;
                        default:
                            break;
                        }
                        break;
                        
                    case SYSCALL:
                        if (feeble[SYSCALL])
                        {
                            throw new IllegalInstructionException();
                        } else
                        {
                        	intSp=0;	// flush internal stack
                            syscall.syscall(this);
                        }
                        break;
                            
                    default:
                        throw new IllegalInstructionException();
                    }
                }
            }
            if (!touchedPc)
            {
                setPc(pc + 1);
            }
            committed();
            
            // one more instruction retired
            instructionCount++;
        }
	}


	protected void setFeeble()
	{
		feeble[NEQBRANCH] = false;
		feeble[EQ] = false;
		feeble[LOADB] = false;
		feeble[LESSTHAN] = false;
		feeble[ULESSTHAN] = false;
		feeble[STOREB] = false;
		feeble[MULT] = false;
		feeble[CALL] = true;
		feeble[POPPCREL] = true;
		feeble[LESSTHANOREQUAL] = true;
		feeble[ULESSTHANOREQUAL] = true;

		feeble[PUSHSPADD] = false;
		feeble[CALLPCREL] = false;
		feeble[SUB] = false;
	}


	private int popIntOrExt()
	{
		int a;
		if (intSp==0)
		{
			a=pop();
		} else
		{
			a=popIntStack();
		}
		return a;
	}

	int intSp;

	private int emulateSp;

	private int emulateOpcode;

	private boolean emulateInProgress;

	protected boolean timerPending;

	private boolean inInterrupt;
    private int popIntStack()
	{
//    	if (intSp<=0)
//    		throw new IllegalInstructionException();
    	intSp--;
    	return pop();
	}
    
    private void pushIntStack(int x)
	{
//    	if (intSp>=32)
//    		throw new IllegalInstructionException();
    	push(x);
    	intSp++;
	}



    private static boolean isAddSP(int instruction)
    {
        return (instruction >= ADDSP) && (instruction < ADDSP + 16);
    }


    private static boolean isStoreSP(int instruction)
    {
        return (instruction >= STORESP) && (instruction < STORESP + 32);
    }


    protected boolean emulateConfig()
    {
        return false;
    }


    private void checkCommit() throws CPUException
    {
        if (!commit)
        {
            decodeMask=savedDecodeMask;
            pc=savedPc;
            setSp(savedSp);
            committed();
        }
    }


    private void committed()
    {
        commit=true;
        tracer.commit();
    }


    private void emulate() throws CPUException
	{
    	// NB! Do NOT flush internal stack
//    	intSp=0;	// flush internal stack
        /* three total overhead to emulate instruction */
    	if (!emulateInProgress)
    	{
    		emulateInProgress=true;
	    	emulateSp = sp;
	    	emulateOpcode = getOpcode();
	    	emulateCycles = cycles;
    	}
		pushIntStack(pc+1);
		setPc((cpuReadByte(pc)-32)*VECTORSIZE+VECTORBASE);
	}



	private void checkInterrupts() throws InterruptException
	{
		if (!tracer.simInterrupt())
		{
			/* These flags are set *regardless* of interrupt state. */
			while (lastTimer+timerInterval<cycles)
			{
				if (timerInterval>0)
				{
					lastTimer+=timerInterval;
				} else
				{
					lastTimer=cycles;
				}
				timerPending=true;
			}
		}
		
		if (!interrupt)
			return;
		
        /* if we are in the middle of decoding an instruction, no interrupt */
        if (decodeMask)
        {
        	return;
        }
        if (tracer.simInterrupt())
        {
    		if (!tracer.onInterrupt())
    		{
    			inInterrupt=false;
    		}
    		if (inInterrupt)
    		{
    			return;
    		}
            /* Use trace information instead of trying to figure out when an interrupt happens. We don't try
             * to simulate anything more complicated than timer interrupts so we don't need to worry about source.
             */
            
    		if (tracer.onInterrupt()&&!inInterrupt)
    		{
    			if (!timer)
    			{
    				throw new IllegalInstructionException();
    			}
    			
    			inInterrupt=true;
    			timerPending=true;
    			throw new InterruptException();
    		}
            
        } else
        {
    		if (!timerPending)
    			inInterrupt=false;
    		
    		if (inInterrupt)
    		{
    			return;
    		}
            
    		if (timer&&timerPending)
    		{
    			inInterrupt=true;
    			throw new InterruptException();
    		}
        }
	}



	
	private void cpuWriteWord(int addr, int val) throws MemoryAccessException
	{
		if ((addr&0x1)!=0)
		{
			throw new MemoryAccessException();
		}
		for (int i=0; i<2; i++)
		{
			writeByte(addr+i, val>>(8*(1-i)));
		}
	}

	/**
     * @param i
     * @return
     * @throws MemoryAccessException
     */
	private int cpuReadWord(int addr) throws MemoryAccessException
	{
		if ((addr&0x1)!=0)
		{
			throw new MemoryAccessException();
		}
		return ((readByteInternal(addr+0)&0xff)<<8) | (readByteInternal(addr+1)&0xff);
	}

	private void cpuWriteByte(int addr, int val) throws MemoryAccessException
	{
		writeByte(addr, val);
	}


	protected boolean interrupt;
	protected long timerInterval;
    private boolean touchedPc;

	private boolean accessWatchPoint;

	private int accessWatchPointAddress;

	private int accessWatchPointLength;

    private boolean commit;

    private boolean savedDecodeMask;

    private int savedSp;

    private int savedPc;

    private long[] profile;

    private int cpu;

    private long sampledCycle;

    private Tracer tracer=new Tracer()
    {

        public void instructionEvent()
        {
            
        }

        public void commit()
        {
        }

        public void setSp(int sp)
        {
        }

		public void dumpTraceBack()
		{
			
		}

		public boolean onInterrupt()
		{
			return false;
		}

		public boolean simInterrupt()
		{
			return false;
		}
        
    };

    private int instruction;

	private long totalCycles;

	
	private String traceFileName;

	private int prevOpcode;

	private long prevCycles2;

	private int prevOpcode2;


	

	/**
	 * checks if the CPU should halt, and halts. Fn. returns when the
	 * CPU has resumed execution.
	 * @throws EndSessionException 
	 */
	private void checkHalt() throws EndSessionException
	{
		synchronized(halt)
		{
			if (powerdown)
			{
				throw new EndSessionException();
			}
			
			if (breakNext)
			{
				breakNext=false;
				
				halt.notify();
				try
				{
					syscall.halted();
					halt.wait();
					syscall.running();
				} catch (InterruptedException e)
				{
					e.printStackTrace();
				}
			}
			
			if (powerdown)
			{
				throw new EndSessionException();
			}
		}
	}

	private int flip(int i)
	{
		int t=0;
		for (int j=0; j<32; j++)
		{
			t|=((i>>j)&1)<<(31-j);
		}
		return t;
	}

	/** the CPU is writing a long during execution */
	public void cpuWriteLong(int addr, int val) throws MemoryAccessException
	{
		if (accessWatchPoint&&(addr==accessWatchPointAddress))
		{
			suspend();
		}
        if ((addr&0x3)!=0)
        {
            throw new MemoryAccessException();
        }
		if ((addr>=getIO())&&(addr<getIO()+IOSIZE))
		{
			ioWrite(addr, val);
		} else if ((addr>=0)&&(addr<=memory.length*4))
		{
			memory[addr/4]=val;
			validMemory[addr/4]=true;
		} else
        {
            throw new MemoryAccessException();
        }
	}

	public void writeByte(int addr, int val) throws MemoryAccessException
	{
		if ((addr>=0)&&(addr<memory.length*4))
		{
			memory[addr/4]=(memory[addr/4]&(~(0xff<<((3-addr&3)*8))))|((val&0xff)<<((3-addr&3)*8));
		} else 
		{
			throw new MemoryAccessException();
		}
	}

	protected void ioWrite(int addr, int val) throws MemoryAccessException
	{
        addr-=getIO();
		/* note, big endian! */
		switch (addr)
		{
			case 12:
                syscall.writeUART(val);
				break;
			case 20:
				interrupt=val!=0;
				break;
			case 28:
				timerInterval=val;
				break;
			case 32:
				timer=val!=0;
				break;
            case 0x24:
                syscall.writeUART(val);
                break;
            case 0x100:
                writeTimerSampleReg(val);
                break;
			default:
                break;
		}
		
	}




    protected void writeTimerSampleReg(int val)
    {
        if ((val&0x2)!=0)
        {
            sampledCycle=getSampleOffset(); // we need a fudge factor to make up for differences in when relative to the instruction the data is sampled.
        }
    }


	protected long getSampleOffset()
	{
		return cycles+2+0xd-(0x8e-0x74);
	}
	


    protected int ioRead(int addr) throws CPUException
	{
        addr-=getIO();
		/* note, big endian! */
		switch (addr)
		{
			case 20:
				return interrupt?1:0;
				
			case 32:
				return timer?1:0;
			
            case 0x24:
                return syscall.readUART();
                
                /* FIFO empty? bit 0, FIFO full bit 1(never the case) */
            case 0x28:
                return syscall.readFIFO();
                
            case 0x100:
            case 0x104:
            case 0x108:
            case 0x10c:
                
            case 0x110:
            case 0x114:
            case 0x118:
            case 0x11c:
            return readSampledTimer(addr, 0x100);
            
            case 0x200:
                return readMHz();
                
			default:
				throw new MemoryAccessException();
		}
	}




    protected int readMHz()
    {
        /* 90 MHz */
        return 100;
    }


    protected int readSampledTimer(int addr, int base)
    {
        int t=0;
        t=(int)((sampledCycle>>(((addr-base)/4)*32))&0xffffffff);
        return t;
    }



	private int cpuReadByte(int addr) throws MemoryAccessException
	{
		return readByteInternal(addr);
	}

	
	/** this is the CPU reading a long word during execution */
	public int cpuReadLong(int addr) throws CPUException
	{
		if (accessWatchPoint&&(addr==accessWatchPointAddress))
		{
			suspend();
		}
		if ((addr&0x3)!=0)
		{
			throw new MemoryAccessException();
		}
		if ((addr>=getIO())&&(addr<getIO()+IOSIZE))
		{
			return ioRead(addr);
		} else  if ((addr>=0)&&(addr<=memory.length*4))
		{
			return memory[addr/4];
		} else
        {
            throw new MemoryAccessException();
        }
	}

	/**
	 * Causes a cycle to pass.
	 * @throws MemoryAccessException 
	 */
	/** increase time and record how long we spent on this instruction */
    private void tick() throws MemoryAccessException
    {
        profile[pc]++;
        int opcode;
        opcode=readByte(pc);
        opcodeHistogram[prevOpcode]++;
        opcodeHistogramCycles[prevOpcode]+=cycles-prevCycles;
        int opcodePair=groupOpcode(prevOpcode2)*256+groupOpcode(prevOpcode);

        opcodePairHistogram[opcodePair]++;
        opcodePairHistogramCycles[opcodePair]+=cycles-prevCycles2;

        prevOpcode2=prevOpcode;
        prevOpcode=opcode;
        
        
        
        prevCycles2=prevCycles;
        prevCycles=cycles;
		cycles++;
    }

    private int groupOpcode(int instruction)
	{
        if (isAddSP(instruction))
        {
        	return ADDSP;
        } else if ((instruction >= LOADSP) && (instruction < LOADSP + 32))
        {
        	return LOADSP;
        } else if (isStoreSP(instruction))
        {
        	return STORESP;
        }

    	if ((instruction&0x80)!=0)
    		return 0x80;
    	return instruction;
	}


	public int readByte(int addr) throws MemoryAccessException
	{
		if ((addr>=0)&&(addr<memory.length*4))
		{
			return readByteInternal(addr);
		} else
		{
			throw new MemoryAccessException();
		}
	}

    
	protected int readByteInternal(int addr) throws MemoryAccessException
	{
		return (memory[addr/4]>>((3-addr&0x3)*8))&0xff;
	}

	private int pop() throws CPUException
	{
		int val;
		validMemory[getSp()/4]=false;
		val=cpuReadLong(getSp());
		setSp(getSp() + 4);
		return val;
	}

	private void push(int imm) throws CPUException
	{
		setSp(getSp() - 4);
		cpuWriteLong(getSp(), imm);
	}

    private  final class OpcodeSample
	{
		private final int j;

		int opcode;

		long count;

		private OpcodeSample(int j, long l)
		{
			this.j = j;
			opcode = j;
			count = l;
		}
	}


    

	private void initRam()
	{
		memory = (new int[getRAMSIZE()/4]);
		validMemory = new boolean[getRAMSIZE()/4];
		for (int i=0; i<validMemory.length; i++)
		{
			validMemory[i]=true;
		}
		
        profile = new long[getRAMSIZE()];
	}

	
	
	public void setPc(int pc) throws MemoryAccessException
	{
		if ((pc<VECTORBASE)||(pc>memory.length*4))
		{
			throw new MemoryAccessException();
		}
		this.pc = pc;
        touchedPc=true;
	}

	public int getPc()
	{
		return pc;
	}

	/** resume execution. This function returns when the CPU halts again. */
	public void cont()
	{
        for (;;)
        {
    		synchronized(halt)
    		{
    			halt.notify();
    			try
    			{
    				halt.wait();
    			} catch (InterruptedException e)
    			{
    				e.printStackTrace();
    			}
    		}
            if (syscall.doneContinue())
            {
                    break;
            }
        }
	}
	
    /** resume execution. This function returns when the CPU halts again. */
	public void step()
	{
		synchronized(halt)
		{
			suspend();
			cont();
		}
	}
	

	
	public int getReg(int regNum) throws CPUException
	{
		if ((regNum>=0)&&(regNum<32))
		{
           	return memory[regNum];
		} else if (regNum==32)
		{
			return getSp();
		} else if (regNum==33)
		{
			return pc;
		} else
		{
			throw new RuntimeException("Illegal getReg()");
		}
	}

	public int getREGNUM()
	{
		return 34;
	}

	public long getCycleCounter()
	{
		return cycles;
	}

	public void addWaitStates(int num)
	{
	}

	/** tells simulator to enter the suspended state */
	public void suspend()
	{
		synchronized(halt)
		{
		    breakNext=true;
		}
//		tracer.dumpTraceBack();
	}


    public long getPrevCycles()
    {
        return prevCycles;
    }

    public long getCycles()
    {
        return cycles;
    }


	public void enableAccessWatchPoint(int address, int length) throws CPUException 
	{
		if (accessWatchPoint)
		{
			throw new HardwareWatchPointException();
		}
		accessWatchPointAddress=address;
		accessWatchPointLength=length;
		accessWatchPoint=true;
	}
	public void disableAccessWatchPoint(int address, int length) throws CPUException 
	{
		if (!accessWatchPoint)
		{
			throw new HardwareWatchPointException();
		}
		if ((address!=accessWatchPointAddress)||(length!=accessWatchPointLength))
		{
			throw new HardwareWatchPointException();
		}
		
		accessWatchPoint=false;
	}

	/** POPSP changes the stack pointer */
    public void changeSp(int sp) throws CPUException 
    {
        setSp(sp);
        tracer.setSp(sp);
    }

    public void setSp(int sp) throws CPUException
    {
        if ((sp%4)!=0)
        {
            throw new IllegalInstructionException();
        }
        
        if (sp<minStack)
        {
            minStack=sp;
        }
        
        
        this.sp = sp;
    }


    public int getSp()
    {
        return sp;
    }
    public int getIntSp()
    {
        return (intSp+(INTSTACKSIZE-1))%INTSTACKSIZE;
    }


    

    protected int getIO()
    {
        return 0x80000000;
    }


    protected int getRAMSIZE()
    {
        return (16*1024*1024);
    }

    protected int getStartStack()
    {
        return memory.length*4-0x10000;
    }


    public void setTraceFile(String string)
    {
    	traceFileName=string;
    }


    public void setSyscall(Host syscall)
    {
        this.syscall=syscall;
    }


    public void loadImage(InputStream inputStream, int length) throws IOException, CPUException
    {
    	if (length==-1)
    		throw new IOException("File image length not known");
    	for (int i=0; i<length; i++)
    	{
		    int t=inputStream.read();
		    writeByte(0+i, t);
		} 
        
    }

    public int getArg(int num) throws CPUException
    {
        return cpuReadLong(getSp()+4+num*4);
    }


	public int getOpcode() throws MemoryAccessException
	{
		return readByte(pc);
	}

	static final int INTSTACKSIZE=32;

	public boolean checkMatch(Trace trace)
	{
		cycles=trace.cycle;
		if (!trace.undefinedIntSp)
		{
			if (trace.intSp!=((intSp+(INTSTACKSIZE-1))%INTSTACKSIZE))
				return false;
		}
		
		if ((getPc() != trace.pc) || (getSp() != trace.sp)
				|| (getOpcode() != trace.opcode))
		{
			return false;
		}
	    
		if (cpuReadLong(getSp()) == trace.stackA)
		{
			if (cpuReadLong(getSp() + 4) == trace.stackB)
			{
				return true;
			}
		}
		if ((!validMemory[getSp()/4])||cpuReadLong(getSp()) == trace.stackA)
		{
			if ((!validMemory[(getSp()+4)/4])||cpuReadLong(getSp() + 4) == trace.stackB)
			{
//				System.out.println("Undefined memory location mismatch");
				return true;
			}
		}
		if (!trace.undefinedIntSp)
		{
			if ((intSp<1)||cpuReadLong(getSp()) == trace.stackA)
			{
				if ((intSp<2)||cpuReadLong(getSp() + 4) == trace.stackB)
				{
					return true;
				}
			}
		}
	    return false;
	}


	public void sessionStarted()
	{
		if (traceFileName!=null)
		{
			tracer = new FileTracer(this, traceFileName);
		}

		/* Set the feeble flag to enable/disable instructions here */
		initRam();
		resetHardwareInternal();			


		
	}


	void printState(FileTracer fileTracer)
	{
		System.err.println("intSp: " + getIntSp());
		System.err.println(Integer.toHexString(getPc())+ " " +
		Integer.toHexString(getOpcode()) + " " +
		Integer.toHexString(getSp()) + " " + 
		Integer.toHexString(cpuReadLong(getSp())) + " " + 
		Integer.toHexString(cpuReadLong(getSp()+4)));
	}


	
	

}
