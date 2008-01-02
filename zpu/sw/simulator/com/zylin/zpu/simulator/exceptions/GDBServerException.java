package com.zylin.zpu.simulator.exceptions;


public class GDBServerException extends RuntimeException
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public GDBServerException(NumberFormatException e)
	{
		super(e);
	}

	public GDBServerException()
	{
		
	}

    public GDBServerException(Exception e)
    {
        super(e);
    }
}
