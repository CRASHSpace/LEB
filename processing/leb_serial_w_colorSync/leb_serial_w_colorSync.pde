/*
author: mpinner
 date: 2013-03-02
 
 intent: simulate rgb led balls for testing sequeces
 
 usage: 
 - x, y, and z keys will enable/dissable the rotations along these axises
 
 */

import processing.serial.*;


import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;


Minim minim;  
AudioInput in;
FFT fft;

int rings[] = {
  7, 11, 15, 17, 19, 19, 17, 15, 11, 7
};

int ringHeights[] = {
  -8, -7, -5, -3, -1, 1, 3, 5, 7, 8
};

int SCALE = 10;
int colorMax; // need init in setup()


boolean rotX = false;
boolean rotY = false;
boolean rotXY = true;
boolean rotZ = true;

boolean nuts = true;
boolean frames = false;
boolean redOn = true;
boolean greenOn = true;
boolean blueOn = true;

boolean serialReading = false;

int audio = 0;

int x = 0;
int y = 0;
int z = 0;

int xRead, yRead, zRead;

float xRot = 0;
float yRot = 0;
float zRot = 0;

int rotSampleSize = 5;
int currentRotSample = 0;
float sample[][] = new float[3][rotSampleSize];
float rotAngle[] = {
  0.0, 0.0, 0.0
};



int ZERO_ACCELL = 512;
int ERROR = 100;
int[][] accellerationColors;

long lastReading = 0;
int ACCELL_THRESHOLD = 1;


int min = 290;
int max = 890;


static final int nPoints = 12;                   // # polyhedron vertices
PVector          pt[]    = new PVector[nPoints]; // 3D vertex coordinates
int ledCount = 0;

Serial myPort;  // The serial port


void setup() {

  for (int ring=0; ring < rings.length; ring++) {
    ledCount += rings[ring];
  }

  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.STEREO, ledCount);


  colorMax = ledCount;
  
  accellerationColors= new int[3][ledCount];

  for (int i=0; i < ledCount; i++) {
    accellerationColors[0][i] = 150;  
    accellerationColors[1][i] = 150;  
    accellerationColors[2][i] = 150;
  }

  colorMode(RGB, 256);

  int   i;
  float c, r, h, angle, a;

  size(800, 800, P3D);
  sphereDetail(6);

  // List all the available serial ports
  println(Serial.list());
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 57600);
}

void draw() {
  int i, j, k;

  background(0);
  ball(1);

  return;
}

void ball(int shift) {
  pushMatrix();
  translate(width / 2.0, height / 2.0);

  if (serialReading) {
    readingValue();
    rotateX(radians(rotAngle[0]));
    rotateY(radians(rotAngle[2]));
    rotateZ(radians(rotAngle[1]));
  } 
  else {

    if (rotX) rotateX(radians(mouseY/(float)height*360));
    if (rotY) rotateY(radians((float)mouseX/width*360));
    if (rotXY) {
      rotateX(radians(shift*frameCount * 0.01));
      rotateY(radians(shift*frameCount * 0.01));
    }

    if (rotZ) rotateZ(shift*frameCount * 0.01);
  }
  scale(width / 3.0);

  /*  for(i=0; i<5; i++) {
   j = 1 + (i + 1) % 5;
   k = 6 + (i + 1) % 5;
   face(0,i+1,j);   // Top endcap faces
   face(i+1,j,i+6); // Upper mid faces
   face(j,i+6,k);   // Lower mid faces
   face(i+6,k,11);  // Bottom endcap faces
   }
   */
  int ledIndex = 0;
  for (int ring=0; ring < rings.length; ring++) {
    int ringLedCount = rings[ring];
    float degreesPerLed = 360 / (float)ringLedCount; 
    int ringHeight = ringHeights[ring];

    for (int rad = 0; rad < ringLedCount; rad++) {
      ledIndex++;
      int ledDegree = (int)(rad*degreesPerLed);
      pushMatrix();
      translate(sin(radians(ledDegree))* ringLedCount / 20, cos(radians(ledDegree))* ringLedCount / 20, ringHeight/10.0);
      scale(0.01); // Processing has trouble with tiny spheres,
      // fillFromIndex(ledIndex+frameCount);
      //fillFromIndex(ledIndex);
      fillFromAccell(ledIndex);
      //fillFromIndex(ledDegree);
      noStroke();

      int scale = SCALE;

      scale += in.left.get(ledIndex%ledCount)*audio;

      sphere(scale);   // so set 'scale' small & draw a big one.
      popMatrix();
    }
  }
  popMatrix(); 
  return;
}


void fillFromAccell(int index) {
  fill( accellerationColors[0][index], accellerationColors[1][index], accellerationColors[2][index]);
}

