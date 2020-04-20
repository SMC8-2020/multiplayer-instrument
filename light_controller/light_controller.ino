#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>

#include <FastLED.h>
#include <Bounce2.h>
#include <Adafruit_NeoPixel.h>

#include "WiFiCredentials.h"

//#define SIMPLE_MODEL

#ifndef SIMPLE_MODEL
#define ROTARY_MODEL
#endif

#ifdef ROTARY_MODEL
#define ENC_PIN_A  D7
#define ENC_PIN_B  D6
#define DELTA       4
#define ROT_MAX   100
#endif


//Common defs
#define BUTTON_PIN D3
#define LED_PIN    D1

#define MAX_STATE   9

#define MIN_HZ      0.1
#define MAX_HZ      9.0


//Network things
OSCMessage msg("/smc8/Melody1/LDR1/LDRS1");
const unsigned int outPort = 11000;          // remote port
const unsigned int localPort = 12000;        // local port
WiFiUDP Udp;


//Hardware
Bounce button;

#ifdef ROTARY_MODEL
#define LED_COUNT   6
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
#else
#define LED_COUNT   1
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRBW + NEO_KHZ800);
#endif



//Internal states
int state;
boolean buttonPressed;
float current_hz;

#ifdef ROTARY_MODEL
int pin_a_last;
int rot_value = 0;
#endif


void setup() {

  Serial.begin(115200);

  initBoard();
  initWiFi();

  state = 0;
  buttonPressed = false;
  current_hz = MIN_HZ;

}


void loop() {

  button.update();

  //Button pressed
  if (button.fallingEdge()) {
    buttonPressed = true;
    digitalWrite(LED_BUILTIN, LOW);
    strip.fill(strip.Color(0, 0, 255));
  }

  //Button released
  if (button.risingEdge()) {
    buttonPressed = false;
    state++;
#ifdef ROTARY_MODEL
    //ROTARY SKIPS ALWAYS ONE STATE
    state++;
#endif
    if (state >= MAX_STATE) {
      state = 0;
    }
#ifdef SIMPLE_MODEL
    current_hz = state % 2 == 0 ? MIN_HZ : MAX_HZ;
    Serial.println(current_hz);
#endif
    digitalWrite(LED_BUILTIN, HIGH);
    strip.fill(strip.Color(0, 0, 0));
  }

#ifdef ROTARY_MODEL
  int pin_a_curr = digitalRead(ENC_PIN_A);

  if (pin_a_curr != pin_a_last) {

    delay(1); //Software debouncing. Good enough.
    if (pin_a_curr == LOW) {

      if (digitalRead(ENC_PIN_B) == pin_a_curr) {
        rot_value -= DELTA;
      } else {
        rot_value += DELTA;
      }

      if (rot_value < 0) {
        rot_value = 0;
      } else if (rot_value > ROT_MAX) {
        rot_value = ROT_MAX;
      }

      current_hz = mapfloat(rot_value, 0, ROT_MAX, MIN_HZ, MAX_HZ);
      //Serial.println(current_hz);
    }
    pin_a_last = pin_a_curr;
  }
#endif

  if (!buttonPressed) {
    float pos = fmod(current_hz * millis() / 1000.0, 1.0);
    int value = 0;
    switch (state) {

      //SINE WAVE
      case 0:
      case 1:
        value = int(sin(pos * TWO_PI) * 512.0) + 512;
        break;

      //SAW WAVE
      case 2:
      case 3:
        value = int(pos * 1024.0);
        break;

      //SQUARE WAVE
      case 4:
      case 5:
        value = pos < 0.5 ? 0 : 1023;
        break;

      //NOISE
      case 6:
      case 7:
        value = inoise16(int(millis() * current_hz) << 8) >> 6;
        break;

      //NOTHING
      case 8: value = 0;
        break;
    }

    //Just in case, clamp the value between 0 and 1023
    value = 0x3FF & value;

    //Serial.println(value);
    strip.fill(strip.Color(value >> 2, value >> 2, value >> 2));

    if (state != 8) {
      msg.add(value);
      msg.add(0);
      msg.add(0);
      msg.add(0);
      Udp.beginPacket(outIp, outPort);
      msg.send(Udp);
      Udp.endPacket();
      msg.empty();
    }

  }

  strip.show();

  delay(50);
}


void initBoard() {

  pinMode(LED_BUILTIN, OUTPUT);

  //pinMode(BUTTON_PIN, INPUT_PULLUP);
  //button = Bounce(BUTTON_PIN, 15);
  button = Bounce();
  button.attach(BUTTON_PIN, INPUT_PULLUP);
  button.interval(15);

#ifdef ROTARY_MODEL
  pinMode(ENC_PIN_A, INPUT_PULLUP);
  digitalWrite(ENC_PIN_A, HIGH);
  pin_a_last = digitalRead(ENC_PIN_A);

  pinMode(ENC_PIN_B, INPUT_PULLUP);
  digitalWrite(ENC_PIN_B, HIGH);
#endif

  strip.begin();
  strip.show();
  strip.setBrightness(255);


}


void initWiFi() {

  byte ledStatus = LOW;

  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.print(ssid);
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_BUILTIN, ledStatus); // Write LED high/low
    ledStatus = !ledStatus;
    delay(200);
  }
  digitalWrite(LED_BUILTIN, HIGH);

  Serial.println();
  Serial.print("Local IP: ");
  Serial.println(WiFi.localIP());
  Serial.println("Starting UDP");
  Udp.begin(localPort);
  Serial.print("Local port: ");
  Serial.println(Udp.localPort());

}


float mapfloat(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
