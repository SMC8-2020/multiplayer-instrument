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

  public Instrument () {
    sections = new ArrayList<Module>();
    moduleGroups = new ArrayList<Module>();
    controllerModules = new ArrayList<Module>();

    this.cb = new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        onControllerChanged(event);
      }
    };

    cp5.addCallback(this.cb);
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
  
  public Module addGroupToSection(String groupName, Module section) {
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
  
  public void addControllerToModule(int type, int num, Module module) {
    ControllerModule cm = (ControllerModule) module;
    cm.addNumControllers(type, num);
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

  public void display() {
    for (int i = 0; i < sections.size(); i++) {
      sections.get(i).display();
    }
  }

  public void onControllerChanged(CallbackEvent event) {
    if (event.getAction() == ControlP5.ACTION_BROADCAST) {

      Controller c = event.getController();
      int id  = c.getId();
      if (id != prevId) {
        prevVal = -1000;
        prevId = id;
      }

      int val = (int) c.getValue();
      if (val != prevVal) {
        String oscUrl = c.getName();
        OscMessage myMessage = new OscMessage(oscUrl);        
        myMessage.add(val);
        
        myMessage.print();
        oscP5.send(myMessage, myRemoteLocation);
        prevVal = val;
      }
    }
  }
}