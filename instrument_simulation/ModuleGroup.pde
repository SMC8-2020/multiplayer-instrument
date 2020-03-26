public class ModuleGroup {
  private final int WSPACE = 15;

  private String sectionName;
  private String sectionId;
  private String moduleGroupName;

  private int moduleRX, moduleRY, moduleLX, moduleLY;
  private int moduleRW, moduleRH, moduleLW, moduleLH;

  public ModuleGroup (String sectionName, String sectionId, String moduleGroupName) {
    this.sectionName     = sectionName;
    this.sectionId       = sectionId;
    this.moduleGroupName = moduleGroupName;
  }
  
  public void setBounds(int x, int y, int w, int h, float lrpct) {
    float rx = x;
    float ry = y;
    float rw = (w - w*lrpct);
    float rh = h;
    
    float lx = rx + rw;
    float ly = ry;
    float lw = w*lrpct;
    float lh = rh;
    
    setRightBounds((int)rx, (int)ry, (int)rw, (int)rh);
    setLeftBounds((int)lx, (int)ly, (int)lw, (int)lh);
  }
  
  public void setRightBounds(int x, int y, int w, int h) {
    this.moduleRX = x + WSPACE; 
    this.moduleRY = y + WSPACE;
    this.moduleRW = w - 2*WSPACE; 
    this.moduleRH = h - 2*WSPACE;
  }

  public void setLeftBounds(int x, int y, int w, int h) {
    this.moduleLX = x + WSPACE; 
    this.moduleLY = y + WSPACE;
    this.moduleLW = w - 2*WSPACE; 
    this.moduleLH = h - 2*WSPACE;
  }

  public void addModule(int moduleType, int numControllersInModule, String[] tags) {
  }

  public void fitModules() {
  }

  public void unionModules() {
  }

  public void display() {
    fill(200);
    rect(moduleRX, moduleRY, moduleRW, moduleRH);
    rect(moduleLX, moduleLY, moduleLW, moduleLH);

  }
}