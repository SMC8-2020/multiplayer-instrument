import oscP5.*;
import netP5.*;

NetAddress server;

int sendPort = 10000;
String serverIP = "127.0.0.1";
//String serverIP = "192.168.8.100";
//String serverIP = "192.168.1.44";

PFont mono;
PImage background;

Performance p, reset;
boolean isResetting = false;

void setup() {

  size(400, 370);
  noStroke();
  fill(255);
  frameRate(100);
  mono = createFont("Andale Mono", 14);
  textFont(mono);
  textAlign(RIGHT, CENTER);

  background = loadImage("background.png");

  server = new NetAddress(serverIP, sendPort);

  p = new Performance("1B4868_20200506_220405.csv", server);
  p.startPerformance();

  reset = new Performance("reset.csv", server);
}



void draw() {

  background(background);

  if (!isResetting) {
    p.tick();
  } else {
    reset.tick();
    if (reset.hasEnded) {
      isResetting = false;
    }
  }

  if (!isResetting) {
    fill(255);
    text(p.nextEvent + "/" + p.timestamps.length, 380, 317);
    text(frameRate, 380, 343);
    p.update();
    p.draw();
  }

  //text(mouseX + "," + mouseY, mouseX, mouseY);
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
