package com.zylin.zpu.simulator;

public class PhiFeeble extends Phi
{
	public static void main(String[] args)
	{
        new SimApp(new SimFactory()
        {
        	public Simulator create()
        	{
        		return new PhiFeeble();
        	}
        }).run(args);
	}
	protected void setFeeble()
	{
//		feeble[NEQBRANCH] = false;
//		feeble[EQ] = false;
//		feeble[LOADB] = false;
//		feeble[LESSTHAN] = false;
//		feeble[ULESSTHAN] = false;
//		feeble[STOREB] = false;
//		feeble[MULT] = false;
//		feeble[CALL] = true;
//		feeble[POPPCREL] = true;
//		feeble[LESSTHANOREQUAL] = true;
//		feeble[ULESSTHANOREQUAL] = true;
//
//		feeble[PUSHSPADD] = false;
//		feeble[CALLPCREL] = false;
//		feeble[SUB] = false;
	}
	
}
