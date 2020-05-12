PFont mono;

Heatmap h;


void setup() {

  size(1008, 933);
  mono = createFont("Andale Mono", 20);
  textFont(mono);
  textAlign(CENTER, CENTER);

  String filename = "5CAFF6_20200508_230236.csv";
  h = new Heatmap(filename);
  h.analyze();
  h.saveData();
  h.draw();
  save("output/" + filename.substring(0,22) + ".png");

  noLoop();
}



void draw() {

  //text(mouseX + "," + mouseY, mouseX, mouseY);
}
