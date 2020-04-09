import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddressList sendTo = new NetAddressList();

int listeningPort = 11000;
int broadcastPort = 10000;

String connectPattern = "/smc8/connect";
String disconnectPattern = "/smc8/disconnect";

PFont monoMini, mono, monoBig;

String IP;

StringList clients = new StringList();
int lastMessage, currentDecay = 0;
final int DECAY = 10;


void setup() {

  size(412, 268);
  pixelDensity(2);
  noStroke();
  monoMini = createFont("Andale Mono", 14);
  mono = createFont("Andale Mono", 28);
  monoBig = createFont("Andale Mono", 42);

  oscP5 = new OscP5(this, listeningPort);
  IP = oscP5.ip();
}



void draw() {

  background(0);

  fill(70, 255, 70, 255);
  textFont(monoBig);
  textAlign(CENTER, TOP);
  text(IP, width/2, 4);

  textFont(mono);
  if (currentDecay>0) {
    fill(70, 255, 70, map(currentDecay, 1, DECAY, 0, 180));
    text("+             +", width/2, 52);
  } 

  fill(70, 255, 70, 180);
  text(listeningPort + "->" + broadcastPort, width/2, 52);

  fill(70, 255, 70, 180);
  textFont(monoMini);
  textAlign(LEFT, TOP);
  for (int f=0; f<min(clients.size(), 10); f++) {
    int dx = 18;
    int dy = 110+(f%10)*14;
    text(clients.get(f), dx, dy);
  }

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
  oscP5.send(msg, sendTo);
  currentDecay = DECAY;
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
