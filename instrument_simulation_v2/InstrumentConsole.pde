public class InstrumentConsole extends Instrument  {

  private final String CONSOLE_PATH   = "sections/consoleSection.json";
  private final float  CONSOLE_WEIGHT = 0.35f;  

  private final int PREVRESET = -1;

  private int prevValue = PREVRESET;
  private IController.IControllerInterface<?> activeController;
  private IController.IControllerInterface<?> prevController;

  private InstrumentSection instrumentSection;

  public InstrumentConsole(OscP5 osc, NetAddress remoteLocation, InstrumentSection instrumentSection) {
    super(osc, remoteLocation);
    this.instrumentSection = instrumentSection;
    this.activeSection = createSectionFromJson(CONSOLE_PATH, CONSOLE_WEIGHT);
  } 

  @Override public void controlEvent(ControlEvent event) {
    if (activeSection == null) return;

    Controller ctr = event.getController();
    if (!isCtrInSection(ctr, activeSection.getName())) {
      return;
    }

    activeController 
      = (IController.IControllerInterface<?>)ctr;

    if (!activeController.equals(prevController)) {
      prevValue = PREVRESET;
      prevController = activeController;
    }

    int currentValue = (int) activeController.getValue();
    if (currentValue != prevValue) {

      broadcastOsc(activeController.getOscAddress(), currentValue);
      prevValue = currentValue;
    }
  }

  public void setSection(String name) {
    root.remove(activeSection);
    instrumentSection.setSection(name);
    root.add(activeSection);
  }
}