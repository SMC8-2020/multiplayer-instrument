import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.puredata.processing.*; 
import java.util.List; 
import java.util.Map; 
import java.util.Arrays; 
import java.util.Objects; 
import java.util.Random; 
import controlP5.*; 
import oscP5.*; 
import netP5.*; 
import http.requests.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class instrument_simulation_v2 extends PApplet {











final boolean LOG         = true;
final boolean DEBUG       = true;
final boolean NETWORK     = false;
final boolean RENDERX2    = false;
final boolean SECTIONLOCK = false;



final int ZINWALDBROWN = color(43, 0, 0);
final int BURLYWOOD    = color(158, 131, 96);
final int PLATINUM     = color(229, 234, 218);
final int PLATINUM_40  = color(229, 234, 218, 100);
final int ONYX         = color(0, 26, 13);



String HOST;
final String DEFAULTHOST = "127.0.0.1";
final int    PORT        = 11000;

InstrumentModel model;
ControllerHandler handler;
InstrumentSectionView view;

PureDataProcessing pd = null;

public void setup() 
{
  
  
  if (RENDERX2) {
    pixelDensity(2);
  }
 
  // SETUP CP5 
  ControlP5 cp5 = new ControlP5(this);
  setColor(cp5);

  // SETUP MODEL
  if (NETWORK) {
    setupNetwork();
  } else {
    try {
      setupPd();
    } catch (Exception e) {
      e.printStackTrace();
      setupNetwork();
    }
  }

  // SETUP VIRTUAL INSTRUMENT
  handler = new ControllerHandler();
  view    = new InstrumentSectionView(cp5);

  model.setView(view);
  handler.setModel(model);
  view.setHandler(handler);

  model.initView();
  
  prepareExitHandler();
}

public void draw() 
{
  background(ZINWALDBROWN);
  model.renderInstrumentID();
}

public void setupNetwork() {
  OscP5 oscP5 = new OscP5(this, 12000);
  HOST = oscP5.ip();
  NetAddress remoteLocation = new NetAddress(HOST, PORT);
  model = new InstrumentModel(oscP5, remoteLocation);
}

public void setupPd() {
  pd = new PureDataProcessing(this, 44100, 0, 2);
  pd.openPatch("puredata/instrument.pd");
  String recv = "controlmsg";
  model = new InstrumentModel(pd, recv);
}

public void setColor(ControlP5 cp5) {
  CColor col = new CColor();
  col.setBackground(ZINWALDBROWN);
  col.setForeground(BURLYWOOD);
  col.setActive(PLATINUM);
  col.setCaptionLabel(ONYX);
  cp5.setColor(col);
}

public void pdPrint(String s) {
  if (DEBUG){
    if (!s.contains("warning")) {
      println(s);
    }
  } 
}

public void prepareExitHandler() {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run() {
      System.out.println("Shutting down application " + this);
      if (model != null) {
        model.saveRecordToServer();
      }
      if (pd != null) {
        pd.stop();
      }
      stop();
    }
  }));
}
public class ControllerHandler {

  private final int RNGVALUE = 1;

  private InstrumentModel model;

  private int prevBroadcastValue = -1;
  private Controller prevBroadcastController;

  private String prevSection;
  private boolean setSectionLock = false;

  private Map<String, ControllerList> callbackControllerMap;

  public ControllerHandler() {
    prevBroadcastController = null;
    this.callbackControllerMap = new 
      HashMap<String, ControllerList>();
  }

  public void setModel(InstrumentModel model) {
    this.model = model;
    this.prevSection = model.MELODYTAG;
  }

  public void addControllerToCallbackMap(String callback, Controller ctr) {
    ControllerList li = null;
    if (!callbackControllerMap.containsKey(callback)) {
      li = new ControllerList();
      li.add(ctr);
      callbackControllerMap.put(callback, li);
      return;
    }

    li = callbackControllerMap.get(callback);
    li.add(ctr);
  }

  public void broadcast(ControlEvent event) {
    Controller ctr = event.getController();

    if (!ctr.equals(prevBroadcastController)) {
      prevBroadcastValue = -1;
      prevBroadcastController = ctr;
    }

    int currentValue = (int) ctr.getValue();
    if (currentValue != prevBroadcastValue) {
      model.broadcastOsc(ctr.getName(), currentValue);
      prevBroadcastValue = currentValue;
    }
  }

