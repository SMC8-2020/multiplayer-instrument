package com.smc8;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;

public class SMC8_ProcessHandler {
	
	final static String ROOTDIR = "/usr/local";
	final static String DLLNAME = "libportaudio.2.dylib";
	final static String DLLPATH = ROOTDIR + "/opt/portaudio/lib/" + DLLNAME;
	final static String PATOKS  = "opt&portaudio&lib";
	
	final static String LOGTMP = "/outputlog%d.txt";
	final static String EXETMP = "/%1$s.app/Contents/MacOS/%1$s";
	final static String LIBTMP = "/%1$s.app/Contents/Java/%2$s";
	
	static HashMap<String, Boolean> rsc;
	
	static String serverName, instrumentName;
	static String APPDIR;
	static String DEPENDENCY;
	static String LIBPATH;
	
	public static void main(String args[]) {
		
		if (args.length < 2) {
			// <current dir path> <dependency> [list of programs]
			System.out.println("<src path> <dependency> [list of programs]");
			System.exit(-1);
		}
		
		APPDIR     = args[0];
		DEPENDENCY = APPDIR + String.format(EXETMP, args[1]);
		LIBPATH    = APPDIR + String.format(LIBTMP, DEPENDENCY, DLLNAME);
		
		File f = new File(DEPENDENCY);
		if (!f.exists()) {
			System.out.println("File " + DEPENDENCY + "could not be found");
			System.out.println("Dependecy file missing...");
			System.exit(-1);
		}
		
		pre();
		
		String exe = DEPENDENCY;
		String log = APPDIR + String.format(LOGTMP, 0);
		boolean res = ProcessHandler.addProcess(exe, log);
		
		if (!res) {
			post();
			System.out.println("An error occured trying to exec file " + exe);
			System.exit(-1);
		}
		
		for (int i = 2; i < args.length; i++) {
			exe = APPDIR + String.format(EXETMP, args[i]);
			log = APPDIR + String.format(LOGTMP, i - 1);
			res = ProcessHandler.addProcess(exe, log);
			
			if (!res) {
				post();
				System.out.println("An error occured trying to exec file " + exe);
				System.exit(-1);
			}
		}
		
		try {
			ProcessHandler.startAllProcesses();
		} catch (IOException e) {
			post();
			e.printStackTrace();
			System.out.println("An error occured...");
			System.exit(-1);
		}
		
		ProcessHandler.waitForFirst();
		ProcessHandler.killProcesses();
		
		post();
		
		System.out.println("...Terminated program...");
	}
	
	public static void pre() {
		
		System.out.println("\nInitializing...");
		
		rsc = new HashMap<String, Boolean>();
		String[] toks = PATOKS.split("&");
		for(String tok : toks) {
			rsc.put(tok, true);
		}
		
		rsc.put(DLLNAME, true);
		
		try {
			addPaDependency();
		} catch(IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("\n\n");
	}
	
	public static void post() {
		
		System.out.println("\nCleaning up...");
		
		try {
			removePaDependency();
		} catch(IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("\n\n");
	}
	
	public static File getDstDylib() {
		File f = new File(DLLPATH);
		if (!f.exists()) {
			System.out.println("creating path hierarchy");
			f = createDstDylib();
		}
		
		return f;
	}
	
	private static File createDstDylib() {
		File f = null;
		String absPath = ROOTDIR;
		String[] tokens = PATOKS.split("&");
		for (String tok : tokens) {
			absPath += "/" + tok;
			f = new File(absPath);
			if (!f.exists()) {
				f.mkdir();
				rsc.put(tok, false);
				System.out.println("created dir " + absPath);
			} 
		}
		
		f = new File(absPath + "/" + DLLNAME);
		if (!f.exists()) {
			rsc.put(DLLNAME, false);
		}
		
		return f;
	}
	
	private static void addPaDependency() throws IOException {
		File dst = getDstDylib();
		
		if (dst.exists()) {
			System.out.println("Dylib allready installed");
			return;
		}
		
		File src = new File(LIBPATH);
		Files.copy(src.toPath(), dst.toPath());
		System.out.println("created file " + dst.getPath());
	}
	
	private static void removePaDependency() throws IOException {
		File dst = getDstDylib();
		
		File cur = dst;
		while(!cur.getAbsolutePath().equals(ROOTDIR)) {
			String tok = cur.getName();
			boolean del = !rsc.get(tok);
			
			if (del) {
				cur.delete();
				System.out.println("removed " + cur.getPath());
			}
			
			cur = cur.getParentFile();
		}
	}
}