void fillFromIndex(int index) {

  int i = index % colorMax;

  float timeSec = ((float)millis()/10000.0);
  if (frames) timeSec = frameCount/1000.0;

  if (nuts) {
    int r = 0;
    int g = 0;
    int b = 0;
    if (redOn) r = (int)(sin(radians(index)*timeSec*3.333)*255);
    if (greenOn)g = (int)(sin(radians(index)*timeSec*3.666)*255);
    if (blueOn) b = (int)(sin(radians(index)*timeSec*9.0)*255);
    // int g = (int)(sin(timeSec*6.2*(i*3+1)/30.0)*255);
    //    int b = (int)(sin(timeSec*6.2*(i*3+2)/29.666)*255);
    fill( r, g, b);
  } 
  else {
    fill((index+frameCount)%256);
  }

  // fill(index, mouseX, mouseY);
  //  fill(index, colorMax, colorMax);

  return;
}

void keyTyped() {
  if (key == 'x') {
    rotX = (false == rotX);
  }

  if (key == 'y') {
    rotY = (false == rotY);
  }

  if (key == 'q') {
    rotXY = (false == rotXY);
  }

  if (key == 'z') {
    rotZ = (false == rotZ);
  }  

  if (key == 'n') {
    nuts = (false == nuts);
  }

  if (key == 'f') {
    frames = (false == frames);
  }


  if (key == 'r') {
    redOn = (false == redOn);
  }

  if (key == 'g') {
    greenOn = (false == greenOn);
  }

  if (key == 'b') {
    blueOn = (false == blueOn);
  }

  if (key == '+') {
    audio += 1;
    println("audio:"+audio);
  } 
  if (key == '-') {
    audio -= 1;
    println("audio:"+audio);
  }

  if (key == 's') {
    serialReading = (false == serialReading);
    readingValue();
  }
}



void readingValue()
{
  if ( myPort.available() > 0) {  // If data is available,
    String val = myPort.readStringUntil(10);         // read it and store it in val

    String valueAccumulator = val;

    xRead = getSerialValue("x", valueAccumulator);
    if (xRead > 0) {
      x = xRead;
    }

    yRead = getSerialValue("y", valueAccumulator);
    if (yRead > 0) {
      y = yRead;
    }

    zRead = getSerialValue("z", valueAccumulator);
    if (zRead > 0) {
      z = zRead;
      myPort.clear();
    }
  }


  int xAng = (int)map(x, min, max, -90, 90);
  int yAng = (int)map(y, min, max, -90, 90);
  int zAng = (int)map(z, min, max, -90, 90);

  xRot = RAD_TO_DEG * (atan2(-yAng, -zAng) + PI);
  yRot = RAD_TO_DEG * (atan2(-xAng, -zAng) + PI);
  zRot = RAD_TO_DEG * (atan2(-yAng, -xAng) + PI);

  sample[0][currentRotSample] = xRot;
  sample[1][currentRotSample] = yRot;
  sample[2][currentRotSample] = zRot;
  currentRotSample++;

  if (currentRotSample == rotSampleSize) {
    currentRotSample = 0;
    for ( int i = 0; i < 3; i++) {
      sample[i] = sort(sample[i]);
      rotAngle[i] = sample[i][rotSampleSize/2];
      println("i:"+i+",rot:"+rotAngle[i]);
    }
  }


  if (lastReading + ACCELL_THRESHOLD < millis()) {
    lastReading = millis();  
    int xColor = convertAccellRead(x);
    int yColor = convertAccellRead(y);
    int zColor = convertAccellRead(z);

    // add to array
    for (int i = ledCount-1; i > 0; i--) {
      for (int j=0; j<3; j++) {
        accellerationColors[j][i] = accellerationColors[j][i-1];
      }
    }
    accellerationColors[0][0] = xColor;
    accellerationColors[1][0] = yColor;
    accellerationColors[2][0] = zColor;
  }

  println("x:"+x+",y:"+y+",z:"+z);
  println("x:"+xRot+",y:"+yRot+",z:"+zRot+",min:"+min+",max:"+max);
}


int getSerialValue(String readingParam, String valueAccumulator) {
  println(readingParam +":" + valueAccumulator);
  if (null == valueAccumulator)
    return -1;

  valueAccumulator.trim();
  valueAccumulator = valueAccumulator.trim() + ",";

  //  if (readingParam.equals("z")) println("ZZZ:" + valueAccumulator);

  if (valueAccumulator.contains(readingParam)) {
    valueAccumulator = valueAccumulator.substring(valueAccumulator.indexOf(readingParam));

    int commaIndex = valueAccumulator.indexOf(",");
    if (commaIndex > 0) {
      valueAccumulator  = valueAccumulator.substring(2, commaIndex);  
      try {
        int readingValue = Integer.parseInt(valueAccumulator);
        //   println(readingParam +":"+ readingValue);

        /*
    if (min>readingValue) {
         min = readingValue;
         }
         
         if (max<readingValue) {
         max = readingValue;
         }
         */
        return readingValue;
      } 
      catch (Exception e) {
        // dont care
      }
    }
  } 
  return 0;
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

  return reading;
}

