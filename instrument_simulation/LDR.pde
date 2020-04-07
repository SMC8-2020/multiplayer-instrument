public class LDR extends Button {
  
  private final float SAMPLERATE = frameRate;
  private float frequency;
  
  public LDR (ControlP5 cp5, String name) {
    super(cp5, name);
    frequency = random(0.1f, 3.0f);
  }
  
  @Override public float getValue() {
    return getBooleanValue() ? getNext() : 0.0f;
  }
  
  @Override public void draw(PGraphics p) {
    super.draw(p);
  }
  
  private float getNext() {
    return random(0, 1023);
  }
  
}