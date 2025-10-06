#include <ESP8266WiFi.h>
#include <SinricPro.h>
#include <SinricProSwitch.h>

#define WIFI_SSID     "YOUR_WIFI"
#define WIFI_PASS     "YOUR_PASS"
#define APP_KEY       "YOUR_APP_KEY"
#define APP_SECRET    "YOUR_APP_SECRET"

#define LAMP1_ID      "DEVICE_ID_LAMP1"   // Lamp Shed
#define LAMP2_ID      "DEVICE_ID_LAMP2"   // Table Lamp

#define RELAY1        D1
#define RELAY2        D2
#define TRIG_PIN      D5
#define ECHO_PIN      D6

bool lamp1State = false;
bool lamp2State = false;
unsigned long motionStart = 0;
bool motionActive = false;

SinricProSwitch& lamp1 = SinricPro[LAMP1_ID];
SinricProSwitch& lamp2 = SinricPro[LAMP2_ID];

void handleLamp1(bool state) {
  digitalWrite(RELAY1, state ? LOW : HIGH);
  lamp1State = state;
}

void handleLamp2(bool state) {
  digitalWrite(RELAY2, state ? LOW : HIGH);
  lamp2State = state;
}

bool onPowerState(const String &deviceId, bool &state) {
  if (deviceId == LAMP1_ID) handleLamp1(state);
  else if (deviceId == LAMP2_ID) handleLamp2(state);
  return true;
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(RELAY1, HIGH);
  digitalWrite(RELAY2, HIGH);

  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi Connected!");

  lamp1.onPowerState(onPowerState);
  lamp2.onPowerState(onPowerState);
  SinricPro.begin(APP_KEY, APP_SECRET);

  Serial.println("Novara Smart Lamp v1.0 Ready ✅");
}

long readDistance() {
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  return duration * 0.034 / 2; // cm
}

void loop() {
  SinricPro.handle();

  long distance = readDistance();
  unsigned long now = millis();

  // Motion detected within 60cm
  if (distance > 0 && distance < 60) {
    motionActive = true;
    motionStart = now;
    if (!lamp1State) {
      Serial.println("🔆 Motion detected → Lamp1 ON");
      handleLamp1(true);
      lamp1.sendPowerStateEvent(true);
    }
  }

  // Turn off after 2 minutes if no motion
  if (lamp1State && motionActive && (now - motionStart > 120000)) {
    Serial.println("💤 No motion → Lamp1 OFF");
    handleLamp1(false);
    lamp1.sendPowerStateEvent(false);
    motionActive = false;
  }
}
