public class InstrumentSection extends Instrument {

  private final String DEFAULT_SECTION = "sections/presets/melodySection.json";
  private final float  DEFAULT_WEIGHT  = 0.65f;

  private HashMap<String, IController.IGroup> sections;
    
  public InstrumentSection (OscP5 osc, NetAddress remoteLocation) {
    super(osc, remoteLocation);    
    this.sections = new HashMap<String, IController.IGroup>();
    this.activeSection = addSection(DEFAULT_SECTION, DEFAULT_WEIGHT);
  }

  @Override protected int[] broadcastDiscrete(IController.IControllerInterface<?> ctr) {
    return new int[] {(int) ctr.getValue()};
  }

  @Override protected boolean handleLocalEvent(IController.IControllerInterface<?> ctr) {
    if (ctr.getName().contains(IController.BUTTONTAG)) {
      
      println("Activated an LDR");
      
      return true;
    }
    
    return false;
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