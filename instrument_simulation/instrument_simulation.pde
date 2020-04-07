import oscP5.*;
import netP5.*;
import controlP5.*;
import java.util.Map;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;

Instrument instr;

PFont mono;

void setup ()
{
  size(700, 600);
  pixelDensity(2);
  smooth();

  mono = createFont("Andale Mono", 12);
  textFont(mono);

  oscP5 = new OscP5(this, 12000);
  cp5   = new ControlP5(this);
  myRemoteLocation = new NetAddress("192.168.1.44", 11000);

  instr = new Instrument("smc8");
  instr.createFromJson("smc8_sections.json");
  instr.fitModules();
}

void draw() 
{
  background(250, 251, 245);
  instr.listenForBroadcastEvent();
  instr.display();
}



//////////////////////////////////////////////
//                                          //
//        UTILITY CLASSES AND FUNCTIONS     //
//                                          //
//////////////////////////////////////////////

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