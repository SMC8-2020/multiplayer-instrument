public static class IController { 
  private static final float[] MARGINS_ROOT = {0, 0, 250, 0};
  private static final float[] MARGINS_GRP  = {8, 15};
  private static final float[] MARGINS_CTR  = {10, 10};

  private static final int ANALOGMIN     = 0;
  private static final int ANALOGMAX     = 1023;
  private static final int ANALOGDEFAULT = 0;

  private static final int IGROUP  = 0;
  private static final int ISLIDER = 1;
  private static final int IKNOB   = 2;
  private static final int IBUTTON = 3;
  private static final int ITOGGLE = 4;

  private static final String SLIDERTAG = "Slider";
  private static final String KNOBTAG   = "Knob";
  private static final String BUTTONTAG = "Button";
  private static final String TOGGLETAG = "Toggle";

  private static String ROOTNAME = "smc8";
  private static IGroup rootIGroup = null;

  private static String FONTTYPE = "default";

  private PApplet pa;
  private ControlP5 cp5;

  private HashMap<String, Integer> uniqueIds;

  public IController (PApplet pa, ControlP5 cp5) {
    this.pa = pa;
    this.cp5 = cp5;
    this.uniqueIds = new HashMap<String, Integer>();
    this.uniqueIds.put(SLIDERTAG, 0);
    this.uniqueIds.put(KNOBTAG, 0);
    this.uniqueIds.put(BUTTONTAG, 0);
    this.uniqueIds.put(TOGGLETAG, 0);
  }

  public static float[] fitToContainer(IControllerInterface<?> caller, float[] margins, float weight) {
    IControllerInterface<?> parent = (IControllerInterface<?>) caller.getParent();
    ControllerList siblings = parent.getChildren();
    int idx = getIdx(parent, caller);
    float[] prect = getRect(parent);

    if (idx > 0) {
      IControllerInterface<?> s;
      for (int i = idx; i > 0; i--) {
        s = (IControllerInterface<?>)siblings.get(idx - i);
        prect[0] += s.getAbsoluteWidth();
        prect[1] += s.getAbsoluteHeight();
      }
    }

    return stack(prect, margins, weight);
  }

  public static int getIdx(IControllerInterface<?> parent, IControllerInterface<?> caller) {
    ControllerList children = parent.getChildren();
    return children.get().indexOf(caller);
  }

  public static float[] getRect(IControllerInterface<?> ctr) {
    float w = ctr.getWidth();
    float h = ctr.getHeight();
    return new float[] {0, 0, w, h};
  }

  public static float[] stack(float[] rect, float[] margins, float weight) {
    float x, y, w, h;
    if (rect[2] > rect[3]) {
      w = rect[2] * weight - 2*margins[0];
      h = rect[3] - 2*margins[1];
      x = margins[0] + rect[0];
      y = margins[1];
    } else {
      h = rect[3] * weight - 2*margins[1];
      w = rect[2] - 2*margins[0];
      y = margins[1] + rect[1];
      x = margins[0];
    }
    
    return new float[] {x, y, w, h, rect[2], rect[3]};    
  }

  public interface IControllerInterface<T> extends ControllerInterface<T> {    
    public ControllerList getChildren();
    public ControllerGroup<?> get();
    public float getAbsoluteWidth();
    public float getAbsoluteHeight();
    public String getOscAddress();
    public IControllerInterface<?> fit();
    public IControllerInterface<?> fit(float weight);
  }

  public IGroup[] getRootIGroups() {
    int px = (int)MARGINS_ROOT[0];
    int py = (int)MARGINS_ROOT[1];
    int pw = (int)MARGINS_ROOT[2];
    int ph = (int)MARGINS_ROOT[3];
    IGroup gRoot = new IGroup(cp5, ROOTNAME, px, py, pa.width - px-pw, pa.height - py-ph);
    IGroup gConsole = new IGroup(cp5, ROOTNAME+"_console", pa.width - px-pw, py, pw, pa.height - py-ph);
    return new IGroup[] {gRoot, gConsole};
  }
  /*
  public IGroup getRootIGroup() {
   if (rootIGroup == null) {
   int px = (int)MARGINS_ROOT[0];
   int py = (int)MARGINS_ROOT[1];
   int pw = (int)MARGINS_ROOT[2];
   int ph = (int)MARGINS_ROOT[3];
   rootIGroup = new IGroup(cp5, ROOTNAME, px, py, pa.width - px-pw, pa.height - py-ph);
   
   }
   return rootIGroup;
   }
   */
  private String getTag(String tag) {
    int id = uniqueIds.get(tag);
    uniqueIds.put(tag, id + 1);
    return tag + id;
  }

  public IControllerInterface<?> addIController(int type, ControllerGroup<?> parent, String addr) {
    IControllerInterface<?> controller = null;

    switch(type) {

      case IGROUP:
        controller = new IGroup(cp5, parent, addr);
      break;

      case ISLIDER:
        controller = new ISlider(cp5, parent, getTag(SLIDERTAG), addr);
      break;

      case IKNOB:
        controller = new IKnob(cp5, parent, getTag(KNOBTAG), addr);
      break;

      case IBUTTON:
        controller = new IButton(cp5, parent, getTag(BUTTONTAG), addr);
      break;

      case ITOGGLE:
        controller = new IToggle(cp5, parent, getTag(TOGGLETAG), addr);
      break;
    }

    return controller;
  }

  public void addNumControllers(int[] types, String[] labels, ControllerGroup<?> parent) {
    float weight = 1.0f / (float)types.length;

    if (types.length == 1) {
      weight *= 0.5;
    }

    for (int i = 0; i < types.length; i++) {
      String label = i < labels.length ? labels[i] : "";
      IControllerInterface<?> ctr = addIController(types[i], parent, label);
      ctr.fit(weight);
    }
  }

  public class IGroup extends Group implements IControllerInterface<Group> {

    private final int ROOT_BACKGROUND = -13959168;
    private final int BACKGROUND = 1692789466;
    private final int BARCOLOR = -2180985;

    private String oscAddress;

    public IGroup(ControlP5 cp5, String name, int x, int y, int w, int h) {
      super(cp5, name);
      setPosition(x, y);
      setWidth(w);
      setBackgroundHeight(h);
      setBackgroundColor(ROOT_BACKGROUND);
      setColorBackground(BARCOLOR);
      setColorForeground(BARCOLOR);
      setColorActive(BARCOLOR);
      disableCollapse();

      oscAddress = "/" + name;

      if (!FONTTYPE.equals("default")) {
        getCaptionLabel().getStyle().setPaddingTop(-2);
      }
    }

    public IGroup(ControlP5 cp5, ControllerGroup<?> parent, String name) {
      this(cp5, name, 0, 0, parent.getWidth(), parent.getHeight());
      setBackgroundColor(BACKGROUND);

      setGroup(parent);
      oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;
    }

    public IGroup get() {
      return this;
    }

    public String getOscAddress() {
      return oscAddress;
    }

    public float getAbsoluteWidth() {
      return getWidth() + 2*MARGINS_GRP[0];
    }

    public float getAbsoluteHeight() {
      return getHeight() + 2*MARGINS_GRP[1];
    }    

    public ControllerList getChildren() {
      return this.controllers;
    }

    @Override public int getHeight() {
      return getBackgroundHeight();
    }

    @Override public IGroup addListener(final ControlListener theListener) {
      super.addListener(theListener);
      ControllerList children = getChildren();

      if (children != null) {
        for (int i = 0; i < children.size(); i++) {
          ControllerInterface<?> c = children.get(i);
          c.addListener(theListener);
        }
      }

      return this;
    }

    public IControllerInterface<?> fit() {
      return fit(1.0f);
    }

    public IControllerInterface<?> fit(float weight) {
      ControllerInterface<?> p = getParent();
      if (p.getName().equals("default")) {
        return null;
      }

      float[] crect = fitToContainer(this, MARGINS_GRP, weight);
      setPosition(crect[0], crect[1] + super.getHeight()/2);
      setWidth((int)crect[2]);
      setBackgroundHeight((int)crect[3]);
      return this;
    }
  }

  public class ISlider extends Slider implements IControllerInterface<Slider> {

    private final int NTICKS = 13;
    private String oscAddress;

    public ISlider(ControlP5 cp5, ControllerGroup<?> parent, String name, String label) {
      super(cp5, name);
      setRange(ANALOGMIN, ANALOGMAX);
      setValue(ANALOGDEFAULT);
      setSliderMode(Slider.FLEXIBLE);
      setNumberOfTickMarks(NTICKS);
      snapToTickMarks(true);

      setGroup(parent);

      setLabel(label);
      setLabelVisible(!label.equals(""));
      getValueLabel().setVisible(false);

      oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;

      if (!FONTTYPE.equals("default")) {
        getCaptionLabel().getStyle().setPaddingTop(-5);
        getCaptionLabel().setSize((int)MARGINS_CTR[1]-2);
      }
    }

    public IGroup get() {
      IControllerInterface<?> p = (IControllerInterface<?>) getParent();
      return (IGroup)p.get();
    }

    public String getOscAddress() {
      return oscAddress;
    }

    public float getAbsoluteWidth() {
      return getWidth() + 2*MARGINS_CTR[0];
    }

    public float getAbsoluteHeight() {
      return getHeight() + 2*MARGINS_CTR[1];
    } 

    public ControllerList getChildren() {
      return null;
    }

    public IControllerInterface<?> fit() {
      return fit(1.0f);
    } 

    public IControllerInterface<?> fit(float weight) {
      float[] crect = fitToContainer(this, MARGINS_CTR, weight);
      setPosition(MARGINS_CTR[0]/2 + crect[0], crect[1]);
      setSize((int)crect[2], (int)crect[3]);
      return this;
    }
  }

  public class IKnob extends Knob implements IControllerInterface<Knob> {

    private String oscAddress;

    public IKnob(ControlP5 cp5, ControllerGroup<?> parent, String name, String label) {
      super(cp5, name);
      setRange(ANALOGMIN, ANALOGMAX);
      setValue(ANALOGDEFAULT);
      showTickMarks();
      snapToTickMarks(true);
      setViewStyle(Knob.ELLIPSE);
      setGroup(parent);

      setLabel(label);
      setLabelVisible(!label.equals(""));
      getValueLabel().setVisible(false);

      oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;

      if (!FONTTYPE.equals("default")) {
        getCaptionLabel().getStyle().setPaddingTop(-5);
        getCaptionLabel().setSize((int)MARGINS_CTR[1]-2);
      }
    }

    public IGroup get() {
      IControllerInterface<?> p = (IControllerInterface<?>) getParent();
      return (IGroup)p.get();
    }

    public String getOscAddress() {
      return oscAddress;
    }

    public float getAbsoluteWidth() {
      return getWidth() + 2*MARGINS_CTR[0];
    }

    public float getAbsoluteHeight() {
      return getHeight() + 2*MARGINS_CTR[1];
    } 

    public ControllerList getChildren() {
      return null;
    }

    public IControllerInterface<?> fit() {
      return fit(1.0f);
    } 

    public IControllerInterface<?> fit(float weight) {
      float[] crect = fitToContainer(this, MARGINS_CTR, weight);

      float s;
      if (crect[4] > crect[5]) {
        s = crect[2];
        crect[1] += crect[5]/2 - s/2 - MARGINS_CTR[1];
      } else {
        s = crect[3];
        crect[0] += crect[4]/2 - s/2 - MARGINS_CTR[0];
      }

      setPosition(crect[0], crect[1]);
      setSize((int)s, (int)s);
      return this;
    }
  }

  public class IButton extends Button implements IControllerInterface<Button> {

    private String oscAddress;

    public IButton(ControlP5 cp5, ControllerGroup<?> parent, String name, String label) {
      super(cp5, name);
      setValue(ANALOGDEFAULT);
      setSwitch(true);
      setGroup(parent);

      setLabel(label);
      setLabelVisible(!label.equals(""));

      oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;

      if (!FONTTYPE.equals("default")) {
        getCaptionLabel().getStyle().setPaddingTop(-5);
        getCaptionLabel().setSize((int)MARGINS_CTR[1]-2);
      }
    }

    public IGroup get() {
      IControllerInterface<?> p = (IControllerInterface<?>) getParent();
      return (IGroup)p.get();
    }

    public String getOscAddress() {
      return oscAddress;
    }

    public float getAbsoluteWidth() {
      return getWidth() + 2*MARGINS_CTR[0];
    }

    public float getAbsoluteHeight() {
      return getHeight() + 2*MARGINS_CTR[1];
    } 

    public ControllerList getChildren() {
      return null;
    }

    public IControllerInterface<?> fit() {
      return fit(1.0f);
    } 

    public IControllerInterface<?> fit(float weight) {
      float[] crect = fitToContainer(this, MARGINS_CTR, weight);

      float s;
      if (crect[4] > crect[5]) {
        s = crect[2];
        crect[1] += crect[5]/2 - s/2 - MARGINS_CTR[1];
      } else {
        s = crect[3];
        crect[0] += crect[4]/2 - s/2 - MARGINS_CTR[0];
      }

      setPosition(crect[0], crect[1]);
      setSize((int)s, (int)s);
      return this;
    }
  }

  public class IToggle extends Toggle implements IControllerInterface<Toggle> {

    private String oscAddress;

    public IToggle(ControlP5 cp5, ControllerGroup<?> parent, String name, String label) {
      super(cp5, name);
      setMode(ControlP5.SWITCH);
      setGroup(parent);

      setLabel(label);
      setLabelVisible(!label.equals(""));

      oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;

      if (!FONTTYPE.equals("default")) {
        getCaptionLabel().getStyle().setPaddingTop(-5);
        getCaptionLabel().setSize((int)MARGINS_CTR[1]-2);
      }
    }

    public IGroup get() {
      IControllerInterface<?> p = (IControllerInterface<?>) getParent();
      return (IGroup)p.get();
    }

    public String getOscAddress() {
      return oscAddress;
    }

    public float getAbsoluteWidth() {
      return getWidth() + 2*MARGINS_CTR[0];
    }

    public float getAbsoluteHeight() {
      return getHeight() + 2*MARGINS_CTR[1];
    } 

    public ControllerList getChildren() {
      return null;
    }

    public IControllerInterface<?> fit() {
      return fit(1.0f);
    } 

    public IControllerInterface<?> fit(float weight) {
      float[] crect = fitToContainer(this, MARGINS_CTR, weight);

      float s;
      if (crect[4] > crect[5]) {
        s = crect[2];
        crect[1] += crect[5]/2 - s/2 - MARGINS_CTR[1];
      } else {
        s = crect[3];
        crect[0] += crect[4]/2 - s/2 - MARGINS_CTR[0];
      }

      setPosition(crect[0], crect[1]);
      setSize((int)s, (int)s);
      return this;
    }
  }
}