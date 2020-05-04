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
  public color col = -1;

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