  public void setSection(ControlEvent event) {
    if (setSectionLock) {
      return;
    }

    setSectionLock = true;
    Toggle ctr = (Toggle)event.getController();
    String name = ctr.getName();
    int idx = Integer.parseInt(""+name.charAt(name.length() - 1));
    
    String currentSection = model.sectionTags[idx];
    
    if (prevSection.equals(currentSection)) {
      ctr.toggle();
      setSectionLock = false;
      return;
    }
    
    model.setSection(currentSection);
    prevSection = currentSection;
    
    ControllerList li 
      = callbackControllerMap.get("setSection");

    for (ControllerInterface<?> c : li.get()) {
      Toggle t = (Toggle)c;
      if (!t.equals(ctr)) {
        if (t.getBooleanValue())
          t.toggle();
      }
    }
    
    setSectionLock = false;
  }

  public void setBroadcast(ControlEvent event) {
    Toggle t = (Toggle) event.getController();
    model.setBroadcast(t.getBooleanValue());
    println("setting broadcast: " + (t.getBooleanValue() ? "On" : "Off"));
  }

  public void reset(ControlEvent event) {
    println("resetting controllers");
    model.resetOnlineControllers();
  } 

  public void ldrActivated(ControlEvent event) {
    Toggle t = (Toggle)event.getController();
    model.broadcastOsc(t.getName(), (int)t.getValue());
  }

