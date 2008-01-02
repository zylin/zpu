
package com.zylin.zpu.simulator.tools;

import java.io.FileInputStream;
import java.io.IOException;

public class MakeRam
{
    public static void main(String[] args) throws IOException
    {
       new MakeRam().run(args[0]);
    }

    private void run(String string) throws IOException
    {
        FileInputStream file=new FileInputStream(string);
        
        int i=0;
        while (file.available()>4)
        {
            byte[] tmp=new byte[4];
            file.read(tmp);
            int word=0;
            for (int j=0; j<4; j++)
            {
                word|=((int)(tmp[j])&0xff)<<((3-j)*8);
            }
            String str=Integer.toHexString(word);
            while (str.length()<8)
            {
                str="0"+str;
            }
            
            System.out.println("" + i + " => x\"" + str + "\",");
            i++;
        }
    }

}
