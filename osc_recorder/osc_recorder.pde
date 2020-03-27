import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress server;

PrintWriter output;
String filename;
int epoch, prevEvent, currentEvent, eventCounter;
final int INACTIVITY = 10000;

PFont mono;

String[] lines = new String[20];

void setup() {

  size(560, 404);
  pixelDensity(2);
  strokeWeight(2);
  mono = createFont("Andale Mono", 14);
  textFont(mono);
  textAlign(LEFT, TOP);

  epoch = -1;

  initBuffer();

  filename="";

  server = new NetAddress("192.168.8.100",11000);
  oscP5 = new OscP5(this, 10000);
  
  OscMessage m = new OscMessage("/smc8/connect", new Object[0]);
  OscP5.flush(m, server);
}


void draw() {

  background(0);

  for (int f=0; f<lines.length; f++) {
    fill(70, 255, 70, (int)map(f, 0, lines.length-1, 64, 255));
    text(lines[f], 10, f*18+4);
  }

  fill(70, 255, 70, 180);
  text("File:                      Events:", 10, lines.length*18+22);
  fill(70, 255, 70, 255);
  text(filename, 52, lines.length*18+22);
  text(eventCounter, 296, lines.length*18+22);
}

void oscEvent(OscMessage theOscMessage) {

  currentEvent = millis();
  if (currentEvent-prevEvent >= INACTIVITY) {
    if (epoch >= 0) {
      output.close();
    }
    epoch = -1;
  }

  if (epoch < 0) {
    epoch = currentEvent;
    prevEvent = currentEvent;
    filename = getFilename();
    output = createWriter(filename);
    initBuffer();
  }

  String typetag = theOscMessage.typetag();

  String log = String.format("%d,%s,%s", 
    currentEvent-epoch, 
    theOscMessage.addrPattern(), 
    typetag);

  //println(typetag);
  for (int f=0; f<typetag.length(); f++) {
    switch(typetag.charAt(f)) {
    case 'i':
      log += "," + theOscMessage.get(f).intValue();
      break;
    case 'c':
      log += ",'" + theOscMessage.get(f).charValue()+"'";
      break;
    case 's':
      log += ",'" + theOscMessage.get(f).stringValue()+"'";
      break;
    case 'f':
      log += "," + theOscMessage.get(f).floatValue();
      break;
    case 'T':
      log += ",true";
      break;    
    case 'F':
      log += ",false";
      break;
    default:
      println("Unknown element " + typetag.charAt(f));
      break;
    }
  }

  output.println(log); 
  output.flush();

  arrayCopy(lines, 1, lines, 0, lines.length-1);
  lines[lines.length-1] = log;
  eventCounter++;

  prevEvent = currentEvent;
}



void stop() {
  output.close();
}



String getFilename() {

  return String.format("%02d%02d%02d_%02d%02d%02d.csv", 
    year(), month(), day(), hour(), minute(), second()
    );
}


void initBuffer() {
  eventCounter = 0;
  for (int f=0; f<lines.length; f++) {
    lines[f]="";
  }
}
