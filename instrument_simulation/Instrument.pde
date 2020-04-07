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
    sections          = new ArrayList<Module>();
    moduleGroups      = new ArrayList<Module>();
    controllerModules = new HashMap<String, Module>();

    lst = new InstrumentListener(controllerModules);
    cp5.addCallback(lst);
  }

  public Instrument(String instrumentName) {
    this();
    this.instrumentName = instrumentName;
  }

  public Module addSection(String sectionName, int sectionId) {
    String prefix = "/" + instrumentName + "/";
    Module section = new Module(prefix + sectionName, sectionId, SECTION_BOXIN);
    sections.add(section);
    return section;
  }

  public Module addGroupToSection(Module section, String groupName, int groupId) {
    String prefix = section.moduleName + section.moduleId + "/";
    Module group = new Module(prefix + groupName, groupId, MDGROUP_BOXIN);
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
    int x, y, w, h;
    int numSections = sections.size();
    
    if (numSections == 0) {
      return;
    }
    
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
  
  public void cj (JSONObject obj, Module parent, int idx) {
    
    String name = obj.getString("name");
    int id      = obj.getInt("id");
    
    float spacingx = obj.getFloat("spacingx");
    float spacingy = obj.getFloat("spacingy");
    float weight   = obj.getFloat("weight");
    
    Module module = new Module(name, id, parent, null);
    
    JSONArray children = obj.getJSONArray("children");    
    for (int i = 0; i < children.size(); i++) {
      cj(children.getJSONObject(i), module, i);
    }
    
    JSONArray controllers = obj.getJSONArray("controllers");
    for (int i = 0; i < controllers.size(); i++) {
      // TODO: Handle controllers
    }    
    
  }
  
  public void createFromJson(String jsonPath) {
    JSONObject root = loadJSONObject(jsonPath);

    JSONArray sections = root.getJSONArray("sections");
    for (int s = 0; s < sections.size(); s++) {
      JSONObject section = sections.getJSONObject(s);
      String sectionName = section.getString("name");
      int sectionId = section.getInt("id"); 

      Module sectionModule = addSection(sectionName, sectionId);

      JSONArray groups = section.getJSONArray("groups");
      for (int g = 0; g < groups.size(); g++) {
        JSONObject group = groups.getJSONObject(g);
        String groupName = group.getString("name");
        int groupId = group.getInt("id");

        Module groupModule = addGroupToSection(sectionModule, groupName, groupId);

        JSONArray modules = group.getJSONArray("modules");
        for (int m = 0; m < modules.size(); m++) {
          JSONObject module = modules.getJSONObject(m);
          String moduleName = module.getString("name");
          float weight = module.getFloat("weight");

          Module controllerModule = addModuleToGroup(groupModule, moduleName, weight);

          JSONArray controllers = module.getJSONArray("controllers");
          for (int c = 0; c < controllers.size(); c++) {
            JSONObject controller = controllers.getJSONObject(c);
            int type = controller.getInt("type");
            int num = controller.getInt("num");
            String[] labels = controller.getJSONArray("labels").getStringArray();
            
            addControllerToModule(controllerModule, type, num, labels);
          }
        }
      }
    }
  }
  
  
  
}