package com.smc8;

import java.util.concurrent.locks.ReentrantLock;

public class ProcessMonitor {
	
	private final ReentrantLock lock = new ReentrantLock();
	private volatile boolean processDied;
		
	public ProcessMonitor() {
		this.processDied = false;
	}
	
	public boolean getIsProcessDead() {
		return this.processDied;
	}
	
	public void setProcessDead() {
		lock.lock();	
		try {
			this.processDied = true;
		} finally {
			lock.unlock();
		}
	}
	
}
