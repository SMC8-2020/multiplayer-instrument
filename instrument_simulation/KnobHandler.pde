class KnobHandler {   
  final int MAXKNOBS = 6;
  final int KNOBX = 2*width/3;
  final int KNOBW = width/3 - EDGE_OFFSET;
  final int KNOBH = (height - (MAXKNOBS+1)*EDGE_OFFSET) / MAXKNOBS;
  final int KNOBR = KNOBH/2;

  ControlP5 cp5;
  ArrayList<Knob> knobs;

  public KnobHandler(ControlP5 cp5) {
    this.cp5 = cp5;
    knobs = new ArrayList<Knob>();
  }

  public void addKnob(int bin, String tag) {
    int KNOBY = (bin + 1)*EDGE_OFFSET + bin*KNOBH;
    Knob knob = cp5.addKnob(tag)
      .setRange(0, 1023)
      .setValue(0)
      .setPosition(KNOBX + KNOBW/3, KNOBY)
      .setRadius(KNOBR)
      .setDragDirection(Knob.VERTICAL)
      .setViewStyle(Knob.ELLIPSE)
      .showTickMarks()
      .snapToTickMarks(true)
      ;
    
    knob.setId(bin);
    knobs.add(knob);
  }
  
}