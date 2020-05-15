public class Performance {

  private String filename;
  private int[] timestamps;
  private OscMessage[] messages;

  private NetAddress server;

  boolean isPlaying = false;
  boolean hasEnded = false;
  int nextEvent = 0;
  int epoch = 0;

  HashMap<String, PVector> coordinates;
  ArrayList<Touch> touches;



  Performance(String filename, NetAddress server) {
    this.filename = filename;
    this.server = server;

    touches = new ArrayList<Touch>();

    loadPerformance();

    coordinates = new HashMap<String, PVector>();
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



  void loadPerformance() {

    String[] events = loadStrings("data/" + filename);
    timestamps = new int[events.length];
    messages = new OscMessage[events.length];

    int deltaTime = 0;
    int f = 0;

    for (String event : events) {

      String[] split = split(event, ',');
      if (f==0) {
        deltaTime = 500 - Integer.parseInt(split[0]);
      }
      timestamps[f] = Integer.parseInt(split[0]) + deltaTime;

      OscMessage m = new OscMessage(split[1]);

      for (int i=0; i<split[2].length(); i++) {
        switch(split[2].charAt(i)) {
        case 'i':
          m.add(Integer.parseInt(split[3+i]));
          break;
        default:
          println("Unknown element " + split[2].charAt(i));
          break;
        }
      }
      messages[f] = m; 
      f++;
    }
  }



  void startPerformance() {
    nextEvent = 0;
    epoch = millis();
    isPlaying = true;
    hasEnded = false;
  }



  void stopPerformance() {
    nextEvent = timestamps.length;
    epoch = millis();
    isPlaying = false;
    hasEnded = true;
  }



  void tick() {
    int currentTime = millis() - epoch;
    while (nextEvent<timestamps.length && timestamps[nextEvent]<=currentTime) {
      OscP5.flush(messages[nextEvent], server);
      String msg = messages[nextEvent].toString();
      msg = msg.substring(15, msg.length()-2);
      println(currentTime - timestamps[nextEvent], ":", messages[nextEvent].toString());
      //println(msg);
      PVector coords = p.coordinates.get(msg);
      touches.add(new Touch(coords, 30));

      nextEvent++;
    }
    if (nextEvent >= timestamps.length) {
      isPlaying = false;
      hasEnded = true;
    }
  }

  void update() {
    for (int i = touches.size()-1; i >= 0; i--) {
      Touch t = touches.get(i);
      t.update();
      if (t.isDead()) {
        touches.remove(i);
      }
    }
  }

  void draw() {
    for (int i = touches.size()-1; i >= 0; i--) {
      Touch t = touches.get(i);
      t.draw();
    }
  }
}
