import processing.opengl.*;
import processing.serial.*;

/**
 *
 *
 */


int HAIRLENGTH = 18;
int NUMHAIR = 600;
int NUMBALLS = 10;
float TEMPVAR = 0.5;

ArrayList Hairs;
ArrayList<Flock> F;

float[][] PVX;
float[][] PVY;

color[] pFrame;
int[] removed;

PImage img;

int htimer;

BufferedReader webReader;
Serial myPort;
DataReader dReader;
String dataStr;
int serialTimer;

float temperature, humidity, light, temperature0, humidity0, light0; 

void setup() {
  //size(800, 600, OPENGL);
  size(screen.width, screen.height, OPENGL);
  smooth();
  fill(0);

  frameRate(24);

  println (Serial.list());
  if (Serial.list().length > 0) {
    myPort = new Serial(this, Serial.list()[0], 9600);
    System.out.println("found "+Serial.list().length+" serial ports");
    myPort.bufferUntil('\n');
    myPort.clear();
  }
  else {
    myPort = null;
  }


  // data reader
  // pass a url to read from web
  // or serial object to read from serial port

  // ****
  // **** mudar aqui se for necessario usar a entrada serial.
  // ****
  dReader = new DataReader("http://ecolab.plataformacero.cc/datos/datos.php?sensor_id=6");
  //dReader = new DataReader(myPort);

  Hairs = new ArrayList();
  F = new ArrayList<Flock>();

  //img = loadImage("xadrez.bmp");
  //img = loadImage("desenho1.bmp");
  img = loadImage("desenho6.bmp");
  img.resize(width, height);

  img.loadPixels();

  htimer = millis();

  serialTimer = millis();

  PVX = new float[height][width];
  PVY = new float[height][width];

  removed = new int[height*width];

  float maxX=0;
  float maxY=0;

  temperature = humidity = light = -10;
  temperature0 = humidity0 = light0 = -10;

  for (int j=1; j<(img.height-1); j++) {
    for (int i=1; i<(img.width-1); i++) {

      float areaP[] = new float[9];

      for (int jj=-1; jj<2; jj++) {
        for (int ii=-1; ii<2; ii++) {

          int readPos = ((j+jj)*img.width)+(i+ii);
          int writePos = (jj+1)*3+(ii+1);

          // assume grey image
          float r = red(img.pixels[readPos]);
          float g = green(img.pixels[readPos]);
          float b = blue(img.pixels[readPos]);

          float GS = (0.299 * r) + (0.587 * g) + (0.114 * b);

          areaP[writePos] = GS;
        }
      }

      float dx = ((areaP[0] + areaP[3] + areaP[6]) - (areaP[2] + areaP[5] + areaP[8]))/3;
      float dy = ((areaP[0] + areaP[1] + areaP[2]) - (areaP[6] + areaP[7] + areaP[8]))/3;

      // to get rid of white places
      if ((dx==0)&&(dy==0)) {
        if ((areaP[0] + areaP[3] + areaP[6]) == (255*3)) {
          if (j>(img.height/2))
            dy = maxY;
          else
            dy = -maxY;

          if (i>(img.width/2))
            dx=maxX;
          else
            dx=-maxX;
        }
      }


      PVX[j][i] = dx;
      PVY[j][i] = dy;

      if (abs(dx) > maxX) 
        maxX = abs(dx);

      if (abs(dy) > maxY)
        maxY = abs(dy);
    }
  }

  for (int j=1; j<(img.height-1); j++) {
    for (int i=1; i<(img.width-1); i++) {

      PVX[j][i] /= maxX;
      PVY[j][i] /= maxY;
    }
  }

  for (int j=0; j<height; j++) {
    for (int i=0; i<width; i++) {
      removed[j*width+i] = 0;
    }
  }


  ///// add hairs
  for (int i=0; i<NUMHAIR; i++) {
    int tx = (int)random(0, width);
    int ty = (int)random(height*0.5, height);

    Hairs.add(new Hair(HAIRLENGTH, PVX, PVY, tx, ty, img));
  }

  /// add balls 
  F.add(new Flock(new PVector(width*1.0/5.0, height*1.0/5.0), color(#000000), TEMPVAR));
  F.add(new Flock(new PVector(width*4.0/5.0, height*1.0/5.0), color(#000000), TEMPVAR));
  F.add(new Flock(new PVector(width*2.5/5.0, height*2.5/5.0), color(#000000), TEMPVAR));
  F.add(new Flock(new PVector(width*1.0/5.0, height*4.0/5.0), color(#000000), TEMPVAR));
  F.add(new Flock(new PVector(width*4.0/5.0, height*4.0/5.0), color(#000000), TEMPVAR));
}

void draw() {
  background(255, 255, 255);

  // read from serial only twice per minute...
  // this only detects once a minute has passed, 
  // clears the buffer, and sets up readFromSerial
  // in order to catch the next serial bundle
  if (((millis()-serialTimer) > 30000) && (dReader != null)) {

    dataStr = dReader.readLine();
    //System.out.println(dataStr);
    // split line
    String[] serialArray = splitTokens(dataStr, ",");
    // assign values to temperature,light,humidity
    if (serialArray.length == 5) {

      float t0 = Float.parseFloat(serialArray[2]);
      float h0 = Float.parseFloat(serialArray[3]);
      float l0 = Float.parseFloat(serialArray[4]);

      // boundary checking  
      if ((t0 < 45.0) && (t0 > -10.0)) {
        temperature = t0;
      }

      if ((h0 > 50.0) && (h0 < 110.0)) {
        humidity = h0;
      }

      if ((l0 > -1.0) && (l0 < 11.0)) {
        light = l0;
      }

      //println("got (t,l,h): "+temperature+" "+light+" "+humidity);
    }
    serialTimer = millis();
  }


  // if temp <<>> oldtemp
  // update TEMPVAR:(0,1]
  if (temperature != -10) {
    if ((temperature0 == -10)||(abs(temperature-temperature0) > 5)) {
      temperature0 = temperature;
      // correction
      float tt = (float)temperature + 0.0;
      TEMPVAR = map(tt, 15, 35, 0.0, 1.0);

      if (TEMPVAR < 0.0) TEMPVAR = 0.0;
      if (TEMPVAR > 1.0) TEMPVAR = 1.0;
    }
  }


  // if humidity <<>> oldhumidity
  // update HAIRLENGTH: [5, 20]
  if (humidity != -10) {
    if ((humidity0 == -10)||(abs(humidity-humidity0) > 10)) {

      HAIRLENGTH = (int)map(humidity, 60, 100, 5, 20);

      if (HAIRLENGTH < 5) HAIRLENGTH = 5;
      if (HAIRLENGTH >20) HAIRLENGTH = 20;

      humidity0 = humidity;
      for (int i=0; i<Hairs.size(); i++) {
        Hair h = (Hair) Hairs.get(i);
        h.setLength(HAIRLENGTH);
      }
    }
  }


  // if light <<>> oldlight
  // update NUMHAIR: [250, 900]
  if (light != -10) {
    if ((light0 == -10)||(abs(light-light0) > 0.2)) {
      light0 = light;
      NUMHAIR = (int)map(light, 0, 2, 300, 900);

      if (NUMHAIR < 200 ) NUMHAIR = 200;
      if (NUMHAIR > 900) NUMHAIR = 900;

      while (NUMHAIR > Hairs.size ()) {
        int tx = (int)random(0, width);
        int ty = (int)random(height*0.5, height);

        Hairs.add(new Hair(HAIRLENGTH, PVX, PVY, tx, ty, img));
      }

      while ( (Hairs.size () > NUMHAIR)&&(Hairs.size() > 0)) {
        Hair h = (Hair) Hairs.get(Hairs.size()-1);
        h.clear();
        Hairs.remove(Hairs.size()-1);
      }
    }
  }


  // every 20 seconds after 2 minutes... 
  // replace some hairs besed on humidity level.
  int replace_p = (HAIRLENGTH>18)?1000:15000;

  if (((millis() - htimer) > replace_p)&&(millis() > 120000)) {

    htimer = millis();

    // use hairlength for humidity factor
    // max HAIRLENGTH will be 20... so at most replace 1/3 of the hairs
    int numh = 3;

    if (HAIRLENGTH > 18) {
      numh += (int) ((float)Hairs.size()/40.0);
    }
    else if (HAIRLENGTH > 10) {
      numh += (HAIRLENGTH - 10);
    }

    int ii = (int)random(0, Hairs.size()-numh-1);

    for (int i=ii; i<(ii+numh); i++) {
      Hair h = (Hair) Hairs.get(i);
      //println("replacing "+ i);

      int rx = (int)h.tx;
      int ry = (int)h.ty;

      h.clear();

      Hairs.set(i, new Hair(HAIRLENGTH, PVX, PVY, rx, ry, img));
    }
  }

  for (int i=0; i<Hairs.size();i++) {
    Hair h = (Hair) Hairs.get(i);
    if (h.isDead == 1) {
      //println("reseeding "+ i);

      int rx = (int)h.tx;
      int ry = (int)h.ty;

      removed[ry*width+rx] = 1;

      h.clear();

      while (removed[ry*width+rx] == 1) {
        rx = (int) random(0, width);
        ry = (int) random(height*0.75, height);
      }
      Hairs.set(i, new Hair(HAIRLENGTH, PVX, PVY, rx, ry, img));
    }
    else {
      h.display();
    }
  }

  // display flocks
  for (int i=0; i<F.size(); i++) {
    Flock f = F.get(i);
    f.updateFlock(TEMPVAR);
  }
  //
}


// for testing
void keyReleased() {
  // testing temp
  if (((key == 't')||(key == 'b'))&&(temperature <=0)) {
    temperature = 20;
    println("up to: "+temperature);
  }
  else if ((key == 't')) {
    temperature += 5;
    temperature = (temperature>40)?40:temperature;
    println("up to: "+temperature);
  }
  else if ((key == 'b')) {
    temperature -= 3;
    temperature = (temperature<15)?15:temperature;
    println("down to: "+temperature);
  }
  else if (key == 'g') {
    println("t, t0, TEMPVAR: "+temperature+" "+temperature0+" "+TEMPVAR);
  }

  /// testing light
  if (((key == 'u')||(key == 'm'))&&(light <=0)) {
    light = 5;
    println("up to: "+light);
  }
  else if ((key == 'u')) {
    light += 1;
    light = (light>10)?10:light;
    println("up to: "+light);
  }
  else if ((key == 'm')) {
    light -= 1;
    light = (light<1)?1:light;
    println("down to: "+light);
  }
  else if (key == 'j') {
    println("l, l0, NUMHAIR: "+light+" "+light0+" "+NUMHAIR);
  }

  /// testing humidity
  if (((key == 'e')||(key == 'c'))&&(humidity <=0)) {
    humidity = 70;
    println("up to: "+humidity);
  }
  else if ((key == 'e')) {
    humidity += 10;
    humidity = (humidity>110)?100:humidity;
    println("up to: "+humidity);
  }
  else if ((key == 'c')) {
    humidity -= 10;
    humidity = (humidity<50)?50:humidity;
    println("down to: "+humidity);
  }
  else if (key == 'd') {
    println("h, h0, HAIRLENGTH: "+humidity+" "+humidity0+" "+HAIRLENGTH);
  }
}

