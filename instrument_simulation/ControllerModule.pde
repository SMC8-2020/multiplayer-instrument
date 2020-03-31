public class ControllerModule extends Module {

  private final int ANALOGMIN = 0;
  private final int ANALOGMAX = 1023;
  private final int CTRIN = 12;

  private final class Label {
    private final float defaultTextW = 24.0f;
    private String str;
    private float textH;
    private float x, y, size;
    public Label (String label, float x, float y, float s) {
      this.str = label.toUpperCase();
      this.textH = (textDescent()+textAscent());
      this.size = defaultTextW / this.textH * (s/4);
      this.x = x + s/2.0f;
      this.y = y + this.size;
    }

    public void show() {
      fill(255);
      textAlign(CENTER);
      textSize(this.size);
      text(this.str, this.x, this.y);
    }
  }

  private ArrayList<Controller> controllers;
  private IntList types;
  private int nsliders, nknobs, nbuttons, ntoggles;

  private ArrayList<Label> labels;

  public ControllerModule(String moduleName) {
    super(moduleName, -1);
    controllers = new ArrayList<Controller>();
    types = new IntList();
    nsliders = nknobs = nbuttons = ntoggles = 0;

    labels = new ArrayList<Label>();
  }

  public void addController(int type, String label) {

    int id = controllers.size();
    String route = this.moduleName;
    Controller ctr;

    switch(type) {
    case ControllerTags.SLIDERTAG:
      ctr = cp5.addSlider(route + "Slider" + id)
        .setId(id)
        .setLabel(label)
        .setRange(ANALOGMIN, ANALOGMAX)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        .setSliderMode(Slider.FLEXIBLE)
        ;
      nsliders++;
      break;

    case ControllerTags.KNOBTAG:
      ctr = cp5.addKnob(route + "Knob" + id)
        .setId(id)
        .setLabel(label)
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
      ctr = cp5.addButton(route + "Button" + id)
        .setId(id)
        .setLabel(label)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        ;
      nbuttons++;
      break;

    case ControllerTags.TOGGLETAG:
      ctr = cp5.addToggle(route + "Toggle" + id)
        .setId(id)
        .setLabel(label)
        .setValue((ANALOGMAX - ANALOGMIN) / 2)
        .setLabelVisible(false)
        .setMode(ControlP5.SWITCH)
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

  public void addNumControllers(int type, int num, String[] labels) {
    for (int i = 0; i < num; i++) {
      addController(type, labels[i]);
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
    case ControllerTags.BUTTONTAG:
    case ControllerTags.TOGGLETAG:
      formatFixedSizeCtr(ctr, idx, container);
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

  private void formatFixedSizeCtr(Controller ctr, int idx, Rect container) {
    float x, y, w, h, s;
    float alpha  = (container.w > container.h) ? 0.0f : 1.0f ;
    float ntotal = (float)(nknobs + nbuttons + ntoggles);
    ntotal += ((ntotal == 1) ? 1 : 0);

    if (alpha == 0) {
      w = (container.w - (ntotal + 1)*CTRIN) / ntotal;
      h = (container.h - 2*CTRIN) / 2.0f;      
      x = (idx + 1)*CTRIN + container.x + idx*w;
      y = container.y + container.h/2 - w/2;
    } else {
      h = (container.h - (ntotal + 1)*CTRIN) / ntotal;
      w = (container.w - 2*CTRIN) / 2.0f;
      y = (idx + 1)*CTRIN + container.y + idx*h;
      x = container.x + container.w/2 - h/2;
    }

    s = (1.0f - alpha)*w + alpha*h;

    ctr.setPosition(x, y);
    ctr.setSize((int)s, (int)s);

    String label = ctr.getLabel();
    if (!label.equals("")) {
      labels.add(new Label(label, x, y + s, s));
    }
  }

  @Override public void display () {
    super.display();
    for (Label label : labels) {
      label.show();
    }
  }
}