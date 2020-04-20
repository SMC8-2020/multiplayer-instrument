import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.puredata.processing.PureData; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class HelloPd extends PApplet {

/**
 * A sample Processing applet using libpd, illustrating all major features.
 * 
 * Based on RJ Marsan's YayProcessingPD (https://github.com/rjmarsan/YayProcessingPD).
 * 
 * @author Peter Brinkmann (peter.brinkmann@gmail.com)
 */



PureData pd;

public void setup() {
  //fullScreen();
  
  ellipseMode(CENTER);
  pd = new PureData(this, 44100, 0, 2);
  //pd.unpackAndOpenPatch("test.tar", "test.pd");
  pd.openPatch("test.pd");
  // pd.subscribe("foo");  // Uncomment if you want to receive messages sent to the receive symbol "foo" in Pd.
  pd.start();
}

public void draw() {
  background(0);
  ellipse(mouseX, mouseY, 20, 20);
  pd.sendFloat("pitch", (float)mouseX / (float)width); // Send float message to symbol "pitch" in Pd.
  pd.sendFloat("volume", (float)mouseY / (float)height);
}

/*
// Implement methods like the following if you want to receive messages from Pd.
// You'll also need to subscribe to receive symbols you're interested if you want
// to receive messages.
//
// Note that invocations of these methods will occur before the draw method, and
// so you can't use any graphics commands in here.

void pdPrint(String s) {
  // Handle string s, printed by Pd
}

void receiveBang(String source) {
  // Handle bang sent to symbol source in Pd
}

void receiveFloat(String source, float x) {
  // Handle float x sent to symbol source in Pd
}

void receiveSymbol(String source, String sym) {
  // Handle symbol sym sent to symbol source in Pd
}
*/
  public void settings() {  size(400, 400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "HelloPd" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
