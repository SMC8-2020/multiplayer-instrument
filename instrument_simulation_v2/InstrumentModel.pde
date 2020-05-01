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
  private float sectionAlpha = 0.65;

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
    conH = (int) (height * (1.0 - sectionAlpha));
    conW = secW;
    consoleRoot = view.createRootGroup(CONSOLEROOTNAME, conX, conY, conW, conH);
    view.parse(CONSOLEPATH, consoleRoot);
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
}

public abstract class InstrumentBroadcastHandler {

  protected final String BASEURL = "/smc8";
  protected OscMessage broadcastRoute;
  protected boolean isBroadcastable = false;
  protected int formatDepth = 2;
  
  final int timeOut = 60000;
  protected OSCRecorder recorder;
  
  public InstrumentBroadcastHandler() {
    this.recorder = new OSCRecorder(timeOut);
  }

  public abstract void broadcast(String addr, int...values);

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

  public void setBroadcast(boolean toggle) {
    isBroadcastable = toggle;
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

    if (!isBroadcastable) {
      if (DEBUG) println("broadcast is disabled");
      return;
    }

    String oscAddr = formatAddr(addr);
    broadcastRoute = new OscMessage(oscAddr);
    assignValues(broadcastRoute, values);

    if (DEBUG) {
      String dbg = String.format("%s   %s   %s", 
        broadcastRoute.addrPattern(), 
        arr2str(values), 
        broadcastRoute.typetag()
        );
      println(dbg);
    }
    
    recorder.record(broadcastRoute);
    osc.send(broadcastRoute, remoteLocation);
  }
}

public class InstrumentPdHandler extends InstrumentBroadcastHandler {

  private String recv;
  private PureDataProcessing pd;

  public InstrumentPdHandler(PureDataProcessing pd, final String recv) {
    super();
    this.pd = pd;
    this.recv = recv;
  }

  @Override public void broadcast(String addr, int...values) {

    if (!isBroadcastable) {
      if (DEBUG) println("broadcast is disabled");
      return;
    }

    String oscAddr = formatAddr(addr);
    broadcastRoute = new OscMessage(oscAddr);
    assignValues(broadcastRoute, values);

    byte[] oscbytes = broadcastRoute.getBytes();
    Object[] oscfloats = new Object[oscbytes.length];
    for (int i = 0; i < oscfloats.length; i++) {
      oscfloats[i] = (float)oscbytes[i];
    }
    
    recorder.record(broadcastRoute);
    pd.sendList(recv, oscfloats);
  }
}
