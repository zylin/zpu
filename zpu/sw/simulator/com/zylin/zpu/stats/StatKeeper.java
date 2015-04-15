package com.zylin.zpu.stats;

import com.zylin.zpu.simulator.Machine;
import com.zylin.zpu.simulator.State;

public class StatKeeper
{
	private Instruction top=new Instruction();
	private int trackPos;

    private State[] state = new State[3];
    private Machine simulator;
	/**
     * @param simulator
     */
    public StatKeeper(Machine simulator)
    {
        this.simulator=simulator;
		for (int i=0; i<state.length; i++)
		{
			state[i]=new State();
		}
    }
    /**
	 * this instruction has been retired. Count it.
	 */
	public void countInstruction(int instruction)
	{
		State currentState=state[trackPos%state.length];
		currentState.cycle=simulator.getPrevCycles(); // start of instruction
		currentState.insn=instruction;
		trackPos++;
        int backtrackNum;
		backtrackNum=Math.min(trackPos, state.length);
		for (int i=0; i<backtrackNum; i++)
		{
            Instruction t=top;
			for (int j=0; j<=i; j++)
			{
                currentState=state[(trackPos-backtrackNum+j)%state.length];
				t=t.addInstruction(currentState.insn);
			}
            t.count++;
		}
		
	}
    public void printStats()
    {
        top.printStats();
        
    }
}
