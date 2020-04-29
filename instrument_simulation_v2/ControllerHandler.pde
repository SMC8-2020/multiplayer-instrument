public class ControllerHandler {
  
  private final int LDRVALUE = 1;
  private final int RNGVALUE = 1;
  
  private InstrumentModel model;
  
  private int prevBroadcastValue = -1;
  private Controller prevBroadcastController;
  
  private Button currentLdr;
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
    //println("activated an LDR");
    //currentLdr = (Toggle)event.getController();
    Toggle t = (Toggle)event.getController();
    model.broadcastOsc(t.getName(), (int)t.getValue());
  }
  
  public void rng(ControlEvent event) {
    println("randomizing a beat!");
    model.broadcastOsc(event.getController().getName(), RNGVALUE);
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
