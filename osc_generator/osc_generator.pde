import themidibus.*;
import oscP5.*;
import netP5.*;

MidiBus bus; 

NetAddress oscServer;
int sendToPort = 11000;
String serverIP = "192.168.8.100";

final int elements = 100;
final int threshold = 125;

float[][] trigger = new float[4][100];
float[][] note = new float[4][100];
int[] notePlaying = {-1, -1, -1, -1};
int[] chordnotes = {0, 3, 7, 10};

float[] t = {0, 0, 0, 0};
float[] dt = {0.005, 0.015, 0.02, 0.01};

//float maxN = -100;
//float minN =  100;

void setup() {

  size(550, 550);
  pixelDensity(2);
  noFill();
  strokeWeight(2);

  noiseDetail(4, 0.5);
  noiseSeed(0);

  MidiBus.list();
  bus = new MidiBus(this, -1, "Bus IAC 1");

  oscServer = new NetAddress(serverIP, sendToPort);
}



void draw() {

  background(0);

  for (int i = 0; i<4; i++) {

    for (int f = 0; f<elements; f++) {
      trigger[i][f] = noise(i, t[i]+f/20.0)*200;
      note[i][f] = noise(i+20, t[i]+f/15.0)*200;
    }

    if (trigger[i][elements/2]>threshold) {
      if (notePlaying[i]==-1) {
        int intValue = int(note[i][elements/2]/4);
        notePlaying[i]=36+12*(intValue/12) + chordnotes[intValue % chordnotes.length];
        bus.sendNoteOn(i, notePlaying[i], 100);
        OscMessage message = new OscMessage("/note/on");
        message.add(i); 
        message.add(notePlaying[i]); 
        OscP5.flush(message, oscServer);
      }
    } else {
      if (notePlaying[i]!=-1) {
        bus.sendNoteOff(i, notePlaying[i], 100);
        OscMessage message = new OscMessage("/note/off");
        message.add(i);         
        message.add(notePlaying[i]); 
        OscP5.flush(message, oscServer);        
        notePlaying[i]=-1;
      }
    }

    int dx = 50+250*(i/2);
    int dy = 50+(i%2)*250;

    stroke(#111177);
    if (notePlaying[i]>-1) {
      stroke(#5555cc);
    }
    line (100+dx, dy, 100+dx, 200+dy);
    line (dx+90, (200-threshold)+dy, dx+110, (200-threshold)+dy);

    stroke(#dd3333);
    for (int f = 0; f<99; f++) {
      line(f*2+dx, dy+200-note[i][f], (f+1)*2+dx, dy+200-note[i][f+1]);
    }

    stroke(#33dd33);
    if (notePlaying[i]>-1) {
      stroke(#66ee66);
      strokeWeight(3);
    }
    for (int f = 0; f<99; f++) {
      line(f*2+dx, dy+200-trigger[i][f], (f+1)*2+dx, dy+200-trigger[i][f+1]);
    }
    strokeWeight(2);

    t[i] += dt[i];
  }

  stroke(#111177);
  rect (50, 50, 200, 200);
  rect (300, 50, 200, 200);
  rect (50, 300, 200, 200);
  rect (300, 300, 200, 200);
}
