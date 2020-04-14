#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>

#include <FastLED.h>
#include <Bounce2.h>
#include <Adafruit_NeoPixel.h>

#include "WiFiCredentials.h"


//Defs
#define BUTTON_PIN D3
#define LED_PIN    D1

#define LED_COUNT   1
#define MAX_STATE   9


//Network things
OSCMessage msg("/smc8/Melody1/LDR1/LDRS1");
const unsigned int outPort = 11000;          // remote port
const unsigned int localPort = 12000;        // local port
WiFiUDP Udp;


//Hardware
Bounce button = Bounce(BUTTON_PIN, 15);
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRBW + NEO_KHZ800);


//Internal states
int state;
boolean buttonPressed;


void setup() {

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);

  strip.begin();
  strip.show();
  strip.setBrightness(255);

  Serial.begin(115200);

  state = 0;
  buttonPressed = false;

  initWiFi();

}


void loop() {

  button.update();

  //Button pressed
  if (button.fallingEdge()) {
    buttonPressed = true;
    digitalWrite(LED_BUILTIN, LOW);
    strip.fill(strip.Color(0, 0, 255, 0));
  }

  //Button released
  if (button.risingEdge()) {
    buttonPressed = false;
    state++;
    if (state >= MAX_STATE) {
      state = 0;
    }
    digitalWrite(LED_BUILTIN, HIGH);
    strip.fill(strip.Color(0, 0, 0, 0));
  }

  if (!buttonPressed) {
    int value = 0;
    switch (state) {
      case 0: value = (millis() % 512) >> 1;
        break;
      case 1: value = (millis() % 1024) >> 2;
        break;
      case 2: value = sin8((millis() % 512) >> 1);
        break;
      case 3: value = sin8((millis() % 1024) >> 2);
        break;
      case 4: value = ((millis() % 512) >> 1) > 128 ? 255 : 0;
        break;
      case 5: value = ((millis() % 1024) >> 2) > 128 ? 255 : 0;
        break;
      case 6: value = inoise8(millis());
        break;
      case 7: value = inoise8(millis() / 2);
        break;
      case 8: value = 0;
        break;
    }
    strip.fill(strip.Color(0, 0, 0, value));

    if (state != 8) {
      msg.add(0x3FF & (value << 2));
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
  delay(100);
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
