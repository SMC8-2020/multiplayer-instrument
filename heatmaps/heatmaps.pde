PFont mono;

Heatmap h;

PImage background;

void setup() {

  size(1008, 933);
  mono = createFont("Andale Mono", 20);
  textFont(mono);
  textAlign(CENTER, CENTER);
  //pixelDensity(2);
  //frameRate(15);
  
  background = loadImage("background.png");

  h = new Heatmap("1B4868_20200506_220405.csv");
}



void draw() {

  h.tick();

  image(background,0,0);
  text(mouseX + "," + mouseY, mouseX, mouseY);
  
  h.draw();

  //fill(70, 255, 70, 180);
  //text("File:                      Events:                   FPS:", 10, height-23);
  //fill(70, 255, 70, 255);
  //text(h.filename, 8+5*9, height-23);
  //text(h.nextEvent + "/" + h.timestamps.length, 9+32*9, height-23);
  //text(frameRate, 13+52*9, height-23);
}
