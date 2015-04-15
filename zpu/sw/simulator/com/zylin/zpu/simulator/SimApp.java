package com.zylin.zpu.simulator;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.channels.ServerSocketChannel;

import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.gdb.GDBServer;

public class SimApp
{
	private static Simulator simulator;
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
		createSimulator();
        parseArgs();
        moreParse();
        runSimAndGDB();
	}
	Object launched=new Object();
	private boolean doneLaunching;
	private boolean manyGDBSessions;
	public ServerSocket serverSocket;
	public void runSimAndGDB()
	{
        try
		{
			serverSocket = new ServerSocket(portNumber);
			try
			{
				serverSocket.setReuseAddress(true);
                System.out.println("Listening on port " + portNumber);
                setLaunchedFlag();
                do 
                {
					try
					{
						runGDBServer();
					} catch (CPUException e)
					{
						e.printStackTrace();
					}
                } while (manyGDBSessions);
			} finally
			{
				serverSocket.close();
			}
		} catch (IOException e1)
		{
			e1.printStackTrace();
		} finally
		{
            setLaunchedFlag();
		}
	
	}

	private void setLaunchedFlag()
	{
		synchronized(launched)
		{
			doneLaunching=true;
			launched.notify();
		}
	}

	public void createSimulator()
	{
		simulator=simFactory.create();
        simulator.suspend();
	}

    private void runGDBServer() throws CPUException
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

	public Simulator getSimulator()
	{
		return simulator;
	}

	public void setPort(int i)
	{
		portNumber=i;
	}

	/** synchronous launch of GDB server */
	public void launchGDBServer()
	{
		Thread t=new Thread(new Runnable()
		{

			public void run()
			{
				runSimAndGDB();
			}
		});
		t.start();
		synchronized (launched)
		{
			while (!doneLaunching)
			{
				try
				{
					launched.wait(2000);
				} catch (InterruptedException e)
				{
					e.printStackTrace();
				}
			}
		}
		
		
	}
}
