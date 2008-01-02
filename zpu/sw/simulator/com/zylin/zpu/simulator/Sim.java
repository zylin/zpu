
package com.zylin.zpu.simulator;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;

public interface Sim
{
/**
     * halts the CPU. 
     */
    void suspend();
    void writeByte(int i, int val) throws CPUException;
    /** 
     * synchronous method that returns when simulator enters the halt state. 
     **/
    void cont();
    /** 
     * synchronous method that returns when simulator finishes step or otherwise enters
     * the halt state. 
     **/
    void step();

    int getReg(int i) throws CPUException;

    int getREGNUM();
    int readByte(int addr) throws CPUException;

    /**
     * @param sp The sp to set.
     * @throws CPUException 
     */
    void setSp(int sp) throws CPUException;

    /**
     * @return Returns the sp.
     */
    int getSp();

    /**
     * @param pc The pc to set.
     * @throws MemoryAccessException
     */
    void setPc(int pc) throws MemoryAccessException;

    /**
     * @return Returns the pc.
     */
    int getPc();

    void enableAccessWatchPoint(int address, int length) throws CPUException;

    void disableAccessWatchPoint(int address, int length) throws CPUException;

    int cpuReadLong(int i) throws CPUException;

    void cpuWriteLong(int i, int retval) throws MemoryAccessException;

    int getArg(int num) throws CPUException;
	void sessionStarted();

}
