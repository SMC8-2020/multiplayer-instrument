public abstract class InstrumentModule {
  public final int ANALOGMIN = 0;
  public final int ANALOGMAX = 1023;
  
  public final int MAXCONTROLLERS = 32;
  public final color MODULECOLOR = color(190, 206, 228); 
  
  protected int numControllers = 0;
  
  protected CallbackListener cb;

  protected final int TOKENS  = 7;
  protected String name       = "name"; 
  protected String section    = "section";
  protected String section_id = "section_id";
  protected String module     = "module";
  protected String ctag       = "controller";
  protected String cid        = "controller_id";
  protected String cval       = "value";

  protected String[] msgTemplate;

  protected int prevVal = -1000;
  protected int prevId  = -1000;
  
  protected ControlP5 cp5;
  
  public abstract void addController(int idx, int id, String tag);
  public abstract void setControllerArea(int x, int y, int w, int h);
  public abstract void setController(int idx);
  public abstract void renderControllerArea();
  
  public InstrumentModule (ControlP5 cp5) {
    
    this.cp5 = cp5;
    
    this.msgTemplate = new String[TOKENS];
    this.msgTemplate[0] = this.name;
    this.msgTemplate[1] = this.section;
    this.msgTemplate[2] = this.section_id;
    this.msgTemplate[3] = this.module;
    this.msgTemplate[4] = this.ctag;
    this.msgTemplate[5] = this.cid;
    this.msgTemplate[6] = this.cval;

    this.cb = new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        onControllerChanged(event);
      }
    };
  }
    
  /*
  public InstrumentModule(ControlP5 cp5, String[] oscTags) {
    this(cp5);
    if (oscTags.length == 4) {
      this.msgTemplate[0] = oscTags[0];
      this.msgTemplate[1] = oscTags[1];
      this.msgTemplate[2] = oscTags[2];
      this.msgTemplate[3] = oscTags[3];
    }
  }
  
  public CallbackListener getControllerCallback() {
    return this.cb;
  }
  */
  
  protected String createOSCMessage() {
    this.msgTemplate[4] = this.ctag;
    this.msgTemplate[5] = this.cid;
    this.msgTemplate[6] = this.cval;
    return "/" + join(this.msgTemplate, "/");
  }

  public void onControllerChanged(CallbackEvent event) {
    if (event.getAction() == ControlP5.ACTION_BROADCAST) {
      Controller c = event.getController();

      int id  = c.getId();
      if (id != prevId) {
        prevVal = -1000;
        prevId = id;
      }

      int val = (int) c.getValue();
      if (val != prevVal) {
        ctag = c.getName();
        cid  = str(id);
        cval = str(val);
        String msg = createOSCMessage();
        println(msg);
        prevVal = val;
      }
    }
  }
}