public class ControllerModule extends Module {

  private final int ANALOGMIN = 0;
  private final int ANALOGMAX = 1023;
  private final int CTRIN = 5;

  private ArrayList<Controller> controllers;
  private IntList types;
  private int nsliders, nknobs, nbuttons, ntoggles;

  public ControllerModule(String moduleName) {
    super(moduleName, -1);
    controllers = new ArrayList<Controller>();
    types = new IntList();
    nsliders = nknobs = nbuttons = ntoggles = 0;
  }

  private String constructMsg() {

    ArrayList<String> msg = new ArrayList<String>();
    Module current = this.getParent();

    while (current != null) {
      String name = current.moduleName;
      String id   = "" + current.moduleId;

      msg.add(id);
      msg.add(name);

      current = current.getParent();
    }

    String[] msgArr = reverse(msg.toArray(new String[0]));
    return "/" + join(msgArr, "/");
  }

  public void addController(int type) {

    int id = controllers.size();
    String msg = constructMsg();
    Controller ctr;

    switch(type) {
    case ControllerTags.SLIDERTAG:
      ctr = cp5.addSlider(msg + "/Slider" + id)
        .setId(id)
        .setRange(ANALOGMIN, ANALOGMAX)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        .setSliderMode(Slider.FLEXIBLE)
        ;
      nsliders++;
      break;

    case ControllerTags.KNOBTAG:
      ctr = cp5.addKnob(msg + "/Knob" + id)
        .setId(id)
        .setRange(ANALOGMIN, ANALOGMAX)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        .showTickMarks()
        .snapToTickMarks(true)
        .setViewStyle(Knob.ELLIPSE)
        ;
      nknobs++;
      break;

    case ControllerTags.BUTTONTAG:
      ctr = cp5.addButton(msg + "/Button" + id)
        .setId(id)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        ;
      nbuttons++;
      break;

    case ControllerTags.TOGGLETAG:
      ctr = cp5.addToggle(msg + "/Toggle" + id)
        .setId(id)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        ;
      ntoggles++;
      break;

    default:
      ctr = null;
      break;
    }

    if (ctr == null) return;
    controllers.add(ctr);
    types.append(type);
  }

  public void addNumControllers(int type, int num) {
    for (int i = 0; i < num; i++) {
      addController(type);
    }
  }

  public void fitControllersToContainer() {
    Rect container = this.getRect();
    for (int i = 0; i < controllers.size(); i++) {
      int type = types.get(i); 
      Controller ctr = controllers.get(i);
      handleFormatForType(type, ctr, i, container);
    }
  }

  private void handleFormatForType(int type, Controller ctr, int idx, Rect container) {
    switch(type) {
    case ControllerTags.SLIDERTAG:
      formatSlider((Slider) ctr, idx, container);
      break;

    case ControllerTags.KNOBTAG:
      formatKnob((Knob) ctr, idx, container);
      break;

    case ControllerTags.BUTTONTAG:
      formatButton((Button) ctr, idx, container);
      break;

    case ControllerTags.TOGGLETAG:
      break;
    }
  }

  private void formatSlider(Slider slider, int idx, Rect container) {
    float x, y, w, h;
    w = (container.w - (nsliders + 1)*CTRIN) / nsliders;
    h = container.h - 2*CTRIN;
    x = (idx + 1)*CTRIN + container.x + idx*w;
    y = container.y + CTRIN;

    slider.setPosition(x, y);
    slider.setSize((int) w, (int) h);
  }

  private void formatKnob(Knob knob, int idx, Rect container) {
    float x, y, w, h, r;
    
    float alpha = (container.w > container.h) ? 1.0f : 0.0f ;
    
    w = (container.w - 3*CTRIN) / 2.0f;
    h = (container.h - (nknobs + 1)*CTRIN) / nknobs;
    
    y = (idx + 1)*CTRIN + container.y + idx*h;
  
    r = (container.w < h) ? w : h/2;  
    x = 1.5f*CTRIN + container.x + w - r;

    knob.setPosition(x, y);
    knob.setRadius(r);
  }
  
  private void formatButton(Button button, int idx, Rect container) {
    float x, y, s;
    
    s = (container.w - (nbuttons + 1)*CTRIN) / nbuttons;
    
    x = (idx + 1)*CTRIN + container.x + idx*s;
    y = container.y + (container.h - 3*CTRIN) / 2.0f - s/3;
    
    button.setPosition(x, y);
    button.setSize((int) s, (int) s);
  }
  
  
}