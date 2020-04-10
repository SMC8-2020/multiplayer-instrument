public class InstrumentSection extends Instrument {

  private final String DEFAULT_SECTION = "sections/presets/melodySection.json";
  private final float  DEFAULT_WEIGHT  = 0.65f;
  
  private final int PREVRESET = -1;
  
  private HashMap<String, IController.IGroup> sections;
  
  private int prevValue = PREVRESET;
  private IController.IControllerInterface<?> activeController;
  private IController.IControllerInterface<?> prevController;
  
  public InstrumentSection (OscP5 osc, NetAddress remoteLocation) {
    super(osc, remoteLocation);    
    this.sections = new HashMap<String, IController.IGroup>();
    this.activeSection = addSection(DEFAULT_SECTION, DEFAULT_WEIGHT);
    
    this.activeController = null;
    this.prevController   = null;
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
 
  private IController.IGroup addSection(String name, float weight) {
    IController.IGroup section = createSectionFromJson(name, weight);
    sections.put(name, section);
    return section;
  }

  public void setSection(String name) {
    if (!sections.containsKey(name)) {
      root.remove(activeSection);
      activeSection = addSection(name, DEFAULT_WEIGHT);
      return;
    }

    IController.IGroup section = sections.get(name);
    if (!activeSection.equals(section)) {
      root.remove(activeSection);
      activeSection = section;
      root.add(activeSection);
    }
  }
}