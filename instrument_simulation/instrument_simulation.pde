import controlP5.*;
ControlP5 cp5;

Instrument instr;

void setup ()
{
  size(700, 600);
  smooth();

  cp5 = new ControlP5(this);

  instr = new Instrument();

  instr.addSection("Melody", 1);
  
  ////
  instr.addModuleGroupToSection("Sequencer", 1, "Melody");
  
  instr.addModuleToModuleGroup("Sliders", "Sequencer", 0.7f);
  instr.addControllerToModule(ControllerTags.SLIDERTAG, 8, "Sliders");

  instr.addModuleToModuleGroup("Knobs", "Sequencer", 0.3f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 2, "Knobs");
  ////
  
  ////
  instr.addModuleGroupToSection("LDR", 1, "Melody");
  
  instr.addModuleToModuleGroup("Buttons", "LDR", 0.7f);
  instr.addControllerToModule(ControllerTags.BUTTONTAG, 4, "Buttons");
  
  instr.addModuleToModuleGroup("Knob", "LDR", 0.3f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 1, "Knob");
  ////
  
  instr.addModuleGroupToSection("Mixed", 1, "Melody");
  instr.addModuleToModuleGroup("Knobs/Toggles", "Mixed", 0.7f);
  instr.addControllerToModule(ControllerTags.KNOBTAG, 2, "Knobs/Toggles");

  instr.addSection("Rhytm", 1);
  instr.fitModules();
}

void draw() 
{
  background(200);
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