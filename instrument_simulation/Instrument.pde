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

  public void addSection(String sectionName, int sectionId) {
    Module section = new Module(sectionName, sectionId, SECTION_BOXIN);
    sections.add(section);
  }

  public void addModuleGroupToSection(String groupName, int groupId, String sectionName) {
    Module moduleGroup = new Module(groupName, groupId, MDGROUP_BOXIN);

    Module parent = findModule(sectionName, sections);
    if (parent != null) {
      parent.assignSubModule(moduleGroup);
      moduleGroups.add(moduleGroup);
      return;
    }

    println("No section by that name available");
  }

  public void addModuleToModuleGroup(String moduleName, String groupName, float weight) {
    ControllerModule ctrModule = new ControllerModule(moduleName);

    Module parent = findModule(groupName, moduleGroups);
    if (parent != null) {
      parent.assignSubModule(ctrModule, weight);
      controllerModules.add(ctrModule);
      return;
    }

    println("No module group by that name available");
  }

  public void addControllerToModule(int type, int num, String moduleName) {
    ControllerModule cm = (ControllerModule) findModule(moduleName, controllerModules);
    cm.addNumControllers(type, num);
  }

  private Module findModule(String moduleName, ArrayList<Module> searchArray) {
    for (int i = 0; i < searchArray.size(); i++) {
      Module m = searchArray.get(i);
      if (m.moduleName.equals(moduleName)) {
        return m;
      }
    }

    return null;
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
        String ctag = c.getName();
        ctag = ctag.substring(0, ctag.length() - 1);
        String cid  = str(id);

        String oscUrl = instrumentName + ctag + "/" + cid;
        OscMessage myMessage = new OscMessage(oscUrl);

        myMessage.add(val);
        oscP5.send(myMessage, myRemoteLocation);
        prevVal = val;
      }
    }
  }
}