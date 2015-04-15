
package com.zylin.zpu.simulator.exceptions;


public class TraceException extends GDBServerException
{

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public TraceException(Exception e)
    {
        super(e);
    }

    public TraceException()
    {
    }

}
