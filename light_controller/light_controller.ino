#include <Bounce2.h>
#include <Adafruit_NeoPixel.h>

#define BUTTON_PIN D3
#define LED_PIN    D1

#define LED_COUNT   1

Bounce button = Bounce(BUTTON_PIN, 15);
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRBW + NEO_KHZ800);

void setup() {

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);

  strip.begin();
  strip.show();
  strip.setBrightness(255);

  Serial.begin(9600);

}



void loop() {

  button.update();

  if (button.fallingEdge()) {
    digitalWrite(LED_BUILTIN, LOW);
    strip.fill(strip.Color(0, 0, 0, 255));
    strip.show();
  }

  if (button.risingEdge()) {
    digitalWrite(LED_BUILTIN, HIGH);
    strip.fill(strip.Color(0, 0, 0, 0));
    strip.show();
  }

  delay(25);
}
