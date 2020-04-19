public class ControllerHandler {

  private InstrumentModel model;

  private int prevBroadcastValue = -1;
  private Controller prevBroadcastController;
  
  private Toggle currentLdr;
  private int ldrCount = 0;
  
  public ControllerHandler() {
    prevBroadcastController = null;
  }

  public void setModel(InstrumentModel model) {
    this.model = model;
  }

  public void broadcast(ControlEvent event) {
    Controller ctr = event.getController();

    if (!ctr.equals(prevBroadcastController)) {
      prevBroadcastValue = -1;
      prevBroadcastController = ctr;
    }

    int currentValue = (int) ctr.getValue();
    if (currentValue != prevBroadcastValue) {
      model.broadcastOsc(ctr.getName(), currentValue);
      prevBroadcastValue = currentValue;
    }
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
    println("activated an LDR");
    currentLdr = (Toggle)event.getController();
  }
  
  public void updateContinousEvents() {
    
    if (currentLdr != null) {
      if (currentLdr.getBooleanValue()) {
        println("ping" + ldrCount);
        ldrCount++;
      } else {
        println("released LDR");
        currentLdr = null;
        ldrCount = 0;
      }
     
    }
    
  }
  
}