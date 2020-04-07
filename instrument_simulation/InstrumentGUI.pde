public static class InstrumentGUI {

  private static final float TEXT_PIXELOS  = 1.0f;
  private static final float TEXT_DEFAULTW = 12.0f;

  private static PApplet pa;

  public static ModuleWindow createSubWindowOf(ModuleWindow container, float idx, float sx, float sy, float weight) {
    float x, y, w, h;
   
        
    
    return null;
  }
  

  public interface Sizeable {
    public void setPosition(float x, float y);
    public void setSize(float w, float h);
  }

  public final class ModuleWindow implements Sizeable {
    public float x, y, w, h;
    public float weight;
    public boolean empty;

    public ModuleWindow() {
      this.empty = true;
    }

    public ModuleWindow(float x, float y, float w, float h, float weight) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.weight = weight;
      this.empty = false;
    }

    public void setPosition(float x, float y) {
      this.x = x;
      this.y = y;
    }

    public void setSize(float w, float h) {
      this.w = w;
      this.h = h;
    }
  }

  public final class Label {
    private String str;
    private float textH;
    private float x, y, size;

    public Label (String label, float x, float y, float s) {
      pa.textSize(TEXT_DEFAULTW);
      this.str = label.trim().toUpperCase();
      this.textH = (pa.textDescent()+pa.textAscent());
      this.size = TEXT_DEFAULTW / this.textH * (s/4);
      this.x = x + s/2.0f;
      this.y = y + TEXT_PIXELOS + this.size - pa.textDescent();
    }

    public void show() {
      pa.fill(255);
      pa.textSize(this.size);
      pa.textAlign(CENTER, CENTER);
      pa.text(this.str, this.x, this.y);
    }
  }
}