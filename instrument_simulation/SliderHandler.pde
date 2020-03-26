class SliderHandler {
  final int SLIDERX = EDGE_OFFSET;
  final int SLIDERW = (width - width/3) - 2*EDGE_OFFSET;
  final int SLIDERH = (height - 4*EDGE_OFFSET) / 3;

  final int NUMSLIDERS = 8;
  final int BOXOFFSET  = 15;
  final int SX = SLIDERX + BOXOFFSET;
  final int SW = SLIDERW - 2*BOXOFFSET;
  final int SH = SLIDERH - 2*BOXOFFSET;

  final int SLIDER_WIDTH  = SW / (NUMSLIDERS*2);
  final int SLIDER_HEIGHT = SH;
  final int RMN = (SX + SW) - (SX + (NUMSLIDERS - 1)*SLIDER_WIDTH*2);

  ControlP5 cp5;
  ArrayList<Slider> sliders;

  public SliderHandler( ControlP5 cp5) {
    this.cp5 = cp5;
    sliders = new ArrayList<Slider>();
  }

  public void addSlider(int binx) {    
    int SLIDERX = SX + RMN/3 + binx*2*SLIDER_WIDTH;
    int SLIDERY = EDGE_OFFSET;
    SLIDERY += BOXOFFSET;

    Slider slider = cp5.addSlider("slider" + binx)
      .setPosition(SLIDERX, SLIDERY)
      .setSize(SLIDER_WIDTH, SLIDER_HEIGHT)
      .setRange(0, 1023)
      .setValue((int)random(0, 1023))
      .setSliderMode(Slider.FLEXIBLE)
      .setLabelVisible(false)
      ;
    
    slider.addCallback(new CallbackListener () {
      public void controlEvent(CallbackEvent event) {
        printController(event);
      }
    });
    
    sliders.add(slider);
  }
  
  public void printController(CallbackEvent event) {
    if (event.getAction() == ControlP5.ACTION_BROADCAST) {
      Slider s = (Slider) event.getController();
      println(s.getValue());
    }
  }
  
}