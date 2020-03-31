public class Instrument {

  private final int BOXIN = 20;
  private final int SECTION_BOXIN = 20;
  private final int MDGROUP_BOXIN = 7;

  private ArrayList<Module> sections;
  private ArrayList<Module> moduleGroups;
  private HashMap<String, Module> controllerModules;

  private String instrumentName = "name_of_instrument";

  private InstrumentListener lst;

  public Instrument () {
    sections = new ArrayList<Module>();
    moduleGroups = new ArrayList<Module>();
    controllerModules = new HashMap<String, Module>();

    lst = new InstrumentListener(controllerModules);
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

  public Module addModuleToGroup(Module group, String mapName, float weight) {
    String moduleName = group.moduleName + group.moduleId + "/" + mapName + "/";
    ControllerModule module = new ControllerModule(moduleName); 
    group.assignSubModule(module, weight);
    controllerModules.put(moduleName, module);
    return module;
  }
  
  public void addControllerToModule(Module module, int type, int num, String...labels) {
    ControllerModule cm = (ControllerModule) module;
    for (int i = 0; i < num; i++) {
      String label = i < labels.length ? labels[i] : "";
      cm.addController(type, label);
    }    
  }
  
  public void fitModules() {
    setConsoleRect();
    setModuleRects();
    fitControllerModules();
  }
  
  private void setConsoleRect() {
    float x, y, w, h;
    x = BOXIN;
    y = height - height/4;
    w = width - 2*BOXIN;
    h = height/4 - BOXIN;
    lst.setConsoleRect(new Rect(x, y, w, h));
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
    for (Map.Entry entry : controllerModules.entrySet()) {
      ControllerModule ctr = (ControllerModule) entry.getValue();
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
    
    lst.display();
  }
}