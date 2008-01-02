/*
 * Created on Jan 18, 2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package com.zylin.zpu.stats;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import com.zylin.zpu.simulator.Machine;

public class CountSequences implements Machine
{

    private byte[] array;
    private StatKeeper statKeeper;

    public static void main(String[] args)
    {
        new CountSequences().run(args[0]);
    }

    private void run(String string)
    {
        try
        {
            File file=new File(string);
            if (file.exists())
                System.out.println("It exists!");
            FileInputStream in=new FileInputStream(file);
            
            try
            {
                array=new byte[(int) file.length()];
                
                if (in.read(array)!=array.length)
                    throw new IOException();
                
                countStats();
                
                statKeeper.printStats();
            } finally
            {
                in.close();
            }
            
        } catch (FileNotFoundException e)
        {
            e.printStackTrace();
        } catch (IOException e)
        {
            e.printStackTrace();
        }
        
        
    }


    private void countStats()
    {
        statKeeper=new StatKeeper(this);
        for (int i=0; i<array.length; i++)
        {
            int j = array[i]&0xff;
//            
//            if ((j>=64)&&(j<96))
//            {
//                j=64;
//            } else if ((j>=96)&&(j<128))
//            {
//                j=96;
//            } else if ((j>=128)&&(j<256))
//            {
//                j=128;
//            }
            statKeeper.countInstruction(j);
        }
        
    }

    public long getPrevCycles()
    {
        return 0;
    }

    public long getCycles()
    {
        return 0;
    }
}
