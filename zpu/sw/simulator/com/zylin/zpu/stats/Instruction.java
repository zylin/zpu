package com.zylin.zpu.stats;

public class Instruction 
{
	public class DumpCycles implements DumpIt
	{
		public int dumpIt(int i)
		{
			return insn[i].cycles;
		}
	}



	public Instruction[] insn=new Instruction[256];
	public int count;
	public int cycles;

	public Instruction addInstruction(int i)
	{
		if (insn[i]==null)
		{
			insn[i]=new Instruction();
		}
		return insn[i];
	}

	/**
	 * Recursive print of statistics
	 */
	public void printStats()
	{
		System.out.println("Count dump");
		DumpIt cDump = new DumpCount();
		printCount("", cDump);
	}

	/**
	 * Recursive print of counts
	 * @param string
	 * @param dumpIt TODO
	 */
	private void printCount(String string, DumpIt dumpIt)
	{
		for (int i=0; i<insn.length; i++)
		{
			if (insn[i]!=null)
			{
				insn[i].printCount(string + ", " + i, dumpIt);
				System.out.println("Count: " + insn[i].count + string + ", " + i);
			}
		}
	}

	class DumpCount implements DumpIt
	{
		public int dumpIt(int i)
		{
			return insn[i].count;
		}
	}
}
