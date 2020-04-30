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
  private InstrumentOscHandler oscHandler;

  public InstrumentModel(OscP5 osc, NetAddress remoteLocation) {
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

    oscHandler = new InstrumentOscHandler(osc, remoteLocation);
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
    oscHandler.setBroadcast(toggle);
  }

  public void broadcastOsc(String addr, int...values) {
    oscHandler.broadcastOsc(addr, values);
  }
}

public class InstrumentOscHandler {

  final String BASEURL = "/smc8";

  private OscP5 osc;
  private OscMessage broadcastRoute;
  private NetAddress remoteLocation;

  private int formatDepth = 2;
  private boolean isBroadcastable = false;

  public InstrumentOscHandler(OscP5 osc, NetAddress remoteLocation) {
    this.osc = osc;
    this.remoteLocation = remoteLocation;
  }

  private String formatAddr(String addr) {
    String newAddr = BASEURL;
    String[] tokens = addr.split("/");
    for (int i = 0; i < formatDepth; i++) {
      newAddr += "/" + tokens[i];
    }
    newAddr += "/" + tokens[tokens.length - 1];
    return newAddr.replaceAll("\\s+", "");
  }

  private void assignValues(OscMessage route, int[] values) {
    if (values.length == 0) {
      route.add(0);
    } else if (values.length == 1) {
      route.add(values[0]);
    } else {
      route.add(values);
    }
  }

  private String arr2str(int[] arr) {
    String str = "" + arr[0];
    for (int i = 1; i < arr.length; i++) {
      str += "," + arr[i];
    }
    return str;
  } 

  public void setBroadcast(boolean toggle) {
    isBroadcastable = toggle;
  }

  public void broadcastOsc(String addr, int...values) {

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
    
    osc.send(broadcastRoute, remoteLocation);
  }
}
