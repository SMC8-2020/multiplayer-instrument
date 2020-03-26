public class Section {

  private PApplet p;

  private String sectionName = "Section";
  private String sectionId   = "0";

  private int sectionX, sectionY;
  private int sectionW, sectionH;

  private ArrayList<ModuleGroup> groups;

  public Section (PApplet p, int x, int y, int w, int h) {

    groups = new ArrayList<ModuleGroup>();

    this.sectionX = x; 
    this.sectionY = y;
    this.sectionW = w; 
    this.sectionH = h;
    this.p = p;
  }

  public ModuleGroup addModuleGroup (String moduleGroupName) {
    ModuleGroup group = new ModuleGroup(this.sectionName, this.sectionId, moduleGroupName);
    groups.add(group);

    int numgroups = groups.size();
    int moduleGroupWidth  = sectionW;
    int moduleGroupHeight = sectionH / numgroups;

    for (int i = 0; i < numgroups; i++) {
      groups.get(i).setBounds(
        sectionX, 
        sectionY + moduleGroupHeight*i, 
        moduleGroupWidth, 
        moduleGroupHeight,
        0.3f
        );
    }

    return group;
  }
  
  public void display() {
    for (ModuleGroup g : groups) {
      g.display();
    }
  }
  
}