  public void rng(ControlEvent event) {
    println("randomizing a beat!");
    model.broadcastOsc(event.getController().getName(), RNGVALUE);
  }

}
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

    setNumberOfTickMarks(ticks - 1);
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

    setPosition(x + margins[0], y + margins[1]/2);
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

  private final int MAXSIZE = 115;
  private final int[] margins = {10, 10};

  private String oscAddress;
  private float defaultVal;

  public IToggle(ControlP5 cp5, String name) {
    super(cp5, name);
    //setMode(ControlP5.SWITCH);
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
public class InstrumentModel {  
  final String SECTIONROOTNAME = "SECTIONROOT";
  final String CONSOLEROOTNAME = "CONSOLEROOT";
  final String MELODYTAG = "Melody";
  final String RHYTHMTAG = "Rhythm";
  final String MELODYPATH = "sections/presets/melodySection_wide.json";
  final String RHYTHMPATH = "sections/presets/rhythmSection_wide.json";
  final String CONSOLEPATH = "sections/consoleSection.json"; 

  private int secX, secY, secW, secH;
  private int conX, conY, conW, conH;
  private int iidX, iidY, iidW, iidH;
  private float sectionAlpha = 0.65f;

  private IGroup currentSection;
  private Map<String, IGroup> sections;
  private Map<String, String> sectionFilePaths;

  public String[] sectionTags;

  private IGroup sectionRoot;
  private IGroup consoleRoot;

  private InstrumentSectionView view;
  private InstrumentBroadcastHandler broadcastHandler;

  public InstrumentModel() {
    sections = new HashMap<String, IGroup>();

    sectionTags = new String[] {
      MELODYTAG, 
      RHYTHMTAG
    };

    sectionFilePaths = new HashMap<String, String>() {
      {
        put(MELODYTAG, MELODYPATH);
        put(RHYTHMTAG, RHYTHMPATH);
      }
    };
  }

  public InstrumentModel(OscP5 osc, NetAddress remoteLocation) {
    this();
    broadcastHandler = new InstrumentOscHandler(osc, remoteLocation);
  }

  public InstrumentModel(PureDataProcessing pd, String recv) {
    this();
    broadcastHandler = new InstrumentPdHandler(pd, recv);
  }

  public void setView(InstrumentSectionView view) {
    this.view = view;
  }

  public void initView() {
    secX = 0;
    secY = 0;
    secH = (int) (height * sectionAlpha);
    secW = width;
    sectionRoot = view.createRootGroup(SECTIONROOTNAME, secX, secY, secW, secH);
    currentSection = view.parse(MELODYPATH, sectionRoot);
    sections.put(MELODYTAG, currentSection);

    conX = secX;
    conY = secH;
    conH = (int) (height * (1.0f - sectionAlpha));
    conW = secW - 315;
    consoleRoot = view.createRootGroup(CONSOLEROOTNAME, conX, conY, conW, conH);
    view.parse(CONSOLEPATH, consoleRoot);

    // TEMPORARY CODE
    iidX = conW + 10;
    iidY = conY + 9;
    iidW = 295;
    iidH = conH - 20;
  }

  // TEMPORARY FUNCTION
  public void renderInstrumentID() {
    fill(PLATINUM_40);
    rect(iidX, iidY, iidW, iidH);



    textAlign(CENTER, CENTER);
    textSize(48);
    fill(PLATINUM);
    text(broadcastHandler.broadcastID, iidX + iidW/2, iidY + iidH/2);
  }

  public void resetOnlineControllers() {
    for (ControllerInterface<?> ctr : view.onlineControllers.get()) {
      ((InstrumentControllerInterface<?>)ctr).reset();
    }
  }

  public void setSection(String tag) {
    if (SECTIONLOCK) {
      if (DEBUG) println("Section switching is disabled");
      return;
    }

    if (!sections.containsKey(tag)) {

      if (!sectionFilePaths.containsKey(tag)) {
        println("No data available for section with tag: " + tag);
        return;
      }

      String path = sectionFilePaths.get(tag);
      sectionRoot.remove(currentSection);
      currentSection = view.parse(path, sectionRoot);
      sections.put(tag, currentSection);
      return;
    } 

    IGroup potSection = sections.get(tag);

    if (currentSection.equals(potSection)) {
      return;
    }

    sectionRoot.remove(currentSection);
    currentSection = potSection;
    sectionRoot.add(potSection);
  }

  public void setBroadcast(boolean toggle) {
    broadcastHandler.setBroadcast(toggle);
  }

  public void broadcastOsc(String addr, int...values) {
    broadcastHandler.broadcast(addr, values);
  }

  public void saveRecordToServer() {
    if (LOG) {
      broadcastHandler.saveRecordToServer();
    }
  }
}

public abstract class InstrumentBroadcastHandler {

  protected final String BASEURL = "/smc8";
  protected OscMessage broadcastRoute;
  protected boolean isBroadcastable = true;
  protected int formatDepth = 2;

  protected Map<String, int[]> unsentBuffer = null;
  
  private final int IDLEN = 6;
  public String broadcastID;
  protected OSCRecorder recorder;

  public InstrumentBroadcastHandler() {
    this.broadcastID = getRandomHexString(IDLEN);
    this.recorder = new OSCRecorder(this.broadcastID);
  }

  public abstract void broadcast(String addr, int...values);

  private String getRandomHexString(int numchars) {
    Random r = new Random();
    StringBuffer sb = new StringBuffer();
    while (sb.length() < numchars) {
      sb.append(String.format("%08x", r.nextInt()));
    }

    return sb.toString().substring(0, numchars).toUpperCase();
  }

  protected String formatAddr(String addr) {
    String newAddr = BASEURL;
    String[] tokens = addr.split("/");
    for (int i = 0; i < formatDepth; i++) {
      newAddr += "/" + tokens[i];
    }
    newAddr += "/" + tokens[tokens.length - 1];
    return newAddr.replaceAll("\\s+", "");
  }

  protected void assignValues(OscMessage route, int[] values) {
    if (values.length == 0) {
      route.add(0);
    } else if (values.length == 1) {
      route.add(values[0]);
    } else {
      route.add(values);
    }
  }

  protected String arr2str(int[] arr) {
    String str = "" + arr[0];
    for (int i = 1; i < arr.length; i++) {
      str += "," + arr[i];
    }
    return str;
  } 

  protected void assignLastUnsent(String addr, int...values) {
    if (unsentBuffer == null) {
      unsentBuffer = new HashMap<String, int[]>();
    }
    unsentBuffer.put(addr, values);
  }

  protected boolean createOscMessage(String addr, int...values) {

    if (!isBroadcastable) {
      assignLastUnsent(addr, values);
      if (DEBUG) println("broadcast is disabled");
      return false;
    }

    String oscAddr = formatAddr(addr);
    broadcastRoute = new OscMessage(oscAddr);
    assignValues(broadcastRoute, values);
    return true;
  }

  protected void onBroadcastOn() {
    if (unsentBuffer == null) {
      return;
    }

    for (Map.Entry<String, int[]> entry : unsentBuffer.entrySet()) {
      broadcast(entry.getKey(), entry.getValue());
    }

    unsentBuffer.clear();
    unsentBuffer = null;
  }

  protected void onBroadcastOff() {
  }

  public void setBroadcast(boolean toggle) {
    isBroadcastable = toggle;

    if (toggle) {
      onBroadcastOn();
    } else {
      onBroadcastOff();
    }
  }

  public void saveRecordToServer() {
    recorder.startNewRecording();
  }
}

public class InstrumentOscHandler extends InstrumentBroadcastHandler {

  private OscP5 osc;
  private NetAddress remoteLocation;

  public InstrumentOscHandler(OscP5 osc, NetAddress remoteLocation) {
    super();
    this.osc = osc;
    this.remoteLocation = remoteLocation;
  }

  @Override public void broadcast(String addr, int...values) {

    if (!createOscMessage(addr, values)) {
      return;
    }

    if (DEBUG) {
      String dbg = String.format("%s   %s   %s", 
        broadcastRoute.addrPattern(), 
        arr2str(values), 
        broadcastRoute.typetag()
        );
      println(dbg);
    }

    if (LOG) {
      recorder.record(broadcastRoute);
    }

    osc.send(broadcastRoute, remoteLocation);
  }
}

public class InstrumentPdHandler extends InstrumentBroadcastHandler {

  private String recv;
  private PureDataProcessing pd;

  private boolean isDsp;

  public InstrumentPdHandler(PureDataProcessing pd, final String recv) {
    super();
    this.pd = pd;
    this.recv = recv;
    this.isDsp = true;
    this.pd.start();
  }

  private Object[] b2f(OscMessage msg) {
    byte[] oscbytes = msg.getBytes();
    Object[] oscfloats = new Object[oscbytes.length];
    for (int i = 0; i < oscfloats.length; i++) {
      oscfloats[i] = (float)oscbytes[i];
    }
    return oscfloats;
  }

  @Override protected void onBroadcastOn() {
    super.onBroadcastOn();
    if (!isDsp) {
      pd.start();
      isDsp = !isDsp;
    }
  }

  @Override protected void onBroadcastOff() {
    super.onBroadcastOff();
    if (isDsp) {
      pd.stop();
      isDsp = !isDsp;
    }
  }

  @Override public void broadcast(String addr, int...values) {

    if (!createOscMessage(addr, values)) {
      return;
    }

    if (LOG) {
      recorder.record(broadcastRoute);
    }

    Object[] oscfloats = b2f(broadcastRoute);
    pd.sendList(recv, oscfloats);
  }
}
public interface InstrumentViewInterface {
  
  static final String SLIDERTAG = "Slider";
  static final String KNOBTAG   = "Knob";
  static final String BUTTONTAG = "Button";
  static final String TOGGLETAG = "Toggle";

  static final String RECTALGO   = "RectFill";
  static final String SQUAREALGO = "SquareFill";

  static final HashMap<String, Class> CONTROLMAP = new HashMap<String, Class>() {
    {
      put(SLIDERTAG, ISlider.class);
      put(KNOBTAG  , IKnob.class  );
      put(BUTTONTAG, IButton.class);
      put(TOGGLETAG, IToggle.class);
    }
  };
}

public class ViewLayout {
  int pwidth, pheight;
  int cwidth, cheight;
  int rows, cols;
  boolean centering;

  private ViewLayout(int rows, int cols, int pw, int ph) {
    this.rows = rows;
    this.cols = cols;
    pwidth = pw;
    pheight = ph;
  }

  public ViewLayout(int rows, int cols, int pw, int ph, int w, int h) {
    this(rows, cols, pw, ph);
    cwidth = w;
    cheight = h;
  }

  public ViewLayout(int rows, int cols, int pw, int ph, int s) {
    this(rows, cols, pw, ph, s, s);
  }
}

public abstract class InstrumentView implements InstrumentViewInterface {
  final int ZINWALDBROWN = color(43, 0, 0);
  final int COFFEEBROWN  = color(158, 131, 96);
  final int BURLYWOOD    = color(222, 184, 135);
  final int PLATINUM     = color(229, 234, 218);
  final int PLATINUM_40  = color(229, 234, 218, 100);
  final int ONYX         = color(0, 26, 13);

  final String ONLINE = "online";

  protected ControlP5 cp5;
  private ControllerList onlineControllers;
  private ControllerList localControllers;

  private ControllerHandler controllerHandler;

  public InstrumentView (ControlP5 cp5) {
    this.cp5 = cp5;
    onlineControllers = new ControllerList();
    localControllers  = new ControllerList();
  }

  public void setHandler(ControllerHandler handler) {
    controllerHandler = handler;
  }
  
  public ControllerList getOnlineControllers() {
    return onlineControllers;
  }

  public ControllerList getLocalControllers() {
    return localControllers;
  }

  public IGroup initGroup(String name, int x, int y, int w, int h) {
    IGroup group = new IGroup(cp5, name);
    group.setPosition(x, y);
    group.setWidth(w);
    group.setBackgroundHeight(h);
    setGroupGlobals(group);
    group.setBackgroundColor(ZINWALDBROWN);
    group.hideBar();
    return group;
  }

  protected void setGroupGlobals(Group g) {
    g.setBackgroundColor(PLATINUM_40);
    g.setColorBackground(BURLYWOOD);
    g.setColorForeground(BURLYWOOD);
    g.setColorActive(BURLYWOOD);
    g.disableCollapse();
  }

  protected void setControllerParams(Controller ctr, ControllerInfo info) {
    ViewSetupInterface ictr = (ViewSetupInterface) ctr;

    ctr.setLabel(info.label);
    ictr.setIRange(info.minRange, info.maxRange);
    ictr.setITicks(info.nticks);
    ictr.setIDefault(info.defaultValue);
    
    if (info.col != -1) {
      ctr.setColorBackground(info.col);
    }
    
    ctr.plugTo(controllerHandler, info.callback);
    controllerHandler.addControllerToCallbackMap(info.callback, ctr);
  }
  
  protected IGroup createGroup(ControllerGroup<?> parent, String name) {
    IGroup group = new IGroup(cp5, parent, name);    
    setGroupGlobals(group);
    return group;
  }

  protected Controller addController(String name, Class<?> cls) {
    Controller ctr = null;

    if (cls == ISlider.class) {
      ctr = new ISlider(cp5, name);
    } else if (cls == IKnob.class) {
      ctr = new IKnob(cp5, name);
    } else if (cls == IButton.class) {
      ctr = new IButton(cp5, name);
    } else if (cls == IToggle.class) {
      ctr = new IToggle(cp5, name);
    }

    return ctr;
  }

  protected Controller createController(ControllerInfo info, String name) {
    Class<?> controllerType = CONTROLMAP.get(info.type);
    Controller controller = addController(name, controllerType);
    setControllerParams(controller, info);

    if (info.status.equals(ONLINE)) {
      onlineControllers.add(controller);
    } else {
      localControllers.add(controller);
    }

    return controller;
  }

  protected ViewLayout fitRectangles(int ni, int xi, int yi) {
    float n = (float)ni;
    float x = (float)xi;
    float y = (float)yi;

    int w, h, rows, cols;
    if (xi > yi) {
      w = (int) (x / n);
      h = yi;
      rows = 1;
      cols = ni;
    } else {
      h = (int) (y / n);
      w = xi;
      cols = 1;
      rows = ni;
    }

    return new ViewLayout(rows, cols, xi, yi, w, h);
  }

  protected ViewLayout fitSquares(int ni, int xi, int yi) {
    float n, x, y; 
    n = (float)ni;
    x = (float)xi;
    y = (float)yi;

    float ratio = x / y;
    float ncols_float = sqrt(n * ratio);
    float nrows_float = n / ncols_float;

    // fit height
    float nrows1 = ceil(nrows_float);
    float ncols1 = ceil(n / nrows1);
    while ((nrows1 * ratio) < ncols1) {
      nrows1++;
      ncols1 = ceil(n / nrows1);
    }
    float cell_size1 = y / nrows1;

    // fit width
    float ncols2 = ceil(ncols_float);
    float nrows2 = ceil(n / ncols2);
    while (ncols2 < (nrows2 * ratio)) {
      ncols2++;
      nrows2 = ceil(n / ncols2);
    }
    float cell_size2 = x / ncols2;

    int nrows, ncols, size;
    if (cell_size1 <= cell_size2) {
      nrows = (int)nrows2;
      ncols = (int)ncols2;
      size = (int)cell_size2;
    } else {
      nrows = (int)nrows1;
      ncols = (int)ncols1;
      size = (int)cell_size1;
    }

    return new ViewLayout(nrows, ncols, xi, yi, size);
  }

  protected ViewLayout fitControllers(Group parent, int numControllers, String fitAlgo) {
    int parentW = parent.getWidth();
    int parentH = parent.getBackgroundHeight();

    ViewLayout layout;
    if (fitAlgo.equals(RECTALGO)) {
      layout = fitRectangles(
        numControllers, 
        parentW, 
        parentH
        );
    } else {
      layout = fitSquares(
        numControllers, 
        parentW, 
        parentH
        );
    }

    return layout;
  }
} 

public class ControllerInfo {

  public String type;
  public int quantity;
  public String callback;
  public String status;
  public float minRange;
  public float maxRange;
  public float defaultValue;
  public String label;
  public int nticks;  
  public int col = -1;

  public ControllerInfo(JSONObject JSONControllerInfo) {
    type         = JSONControllerInfo.getString("type");
    nticks       = JSONControllerInfo.getInt("ticks");
    status       = JSONControllerInfo.getString("status");
    quantity     = JSONControllerInfo.getInt("quantity");
    callback     = JSONControllerInfo.getString("callback");
    defaultValue = JSONControllerInfo.getFloat("default");

    JSONArray range = JSONControllerInfo.getJSONArray("range");
    if (range.size() > 0) {
      minRange = range.getInt(0);
      maxRange = range.getInt(1);
    }

    String[] labels = JSONControllerInfo.getJSONArray("label").getStringArray();
    label = labels.length > 0 ? labels[0] : "";
    
    int[] rgba = JSONControllerInfo.getJSONArray("color").getIntArray();
    if (rgba.length == 4) {
      col = color(rgba[0], rgba[1], rgba[2], rgba[3]);
    } else if (rgba.length == 3) {
      col = color(rgba[0], rgba[1], rgba[2], 255);
    }
    
  }
}

public class InstrumentViewLayoutParser extends InstrumentView {

  private final String CONTROLLERGROUP = "ControllerGroup";

  public InstrumentViewLayoutParser(ControlP5 cp5) {
    super(cp5);
  }

  public IGroup parseHierarchy(String jsonPath, IGroup root) {
    JSONObject layoutJson = loadJSONObject(jsonPath);
    JSONObject section = layoutJson.getJSONObject("section");

    String name = section.getString("name");
    int id = section.getInt("id");
    float weight = section.getFloat("weight");

    IGroup group = createGroup(root, name + id);
    group.setLabel(name);
    group.setWeight(weight);
    group.fit(null);

    JSONArray children = section.getJSONArray("children");
    for (int i = 0; i < children.size(); i++) {
      parseHierarchy(children.getJSONObject(i), group);
    }

    return group;
  }

  protected void parseHierarchy(JSONObject child, IGroup parent) {    
    String name  = child.getString("name");
    int id = child.getInt("id");
    float weight = child.getFloat("weight");
    
    IGroup group = createGroup(parent, parent.getName() + "/" + name + id);
    group.setLabel(name);
    group.setWeight(weight);
    group.fit(null);

    String groupType = child.getString("grouptype");
    if (groupType.equals(CONTROLLERGROUP)) {
      String fitAlgo = child.getString("fitAlgo");
      parseControllerParams(group, 
        child.getJSONArray("controllers"), 
        fitAlgo
        );
      return;
    }

    JSONArray children = child.getJSONArray("children");
    for (int i = 0; i < children.size(); i++) {
      parseHierarchy(children.getJSONObject(i), group);
    }
  }

  protected void parseControllerParams(IGroup parent, JSONArray controllers, String fitAlgo) {
    ControllerInfo info = null;
    int numControllers = controllers.size();

    ViewLayout layout = fitControllers(parent, numControllers, fitAlgo);

    for (int i = 0; i < numControllers; i++) {
      info = new ControllerInfo(controllers.getJSONObject(i));
      String name = parent.getName() + "/" + info.type + i;
      Controller controller = createController(info, name);
      controller.setGroup(parent);
      ((ViewFitInterface)controller).fit(layout);
    }
  }
}

public class InstrumentSectionView {

  private InstrumentViewLayoutParser parser;
  
  public ControllerList onlineControllers;
  public ControllerList localControllers;

  public InstrumentSectionView(ControlP5 cp5) {
    parser = new InstrumentViewLayoutParser(cp5);
    onlineControllers = parser.getOnlineControllers();
    localControllers = parser.getLocalControllers();
  }
  
  public void setHandler(ControllerHandler handler) {
    parser.setHandler(handler);
  }
  
  public IGroup createRootGroup(String name, int x, int y, int w, int h) {
    return parser.initGroup(name, x, y, w, h);
  }

  public IGroup parse(String path, IGroup root) {
    return parser.parseHierarchy(path, root);
  }
  
}


public class OSCRecorder {

  private int inactivity;
  private boolean forceInt;
  private String playerID;

  private int epoch;
  private int counter;

  private static final int logitems = 25;
  private String[] lines;
  private String filename;
  private PrintWriter output;
  private int prevTimestap;

  private static final String serverURL = "http://neuronasmuertas.com/smc8/";

  public OSCRecorder (String playerID, int inactivity, boolean forceInt) {
    this.playerID = playerID;
    this.inactivity = inactivity;
    this.forceInt = forceInt;

    epoch = -1;
    lines = new String[logitems];
    //filename = "data/20200414_101803.csv";
    filename = "";
    initBuffer();
  }

  public OSCRecorder (String playerID, int inactivity) {
    this(playerID, inactivity, false);
  }

  public OSCRecorder (String playerID) {
    this(playerID, -1, false);
  }

  public void initBuffer() {
    counter = 0;
    for (int f=0; f<logitems; f++) {
      lines[f]="";
    }
  }

  public void record(OscMessage m) {

    int currTimestamp = millis();

    //If the user has been inactive for more than inactivity milliseconds and 
    //has already recorded something (epoch >= 0), close the file and set 
    //epoch to -1 to start a new recording.
    if (inactivity>0 && currTimestamp-prevTimestap >= inactivity) {
      if (epoch >= 0) {
        output.close();
      }
      epoch = -1;
    }

    //We need to start a new recording. Set epoch to current millis, so the
    //messages start at 0, create a writer for the new file.
    if (epoch < 0) {
      epoch = currTimestamp;
      prevTimestap = currTimestamp;
      filename = "data/" + getFilename();
      output = createWriter(filename);
      initBuffer();
    }

    String typetag = m.typetag();

    String log = String.format("%d,%s,%s", 
      currTimestamp-epoch, 
      m.addrPattern(), 
      typetag);

    for (int f=0; f<typetag.length(); f++) {
      switch(typetag.charAt(f)) {
      case 'i':
        log += "," + m.get(f).intValue();
        break;
      case 'c':
        log += ",'" + m.get(f).charValue()+"'";
        break;
      case 's':
        log += ",'" + m.get(f).stringValue()+"'";
        break;
      case 'f':
        if (forceInt) {
          log += "," + PApplet.parseInt(m.get(f).floatValue());
        } else {
          log += "," + m.get(f).floatValue();
        }
        break;
      case 'T':
        log += ",true";
        break;    
      case 'F':
        log += ",false";
        break;
      default:
        println("Unknown element " + typetag.charAt(f));
      }
    }

    output.println(log); 
    output.flush();

    arrayCopy(lines, 1, lines, 0, logitems-1);
    lines[lines.length-1] = log;
    counter++;

    prevTimestap = currTimestamp;
  }



  public String getFilename() {
    return String.format("%s_%02d%02d%02d_%02d%02d%02d.csv", playerID, 
      year(), month(), day(), hour(), minute(), second()
      );
  }

  public void startNewRecording() {

    if (inactivity > 0) {
      prevTimestap = -inactivity;
    }
  
    if (filename.equals("") || counter==0) {
      return;
    }

    String[] lines = loadStrings(filename);
    String file = "";
    for (int i = 0; i < lines.length; i++) {
      file += lines[i] + "\n";
    }

    PostRequest post = new PostRequest(serverURL);
    post.addData("filename", filename);
    post.addData("contents", file);
    post.send();
    println("Reponse Content: " + post.getContent());
    println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
  }
}
  public void settings() {  size(1020, 595); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "instrument_simulation_v2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
