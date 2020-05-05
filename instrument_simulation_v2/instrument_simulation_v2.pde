import org.puredata.processing.*;
import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.Objects;
import java.util.Random;
import controlP5.*;
import oscP5.*;
import netP5.*;

final boolean LOG         = true;
final boolean DEBUG       = true;
final boolean NETWORK     = false;
final boolean RENDERX2    = false;
final boolean SECTIONLOCK = false;



final int ZINWALDBROWN = color(43, 0, 0);
final int BURLYWOOD    = color(158, 131, 96);
final int PLATINUM     = color(229, 234, 218);
final int PLATINUM_40  = color(229, 234, 218, 100);
final int ONYX         = color(0, 26, 13);



String HOST;
final String DEFAULTHOST = "127.0.0.1";
final int    PORT        = 11000;

InstrumentModel model;
ControllerHandler handler;
InstrumentSectionView view;

PureDataProcessing pd = null;

void setup() 
{
  size(1020, 595);
  
  if (RENDERX2) {
    pixelDensity(2);
  }
 
  // SETUP CP5 
  ControlP5 cp5 = new ControlP5(this);
  setColor(cp5);

  // SETUP MODEL
  if (NETWORK) {
    setupNetwork();
  } else {
    try {
      setupPd();
    } catch (Exception e) {
      e.printStackTrace();
      setupNetwork();
    }
  }

  // SETUP VIRTUAL INSTRUMENT
  handler = new ControllerHandler();
  view    = new InstrumentSectionView(cp5);

  model.setView(view);
  handler.setModel(model);
  view.setHandler(handler);

  model.initView();
  
  prepareExitHandler();
}

void draw() 
{
  background(ZINWALDBROWN);
  model.renderInstrumentID();
}

public void setupNetwork() {
  OscP5 oscP5 = new OscP5(this, 12000);
  HOST = oscP5.ip();
  NetAddress remoteLocation = new NetAddress(HOST, PORT);
  model = new InstrumentModel(oscP5, remoteLocation);
}

public void setupPd() {
  pd = new PureDataProcessing(this, 44100, 0, 2);
  pd.openPatch("puredata/instrument.pd");
  String recv = "controlmsg";
  model = new InstrumentModel(pd, recv);
}

public void setColor(ControlP5 cp5) {
  CColor col = new CColor();
  col.setBackground(ZINWALDBROWN);
  col.setForeground(BURLYWOOD);
  col.setActive(PLATINUM);
  col.setCaptionLabel(ONYX);
  cp5.setColor(col);
}

void pdPrint(String s) {
  if (DEBUG){
    if (!s.contains("warning")) {
      if (s.contains("print:")){
        s = s.substring(7);
      }
      s = "from Pd: " + s;
      println(s);
    }
  } 
}

void prepareExitHandler() {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run() {
      System.out.println("Shutting down application " + this);
      if (model != null) {
        model.saveRecordToServer();
      }
      if (pd != null) {
        pd.stop();
      }
      stop();
    }
  }));
}
