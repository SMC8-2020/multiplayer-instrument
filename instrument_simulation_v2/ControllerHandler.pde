public class ControllerHandler {

  private InstrumentModel model;

  private int prevBroadcastValue = -1;
  private Controller prevBroadcastController;

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

      // call model to transmit OSC
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
    model.reset();
  } 

  public void ldrActivated(ControlEvent event) {
    println("activated an LDR");
  }
}