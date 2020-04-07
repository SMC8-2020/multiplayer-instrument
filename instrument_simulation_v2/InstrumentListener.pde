public class InstrumentListener implements ControlListener {

  private IController.IControllerInterface<?> activeController;
  private int prevValue = -1;

  public InstrumentListener() {
    activeController = null;
  }

  public void controlEvent(ControlEvent event) {
    Controller c = event.getController();
    activeController = (IController.IControllerInterface<?>)c;
    println(activeController.getOscAddress());
  }
  
  public void broadCastOnChange() {

    if (activeController == null) {
      return;
    }

    int currentValue = (int) activeController.getValue();
    if (currentValue != prevValue) {

      String addr = activeController.getOscAddress();
      println(addr);
      prevValue = currentValue;
    }
  }
}