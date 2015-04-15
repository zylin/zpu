
package com.zylin.zpu.simulator;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.MemoryAccessException;

public class Abel extends Simulator
{

    protected int getIO()
    {
        return 0x8000;
    }



    protected int ioRead(int addr) throws CPUException
    {
        switch (addr)
        {
            case 0xc000:
                return syscall.readUART();
                
                /* FIFO empty? bit 0, FIFO full bit 1(never the case) */
            case 0xc004:
                return syscall.readFIFO();
                
            case 0x9000:
            case 0x9004:
            case 0x9008:
            case 0x900c:
                
            case 0x9010:
            case 0x9014:
            case 0x9018:
            case 0x901c:
            return readSampledTimer(addr, 0x9000);
            
            case 0x8800:
                return readMHz();
                
        	default:
        		throw new MemoryAccessException();
        }
    }

    /*
    ; Read/write are on different addresses
    ; The registers are 8 bits and mapped to bit[7:0]
    ; 
    ; 0xC000 Write: Writes to UART TX FIFO (4 byte FIFO) 
    ;        Read : Reads from UART RX FIFO (4 byte FIFO)
    ; 0xC004 Read : UART status register
    ;                       Bit 0 = RX FIFO empty
    ;                       Bit 1 = TX FIFO full
    ; 0xA000 Write: 8 LED's 
    */
    
    /*
    0x9000 Write: bit 0: 1= reset counter
                   0= counter running
              bit 1: 1= sample counter (when set to 1)
                   0=not used
         Read : counter bit[7:0]
    0x9004 Read: counter bit [15:8]
    0x9008 Read: counter bit [23:16]
    0x900C Read: counter bit [31:24]
    0x9010 Read: counter bit [39:32]
    0x9014 Read: counter bit [47:40]
    0x9018 Read: counter bit [55:48]
    0x901C Read: counter bit [63:56]

    0x8800 Read: unsigned 8-bit integer with FPGA frequency (in MHz)
    */

    protected void ioWrite(int addr, int val) throws MemoryAccessException
    {
        switch (addr)
        {
            case 0x9000:
                writeTimerSampleReg(val);
            case 0xc000:
                syscall.writeUART(val);
                break;
        	default:
                throw new MemoryAccessException();
        }
    }

    Abel() throws CPUException
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
        return 32768;
    }

}
