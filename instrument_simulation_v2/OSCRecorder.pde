import http.requests.*;

public class OSCRecorder {

  private int inactivity;
  private boolean forceInt;

  private int epoch;
  private int counter;

  private static final int logitems = 25;
  private String[] lines;
  private String filename;
  private PrintWriter output;
  private int prevTimestap;
  
  private static final String serverURL = "http://neuronasmuertas.com/smc8/";

  public OSCRecorder (int inactivity, boolean forceInt) {
    this.inactivity = inactivity;
    this.forceInt = forceInt;

    epoch = -1;
    lines = new String[logitems];
    //filename = "data/20200414_101803.csv";
    filename = "";
    initBuffer();
  }

  public OSCRecorder (int inactivity) {
    this(inactivity, false);
  }

  void initBuffer() {
    counter = 0;
    for (int f=0; f<logitems; f++) {
      lines[f]="";
    }
  }

  void record(OscMessage m) {

    int currTimestamp = millis();

    //If the user has been inactive for more than inactivity milliseconds and 
    //has already recorded something (epoch >= 0), close the file and set 
    //epoch to -1 to start a new recording.
    if (currTimestamp-prevTimestap >= inactivity) {
      if (epoch >= 0) {
        output.close();
      }
      epoch = -1;
    }

    //We need to start a new recording. Set epoch to current millis, so the
    //messages start at 0, create a writer for the new file.
    if (epoch < 0) {
      epoch = currTimestamp;
      prevTimestap = currTimestamp;
      filename = "data/" + getFilename();
      output = createWriter(filename);
      initBuffer();
    }

    String typetag = m.typetag();

    String log = String.format("%d,%s,%s", 
      currTimestamp-epoch, 
      m.addrPattern(), 
      typetag);

    for (int f=0; f<typetag.length(); f++) {
      switch(typetag.charAt(f)) {
      case 'i':
        log += "," + m.get(f).intValue();
        break;
      case 'c':
        log += ",'" + m.get(f).charValue()+"'";
        break;
      case 's':
        log += ",'" + m.get(f).stringValue()+"'";
        break;
      case 'f':
        if (forceInt) {
          log += "," + int(m.get(f).floatValue());
        } else {
          log += "," + m.get(f).floatValue();
        }
        break;
      case 'T':
        log += ",true";
        break;    
      case 'F':
        log += ",false";
        break;
      default:
        println("Unknown element " + typetag.charAt(f));
      }
    }

    output.println(log); 
    output.flush();

    arrayCopy(lines, 1, lines, 0, logitems-1);
    lines[lines.length-1] = log;
    counter++;

    prevTimestap = currTimestamp;
  }



  String getFilename() {
    return String.format("%02d%02d%02d_%02d%02d%02d.csv", 
      year(), month(), day(), hour(), minute(), second()
      );
  }

  void startNewRecording() {

    prevTimestap = -inactivity;
    
    if (filename.equals("") || counter==0) {
      return;
    }

    String[] lines = loadStrings(filename);
    String file = "";
    for (int i = 0; i < lines.length; i++) {
      file += lines[i] + "\n";
    }

    PostRequest post = new PostRequest(serverURL);
    post.addData("filename", filename);
    post.addData("contents", file);
    post.send();
    println("Reponse Content: " + post.getContent());
    println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
  }
}
