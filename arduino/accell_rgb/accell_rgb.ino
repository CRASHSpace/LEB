#include <Adafruit_NeoPixel.h>

#include <HSB_to_RGB.h>


// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_RGB     Pixels are wired for RGB bitstream
//   NEO_GRB     Pixels are wired for GRB bitstream
//   NEO_KHZ400  400 KHz bitstream (e.g. FLORA pixels)
//   NEO_KHZ800  800 KHz bitstream (e.g. High Density LED strip)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(138, 6, NEO_GRB + NEO_KHZ800);


boolean DEBUG = true;

int x, y, z;
int X_PIN = A1;
int Y_PIN = A2;
int Z_PIN = A3;
int xRead, yRead, zRead;

int ZERO_ACCELL = 512;
int ERROR = 100;

void setup() {
  if (DEBUG) Serial.begin(57600);
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop() {
  // Some example procedures showing how to display to the pixels:
  accellColorWipe(1); // Red
  // colorWipe(strip.Color(0, 30, 0), 50); // Green
  // colorWipe(strip.Color(0, 0, 30), 50); // Blue
  //  rainbow(20);
  //  rainbowCycle(20);
}

// Fill the dots one after the other with a color
void accellColorWipe(uint8_t wait) {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    readAccell();
    uint32_t c = strip.Color(x, y, z);

    setColor(i, c);
    strip.show();
    delay(wait);
  }
}



void readAccell() {
  
  xRead = analogRead(X_PIN);
  yRead = analogRead(Y_PIN);
  zRead = analogRead(Z_PIN);
  
  
  x = convertAccellRead(xRead);
  y = convertAccellRead(yRead);
  z = convertAccellRead(zRead);
  
if (DEBUG) {
  Serial.print("x:");
  Serial.print(xRead);
  Serial.print(",y:");
  Serial.print(yRead);
  Serial.print(",z:");
  Serial.print(zRead);
  Serial.println();
}

}

int convertAccellRead(int reading) {

  reading = reading - ZERO_ACCELL;
  if (reading < 0) {
    reading = reading * -1;
  } 
  
  reading = reading - ERROR;
  
  if (reading < 0) {
    reading = 0;
  } 

  return reading/5; 
}


// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t wait) {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

void rainbow(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256; j++) {
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel((i+j) & 255));
    }
    strip.show();
    delay(wait);
  }
}

// Slightly different, this makes the rainbow equally distributed throughout
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256*5; j++) { // 5 cycles of all colors on wheel
    for(i=0; i< strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + j) & 255));
    }
    strip.show();
    delay(wait);
  }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
    return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else if(WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } 
  else {
    WheelPos -= 170;
    return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

void setColor(int index, uint32_t c) {
  strip.setPixelColor(pixelReMapping(index), c);
  return;
}

int pixelReMapping(int index) {

  if (index <= 69) {
    return 69-index;
  }

  return index;
} 


