#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <Adafruit_NeoPixel.h>

// Replace with your network credentials
const char *ssid = "LED_Control_AP";
const char *password = "StrongP@ssw0rd";

// Create an instance of the ESP8266WebServer class
ESP8266WebServer server(80);

// Constants for WS2812B LEDs
const int NUM_LEDS = 60;  // Number of LEDs in your strip
const int LED_PIN = D4;   // Pin to which your LED data line is connected

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

bool isLedOn = false;
String selectedEffect = "Solid";

void handleRoot() {
  server.send(200, "text/html", "<html><body><form action='/setColor' method='post'>Red: <input type='text' name='red'><br>Green: <input type='text' name='green'><br>Blue: <input type='text' name='blue'><br><input type='submit' value='Set Color'></form>"
                                  "<br><form action='/setEffect' method='post'>Select Effect: "
                                  "<select name='effect'><option value='Solid'>Solid</option><option value='Wave'>Wave</option><option value='Pulse'>Pulse</option><option value='Blink'>Blink</option><option value='Fade'>Fade</option></select>"
                                  "<br><input type='submit' value='Set Effect'></form></body></html>");
}

void handleSetColor() {
  int red = server.arg("red").toInt();
  int green = server.arg("green").toInt();
  int blue = server.arg("blue").toInt();

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
    // Turn on all LEDs to white
    for (int i = 0; i < NUM_LEDS; i++) {
      strip.setPixelColor(i, strip.Color(255, 255, 255));
    }
  } else {
    // Turn off all LEDs
    for (int i = 0; i < NUM_LEDS; i++) {
      strip.setPixelColor(i, strip.Color(0, 0, 0));
    }
  }
  strip.show();

  Serial.println(isLedOn ? "LEDs turned on" : "LEDs turned off");

  server.send(200, "text/plain", isLedOn ? "LEDs turned on" : "LEDs turned off");
}

void handleLedState() {
  server.send(200, "text/plain", isLedOn ? "true" : "false");
}

void handleSetEffect() {
  selectedEffect = server.arg("effect");

  if (selectedEffect == "Solid") {
    handleSolidEffect();
  } else if (selectedEffect == "Wave") {
    handleWaveEffect();
  } else if (selectedEffect == "Pulse") {
    handlePulseEffect();
  } else if (selectedEffect == "Blink") {
    handleBlinkEffect();
  } else if (selectedEffect == "Fade") {
    handleFadeEffect();
  }

  Serial.print("Selected effect: ");
  Serial.println(selectedEffect);

  server.send(200, "text/plain", "Effect set");
}

void handleSolidEffect() {
  int red = 255;   // Solid red color
  int green = 0;
  int blue = 0;

  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(red, green, blue));
  }
  strip.show();
}

void handleWaveEffect() {
  // Simulate a wave-like pattern
  for (int i = 0; i < NUM_LEDS; i++) {
    int brightness = 128 + 127 * sin((i * 2 * PI) / NUM_LEDS);
    strip.setPixelColor(i, strip.Color(brightness, 0, brightness));
  }
  strip.show();
}

void handlePulseEffect() {
  // Simulate a pulsating or breathing effect
  int brightness = 128 + 127 * sin(millis() / 1000.0);
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(brightness, 0, brightness));
  }
  strip.show();
}

void handleBlinkEffect() {
  // Simulate a blinking effect
  int color = (millis() / 1000) % 2 == 0 ? strip.Color(255, 255, 255) : strip.Color(0, 0, 0);
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, color);
  }
  strip.show();
}

void handleFadeEffect() {
  // Simulate a fading effect
  int brightness = 128 + 127 * sin(millis() / 1000.0);
  for (int i = 0; i < NUM_LEDS; i++) {
    strip.setPixelColor(i, strip.Color(brightness, 0, brightness));
  }
  strip.show();
}

void setup() {
  Serial.begin(9600);

  // Setup WS2812B LEDs
  strip.begin();
  strip.show();

  // Setup ESP8266 as an access point
  WiFi.softAP(ssid, password);
  IPAddress ipAddress = WiFi.softAPIP();
  Serial.print("Access Point IP Address: ");
  Serial.println(ipAddress);

  // Define the web server routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/setColor", HTTP_POST, handleSetColor);
  server.on("/toggleLed", HTTP_POST, handleToggleLed);
  server.on("/ledState", HTTP_GET, handleLedState);
  server.on("/setEffect", HTTP_POST, handleSetEffect);

  // Start the server
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  // Handle client requests
  server.handleClient();
}
