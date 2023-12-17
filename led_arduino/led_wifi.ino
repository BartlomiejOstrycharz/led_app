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

void handleRoot() {
  server.send(200, "text/html", "<html><body><form action='/setColor' method='post'>Red: <input type='text' name='red'><br>Green: <input type='text' name='green'><br>Blue: <input type='text' name='blue'><br><input type='submit' value='Set Color'></form></body></html>");
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

  // Start the server
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  // Handle client requests
  server.handleClient();
}
