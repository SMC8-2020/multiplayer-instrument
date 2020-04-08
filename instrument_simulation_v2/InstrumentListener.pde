public class InstrumentListener implements ControlListener {

  private IController.IControllerInterface<?> activeController;
  private OscMessage broadcastRoute;
  private int prevValue = -1;

  public InstrumentListener() {
    activeController = null;
  }

  public void controlEvent(ControlEvent event) {
    Controller c = event.getController();
    activeController = (IController.IControllerInterface<?>)c;

    int currentValue = (int) activeController.getValue();
    if (currentValue != prevValue) {

      String addr = activeController.getOscAddress();

      if (LEGACYSUPPORT) {
        String[] tokens = addr.split("/");
        addr = String.format("/%s/%s/%s/%s", 
          tokens[1], tokens[2], tokens[3], tokens[5]
          );
      }

      println(addr + "   " + currentValue);

      broadcastRoute = new OscMessage(addr);
      broadcastRoute.add(currentValue);

      oscP5.send(broadcastRoute, myRemoteLocation);
      
      prevValue = currentValue;
    }
  }
}