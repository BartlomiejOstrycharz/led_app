#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <Adafruit_NeoPixel.h>

const char *ssid = "LED_Control_AP";
const char *password = "StrongP@ssw0rd";

ESP8266WebServer server(80);

const int NUM_LEDS = 60;
const int LED_PIN = D4;

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

bool isLedOn = false;
String selectedEffect = "Solid";
String lastSelectedEffect = "Solid"; // Store the last selected effect
int currentColor[3] = {255, 0, 0}; // Default color: Red
bool waveEffectRunning = false;

uint32_t colorWave(int red, int green, int blue, int pixel, int offset) {
  int wave = sin((pixel + offset) * 0.2) * 127 + 128; // Adjust the frequency and amplitude as needed
  return strip.Color((wave * red) / 255, (wave * green) / 255, (wave * blue) / 255);
}

void handleRoot() {
  server.send(200, "text/html", "<html><body><form action='/setColor' method='post'>Red: <input type='text' name='red'><br>Green: <input type='text' name='green'><br>Blue: <input type='text' name='blue'><br><input type='submit' value='Set Color'></form>"
                                  "<br><form action='/setEffect' method='post'>Select Effect: "
                                  "<select name='effect'><option value='Solid'>Solid</option><option value='Wave'>Wave</option></select>"
                                  "<br><input type='submit' value='Set Effect'></form></body></html>");
}

void handleSetColor() {
  int red = server.arg("red").toInt();
  int green = server.arg("green").toInt();
  int blue = server.arg("blue").toInt();

  currentColor[0] = red;
  currentColor[1] = green;
  currentColor[2] = blue;

  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(red, green, blue));
  }
  strip.show();

  Serial.print("Color set - R: ");
  Serial.print(red);
  Serial.print(" G: ");
  Serial.print(green);
  Serial.print(" B: ");
  Serial.println(blue);

  server.send(200, "text/plain", "Color set");
}

void handleToggleLed() {
  isLedOn = !isLedOn;

  if (isLedOn) {
    if (waveEffectRunning) {
      // If turning on and wave effect is running, restart the wave effect
      waveEffectRunning = true;
    } else {
      // If turning on and last selected effect is solid color, set the solid color
      if (lastSelectedEffect == "Solid") {
        for (int i = 0; i < NUM_LEDS; i++) {
          strip.setPixelColor(i, strip.Color(currentColor[0], currentColor[1], currentColor[2]));
        }
        strip.show();
      }
    }
  } else {
    // If turning off, turn off the LEDs and stop the wave effect
    for (int i = 0; i < NUM_LEDS; i++) {
      strip.setPixelColor(i, strip.Color(0, 0, 0));
    }
    strip.show();
    waveEffectRunning = false;
  }

  Serial.println(isLedOn ? "LEDs turned on" : "LEDs turned off");

  server.send(200, "text/plain", isLedOn ? "LEDs turned on" : "LEDs turned off");
}

void handleLedState() {
  server.send(200, "text/plain", isLedOn ? "true" : "false");
}

void handleSetEffect() {
  selectedEffect = server.arg("effect");

  if (isLedOn) { // Only apply the effect if the LED is turned on
    if (selectedEffect == "Solid") {
      for (int i = 0; i < NUM_LEDS; i++) {
        strip.setPixelColor(i, strip.Color(currentColor[0], currentColor[1], currentColor[2]));
      }
      strip.show();
      waveEffectRunning = false; // Stop the wave effect
    } else if (selectedEffect == "Wave") {
      waveEffectRunning = true; // Start the wave effect
    }

    lastSelectedEffect = selectedEffect; // Update the last selected effect

    Serial.print("Selected effect: ");
    Serial.println(selectedEffect);

    server.send(200, "text/plain", "Effect set");
  } else {
    // If the LED is off, send a response indicating that the effect cannot be set
    server.send(200, "text/plain", "LED is turned off. Cannot set effect.");
  }
}


void handleSolidEffect(int red, int green, int blue) {
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(red, green, blue));
  }
  strip.show();
}

void handleWaveEffect(int red, int green, int blue) {
  static int offset = 0; // Maintain an offset to create the wave effect
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, colorWave(red, green, blue, i, offset));
  }
  strip.show();
  offset++; // Increment the offset to shift the wave
  delay(20); // Adjust the delay to control the speed of the wave
}

void updateWaveEffect() {
  if (waveEffectRunning) {
    handleWaveEffect(currentColor[0], currentColor[1], currentColor[2]);
  }
}

void setup() {
  Serial.begin(9600);

  strip.begin();
  strip.show();

  WiFi.softAP(ssid, password);
  IPAddress ipAddress = WiFi.softAPIP();
  Serial.print("Access Point IP Address: ");
  Serial.println(ipAddress);

  server.on("/", HTTP_GET, handleRoot);
  server.on("/setColor", HTTP_POST, handleSetColor);
  server.on("/toggleLed", HTTP_POST, handleToggleLed);
  server.on("/ledState", HTTP_GET, handleLedState);
  server.on("/setEffect", HTTP_POST, handleSetEffect);

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
  updateWaveEffect(); // Update the wave effect continuously
}
