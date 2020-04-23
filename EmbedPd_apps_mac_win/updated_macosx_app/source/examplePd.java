import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.puredata.processing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class examplePd extends PApplet {


PureDataProcessing pd;

public void setup() 
{
  
  pd = new PureDataProcessing(this, 44100, 0, 2);
  pd.openPatch("test.pd");
  pd.start();
}

public void draw()
{
  background(0);
  ellipse(mouseX, mouseY, 20, 20);
  pd.sendFloat("pitch", (float)mouseX / (float)width); // Send float message to symbol "pitch" in Pd.
  pd.sendFloat("volume", (float)mouseY / (float)height);
}

public void pdPrint(String s) {
  println(s);
}

  public void settings() {  size(400, 400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "examplePd" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
