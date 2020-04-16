public interface InstrumentControllerInterface<T> extends ControllerInterface<T> {
  public List<ControllerInterface<?>> getChildren();
  public int getAbsoluteWidth();
  public int getAbsoluteHeight();
  public String getOscAddress();
  public void reset();
}

public interface ViewSetupInterface {
  public void setIDefault(float value);
  public void setIRange(float min, float max);
  public void setITicks(int ticks);
}

public interface ViewFitInterface {
  public void fit(ViewLayout layout);
}

public class IGroup extends Group implements ViewFitInterface, InstrumentControllerInterface<Group> {

  private final int[] margins = {8, 15};
  private final int barHeight = 9;

  private String oscAddress;
  private float fitWeight;

  public boolean hasSize;

  public IGroup(ControlP5 cp5, String name) {
    super(cp5, name);
    oscAddress = "/" + name;
    hasSize = false;
  }

  public IGroup(ControlP5 cp5, ControllerGroup<?> parent, String name) {
    super(cp5, parent, name, 0, 0, 0, 0);
    setHeight(barHeight);
    oscAddress = ((IGroup)parent).getOscAddress() + "/" + name;
  }

  public String getOscAddress() {
    return oscAddress;
  }

  public float getWeight() {
    return fitWeight;
  }

  public void setWeight(float weight) {
    fitWeight = weight;
  }

  public int getAbsoluteWidth() {
    return getWidth() + 2*margins[0];
  }

  public int getAbsoluteHeight() {
    return getHeight() + 2*margins[1];
  }

  @Override public int getHeight() {
    return getBackgroundHeight();
  }

  @Override public Group setSize(int w, int h) {
    setWidth(w);
    setBackgroundHeight(h);
    hasSize = true;
    return this;
  }

  public List<ControllerInterface<?>> getChildren() {
    return controllers.get();
  }

  private int[] getOffsets() {
    InstrumentControllerInterface<?> p 
      = (InstrumentControllerInterface<?>)getParent();

    List<ControllerInterface<?>> siblings = p.getChildren();
    int idx = siblings.indexOf(this);
    int[] offset = {0, 0};

    if (idx == 0) {
      return offset;
    } else {
      for (int i = idx; i > 0; i--) {
        offset[0] += ((InstrumentControllerInterface<?>)siblings
          .get(idx - i))
          .getAbsoluteWidth()
          ;

        offset[1] += ((InstrumentControllerInterface<?>)siblings
          .get(idx - i))
          .getAbsoluteHeight()
          ;
      }
      return offset;
    }
  }

  public void fit(ViewLayout layout) {
    InstrumentControllerInterface<?> parent =
      (InstrumentControllerInterface<?>) getParent();

    float parentW = parent.getWidth();
    float parentH = parent.getHeight();
    int[] offsets = getOffsets();

    int x, y, w, h;
    if (parentW > parentH) {
      w = (int) (parentW * fitWeight - 2*margins[0]);
      h = (int) (parentH - 2*margins[1]);
      x = margins[0] + offsets[0];
      y = margins[1];
    } else {
      h = (int) (parentH * fitWeight - 2*margins[1]);
      w = (int) (parentW - 2*margins[0]);
      y = margins[1] + offsets[1];
      x = margins[0];
    }

    setPosition(x, y + barHeight/2);
    setSize(w, h);
  }

  // Dummy function
  public void reset() {
  }
}

public class ISlider extends Slider implements ViewFitInterface, ViewSetupInterface, InstrumentControllerInterface<Slider> {

  private final int MAXWIDTH  = 70;
  private final int MAXHEIGHT = 250; 
  private final int TICKSPACE = 5;

  private final int[] margins = {10, 10};

  private String oscAddress;
  private float defaultVal;

  public ISlider(ControlP5 cp5, String name) {
    super(cp5, name);
    setSliderMode(Slider.FLEXIBLE);
    getValueLabel().setVisible(false);
  }

  public List<ControllerInterface<?>> getChildren() {
    return null;
  }

  public String getOscAddress() {
    return oscAddress;
  }

  public int getAbsoluteWidth() {
    return getWidth() + 2*margins[0];
  }

  public int getAbsoluteHeight() {
    return getHeight() + 2*margins[1];
  }

  public void setIDefault(float value) {
    setValue(value);
    defaultVal = value;
  }

  public void setIRange(float min, float max) {
    setRange(min, max);
  }

  public void setITicks(int ticks) {
    if (ticks == 0) {
      return;
    }

    setNumberOfTickMarks(ticks);
    snapToTickMarks(true);
  }

  public void reset() {
    setValue(defaultVal);
  }

  private int getIdx() {
    InstrumentControllerInterface<?> p 
      = (InstrumentControllerInterface<?>)getParent();

    List<ControllerInterface<?>> siblings = p.getChildren();
    return siblings.indexOf(this);
  }

  public void fit(ViewLayout layout) {
    int idx = getIdx();

    int x, y, w, h;
    if (layout.pwidth > layout.pheight) {
      w = layout.cwidth > MAXWIDTH ? MAXWIDTH : layout.cwidth;   
      h = layout.cheight;
      x = TICKSPACE + idx * w;
      y = 0;
    } else {
      h = layout.cheight > MAXHEIGHT ? MAXHEIGHT : layout.cheight;
      w = layout.cwidth;
      y = -TICKSPACE + idx * h;
      x = 0;
    }

    setPosition(x + margins[0], y + margins[1]);
    setSize(w - 2*margins[0], h - 2*margins[1]);
  }
}

