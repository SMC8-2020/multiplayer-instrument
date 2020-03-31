import oscP5.*;
import netP5.*;
import controlP5.*;

import java.util.Map;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;

Instrument instr;

void setup ()
{
  size(700, 600);
  pixelDensity(2);
  smooth();
  
  oscP5 = new OscP5(this, 12000);
  cp5   = new ControlP5(this);
  myRemoteLocation = new NetAddress("192.168.1.44", 11000);
  
  instr = new Instrument("smc8");
  
  Module melodySection = instr.addSection("Melody");
  
  Module g1 = instr.addGroupToSection(melodySection, "Sequencer");
  Module g2 = instr.addGroupToSection(melodySection, "LDR");
  Module g3 = instr.addGroupToSection(melodySection, "Mixed");
  
  Module sliders = instr.addModuleToGroup(g1, 0.66f);
  instr.addControllerToModule(sliders, ControllerTags.SLIDERTAG, 8);
  
  Module knobs = instr.addModuleToGroup(g1, 0.34f);
  instr.addControllerToModule(knobs, ControllerTags.KNOBTAG, 2, "Steps", "Select Patch");
  
  Module ldrs = instr.addModuleToGroup(g2, 0.66f);
  instr.addControllerToModule(ldrs, ControllerTags.BUTTONTAG, 4);
  
  Module vol = instr.addModuleToGroup(g2, 0.34f);
  instr.addControllerToModule(vol, ControllerTags.KNOBTAG, 1, "Volume");
  
  Module mixed = instr.addModuleToGroup(g3, 0.645f);
  instr.addControllerToModule(mixed, ControllerTags.KNOBTAG, 2, "Mode", "Key");
  instr.addControllerToModule(mixed, ControllerTags.TOGGLETAG, 1, "2nd Voice");
  instr.addControllerToModule(mixed, ControllerTags.KNOBTAG, 1, "Semitones");
    
  instr.addSection("Rhytm");
    
  instr.fitModules();
}

void draw() 
{
  background(250, 251, 245);
  instr.listenForBroadcastEvent();
  instr.display();
}

public class Rect {
  public float x, y, w, h;
  public Rect (float x, float y, float w, float h) {
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }
  
  public void show() {
    rect(x, y, w, h);
  }
  
}

public static class ControllerTags {
  public static final int SLIDERTAG = 0;
  public static final int KNOBTAG   = 1;
  public static final int BUTTONTAG = 2;
  public static final int TOGGLETAG = 3;
}
