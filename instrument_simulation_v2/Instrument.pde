public class Instrument 
{
  private IController ict;
  private IController.IGroup root;
  private IController.IGroup currentSection;
  
  private InstrumentListener listener;
  
  public Instrument(PApplet pa, ControlP5 cp5) {
    ict = new IController(pa, cp5);
    root = ict.getRootIGroup();
    createFromJson("json_sec_test.json");
    
    listener = new InstrumentListener();
    currentSection.addListener(listener);
  }

  public void createFromJson(String jsonPath) {
    JSONObject jsonRoot = loadJSONObject(jsonPath);
    JSONObject section = jsonRoot.getJSONObject("section");

    String name = section.getString("name");
    IController.IControllerInterface<?> topGroup = 
      ict.addIController(IController.IGROUP, root, name).fit();
        
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
    float weight = obj.getFloat("weight");

    IController.IControllerInterface<?> group = 
      ict.addIController(IController.IGROUP, parent, name).fit(weight);

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