public class InstrumentConsole extends Instrument {

  private final String CONSOLE_PATH   = "sections/consoleSection.json";
  private final float  CONSOLE_WEIGHT = 0.35f;  

  private final String CONSOLE_BROADCAST_GRP = "Broadcast (0)";
  private final String CONSOLE_LOCAL_GRP     = "Local (0)";

  private InstrumentSection instrumentSection;

  public InstrumentConsole(OscP5 osc, NetAddress remoteLocation, InstrumentSection instrumentSection) {
    super(osc, remoteLocation);
    this.instrumentSection = instrumentSection;
    this.activeSection = createSectionFromJson(CONSOLE_PATH, CONSOLE_WEIGHT);
  } 

  @Override protected int[] broadcastDiscrete(IController.IControllerInterface<?> ctr) {
    return new int[] {(int) ctr.getValue()};
  }

  @Override protected boolean handleLocalEvent(IController.IControllerInterface<?> ctr) {
    String controllerTag = ctr.getName().replaceAll("[0-9]+", "");

    if (controllerTag.equals(IController.BUTTONTAG)) {
      reset(ctr);
      return true;
    } else if (controllerTag.equals(IController.TOGGLETAG)) {
      boolean t = ((Toggle)ctr).getBooleanValue();
      setBroadcastable(t);
      instrumentSection.setBroadcastable(t);
      return true;
    }

    return false;
  }

  public void setSection(String name) {
    root.remove(activeSection);
    instrumentSection.setSection(name);
    root.add(activeSection);
  }

  private void reset(ControllerInterface<?> caller) {
    IController.IGroup sec 
      = instrumentSection.getActiveSection();

    if (sec != null) {
      sec.reset();
    }

    if (activeSection != null) {
      ((IController.IControllerInterface<?>)caller.getParent()).reset();
    }
  }

  public void updateEvents() {
  }
}