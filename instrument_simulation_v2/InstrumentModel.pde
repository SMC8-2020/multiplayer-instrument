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

  final int timeOut = 60000;
  protected OSCRecorder recorder;

  protected Map<String, int[]> unsentBuffer = null;
  
  private final int IDLEN = 6;
  public String broadcastID;

  public InstrumentBroadcastHandler() {
    this.broadcastID = getRandomHexString(IDLEN);
    this.recorder = new OSCRecorder(timeOut);
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
