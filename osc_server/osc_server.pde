import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddressList sendTo = new NetAddressList();

int listeningPort = 11000;
int broadcastPort = 10000;

String connectPattern = "/smc8/connect";
String disconnectPattern = "/smc8/disconnect";



void setup() {
  oscP5 = new OscP5(this, listeningPort);
  frameRate(25);
}



void draw() {
  background(0);
}



void oscEvent(OscMessage msg) {
  
  //Add one new IP to the list
  if (msg.addrPattern().equals(connectPattern)) {
    connect(msg.netAddress().address());
    return;
  }

  //Remove IP from list
  if (msg.addrPattern().equals(disconnectPattern)) {
    disconnect(msg.netAddress().address());
    return;
  }

  //Broadcast the message
  oscP5.send(msg, sendTo);
}



private void connect(String ip) {
  if (!sendTo.contains(ip, broadcastPort)) {
    sendTo.add(new NetAddress(ip, broadcastPort));
    println("### adding "+ip+" to the list.");
  } else {
    println("### "+ip+" is already connected.");
  }
  println("### currently there are "+sendTo.list().size()+" remote locations connected.");
}



private void disconnect(String ip) {
  if (sendTo.contains(ip, broadcastPort)) {
    sendTo.remove(ip, broadcastPort);
    println("### removing "+ip+" from the list.");
  } else {
    println("### "+ip+" is not connected.");
  }
  println("### currently there are "+sendTo.list().size()+" remote locations connected.");
}
