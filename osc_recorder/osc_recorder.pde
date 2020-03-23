import oscP5.*;
import netP5.*;

OscP5 oscP5;

int[] noteReceived = {-1, -1, -1, -1};

int rw = 100;
int gap = 20;

void setup() {

  size(260, 260);
  pixelDensity(2);
  strokeWeight(2);
  textSize(60);
  textAlign(CENTER, CENTER);

  oscP5 = new OscP5(this, 12000);
}


void draw() {

  background(0);


  for (int i=0; i<noteReceived.length; i++) {

    int dx = gap+(rw+gap)*(i/2);
    int dy = gap+(i%2)*(rw+gap);

    fill(0);
    stroke(#111177);
    rect (dx, dy, rw, rw);

    fill(255);
    if (noteReceived[i]!=-1) {
      text(noteReceived[i], dx+rw/2, dy+rw/2-5);
    }
  }
}

void oscEvent(OscMessage theOscMessage) {

  if (!theOscMessage.checkTypetag("ii")) {
    return;
  }

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
