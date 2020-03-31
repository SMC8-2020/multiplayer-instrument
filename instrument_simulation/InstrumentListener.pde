public class InstrumentListener implements CallbackListener {

  private boolean isBroadcastable = true;
  private Controller activeController;
  private OscMessage broadcastRoute;
  
  private int prevValue = -1;
  
  private Rect textField;
  
  public InstrumentListener() {
    activeController = null;
    broadcastRoute   = null;
  }

  public void controlEvent(CallbackEvent event) {

    switch(event.getAction()) {

    case ControlP5.ACTION_ENTER:
      activeController = event.getController();
      prevValue = (int) activeController.getValue();
      break; 

    case ControlP5.ACTION_LEAVE:
      activeController = null;
      prevValue = -1;
      break;
    }
  }
  
  public void display() {
    
    if (textField == null) {
      return;
    }
    
    noStroke();
    fill(isBroadcastable ? color(114, 133, 165, 100) : color(255, 10, 100));
    textField.show();
  }
  
  public void broadcastOSC() {

    if (!isBroadcastable) {
      return;
    }
    
    if (activeController == null) {
      return;
    }
    
    int currentValue = (int) activeController.getValue();
    if (currentValue != prevValue) {
      
      String oscUrl = activeController.getName();
      broadcastRoute = new OscMessage(oscUrl);
      broadcastRoute.add(currentValue);
      
      oscP5.send(broadcastRoute, myRemoteLocation);
      
      println(oscUrl + "  " + currentValue);
      prevValue = currentValue;
    }
    
  }
}