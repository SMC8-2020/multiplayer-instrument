import themidibus.*;
import javax.sound.midi.MidiMessage;
import oscP5.*;
import netP5.*;

int value = 0;
MidiBus bus; 
NetAddress oscServer;
int sendToPort = 11000;
String serverIP = "192.168.1.81";

void setup() {

  MidiBus.list();
  bus = new MidiBus(this,"APC40 mkII", "APC40 mkII");

  oscServer = new NetAddress(serverIP, sendToPort);
}

void draw() {
  
  
  

  
}

void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  
  // Receive a MidiMessage
  // MidiMessage is an abstract class, the actual passed object will be either javax.sound.midi.MetaMessage, javax.sound.midi.ShortMessage, javax.sound.midi.SysexMessage.
  // Check it out here http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
  println();
  println("MidiMessage Data:");
  println("--------");
  println("Status Byte/MIDI Command:"+message.getStatus());
  String mes = "/smc8/Melody1/Sequencer1/Slider0";
  switch(message.getStatus()) {
    case 176:
        mes = "/smc8/Melody1/Sequencer1/Slider0";
        break;
    case 177:
        mes = "/smc8/Melody1/Sequencer1/Slider1";
        break;
    case 178:
        mes = "/smc8/Melody1/Sequencer1/Slider2";
        break;
    case 179:
        mes = "/smc8/Melody1/Sequencer1/Slider3";
        break;
    case 180:
        mes = "/smc8/Melody1/Sequencer1/Slider4";
        break;
    case 181:
        mes = "/smc8/Melody1/Sequencer1/Slider5";
        break;
    case 182:
        mes = "/smc8/Melody1/Sequencer1/Slider6";
        break;
    case 183:
        mes = "/smc8/Melody1/Sequencer1/Slider7";
        break;
    
  }
  
  OscMessage message1 = new OscMessage(mes);
  for (int i = 1;i < message.getMessage().length;i++) {
    println("Param "+(i+1)+": "+(int)(message.getMessage()[i] & 0xFF));
    
    //if ( i + 1 == 2) {
      
    //  value = (int)(message.getMessage()[i] & 0xFF);
    //  if(value == 48) {
    //    message1 = new OscMessage("/smc8/Melody1/PerformanceModifiers1/Knob0");
    //    float v = map(value, 0, 127, 0, 1023);
    //    value = (int) v;
    //    println(value);
    //    message1.add(value); 
    //    OscP5.flush(message1, oscServer);
        
    //  }
     
      
      
    //}
    
    if ( i + 1 == 3) {
      value = (int)(message.getMessage()[i] & 0xFF);
      float v = map(value, 0, 127, 0, 1023);
      value = (int) v;
      println(value);
      message1.add(value); 
      OscP5.flush(message1, oscServer);
    }
  }
}
