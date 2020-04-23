import org.puredata.processing.*;
PureDataProcessing pd;

void setup() 
{
  size(400, 400);
  pd = new PureDataProcessing(this, 44100, 0, 2);
  pd.openPatch("test.pd");
  pd.start();
}

void draw()
{
  background(0);
  ellipse(mouseX, mouseY, 20, 20);
  pd.sendFloat("pitch", (float)mouseX / (float)width); // Send float message to symbol "pitch" in Pd.
  pd.sendFloat("volume", (float)mouseY / (float)height);
}

void pdPrint(String s) {
  println(s);
}
