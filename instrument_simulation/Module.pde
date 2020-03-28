public class Module {

  private int BOXIN = 25;
  private Module parent;
  private ArrayList<Module> children;

  protected String moduleName;
  protected int    moduleId;

  private float[] weights;
  private Rect moduleRect = null;

  public Module(String name, int id) {
    moduleName = name;
    moduleId   = id;
    parent     = null;
    children   = new ArrayList<Module>();
    weights = new float[0];
  }

  public Module(String name, int id, int wspace) {
    this(name, id);
    BOXIN = wspace;
  }

  public void setParent(Module parent) {
    this.parent = parent;
  }

  public Module getParent() {
    return this.parent;
  }

  public Rect getRect() {
    return this.moduleRect;
  }

  public void assignSubModule(Module module) {
    children.add(module);
    weights = append(weights, 0);
    for (int i = 0; i < children.size(); i++) {
      weights[i] = 1.0f / (float) children.size();
    } 
    
    module.setParent(this);
  }

  public void assignSubModule(Module module, float weight) {
    children.add(module);
    weights = append(weights, weight);
    module.setParent(this);
  }

  public void assignSubModules(Module[] modules) {
    for (int i = 0; i < modules.length; i++) {
      children.add(modules[i]);
      modules[i].setParent(this);
    }
  }

  public void setRect(float x, float y, float w, float h, int d) {
    moduleRect = new Rect(x, y, w, h);

    float xn, yn;
    float[] wn, hn;
    float alpha = d % 2;

    int numChildren = children.size();
    wn = new float[numChildren + 1];
    hn = new float[numChildren + 1];

    for (int i = 1; i < numChildren + 1; i++) {
      if (alpha == 0) {
        wn[i] = (w - (numChildren + 1)*BOXIN) * weights[i - 1];
        hn[i] = h - 2*BOXIN;
      } else {
        hn[i] = (h - (numChildren + 1)*BOXIN) * weights[i - 1];
        wn[i] = w - 2*BOXIN;
      }
    }
    
    wn[0] = 0; hn[0] = 0;
    for (int i = 0; i < numChildren; i++) {
      xn = (i*(1.0f - alpha) + 1)*BOXIN + x + i*(1.0f - alpha)*wn[i];
      yn = (i*alpha + 1)*BOXIN + y + i*alpha*hn[i];
      children.get(i).setRect(xn, yn, wn[i + 1], hn[i + 1], d + 1);
    }
  }

  public void display() {
    if (moduleRect != null) { 
      fill(100, 200, 30, 60);
      rect(moduleRect.x, moduleRect.y, moduleRect.w, moduleRect.h);
    }

    if (children.size() != 0) {
      for (Module m : children) {
        m.display();
      }
    }
  }
}