public class IKnob extends Knob implements ViewFitInterface, ViewSetupInterface, InstrumentControllerInterface<Knob> {

  private final int MAXSIZE = 75;
  private final int[] margins = {10, 10};

  private String oscAddress;
  private float defaultVal;

  public IKnob(ControlP5 cp5, String name) {
    super(cp5, name);
    setViewStyle(Knob.ELLIPSE);
    getValueLabel().setVisible(false);
  }

  public List<ControllerInterface<?>> getChildren() {
    return null;
  }

  public int getAbsoluteWidth() {
    return getWidth() + 2*margins[0];
  }

  public int getAbsoluteHeight() {
    return getHeight() + 2*margins[1];
  }

  public String getOscAddress() {
    return oscAddress;
  }

  public void setIDefault(float value) {
    setValue(value);
    defaultVal = value;
  }

  public void setIRange(float min, float max) {
    setRange(min, max);
  }

  public void setITicks(int ticks) {
    if (ticks == 0) {
      return;
    }

    setNumberOfTickMarks(ticks);
    snapToTickMarks(true);
  }

  public void reset() {
    setValue(defaultVal);
  }

  private int getIdx() {
    InstrumentControllerInterface<?> p 
      = (InstrumentControllerInterface<?>)getParent();

    List<ControllerInterface<?>> siblings = p.getChildren();
    return siblings.indexOf(this);
  }

  public void fit(ViewLayout layout) {
    int idx = getIdx();
    int col = idx % layout.cols;
    int row = idx / layout.cols;

    int size = layout.cwidth > MAXSIZE ? MAXSIZE : layout.cwidth;

    int x = col * size + (layout.pwidth/2  - (layout.cols*size)/2);
    int y = row * size + (layout.pheight/2 - (layout.rows*size)/2);

    setPosition(x + margins[0], y + margins[1]);
    setSize(size - 2*margins[0], size - 2*margins[1]);
  }
}

public class IButton extends Button implements ViewFitInterface, ViewSetupInterface, InstrumentControllerInterface<Button> {

  private final int MAXSIZE = 75;
  private final int[] margins = {10, 10};

  private String oscAddress;
  private float defaultVal;

  public IButton(ControlP5 cp5, String name) {
    super(cp5, name);
  }

  public List<ControllerInterface<?>> getChildren() {
    return null;
  }

  public int getAbsoluteWidth() {
    return getWidth() + 2*margins[0];
  }

  public int getAbsoluteHeight() {
    return getHeight() + 2*margins[1];
  }

  public String getOscAddress() {
    return oscAddress;
  }

  public void setIDefault(float value) {
    setValue(value);
    defaultVal = value;
  }

  // Dummy function
  public void setIRange(float min, float max) {
  }

  // Dummy function
  public void setITicks(int ticks) {
  }

  public void reset() {
    if (isOn()) {
      setOff();
      setValue(defaultVal);
    }
  }

  private int getIdx() {
    InstrumentControllerInterface<?> p 
      = (InstrumentControllerInterface<?>)getParent();

    List<ControllerInterface<?>> siblings = p.getChildren();
    return siblings.indexOf(this);
  }

  public void fit(ViewLayout layout) {
    int idx = getIdx();
    int col = idx % layout.cols;
    int row = idx / layout.cols;

    int size = layout.cwidth > MAXSIZE ? MAXSIZE : layout.cwidth;

    int x = col * size + (layout.pwidth/2  - (layout.cols*size)/2);
    int y = row * size + (layout.pheight/2 - (layout.rows*size)/2);

    setPosition(x + margins[0], y + margins[1]);
    setSize(size - 2*margins[0], size - 2*margins[1]);
  }
}

public class IToggle extends Toggle implements ViewFitInterface, ViewSetupInterface, InstrumentControllerInterface<Toggle> {

  private final int MAXSIZE = 75;
  private final int[] margins = {10, 10};

  private String oscAddress;
  private float defaultVal;

  public IToggle(ControlP5 cp5, String name) {
    super(cp5, name);
    setMode(ControlP5.SWITCH);
  }

  public List<ControllerInterface<?>> getChildren() {
    return null;
  }

  public int getAbsoluteWidth() {
    return getWidth() + 2*margins[0];
  }

  public int getAbsoluteHeight() {
    return getHeight() + 2*margins[1];
  }

  public String getOscAddress() {
    return oscAddress;
  }

  public void setIDefault(float value) {
    setValue(value);
    defaultVal = value;
  }

  // Dummy function
  public void setIRange(float min, float max) {
  }

  // Dummy function
  public void setITicks(int ticks) {
  }

  public void reset() {
    setValue(defaultVal);
  }

  private int getIdx() {
    InstrumentControllerInterface<?> p 
      = (InstrumentControllerInterface<?>)getParent();

    List<ControllerInterface<?>> siblings = p.getChildren();
    return siblings.indexOf(this);
  }

  public void fit(ViewLayout layout) {
    int idx = getIdx();
    int col = idx % layout.cols;
    int row = idx / layout.cols;

    int size = layout.cwidth > MAXSIZE ? MAXSIZE : layout.cwidth;

    int x = col * size + (layout.pwidth/2  - (layout.cols*size)/2);
    int y = row * size + (layout.pheight/2 - (layout.rows*size)/2);

    setPosition(x + margins[0], y + margins[1]);
    setSize(size - 2*margins[0], size - 2*margins[1]);
  }
}