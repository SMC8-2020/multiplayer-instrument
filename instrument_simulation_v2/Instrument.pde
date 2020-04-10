public class Instrument implements ControlListener {

  private final String testAddr = "/instrument/section/module/group/controller";

  protected OscP5 osc;
  protected OscMessage broadcastRoute;
  protected NetAddress remoteLocation; 

  protected boolean isBroadcastable = true;

  protected IController.IGroup root;
  protected IController.IGroup activeSection;

  public Instrument() {
    this.root = IController.getInstance().getRootIGroup();
    this.root.addListener(this);
  }

  public Instrument(OscP5 osc, NetAddress remoteLocation) {
    this();
    this.osc = osc;
    this.remoteLocation = remoteLocation; //new NetAddress(LOCALHOST, PORT);
  }

  public void controlEvent(ControlEvent event) {
    broadcastOsc(testAddr, -1, -1, -1, -1);
  }

  public void setIpAddress(String ip) {
    this.remoteLocation = new NetAddress(ip, PORT);
  }

  public void setBroadcastable(boolean toggle) {
    isBroadcastable = toggle;
  }

  public void broadcastOsc(String addr, int...values) {

    if (!isBroadcastable) {
      if (DEBUG) println("broadcasting is disabled");
      return;
    }

    if (LEGACYSUPPORT) {
      String[] tokens = addr.split("/");
      addr = String.format("/%s/%s/%s/%s", 
        tokens[1], tokens[2], tokens[3], tokens[5]
        );
    }
    
    addr = addr.replaceAll("[\\s\\(\\)]", "");
    broadcastRoute = new OscMessage(addr);

    if (values.length == 0) {
      broadcastRoute.add(0);
    } else if (values.length == 1) {
      broadcastRoute.add(values[0]);
    } else {
      broadcastRoute.add(values);
    }

    if (DEBUG) {
      String args = "" + broadcastRoute.get(0).intValue();
      for (int i = 1; i < broadcastRoute.arguments().length; i++) {
        args += "," + broadcastRoute.get(i).intValue();
      }

      String msg = String.format("%s   %s   %s", 
        broadcastRoute.addrPattern(), 
        args, 
        broadcastRoute.typetag()
        );
      println(msg);
    }

    osc.send(broadcastRoute, remoteLocation);
  }


  public boolean isControllerIType(Controller ctr) {
    return (ctr instanceof IController.IControllerInterface);
  }

  public boolean isCtrInSection(Controller ctr, String sectionTag) {

    if (!isControllerIType(ctr)) {
      return false;
    }

    IController.IControllerInterface<?> topSection 
      = IController.getTopFor((IController.IControllerInterface<?>)ctr);

    return topSection.getName().equals(sectionTag);
  }

  public IController.IGroup createSectionFromJson(String jsonPath, float weight) {
    JSONObject jsonRoot = loadJSONObject(jsonPath);
    JSONObject section = jsonRoot.getJSONObject("section");

    String name = section.getString("name");
    int id = section.getInt("id");

    IController.IControllerInterface<?> topGroup = 
      IController.getInstance().addIController(IController.IGROUP, root, name + " (" + id + ")").fit(weight);

    JSONArray children = section.getJSONArray("children");    
    for (int i = 0; i < children.size(); i++) {
      createFromJson(children.getJSONObject(i), topGroup.get());
    }

    return (IController.IGroup)topGroup.get();
  }

  private void createFromJson(JSONObject obj, ControllerGroup<?> parent) {

    String name  = obj.getString("name");
    int id = obj.getInt("id");
    float weight = obj.getFloat("weight");

    IController.IControllerInterface<?> group = 
      IController.getInstance().addIController(IController.IGROUP, parent, name + " (" + id + ")").fit(weight);

    JSONArray children = obj.getJSONArray("children");    
    for (int i = 0; i < children.size(); i++) {
      createFromJson(children.getJSONObject(i), group.get());
    }

    JSONArray controllers = obj.getJSONArray("controllers");
    if (controllers.size() > 0) {
      ControllerInfo info = unpackControllers(controllers);
      IController.getInstance().addNumControllers(info.types, info.labels, group.get());
    }
  }

  private class ControllerInfo {
    public int[] types;
    public String[] labels;
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
}