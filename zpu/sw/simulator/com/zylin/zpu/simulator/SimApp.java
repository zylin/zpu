package com.zylin.zpu.simulator;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.channels.ServerSocketChannel;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.gdb.GDBServer;

public class SimApp
{
	private static Simulator simulator;
	public ServerSocketChannel channel;
    private String[] args;
    private int portNumber;
	private SimFactory simFactory;

    public SimApp(SimFactory factory)
	{
    	simFactory=factory;
	}

	public void parseArgs()
    {
        portNumber = 4444;
        if (args.length>=1)
        {
            portNumber=Integer.parseInt(args[0]);
        }
    }

    private void moreParse()
    {
        if (args.length>=2)
        {
            simulator.setTraceFile(args[1]);
        }
    }

	void run(String[] args)
	{
        this.args=args;
        parseArgs();
        try
		{
			channel = ServerSocketChannel.open();
			try
			{
                System.out.println("Listening on port " + portNumber);
				channel.socket().bind(new InetSocketAddress(portNumber));
				for (;;)
				{
					try
					{
						simulator=simFactory.create();
				        simulator.suspend();
                        moreParse();
						run();
					} catch (CPUException e)
					{
						e.printStackTrace();
					} 
				}
			} finally
			{
				channel.close();
			}
		} catch (IOException e1)
		{
			e1.printStackTrace();
		}
	
	}

    private void run() throws CPUException
    {
        final GDBServer gdbServer=new GDBServer(simulator, this);
        simulator.setSyscall(gdbServer);
        Thread thread = new Thread(new Runnable()
                {
                    public void run()
                    {
                        try
                        {
                            gdbServer.gdbServer();
                        } 
                        catch (Throwable e)
                        {
                            e.printStackTrace();
                        }
                        simulator.shutdown();
                    }
                });
        thread.start();
        try
        {
            simulator.run();
        } 
        finally
        {
            
            try
            {
                thread.join();
            } catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
            
    }
}
