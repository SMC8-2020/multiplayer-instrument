import oscP5.*;
import netP5.*;

OscP5 oscP5;

int[] noteReceived = {-1, -1, -1, -1};

final int RW = 100;
final int GAP = 20;

PrintWriter output;
int epoch, prevEvent, currentEvent;
final int INACTIVITY = 10000;

void setup() {

  size(260, 260);
  pixelDensity(2);
  strokeWeight(2);
  textSize(60);
  textAlign(CENTER, CENTER);

  epoch = -1;

  oscP5 = new OscP5(this, 10000);
}


void draw() {

  background(0);

  for (int i=0; i<noteReceived.length; i++) {

    int dx = GAP+(RW+GAP)*(i/2);
    int dy = GAP+(i%2)*(RW+GAP);

    fill(0);
    stroke(#111177);
    rect (dx, dy, RW, RW);

    fill(255);
    if (noteReceived[i]!=-1) {
      text(noteReceived[i], dx+RW/2, dy+RW/2-5);
    }
  }
}

void oscEvent(OscMessage theOscMessage) {

  if (!theOscMessage.checkTypetag("ii")) {
    return;
  }

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
    output = createWriter(getFilename());
  }

  String log = String.format("%d,%s,%d,%d", 
    currentEvent-epoch, 
    theOscMessage.addrPattern(), 
    theOscMessage.get(0).intValue(), 
    theOscMessage.get(1).intValue());
  output.println(log); 
  output.flush();

  println(epoch + "     " + (currentEvent-prevEvent) + "     " + (currentEvent-epoch));
  prevEvent = currentEvent;

  if (theOscMessage.checkAddrPattern("/note/on")) {
    int i = theOscMessage.get(0).intValue();
    noteReceived[i] = theOscMessage.get(1).intValue();
    return;
  }

  if (theOscMessage.checkAddrPattern("/note/off")) {
    int i = theOscMessage.get(0).intValue();
    noteReceived[i] = -1;
    return;
  }
}



void stop() {
  output.close();
}



String getFilename() {

  return String.format("%02d%02d%02d_%02d%02d%02d.csv", 
    year(), month(), day(), hour(), minute(), second()
    );
}
