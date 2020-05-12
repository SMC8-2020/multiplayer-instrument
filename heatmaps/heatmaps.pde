PFont mono;

Heatmap h;


void setup() {

  size(1008, 933);
  mono = createFont("Andale Mono", 20);
  textFont(mono);
  textAlign(CENTER, CENTER);

  File folder = new File(sketchPath() + "/data");
  String names[] = folder.list();
  for (String filename : names) {
    if (filename.endsWith(".csv")) {
      printArray(filename);
      
      h = new Heatmap(filename);
      h.analyze();
      h.saveData();
      h.draw();
      save("output/" + filename.substring(0, 22) + ".png");
    }
  }

  noLoop();
}



void draw() {

  //text(mouseX + "," + mouseY, mouseX, mouseY);
}
