package com.zylin.zpu.simulator;

public interface ZPU
{
	/**
	 * number of cycles passed since reboot
	 */
	long getCycleCounter();

	/**
	 * Wait this many cycles
	 */
	void addWaitStates(int i);
}
