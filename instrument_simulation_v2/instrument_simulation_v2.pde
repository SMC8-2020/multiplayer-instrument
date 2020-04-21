import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.Objects;
import controlP5.*;
import oscP5.*;
import netP5.*;

final boolean DEBUG = true;
final boolean LEGACYSUPPORT = true;

//final String HOST = "192.168.1.44";
final String HOST = "192.168.1.81";
//final String HOST = "127.0.0.1";
final int    PORT = 11000;

final int ZINWALDBROWN = color(43, 0, 0);
final int BURLYWOOD    = color(158, 131, 96);
final int PLATINUM     = color(229, 234, 218);
final int ONYX         = color(0, 26, 13);

InstrumentModel model;
ControllerHandler handler;
InstrumentSectionView view;

void setup() 
{
  size(700, 600);
  //size(600, 600);
  pixelDensity(2);

  // SETUP CP5 
  ControlP5 cp5 = new ControlP5(this);
  //setFont(cp5);
  setColor(cp5);

  // SETUP OSCP5
  OscP5 oscP5 = new OscP5(this, 12000);
  NetAddress remoteLocation = new NetAddress(HOST, PORT);

  // SETUP VIRTUAL INSTRUMENT
  model   = new InstrumentModel(oscP5, remoteLocation);
  handler = new ControllerHandler();
  view    = new InstrumentSectionView(cp5);
  
  model.setView(view);
  handler.setModel(model);
  view.setHandler(handler);
  
  model.initView();
}

void keyPressed() {

  if (key == 'q') {
  }

  if (key == 'w') {
  }
  
}


void draw() 
{
  background(212);
  handler.updateContinousEvents();
}

public void setFont(ControlP5 cp5) {
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

public void setColor(ControlP5 cp5) {
  CColor col = new CColor();
  col.setBackground(ZINWALDBROWN);
  col.setForeground(BURLYWOOD);
  col.setActive(PLATINUM);
  col.setCaptionLabel(ONYX);
  cp5.setColor(col);
}
