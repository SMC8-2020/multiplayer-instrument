package com.smc8;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class ProcessRunner implements Runnable {
	
	private Process p;
	private ProcessMonitor monitor;
	
	private FileOutputStream fos;
	private StreamGobbler errorGobbler;
	private StreamGobbler outputGobbler;
	
	private long pid = -1;
	
	public ProcessRunner(Process p, FileOutputStream fos, ProcessMonitor monitor) {
		this.p = p;
		this.monitor = monitor;
		
		try {
			this.pid = p.pid();
		} catch(UnsupportedOperationException e) {
			System.out.println("PID Unavailable for this process");
			e.printStackTrace();
		}
		
		this.fos = fos;
		
		this.errorGobbler = new 
				StreamGobbler(p.getErrorStream(), pid + ":ERROR");
		this.outputGobbler = new 
				StreamGobbler(p.getInputStream(), pid + ":OUTPUT", fos);
		
		this.errorGobbler.start();
		this.outputGobbler.start();
		
		System.out.println("Monitoring process with PID: " + this.pid);
	}
	
	@Override
	public void run() {
		if (p != null) {
			
			boolean ret;
			try {
				ret = p.waitFor(10, TimeUnit.MINUTES);
				errorGobbler.join();
				outputGobbler.join();
			} catch(InterruptedException e) {
				ret = false;
				e.printStackTrace();
			}
			
			try {
				fos.flush();
				fos.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			if (ret) {
				System.out.println("Process " + this.pid + " terminated sucessfully");
			} else {
				System.out.println("Process " + this.pid + " timed out");
				System.out.println("terminating...");
			}
						
			monitor.setProcessDead();
		}
	}

}
