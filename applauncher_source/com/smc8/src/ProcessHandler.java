package com.smc8;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public abstract class ProcessHandler {
	
	// constants
	
	// static instance fields
	private static Runtime runTime;
	private static List<Process> processes;
	private static List<String> logs;
	private static List<Thread> threads;
	private static ProcessMonitor monitor;
	private static int pcount = 0;
	
	static {
		runTime = Runtime.getRuntime();
		processes = new ArrayList<Process>();
		logs = new ArrayList<String>();
		threads = new ArrayList<Thread>();
		monitor = new ProcessMonitor();
	}
	
	public static boolean addProcess(String cmd, String logfile) {
		Process p = null;
		
		try {
			p = runTime.exec(cmd);
			processes.add(p);
			logs.add(logfile);
			pcount++;
		} catch(IOException e) {
			e.printStackTrace();
		}
		
		return (p != null);
	}
	
	public static void startAllProcesses() throws IOException {
		for (int i = 0; i < processes.size(); i++) {
			String log = logs.get(i);
			Process proc = processes.get(i);
			
			FileOutputStream fos = 
					new FileOutputStream(log);
			
			ProcessRunner pr = new
					ProcessRunner(proc, fos, monitor);
			
			Thread t = new Thread(pr);
			threads.add(t);
			t.setName("processThread-" + i);
			t.start();
		}
	}
	
	public static void waitForFirst() {
		if (pcount == 0) return;
		
		System.out.println("Processes running...\n");
		while(!monitor.getIsProcessDead()) {
			// spin around
		}
	}
	
	public static void killProcesses() {
		if (pcount == 0) return;
		
		for (Process p : processes) {
			if (p.isAlive()) {
				p.destroy();
			}
		}
		
		for (Thread t : threads) {
			if (t.isAlive()) {
				try {
					t.join();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
		
		pcount = 0;
	}
}
