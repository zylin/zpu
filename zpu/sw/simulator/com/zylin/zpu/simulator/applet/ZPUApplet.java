
package com.zylin.zpu.simulator.applet;

import java.applet.Applet;
import java.awt.TextArea;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.lang.reflect.InvocationTargetException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import javax.swing.SwingUtilities;

import com.zylin.zpu.simulator.Host;
import com.zylin.zpu.simulator.Sim;
import com.zylin.zpu.simulator.Simulator;
import com.zylin.zpu.simulator.exceptions.CPUException;
import com.zylin.zpu.simulator.exceptions.UnsupportedSyscallException;

public class ZPUApplet extends Applet implements Host
{

	private static final long serialVersionUID = 1L;
	private TextArea console;
    private Simulator simulator;
	private PipedOutputStream outputPipe;
	private PipedInputStream inputPipe;

    public void init()
    {
        super.init();
        
        console=new TextArea();
        //console.setEditable(false);

        
        console.addKeyListener(new KeyListener()
                {

                    public void keyPressed(KeyEvent e)
                    {
                    	try 
                    	{
							outputPipe.write((int)e.getKeyChar());
						} catch (Throwable e1) 
						{
							e1.printStackTrace();
						}
                        
                    }

                    public void keyReleased(KeyEvent e)
                    {
                        
                    }

                    public void keyTyped(KeyEvent e)
                    {
                        
                    }
                });

        //Add the text field to the applet.
        add(console);

        //Set the layout manager so that the text field will be
        //as wide as possible.
        setLayout(new java.awt.GridLayout(1,0));

        validate();
        initSimulator();
        
    }
    
    



    public void start() 
	{
		super.start();
	}





	public void stop()
    {
        simulator.shutdown();
        super.stop();
    }

    private void initSimulator()
    {
    	final ZPUApplet me = this;
    	
        try
        {
        	outputPipe = new PipedOutputStream();
			inputPipe = new PipedInputStream(outputPipe);
			
			showStatus("Loading ZPU binary image...");

			Thread thread = new Thread(new Runnable() {
				public void run() {
					try {
						// lineReader=new LineNumberReader(new
						// InputStreamReader(inputPipe));

						simulator = new Simulator();
						simulator.setSyscall(me);

						String file = getParameter("executable");

						URL url;
						url = new URL(getCodeBase(), file);
						showStatus("Loading: " + url.toString() +"...");

						URLConnection connection = url.openConnection();
						
						simulator.loadImage(connection.getInputStream(), connection.getContentLength());

						simulator.run();
					} catch (Throwable e) {
						e.printStackTrace();
					}
				}
			});
			thread.start();
		} catch (MalformedURLException e) {
            throw new RuntimeException(e);
        } catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    public void syscall(Sim s) throws CPUException
    {
        int retval=-1;
        int syscallErrno=0;
        int id;
        id=simulator.getArg(1);
        try
        {
	        switch (id)
	        {
	        case SYS_write:
	            writeToConsole();
	            retval=simulator.getArg(4);
	            break;
	        case SYS_read:
	        	int i;
	        	for (i=0; i<simulator.getArg(4); i++)
	        	{
	        		int t=inputPipe.read();
        			simulator.writeByte(simulator.getArg(3)+i, t);
        			if ((t=='\n')||(t=='\r'))
        			{
        				/* done reading line */
        				i++;
        				break;
        			}
	        	}
	        	retval=i;
	        	break;
	        	
	        case SYS_fstat:
	        	syscallErrno=EIO;
	        	retval=-1;
	            break;
	            
	        default:
	            simulator.suspend();
	            throw new UnsupportedSyscallException();
	        }
        } 
        catch (IOException e)
        {
            retval=-1;
            syscallErrno=EIO;
        }
        simulator.cpuWriteLong(simulator.getArg(0), syscallErrno);
        simulator.cpuWriteLong(0, retval);
    }

    private void writeToConsole() throws CPUException
    {
    	String t="";
        for (int i=0; i<simulator.getArg(4); i++)
        {
        	t+=(char)simulator.readByte(simulator.getArg(3)+i);
        }
        final String t2=t;
        System.out.println(t2);
        try {
			SwingUtilities.invokeAndWait(new Runnable()
			        {
			            public void run()
			            {
			                console.append(t2);
			            }
			        });
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }




    public boolean doneContinue()
    {
        return false;
    }


    public void writeUART(final int val)
    {
        try {
			SwingUtilities.invokeAndWait(new Runnable()
			        {

			            public void run()
			            {
			                console.append(""+(char)(val));
			                repaint();
			                
			            }
			        });
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
    }





	public int readUART() throws CPUException 
	{
		try 
		{
			return inputPipe.read();
		} catch (IOException e) 
		{
			e.printStackTrace();
			throw new CPUException();
		}
	}





	public int readFIFO() 
	{
		return 0;
	}

	public void halted()
	{
		showStatus("ZPU application halted");
	}

	public void running()
	{
		showStatus("ZPU application running...");
	}
}
