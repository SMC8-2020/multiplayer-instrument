import oscP5.*;
import netP5.*;

NetAddress server;

int sendPort = 11000;
String serverIP = "127.0.0.1";
//String serverIP = "192.168.8.100";
//String serverIP = "192.168.1.44";

PFont mono;

Performance p, reset;
boolean isResetting = false;

void setup() {

  size(560, 404);
  pixelDensity(2);
  strokeWeight(2);
  frameRate(100);
  mono = createFont("Andale Mono", 14);
  textFont(mono);
  textAlign(LEFT, TOP);

  server = new NetAddress(serverIP, sendPort);

  p = new Performance("demo_04.csv", server);
  p.startPerformance();

  reset = new Performance("reset.csv", server);
}



void draw() {

  if (!isResetting) {
    p.tick();
  } else {
    reset.tick();
    if (reset.hasEnded) {
      isResetting = false;
    }
  }

  background(0);

  if (!isResetting) {
    fill(70, 255, 70, 180);
    text("File:                      Events:                   FPS:", 10, height-23);
    fill(70, 255, 70, 255);
    text(p.filename, 8+5*9, height-23);
    text(p.nextEvent + "/" + p.timestamps.length, 9+32*9, height-23);
    text(frameRate, 13+52*9, height-23);
  }

  //  for (int f=0; f<lines.length; f++) {
  //    fill(70, 255, 70, (int)map(f, 0, lines.length-1, 64, 255));
  //    text(lines[f], 10, f*18+4);
  //  }
}




void keyPressed() {
  if (key=='P' && !isResetting) {
    p.loadPerformance();
    p.startPerformance();
  } else if (key=='p' && !isResetting) {
    p.startPerformance();
  } else if (key=='r' || key=='R') {
    p.stopPerformance();
    reset.startPerformance();
    isResetting = true;
  }
}
