import oscP5.*;
import netP5.*;

NetAddress server;

int sendPort = 11000;
String serverIP = "192.168.8.100";
//String serverIP = "192.168.1.44";


String filename="testfile_ramon.csv";

String[] events;
int[] timestamps;
OscMessage[] messages;

int nextEvent, epoch;

PFont mono;



void setup() {

  size(560, 404);
  pixelDensity(2);
  strokeWeight(2);
  frameRate(100);
  mono = createFont("Andale Mono", 14);
  textFont(mono);
  textAlign(LEFT, TOP);

  events = loadStrings(filename);
  timestamps = new int[events.length];
  messages = new OscMessage[events.length];

  server = new NetAddress(serverIP, sendPort);

  int f = 0;
  for (String event : events) {
    String[] split = split(event, ',');
    timestamps[f] = Integer.parseInt(split[0]); 
    OscMessage m = new OscMessage(split[1]);
    for (int i=0; i<split[2].length(); i++) {
      switch(split[2].charAt(i)) {
      case 'i':
        m.add(Integer.parseInt(split[3+i]));
        break;
      default:
        println("Unknown element " + split[2].charAt(i));
        break;
      }
    }
    messages[f] = m; 
    println(m.toString());
    f++;
  }

  resetPerformance();
}

void resetPerformance() {
  nextEvent = 0;
  epoch = millis();
}


void draw() {

  int currentTime = millis() - epoch;
  while (nextEvent<events.length && timestamps[nextEvent]<=currentTime) {
    OscP5.flush(messages[nextEvent], server);
    println(currentTime - timestamps[nextEvent], ":", messages[nextEvent].toString());
    nextEvent++;
  }

  background(0);

  fill(70, 255, 70, 180);
  text("File:                      Events:                   FPS:", 10, height-23);
  fill(70, 255, 70, 255);
  text(filename, 8+5*9, height-23);
  text(nextEvent + "/" + events.length, 9+32*9, height-23);
  text(frameRate, 13+52*9, height-23);

  //  for (int f=0; f<lines.length; f++) {
  //    fill(70, 255, 70, (int)map(f, 0, lines.length-1, 64, 255));
  //    text(lines[f], 10, f*18+4);
  //  }
}

void keyPressed() {
  if (key=='r' ||key=='R') {
    resetPerformance();
  } 
}
