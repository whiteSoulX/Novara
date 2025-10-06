/***************************************************
 * NOVARA SMART HOME - ESP32 + Sinric Pro + Motion Sensor
 * Features:
 *  - Light 1 (Lamp Shed): Auto-on (2 min) when motion detected
 *  - Light 2 (Table Lamp): Manual control via Sinric Pro
 *  - Supports Google Home / Alexa integration
 ***************************************************/

#include <WiFi.h>
#include <SinricPro.h>
#include <SinricProSwitch.h>

#define WIFI_SSID       "YOUR_WIFI_NAME"
#define WIFI_PASS       "YOUR_WIFI_PASSWORD"

#define APP_KEY         "YOUR_APP_KEY"
#define APP_SECRET      "YOUR_APP_SECRET"

#define LIGHT1_ID       "YOUR_DEVICE_ID_LIGHT1"   // Lamp Shed
#define LIGHT2_ID       "YOUR_DEVICE_ID_LIGHT2"   // Table Lamp

// ---------------- Pin Setup -----------------
#define RELAY_LIGHT1    4     // GPIO4 -> Relay 1 (Lamp Shed)
#define RELAY_LIGHT2    5     // GPIO5 -> Relay 2 (Table Lamp)
#define TRIG_PIN        12    // GPIO12 -> Ultrasonic TRIG
#define ECHO_PIN        14    // GPIO14 -> Ultrasonic ECHO

// ------------------------------------------------
#define MOTION_DISTANCE_CM 100   // Detect motion within 1 meter
#define AUTO_OFF_TIME 120000     // 2 minutes (in milliseconds)

unsigned long lastMotionTime = 0;
bool light1On = false;

// ---------- WiFi + Sinric Pro Setup ----------
void setupWiFi() {
  Serial.print("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
}

// ---------- Distance Measurement ----------
long getDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH);
  long distance = duration * 0.034 / 2;
  return distance;
}

// ---------- Light Control via Sinric ----------
bool onPowerState(const String &deviceId, bool &state) {
  if (deviceId == LIGHT1_ID) {
    digitalWrite(RELAY_LIGHT1, state ? LOW : HIGH);
    Serial.printf("Lamp Shed turned %s via Sinric Pro\n", state ? "ON" : "OFF");
  } else if (deviceId == LIGHT2_ID) {
    digitalWrite(RELAY_LIGHT2, state ? LOW : HIGH);
    Serial.printf("Table Lamp turned %s via Sinric Pro\n", state ? "ON" : "OFF");
  }
  return true;
}

void setupSinric() {
  SinricProSwitch &lamp1 = SinricPro[LIGHT1_ID];
  lamp1.onPowerState(onPowerState);

  SinricProSwitch &lamp2 = SinricPro[LIGHT2_ID];
  lamp2.onPowerState(onPowerState);

  SinricPro.onConnected([] { Serial.println("Connected to Sinric Pro!"); });
  SinricPro.onDisconnected([] { Serial.println("Disconnected from Sinric Pro"); });

  SinricPro.begin(APP_KEY, APP_SECRET);
}

// ---------------- Setup ----------------
void setup() {
  Serial.begin(115200);

  pinMode(RELAY_LIGHT1, OUTPUT);
  pinMode(RELAY_LIGHT2, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  digitalWrite(RELAY_LIGHT1, HIGH);  // off
  digitalWrite(RELAY_LIGHT2, HIGH);  // off

  setupWiFi();
  setupSinric();
}

// ---------------- Loop ----------------
void loop() {
  SinricPro.handle();

  long distance = getDistance();

  if (distance > 0 && distance < MOTION_DISTANCE_CM) {
    Serial.println("Motion detected!");
    if (!light1On) {
      digitalWrite(RELAY_LIGHT1, LOW);  // Turn ON Lamp Shed
      light1On = true;
      lastMotionTime = millis();
    }
  }

  if (light1On && (millis() - lastMotionTime > AUTO_OFF_TIME)) {
    digitalWrite(RELAY_LIGHT1, HIGH);  // Turn OFF Lamp Shed
    light1On = false;
    Serial.println("Lamp Shed OFF after 2 min");
  }

  delay(500);
}
