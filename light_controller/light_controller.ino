#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>

#include <FastLED.h>
#include <Bounce2.h>
#include <Adafruit_NeoPixel.h>

OSCMessage msg("/smc8/Melody1/Sequencer1/LDR1/");
const unsigned int outPort = 11000;          // remote port
const unsigned int localPort = 12000;        // local port

const char ssid[] = "";
const char pass[] = "";
const IPAddress outIp(192, 168, 8, 100);

WiFiUDP Udp;



//Defs
#define BUTTON_PIN D3
#define LED_PIN    D1

#define LED_COUNT   1
#define MAX_STATE   8



//Hardware
Bounce button = Bounce(BUTTON_PIN, 15);
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRBW + NEO_KHZ800);



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

  if (button.fallingEdge()) {

    buttonPressed = true;

    digitalWrite(LED_BUILTIN, LOW);
    strip.fill(strip.Color(0, 0, 255, 0));
  }

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
    int color = 0;
    switch (state) {
      case 0: color = (millis() % 512) >> 1;
        break;
      case 1: color = (millis() % 1024) >> 2;
        break;
      case 2: color = sin8((millis() % 512) >> 1);
        break;
      case 3: color = sin8((millis() % 1024) >> 2);
        break;
      case 4: color = ((millis() % 512) >> 1) > 128 ? 255 : 0;
        break;
      case 5: color = ((millis() % 1024) >> 2) > 128 ? 255 : 0;
        break;
      case 6: color = inoise8(millis());
        break;
      case 7: color = inoise8(millis() / 2);
        break;
    }
    strip.fill(strip.Color(0, 0, 0, color));
    msg.add(0x3FF & (color<<2));
  }

  strip.show();

  Udp.beginPacket(outIp, outPort);
  msg.send(Udp);
  Udp.endPacket();
  msg.empty();

  delay(25);
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
