import controlP5.*;

int EDGE_OFFSET = 30;

ControlP5 cp5;

Section s;

void setup ()
{
  size(700, 600);
  smooth();

  cp5 = new ControlP5(this);

  //KnobHandler kh = new KnobHandler(cp5);
  //kh.addKnob(0, "Steps");

  /*
  SliderHandler sh = new SliderHandler(cp5);
   for (int i = 0; i < sh.NUMSLIDERS; i++) {
   sh.addSlider(i);
   }
   */

  /*
  int BOX_IN = 5;
   int WIDTH  = width  - 2*EDGE_OFFSET;
   int HEIGHT = height - 2*EDGE_OFFSET;
   
   int NUM_SLIDERS  = 8;
   int SLIDER_WIDTH = (WIDTH - WIDTH/4);
   int SLIDER_HEIGHT = HEIGHT/3;
   
   int slider_sizey = HEIGHT/3;
   int slider_sizex = SLIDER_WIDTH / (NUM_SLIDERS*2);  
   int SLIDER_SPACING = (SLIDER_WIDTH - 2*BOX_IN) / NUM_SLIDERS;
   
   SLIDER_BOX_X = EDGE_OFFSET - BOX_IN;
   SLIDER_BOX_Y = EDGE_OFFSET - BOX_IN;
   SLIDER_BOX_W = SLIDER_WIDTH;
   SLIDER_BOX_H = slider_sizey + 2*BOX_IN;
   
   for (int i = 0; i < 8; i++) {
   int x = EDGE_OFFSET + i*(SLIDER_SPACING);
   int y = EDGE_OFFSET;
   cp5.addSlider("slider" + i)
   .setPosition(x, y)
   .setSize(slider_sizex, slider_sizey)
   .setRange(0, 1023)
   .setValue((int)random(0, 1023))
   .setSliderMode(Slider.FLEXIBLE)
   .setLabelVisible(false)
   ;
   }
   
   int KNOB_X = EDGE_OFFSET/3 + SLIDER_WIDTH + WIDTH/8;
   int KNOB_Y = HEIGHT/12;
   
   float knob_h = (float) KNOB_Y;
   float knob_w = (float) (WIDTH - SLIDER_WIDTH);
   knob_h /= 4;
   knob_w /= 4;
   
   int KNOB_RADIUS = (int) sqrt(knob_h*knob_h + knob_w*knob_w);
   
   cp5.addKnob("Steps")
   .setRange(0, 1023)
   .setValue(50)
   .setPosition(KNOB_X, KNOB_Y)
   .setRadius(KNOB_RADIUS)
   .setDragDirection(Knob.VERTICAL)
   .setViewStyle(Knob.ELLIPSE)
   .showTickMarks()
   .snapToTickMarks(true)
   ;
   
   cp5.addKnob("Select patch")
   .setRange(0, 1023)
   .setValue(50)
   .setPosition(KNOB_X, 3*KNOB_Y)
   .setRadius(KNOB_RADIUS)
   .setDragDirection(Knob.VERTICAL)
   .setViewStyle(Knob.ELLIPSE)
   .showTickMarks()
   .snapToTickMarks(true)
   ;
   
   
   int LDR_HEIGHT = SLIDER_HEIGHT / 2;
   int LDR_BUTTON_WH = LDR_HEIGHT / 2;
   int NUM_BUTTONS = 4;
   
   int BUTTON_OFFSET  = LDR_BUTTON_WH/2;
   int BUTTON_SPACING = (SLIDER_WIDTH - 2*BUTTON_OFFSET) / NUM_BUTTONS;
   
   LDR_BOX_Y = SLIDER_HEIGHT + LDR_HEIGHT;
   LDR_BOX_H = LDR_HEIGHT;
   
   for (int i = 0; i < NUM_BUTTONS; i++) {
   int x = EDGE_OFFSET + BUTTON_OFFSET + i*(BUTTON_SPACING);
   int y = LDR_BOX_Y + BUTTON_OFFSET;
   
   cp5.addButton("LDR" + i)
   .setValue(i)
   .setPosition(x, y)
   .setSize(LDR_BUTTON_WH, LDR_BUTTON_WH)
   ;
   }
   
   cp5.addKnob("Volume")
   .setRange(0, 1023)
   .setValue(50)
   .setPosition(KNOB_X, LDR_BUTTON_WH/4 + 6*KNOB_Y)
   .setRadius(KNOB_RADIUS)
   .setDragDirection(Knob.VERTICAL)
   .setViewStyle(Knob.ELLIPSE)
   .showTickMarks()
   .snapToTickMarks(true)
   ;
   */

  s = new Section(this, 0, 0, width, height);
  s.addModuleGroup("a");
  s.addModuleGroup("b");
  s.addModuleGroup("c");
  s.addModuleGroup("c");
  s.addModuleGroup("c");
}

void draw() 
{
  background(200);
  s.display();
  /*
  int COMMON_X = EDGE_OFFSET;
   int COMMON_W = (width - width/3) - 2*EDGE_OFFSET;
   int COMMON_H = (height - 4*EDGE_OFFSET) / 3;
   
   for (int i = 0; i < 3; i++) {
   int y = (i + 1)*EDGE_OFFSET + i*COMMON_H;
   fill(0, 70, 200, 20);
   rect(COMMON_X, y, COMMON_W, COMMON_H);
   
   int OSX = 30;
   int OSY = 60;
   int SX = COMMON_X + OSX;
   int SW = COMMON_W - 2*OSX;
   int SH = COMMON_H - 2*OSY;
   
   fill(0, 100, 0);
   rect(SX, y + OSY, SW, SH);
   
   int n = 4;
   int w = SW / (2*n);
   
   int rmn = (SX + SW) - (SX + (n-1)*2*w);
   
   for (int j = 0; j < n; j++) {
   fill(255);
   int x = SX + rmn/3 + j*2*w;
   rect(x, y + OSY, w, w);
   }
   }
   
   
   fill(0, 70, 200, 20);
   int KX = 2*width/3;
   int KW = width/3 - EDGE_OFFSET;
   int KH = (height - 7*EDGE_OFFSET) / 6;
   
   for (int i = 0; i < 6; i++) {
   int y = (i + 1)*EDGE_OFFSET + i*KH;
   rect(KX, y, KW, KH);
   }
   */
}