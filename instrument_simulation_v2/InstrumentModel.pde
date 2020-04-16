public class InstrumentModel {  
  final String SECTIONROOTNAME = "SECTIONROOT";
  final String CONSOLEROOTNAME = "CONSOLEROOT";
  //final String DEFAULTSECTIONPATH = "sections/presets/melodySection.json";
  final String DEFAULTSECTIONPATH = "sections/presets/rhythmSection.json";
  final String DEFAULTCONSOLEPATH = "sections/consoleSection.json"; 

  final String BASENAME = "/smc8";

  private OscP5 osc;
  private OscMessage broadcastRoute;
  private NetAddress remoteLocation; 

  private boolean isBroadcastable = false;

  private int secX, secY, secW, secH;
  private int conX, conY, conW, conH;
  private float sectionAlpha = 0.65;

  private IGroup sectionRoot;
  private IGroup consoleRoot;

  private InstrumentSectionView view;

  private int formatDepth = 2;

  public InstrumentModel(OscP5 osc, NetAddress remoteLocation)  {
    this.osc = osc;
    this.remoteLocation = remoteLocation;
  }

  public void setView(InstrumentSectionView view) {
    this.view = view;
  }

  public void initView() {
    secX = 0;
    secY = 0;
    secH = height;
    secW = (int) (width * sectionAlpha);
    sectionRoot = view.createRootGroup(SECTIONROOTNAME, secX, secY, secW, secH);
    view.parse(DEFAULTSECTIONPATH, sectionRoot);

    conX = secW;
    conY = secY;
    conH =  secH;
    conW = (int) (width * (1.0 - sectionAlpha));
    consoleRoot = view.createRootGroup(CONSOLEROOTNAME, conX, conY, conW, conH);
    view.parse(DEFAULTCONSOLEPATH, consoleRoot);
  }

  public void setBroadcast(boolean toggle) {
    isBroadcastable = toggle;
  }

  public void reset() {
    for (ControllerInterface<?> ctr : view.onlineControllers.get()) {
      ((InstrumentControllerInterface<?>)ctr).reset();
    }
  }
  
  private String formatAddr(String addr) {
    String newAddr = BASENAME;
    String[] tokens = addr.split("/");
    for (int i = 0; i < formatDepth; i++) {
      newAddr += "/" + tokens[i];
    }
    newAddr += "/" + tokens[tokens.length - 1];
    return newAddr;
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

  public void broadcastOsc(String addr, int...values) {

    if (!isBroadcastable) {
      println("broadcast is disabled");
      return;
    }

    String oscAddr = formatAddr(addr);
    broadcastRoute = new OscMessage(oscAddr);
    assignValues(broadcastRoute, values);

    String dbg = String.format("%s   %s   %s", 
      broadcastRoute.addrPattern(), 
      arr2str(values), 
      broadcastRoute.typetag()
      );
    println(dbg);

    osc.send(broadcastRoute, remoteLocation);
  }
}