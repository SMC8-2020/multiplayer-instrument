import oscP5.*;
import netP5.*;
import controlP5.*;

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
  myRemoteLocation = new NetAddress("192.168.8.100", 11000);
  
  instr = new Instrument("smc8");
  
  Module melodySection = instr.addSection("Melody");
  
  Module g1 = instr.addGroupToSection("Sequencer", melodySection);
  Module g2 = instr.addGroupToSection("LDR", melodySection);
  Module g3 = instr.addGroupToSection("Mixed", melodySection);
  
  Module sliders = instr.addModuleToGroup(g1, 0.66f);
  instr.addControllerToModule(ControllerTags.SLIDERTAG, 8, sliders);
  
  Module knobs = instr.addModuleToGroup(g1, 0.34f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 2, knobs);
  
  Module ldrs = instr.addModuleToGroup(g2, 0.66f);
  instr.addControllerToModule(ControllerTags.BUTTONTAG, 4, ldrs);
  
  Module vol = instr.addModuleToGroup(g2, 0.34f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 1, vol);
  
  Module mixed = instr.addModuleToGroup(g3, 0.645f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 2, mixed);
  instr.addControllerToModule(ControllerTags.TOGGLETAG, 2, mixed);
    
  instr.addSection("Rhytm");
    
  instr.fitModules();
}

void draw() 
{
  background(255);
  instr.display();
}

public static class Rect {
  public float x, y, w, h;
  public Rect (float x, float y, float w, float h) {
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }
}

public static class ControllerTags {
  public static final int SLIDERTAG = 0;
  public static final int KNOBTAG   = 1;
  public static final int BUTTONTAG = 2;
  public static final int TOGGLETAG = 3;
}