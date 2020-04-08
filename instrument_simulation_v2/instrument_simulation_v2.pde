import java.util.List;
import java.util.Map;
import controlP5.*;
import oscP5.*;
import netP5.*;

final boolean LEGACYSUPPORT = true;

final int ZINWALDBROWN = color(43, 0, 0);
final int BURLYWOOD    = color(158, 131, 96);
final int PLATINUM     = color(229, 234, 218);
final int ONYX         = color(0, 26, 13);

ControlP5 cp5;
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() 
{
  size(700, 600);
  pixelDensity(2);

  // SETUP CP5 
  cp5 = new ControlP5(this);
  setFont();
  setColor();
  
  // SETUP OSC
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("192.168.1.44", 11000);
  //myRemoteLocation = new NetAddress("192.168.8.100", 11000);
  
  // SETUP VIRTUAL INSTRUMENT
  Instrument instr = new Instrument(this, cp5);
}

void draw() 
{
  background(212);
}

public void setFont() {
  String fontName = "";
  String os = System.getProperty("os.name");
  if (os.contains("Windows")) {
    fontName = "Verdana";
  } else if (os.contains("Mac")) {
    fontName = "AndaleMono";
  }

  if (!fontName.equals("")) {
    IController.FONTTYPE = fontName;
    PFont p = createFont(fontName, 9);
    ControlFont cf = new ControlFont(p, 9);
    cp5.setFont(cf);
  }
}

public void setColor() {
  CColor col = new CColor();
  col.setBackground(ZINWALDBROWN);
  col.setForeground(BURLYWOOD);
  col.setActive(PLATINUM);
  col.setCaptionLabel(ONYX);
  cp5.setColor(col);
}
