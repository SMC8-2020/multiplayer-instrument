public class Heatmap {

  private String filename;
  private  String[] events;
  private int nextEvent;

  HashMap<String, Integer> hm;
  HashMap<String, PVector> coordinates;

  PImage background;



  public Heatmap(String filename) {

    background = loadImage("background.png");

    this.filename = filename;
    nextEvent = 0;

    hm = new HashMap<String, Integer>();
    events = loadStrings("data/" + filename);

    coordinates = new HashMap<String, PVector>();

    //First level
    coordinates.put("Melody1", new PVector(970, 9));
    coordinates.put("Rhythm1", new PVector(970, 380));


    //Second level
    coordinates.put("Melody1/PerformanceModifiers1", new PVector(127, 28));
    coordinates.put("Melody1/Sequencer1", new PVector(670, 28));
    coordinates.put("Melody1/SoundModifiers1", new PVector(970, 43));

    coordinates.put("Rhythm1/PerformanceModifiers1", new PVector(127, 399));
    coordinates.put("Rhythm1/Sequencer1", new PVector(670, 399));
    coordinates.put("Rhythm1/SoundModifiers1", new PVector(970, 414));

    coordinates.put("Console0/Broadcast0", new PVector(660, 769));


    //Third level
    coordinates.put("Melody1/Sequencer1/Slider0", new PVector(208, 320));
    coordinates.put("Melody1/Sequencer1/Slider1", new PVector(208+65, 320));
    coordinates.put("Melody1/Sequencer1/Slider2", new PVector(208+65*2, 320));
    coordinates.put("Melody1/Sequencer1/Slider3", new PVector(208+65*3, 320));
    coordinates.put("Melody1/Sequencer1/Slider4", new PVector(208+65*4, 320));
    coordinates.put("Melody1/Sequencer1/Slider5", new PVector(208+65*5, 320));
    coordinates.put("Melody1/Sequencer1/Slider6", new PVector(208+65*6, 320));
    coordinates.put("Melody1/Sequencer1/Slider7", new PVector(208+65*7, 320));

    coordinates.put("Melody1/PerformanceModifiers1/Knob0", new PVector(77, 73));
    coordinates.put("Melody1/PerformanceModifiers1/Knob1", new PVector(77, 73+59*1));
    coordinates.put("Melody1/PerformanceModifiers1/Knob2", new PVector(77, 73+59*2));
    coordinates.put("Melody1/PerformanceModifiers1/Knob3", new PVector(77, 73+59*3));
    coordinates.put("Melody1/PerformanceModifiers1/Knob4", new PVector(77, 73+59*4));

    coordinates.put("Melody1/SoundModifiers1/Knob0", new PVector(780, 80));
    coordinates.put("Melody1/SoundModifiers1/Knob1", new PVector(855, 80));
    coordinates.put("Melody1/SoundModifiers1/Knob2", new PVector(930, 80));

    coordinates.put("Melody1/SoundModifiers1/Toggle0", new PVector(817, 207));
    coordinates.put("Melody1/SoundModifiers1/Toggle1", new PVector(893, 207));
    coordinates.put("Melody1/SoundModifiers1/Toggle2", new PVector(817, 282));
    coordinates.put("Melody1/SoundModifiers1/Toggle3", new PVector(893, 282));

    coordinates.put("Rhythm1/Sequencer1/Slider0", new PVector(208, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider1", new PVector(208+65, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider2", new PVector(208+65*2, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider3", new PVector(208+65*3, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider4", new PVector(208+65*4, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider5", new PVector(208+65*5, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider6", new PVector(208+65*6, 691));
    coordinates.put("Rhythm1/Sequencer1/Slider7", new PVector(208+65*7, 691));

    coordinates.put("Rhythm1/PerformanceModifiers1/Knob0", new PVector(77, 487));
    coordinates.put("Rhythm1/PerformanceModifiers1/Toggle1", new PVector(77, 563));
    coordinates.put("Rhythm1/PerformanceModifiers1/Knob2", new PVector(77, 637));

    coordinates.put("Rhythm1/SoundModifiers1/Toggle0", new PVector(817, 207+369));
    coordinates.put("Rhythm1/SoundModifiers1/Toggle1", new PVector(893, 207+369));
    coordinates.put("Rhythm1/SoundModifiers1/Toggle2", new PVector(817, 282+369));
    coordinates.put("Rhythm1/SoundModifiers1/Toggle3", new PVector(893, 282+369));

    coordinates.put("Rhythm1/SoundModifiers1/Knob0", new PVector(817, 452));
    coordinates.put("Rhythm1/SoundModifiers1/Knob1", new PVector(893, 452));

    coordinates.put("Console0/Broadcast0/Knob0", new PVector(405, 843));
    coordinates.put("Console0/Broadcast0/Knob1", new PVector(480, 843));
    coordinates.put("Console0/Broadcast0/Toggle2", new PVector(555, 843));
  }



  void tick() {

    if (nextEvent<events.length) {
      String[] msg = split(events[nextEvent], ',');
      String[] path = split(msg[1], '/');

      String key = path[2];
      computeKey(key, false);

      key += "/"+path[3];
      computeKey(key, false);

      key += "/"+path[4];
      computeKey(key, true);

      nextEvent++;
    }
  }



  void analyze() {
    while (nextEvent<events.length) {
      tick();
    }
  }    



  void draw() {

    image(background, 0, 0);

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

    text(filename.substring(0, 22), 856, 837);
  }



  void computeKey(String key, boolean log) {

    if (!hm.containsKey(key)) {
      hm.put(key, 1);
    } else {
      hm.put(key, hm.get(key)+1);
    }

    if (log && !(coordinates.containsKey(key))) {
      println(key + ": " + hm.get(key));
    }
  }

  void saveData() {
    PrintWriter output = createWriter(filename.substring(0, 22) + ".txt"); 

    for ( String key : hm.keySet() ) {
      output.println(key + "," + hm.get(key));
    }
    output.flush(); 
    output.close(); 
  }
  
}
