public class ControllerHandler {

  private final int RNGVALUE = 1;

  private InstrumentModel model;

  private int prevBroadcastValue = -1;
  private Controller prevBroadcastController;

  private String prevSection;
  private boolean setSectionLock = false;

  private Map<String, ControllerList> callbackControllerMap;

  public ControllerHandler() {
    prevBroadcastController = null;
    this.callbackControllerMap = new 
      HashMap<String, ControllerList>();
  }

  public void setModel(InstrumentModel model) {
    this.model = model;
    this.prevSection = model.MELODYTAG;
  }

  public void addControllerToCallbackMap(String callback, Controller ctr) {
    ControllerList li = null;
    if (!callbackControllerMap.containsKey(callback)) {
      li = new ControllerList();
      li.add(ctr);
      callbackControllerMap.put(callback, li);
      return;
    }

    li = callbackControllerMap.get(callback);
    li.add(ctr);
  }

  public void broadcast(ControlEvent event) {
    Controller ctr = event.getController();

    if (!ctr.equals(prevBroadcastController)) {
      prevBroadcastValue = -1;
      prevBroadcastController = ctr;
    }

    int currentValue = (int) ctr.getValue();
    currentValue = constrain(currentValue, 0, 1023);
    if (currentValue != prevBroadcastValue) {
      model.broadcastOsc(ctr.getName(), currentValue);
      prevBroadcastValue = currentValue;
    }
  }

  public void setSection(ControlEvent event) {
    if (setSectionLock) {
      return;
    }

    setSectionLock = true;
    Toggle ctr = (Toggle)event.getController();
    String name = ctr.getName();
    int idx = Integer.parseInt(""+name.charAt(name.length() - 1));
    
    String currentSection = model.sectionTags[idx];
    
    if (prevSection.equals(currentSection)) {
      ctr.toggle();
      setSectionLock = false;
      return;
    }
    
    model.setSection(currentSection);
    prevSection = currentSection;
    
    ControllerList li 
      = callbackControllerMap.get("setSection");

    for (ControllerInterface<?> c : li.get()) {
      Toggle t = (Toggle)c;
      if (!t.equals(ctr)) {
        if (t.getBooleanValue())
          t.toggle();
      }
    }
    
    setSectionLock = false;
  }

  public void setBroadcast(ControlEvent event) {
    Toggle t = (Toggle) event.getController();
    model.setBroadcast(t.getBooleanValue());
    println("setting broadcast: " + (t.getBooleanValue() ? "On" : "Off"));
  }

  public void reset(ControlEvent event) {
    println("resetting controllers");
    model.resetOnlineControllers();
  } 

  public void ldrActivated(ControlEvent event) {
    Toggle t = (Toggle)event.getController();
    model.broadcastOsc(t.getName(), (int)t.getValue());
  }

  public void rng(ControlEvent event) {
    println("randomizing a beat!");
    Toggle t = (Toggle)event.getController();
    model.broadcastOsc(t.getName(), (int)t.getValue());
  }

}
