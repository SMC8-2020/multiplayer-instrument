public class InstrumentListener implements CallbackListener {

  private final int BOXIN           = 15;
  private final int MODULEIDX       = 4;
  private final String CONTINOUSTAG = "LDR";
  private final String BCTOGGLETAG  = "isBroadcastable";

  private boolean isBroadcastable = false;
  private Controller activeController;
  private OscMessage broadcastRoute;

  private HashMap<String, Module> controllerModules;

  private int prevValue = -1;

  private Rect consoleRect;
  private Rect callbackRect, continousRect;

  public InstrumentListener(HashMap<String, Module> controllerModules) {
    activeController = null;
    broadcastRoute   = null;
    consoleRect      = null;

    this.controllerModules = controllerModules;
  }

  public void setConsoleRect(Rect rect) {
    consoleRect = rect;

    float s = rect.h - 2*BOXIN;
    float x = rect.w - s;
    float y = rect.y + BOXIN;

    cp5.addToggle(BCTOGGLETAG )
      .setLabel("Broadcast On/Off")
      .setMode(ControlP5.SWITCH)
      .setPosition(x, y)
      .setSize((int)s, (int)s)
      ;

    float w, h;
    x = rect.x + BOXIN;
    y = rect.y + BOXIN;
    w = rect.w / 3;
    h = rect.h - 2*BOXIN;
    callbackRect = new Rect(x, y, w, h);
    continousRect = new Rect(BOXIN + x + w, y, w, h); 
  }

  public void controlEvent(CallbackEvent event) {

    switch(event.getAction()) {

    case ControlP5.ACTION_BROADCAST:
      if (event.getController().getName().equals(BCTOGGLETAG)) {
        isBroadcastable = !isBroadcastable;
      }

      break;

    case ControlP5.ACTION_ENTER:
      activeController = event.getController();
      prevValue = (int) activeController.getValue();
      break; 

    case ControlP5.ACTION_LEAVE:
      activeController = null;
      prevValue = -1;
      break;

    case ControlP5.ACTION_PRESS:
      Controller ctr = event.getController();
      String[] addrsTokens = ctr.getName().split("/");

      if (addrsTokens.length < MODULEIDX) return;

      if (addrsTokens[MODULEIDX].contains(CONTINOUSTAG)) {
        String moduleKey = "";
        for (int i = 0; i < addrsTokens.length - 1; i++) {
          moduleKey += addrsTokens[i] + "/";
        }

        ControllerModule cm = (ControllerModule) controllerModules.get(moduleKey);
        println(cm.moduleName);
      }

      break;
    }
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
      if (oscUrl.equals(BCTOGGLETAG)) {
        return;
      }

      String[] tokens = oscUrl.split("/");
      oscUrl = String.format("/%s/%s/%s/%s", 
        tokens[1], tokens[2], tokens[3], tokens[5]
        );

      broadcastRoute = new OscMessage(oscUrl);
      broadcastRoute.add(currentValue);

      oscP5.send(broadcastRoute, myRemoteLocation);

      println(oscUrl + "  " + currentValue);
      prevValue = currentValue;
    }
  }

  public void display() {
    if (consoleRect == null) {
      return;
    }
    
    noStroke();
    fill(color(114, 133, 165, 100));
    consoleRect.show();
    callbackRect.show();
    continousRect.show();
    
    String bcinfo = isBroadcastable ? "ON" : "OFF";
    
    textAlign(LEFT, TOP);
    
    fill(255);
    textSize(12);
    text("CONTROLLER BROADCAST:", callbackRect.x + 2, callbackRect.y);
    
    fill(isBroadcastable ? color(0, 255, 0) : color(255, 0, 0));
    text(bcinfo, callbackRect.x + textWidth("CONTROLLER BROADCAST:") + 10, callbackRect.y);
    
  }
}