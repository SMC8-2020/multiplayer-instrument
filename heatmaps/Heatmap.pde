public class Heatmap {

  private String filename;
  private  String[] events;
  private int nextEvent;

  HashMap<String, Integer> hm;
  HashMap<String, PVector> coordinates;




  public Heatmap(String filename) {

    this.filename = filename;
    nextEvent = 0;

    hm = new HashMap<String, Integer>();
    loadPerformance();

    coordinates = new HashMap<String, PVector>();

    coordinates.put("Melody1", new PVector(970, 9));
    coordinates.put("Melody1_PerformanceModifiers1", new PVector(127, 28));
    coordinates.put("Melody1_Sequencer1", new PVector(670, 28));
    coordinates.put("Melody1_SoundModifiers1", new PVector(970, 153));

    coordinates.put("Melody1_Sequencer1_Slider0", new PVector(208, 320));
    coordinates.put("Melody1_Sequencer1_Slider1", new PVector(208+65, 320));
    coordinates.put("Melody1_Sequencer1_Slider2", new PVector(208+65*2, 320));
    coordinates.put("Melody1_Sequencer1_Slider3", new PVector(208+65*3, 320));
    coordinates.put("Melody1_Sequencer1_Slider4", new PVector(208+65*4, 320));
    coordinates.put("Melody1_Sequencer1_Slider5", new PVector(208+65*5, 320));
    coordinates.put("Melody1_Sequencer1_Slider6", new PVector(208+65*6, 320));
    coordinates.put("Melody1_Sequencer1_Slider7", new PVector(208+65*7, 320));
    
    coordinates.put("Melody1_PerformanceModifiers1_Knob0", new PVector(77,73));
    coordinates.put("Melody1_PerformanceModifiers1_Knob1", new PVector(77,73+59*1));
    coordinates.put("Melody1_PerformanceModifiers1_Knob2", new PVector(77,73+59*2));
    coordinates.put("Melody1_PerformanceModifiers1_Knob3", new PVector(77,73+59*3));
    coordinates.put("Melody1_PerformanceModifiers1_Knob4", new PVector(77,73+59*4));
    
    coordinates.put("Rhythm1", new PVector(970, 380));
    coordinates.put("Rhythm1_PerformanceModifiers1", new PVector(127, 399));
    coordinates.put("Rhythm1_Sequencer1", new PVector(670, 399));
    coordinates.put("Rhythm1_SoundModifiers1", new PVector(970, 524));

    coordinates.put("Rhythm1_Sequencer1_Slider0", new PVector(208, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider1", new PVector(208+65, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider2", new PVector(208+65*2, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider3", new PVector(208+65*3, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider4", new PVector(208+65*4, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider5", new PVector(208+65*5, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider6", new PVector(208+65*6, 691));
    coordinates.put("Rhythm1_Sequencer1_Slider7", new PVector(208+65*7, 691));

    coordinates.put("Console0_Broadcast0", new PVector(660, 769));
  }



  void loadPerformance() {

    events = loadStrings("data/" + filename);

    //for (String event : events) {
    //  String[] split = split(event, ',');
    //}
  }


  void tick() {

    if (nextEvent<events.length) {
      String[] msg = split(events[nextEvent], ',');
      String[] path = split(msg[1], '/');

      String key = path[2];
      computeKey(key, false);

      key += "_"+path[3];
      computeKey(key, false);

      key += "_"+path[4];
      computeKey(key, true);

      nextEvent++;
    }
  }



  void draw() {
    for ( String key : hm.keySet() ) {
      if (coordinates.containsKey(key)) {
        PVector coords = coordinates.get(key);
        float w = textWidth(hm.get(key)+"") + 10;
        noStroke();
        fill(0, 150);
        rect(coords.x-w/2, coords.y-10, w, 26);
        fill(255);
        text(hm.get(key), coords.x, coords.y);
      }
    }
  }



  void computeKey(String key, boolean log) {

    if (!hm.containsKey(key)) {
      hm.put(key, 0);
    }

    hm.put(key, hm.get(key)+1);
    if (log && !(coordinates.containsKey(key))) {
      println(key + ": " + hm.get(key));
    }
  }
}
