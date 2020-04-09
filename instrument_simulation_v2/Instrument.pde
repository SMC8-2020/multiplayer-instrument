public class Instrument 
{
  private IController ict;
  private IController.IGroup root;
  private IController.IGroup console;
  private IController.IGroup currentSection;
  
  private InstrumentListener listener;
  
  public Instrument(PApplet pa, ControlP5 cp5) {
    ict = new IController(pa, cp5);
    IController.IGroup[] g = ict.getRootIGroups();
    //root = ict.getRootIGroup();
    root = g[0];
    console = g[1];
    
    ict.addIController(IController.IGROUP, console, "Inspector").fit();
    
    createSectionFromJson("melodySection.json", 1f);

    listener = new InstrumentListener();
    root.addListener(listener);
        
  }

  public void createSectionFromJson(String jsonPath, float weight) {
    
    if (currentSection != null) {
      //root.remove(currentSection);
    }
    
    JSONObject jsonRoot = loadJSONObject(jsonPath);
    JSONObject section = jsonRoot.getJSONObject("section");

    String name = section.getString("name");
    int id = section.getInt("id");
    
    IController.IControllerInterface<?> topGroup = 
      ict.addIController(IController.IGROUP, root, name + id).fit(weight);
        
    JSONArray children = section.getJSONArray("children");    
    for (int i = 0; i < children.size(); i++) {
      createFromJson(children.getJSONObject(i), topGroup.get());
    }
    
    currentSection = (IController.IGroup)topGroup.get();
  }

  private ControllerInfo unpackControllers(JSONArray controllers) {
    ControllerInfo info = new ControllerInfo();

    IntList types = new IntList();
    StringList labels = new StringList();
    for (int i = 0; i < controllers.size(); i++) {
      JSONObject ctr = controllers.getJSONObject(i);

      int type = ctr.getInt("type");
      int num = ctr.getInt("num");
      JSONArray jsonLabels = ctr.getJSONArray("labels");
      for (int j = 0; j < num; j++) {
        String label = j < jsonLabels.size() ? jsonLabels.getString(j) : "";
        types.append(type);
        labels.append(label);
      }
    }

    info.types  = types.array();
    info.labels = labels.array();
    return info;
  }

  private void createFromJson(JSONObject obj, ControllerGroup<?> parent) {

    String name  = obj.getString("name");
    int id = obj.getInt("id");
    float weight = obj.getFloat("weight");

    IController.IControllerInterface<?> group = 
      ict.addIController(IController.IGROUP, parent, name + id).fit(weight);

    JSONArray children = obj.getJSONArray("children");    
    for (int i = 0; i < children.size(); i++) {
      createFromJson(children.getJSONObject(i), group.get());
    }

    JSONArray controllers = obj.getJSONArray("controllers");
    if (controllers.size() > 0) {
      ControllerInfo info = unpackControllers(controllers);
      ict.addNumControllers(info.types, info.labels, group.get());
    }
  }

  private class ControllerInfo {
    public int[] types;
    public String[] labels;
  }
}