
package com.zylin.zpu.simulator;

import com.zylin.zpu.simulator.exceptions.GDBServerException;

public interface Tracer
{

    void instructionEvent() throws GDBServerException;

    void commit();

    void setSp(int sp);
    
    void dumpTraceBack();

    
    boolean onInterrupt();
    
    boolean simInterrupt();
}
