public class Performance {

  private String filename;
  private int[] timestamps;
  private OscMessage[] messages;

  private NetAddress server;

  boolean isPlaying = false;
  boolean hasEnded = false;


  int nextEvent = 0;
  int epoch = 0;


  Performance(String filename, NetAddress server) {
    this.filename = filename;
    this.server = server;

    loadPerformance();
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
      println(currentTime - timestamps[nextEvent], ":", messages[nextEvent].toString());
      nextEvent++;
    }
    if (nextEvent >= timestamps.length) {
      isPlaying = false;
      hasEnded = true;
    }
  }
}
