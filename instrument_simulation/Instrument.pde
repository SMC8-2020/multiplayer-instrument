public class Instrument {

  private final int BOXIN = 20;
  private final int SECTION_BOXIN = 20;
  private final int MDGROUP_BOXIN = 7;

  private ArrayList<Module> sections;
  private ArrayList<Module> moduleGroups;
  private ArrayList<Module> controllerModules;

  private String instrumentName = "name_of_instrument";

  private int prevId = -1, prevVal = -1;
  private CallbackListener cb;

  private InstrumentListener lst;

  public Instrument () {
    sections = new ArrayList<Module>();
    moduleGroups = new ArrayList<Module>();
    controllerModules = new ArrayList<Module>();

    lst = new InstrumentListener();
    cp5.addCallback(lst);
  }

  public Instrument(String instrumentName) {
    this();
    this.instrumentName = instrumentName;
  }

  public Module addSection(String sectionName) {
    String prefix = "/" + instrumentName + "/";
    Module section = new Module(prefix + sectionName, 1, SECTION_BOXIN);
    sections.add(section);
    return section;
  }

  public Module addGroupToSection(Module section, String groupName) {
    String prefix = section.moduleName + section.moduleId + "/";
    Module group = new Module(prefix + groupName, 1, MDGROUP_BOXIN);
    section.assignSubModule(group);
    moduleGroups.add(group);
    return group;
  }

  public Module addModuleToGroup(Module group, float weight) {
    String moduleName = group.moduleName + group.moduleId + "/";
    ControllerModule module = new ControllerModule(moduleName); 
    group.assignSubModule(module, weight);
    controllerModules.add(module);
    return module;
  }
  
  public void addControllerToModule(Module module, int type, int num, String...labels) {
    ControllerModule cm = (ControllerModule) module;
    
    String[] _labels = new String[num];
    for (int i = 0; i < num; i++) {
      if (i < labels.length) {
        _labels[i] = labels[i];
        continue;
      }
      _labels[i] = "";
    }
    
    cm.addNumControllers(type, num, _labels);
  }
  
  public void fitModules() {
    setModuleRects();
    fitControllerModules();
  }

  private void setModuleRects() {
    int d = 0;
    int numSections = sections.size();
    int x, y, w, h;

    x = BOXIN;
    y = BOXIN;
    w = (width - (numSections + 1)*BOXIN) / numSections;
    h = (height - height/4) - 2*BOXIN;

    for (int i = 0; i < numSections; i++) {
      sections.get(i).setRect((i + 1)*x + i*w, y, w, h, d + 1);
    }
  }

  private void fitControllerModules() {
    for (int i = 0; i < controllerModules.size(); i++) {
      ControllerModule ctr = (ControllerModule) controllerModules.get(i);
      ctr.fitControllersToContainer();
    }
  }

  public void listenForBroadcastEvent() {
    lst.broadcastOSC();
  }

  public void display() {
    for (int i = 0; i < sections.size(); i++) {
      sections.get(i).display();
    }
  }
}