public class SliderModule extends InstrumentModule {
  
  private int X, Y;
  private int W, H;
  private int OFFX, OFFY;
  
  private Slider[] sliders;

  public SliderModule(ControlP5 cp5, String[] tags) {
    super(cp5);
    sliders = new Slider[MAXCONTROLLERS];
  }

  @Override public void addController(int idx, int id, String tag) {
    float initValue = random(ANALOGMIN, ANALOGMAX);
    Slider s = cp5.addSlider(tag)  
      .setId(id)
      .setValue((int) initValue)
      .addCallback(this.cb)
      .setLabelVisible(false)
      .setRange(ANALOGMIN, ANALOGMAX)
      .setSliderMode(Slider.FLEXIBLE)
      ;
    this.sliders[idx] = s;
  }
  
  @Override public void setControllerArea(int x, int y, int w, int h){
    this.X = x; this.Y = y;
    this.W = w; this.H = h;
    //this.OFFX = offx; this.OFFY = offy;
  }
  
  @Override public void setController(int idx) {
    /*
    sliders[idx]
      .setPosition(this.X + x, this.Y + y)
      .setSize(w, h)
      ;
    */
  }

  @Override public void renderControllerArea() {
    fill(MODULECOLOR);
    rect(X, Y, W, H);
  }
}