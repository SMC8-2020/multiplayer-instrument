import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddressList sendTo = new NetAddressList();

final int BACK1  = color(43, 0, 0);
final int BACK2  = color(116, 92, 85);
final int BACK3  = color(161, 148, 137);
final int BACK4  = color(188, 182, 168);
final int HEADER = color(222, 184, 135);
final int TITLE  = color(0, 26, 13);

int listeningPort = 11000;
int broadcastPort = 10000;

String connectPattern = "/smc8/connect";
String disconnectPattern = "/smc8/disconnect";

PFont monoHeader, mono, monoBig, monoExtra;



String IP;

StringList clients = new StringList();
int lastMessage, currentDecay = 0;
final int DECAY = 8;

Panel pServer, pIP, pPorts, pClients, pRecorder, pLog, pInfo;

OSCRecorder recorder;
boolean forceIntValues = true;

void setup() {

  size(800, 408);
  pixelDensity(2);
  noStroke();
  monoHeader = createFont("Andale Mono", 9);
  mono = createFont("Andale Mono", 12);
  monoBig = createFont("Andale Mono", 27);
  monoExtra = createFont("Andale Mono", 36);

  oscP5 = new OscP5(this, listeningPort);
  IP = oscP5.ip();

  recorder = new OSCRecorder("server");

  pServer = new Panel(Panel.marginhor, Panel.marginver, width/2-Panel.marginhor*2, 155, BACK3, "SERVER");
  pServer.toScreenBottom();

  pIP = new Panel(pServer, 59, BACK4, "IP"); 

  pPorts = new Panel(pIP.x, pIP.nextBelow(), pIP.w, 49, BACK4, "PORTS");

  pClients = new Panel(pIP.x, pPorts.nextBelow(), pIP.w, 100, BACK4, "CLIENTS");
  pClients.adjustHeightToParent(pServer);

  pRecorder = new Panel(pServer.nextLeft(), Panel.marginver, width/2-Panel.marginhor*2, 155, BACK3, "RECORDER");
  pRecorder.toScreenBottom();
  pRecorder.toScreenRight();

  pLog = new Panel(pRecorder, 296+12+12, BACK4, "LOG");

  pInfo = new Panel(pLog.x, pLog.nextBelow(), pLog.w, 100, BACK4, "INFO");
  pInfo.adjustHeightToParent(pRecorder);
}



void draw() {

  background(BACK1);

  pServer.draw();
  pIP.draw();
  pPorts.draw();
  pClients.draw();
  pRecorder.draw();
  pLog.draw();
  pInfo.draw();

  fill(TITLE);
  textFont(monoExtra);
  textAlign(CENTER, CENTER);
  PVector center = pIP.canvasCenter();
  text(IP, center.x, center.y-5);

  textFont(monoBig);
  center = pPorts.canvasCenter();
  text(listeningPort + "->" + broadcastPort, center.x, center.y-4);

  if (currentDecay>0) {
    fill(0, 26, 13, map(currentDecay, 1, DECAY, 0, 255));
    text("+             +", center.x, center.y-4);
  } 

  fill(TITLE);
  textFont(mono);
  textAlign(LEFT, TOP);
  PVector origin = pClients.canvasOrigin();
  for (int f=0; f<min(clients.size(), 10); f++) {
    float dy = origin.y+f*20-2;
    text(clients.get(f), origin.x, dy);
  }

  textFont(mono);  
  origin = pLog.canvasOrigin();
  for (int f=0; f<OSCRecorder.logitems; f++) {
    float dy = origin.y+f*12-5;
    text(recorder.lines[f], origin.x, dy);
  }

  origin = pInfo.canvasOrigin();
  text("File: " + recorder.filename + "   Events: " + recorder.counter, origin.x, origin.y-4);

  if (currentDecay > 0) {
    currentDecay--;
  }
}



void oscEvent(OscMessage msg) {

  //Add one new IP to the list
  if (msg.addrPattern().equals(connectPattern)) {
    String deviceName = "";
    if (msg.typetag()=="s") {
      deviceName = msg.get(0).stringValue();
    }
    connect(msg.netAddress().address(), deviceName);
    return;
  }

  //Remove IP from list
  if (msg.addrPattern().equals(disconnectPattern)) {
    disconnect(msg.netAddress().address());
    return;
  }

  //Broadcast the message
   if (forceIntValues && msg.typetag().equals("f")) {
    OscMessage intMsg = new OscMessage(msg.addrPattern());
    intMsg.add((int)msg.get(0).floatValue());
    oscP5.send(intMsg, sendTo);
  } else {
    oscP5.send(msg, sendTo);
  }
  currentDecay = DECAY;

  //Record the message
  recorder.record(msg);
}



private void connect(String ip, String name) {
  if (!sendTo.contains(ip, broadcastPort)) {
    sendTo.add(new NetAddress(ip, broadcastPort));
    clients.append(ip + ":" + broadcastPort + " " + name);
    println("### adding "+ip+" to the list.");
  } else {
    println("### "+ip+" is already connected.");
  }
  println("### currently there are "+sendTo.list().size()+" remote locations connected.");
}



private void disconnect(String ip) {
  if (sendTo.contains(ip, broadcastPort)) {
    sendTo.remove(ip, broadcastPort);
    clients = new StringList();
    for (int f=0; f<sendTo.list().size(); f++) {
      clients.append(sendTo.list().get(f).toString());
    }
    println("### removing "+ip+" from the list.");
  } else {
    println("### "+ip+" is not connected.");
  }
  println("### currently there are "+sendTo.list().size()+" remote locations connected.");
}



void keyPressed() {
  if (key=='R' || key=='r') {
    recorder.startNewRecording();
  }
}
