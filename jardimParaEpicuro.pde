import processing.opengl.*;
import processing.serial.*;

/**
 *
 *
 */


int HAIRLENGTH = 18;
int NUMHAIR = 600;

int NUMBALLS = 10;
float TEMPVAR = 0.2;

ArrayList Hairs;
ArrayList U;

float[][] PVX;
float[][] PVY;

color[] pFrame;
int[] removed;

PImage img;

int htimer;

PrintWriter output;

Serial myPort;

String serialStr;

int sonar_1, sonar_2, temperature, humidity, light, temperature0, humidity0, light0; 

void setup() {

  println (Serial.list());

  if (Serial.list().length > 0) {
    myPort = new Serial(this, Serial.list()[0], 19200);
    print ("found "+Serial.list().length+" serial ports");
  }
  else
    myPort = null;

  //size(800, 600, OPENGL);
  size(screen.width, screen.height, OPENGL);
  smooth();
  fill(0);

  frameRate(24);

  Hairs = new ArrayList();
  U = new ArrayList();

  //img = loadImage("xadrez.bmp");
  //img = loadImage("desenho1.bmp");
  img = loadImage("desenho6.bmp");

  img.loadPixels();

  htimer = millis();

  PVX = new float[height][width];
  PVY = new float[height][width];

  removed = new int[height*width];

  float maxX=0;
  float maxY=0;

  sonar_1 = sonar_2 = temperature = humidity = light = -10;
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

      //output.println(i+","+j+"="+nx+","+ny);
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
  U.add(new Universe(NUMBALLS, TEMPVAR, width/20, height/20));
  U.add(new Universe(NUMBALLS, TEMPVAR, width/2, height/10));
  U.add(new Universe(NUMBALLS, TEMPVAR, width*18/20, height/18));
  U.add(new Universe(NUMBALLS, TEMPVAR, width*17/20, height*3/10));
  U.add(new Universe(NUMBALLS, TEMPVAR, width*2/20, height*6/10));
  U.add(new Universe(NUMBALLS, TEMPVAR, width*11/20, height*7/10));
}

void draw() {
  background(255, 255, 255);

  if (myPort != null) {

    serialStr = myPort.readString();

    if (serialStr!=null) {
      //println(serialStr);
      String[] serialArray = splitTokens(serialStr, ",");

      for (int i=0; i<serialArray.length; i++) {
        String list[] = splitTokens(serialArray[i], "=");
        try {
          if (list[0].equals("sonar1")) {
            sonar_1 = Integer.parseInt(list[1]);
          }
          else if (list[0].equals("sonar2")) {
            sonar_2 = Integer.parseInt(list[1]);
          }
          else if (list[0].equals("temp")) {
            temperature = Integer.parseInt(list[1]);
          }
          else if (list[0].equals("humid")) {
            humidity = Integer.parseInt(list[1]);
          }
          else if (list[0].equals("light")) {
            light = Integer.parseInt(list[1]);
          }
        }
        catch(Exception e) {
        }
      }
    }
  }

  // if temp <<>> oldtemp
  // update TEMPVAR:(0,1]
  if (temperature != -10) {
    if ((temperature0 == -10)||(abs(temperature-temperature0) > 5)) {
      temperature0 = temperature;
      // correction
      float tt = (float)temperature + 8.0;
      TEMPVAR = map(tt, 15, 40, 0, 1.0);
    }
  }


  // if humidity <<>> oldhumidity
  // update HAIRLENGTH: [5, 20]
  if (humidity != -10) {
    if ((humidity0 == -10)||(abs(humidity-humidity0) > 500)) {

      if ((humidity < 20)&&(humidity0<20)) {
        HAIRLENGTH = 5;
      }
      else if ((humidity > 1020)&&(humidity0>1020)) {
        HAIRLENGTH = 20;
      }
      else if ((humidity0 < 1020)&&(humidity0>20)) {
        HAIRLENGTH = 15;
      }

      //HAIRLENGTH = (int)map((float)humidity, 15, 80, 5, 20);


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
    if ((light0 == -10)||(abs(light-light0) > 20)) {
      light0 = light;
      NUMHAIR = (int)map((float)light, 250, 920, 200, 900);

      while (NUMHAIR > Hairs.size ()) {
        int tx = (int)random(0, width);
        int ty = (int)random(height*0.5, height);

        Hairs.add(new Hair(HAIRLENGTH, PVX, PVY, tx, ty, img));
      }

      while (Hairs.size () > NUMHAIR) {
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
      println("replacing "+ i);

      int rx = (int)h.tx;
      int ry = (int)h.ty;

      h.clear();

      Hairs.set(i, new Hair(HAIRLENGTH, PVX, PVY, rx, ry, img));
    }
  }

  for (int i=0; i<Hairs.size();i++) {
    Hair h = (Hair) Hairs.get(i);
    if (h.isDead == 1) {
      println("reseeding "+ i);

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

  for (int i=0; i<U.size(); i++) {
    Universe u = (Universe) U.get(i);
    u.display(TEMPVAR);
  }
}


// for testing
void keyReleased() {
  // testing temp
  if (((key == 't')||(key == 'b'))&&(temperature <=0)) {
    temperature = 5;
    println("up to: "+temperature);
  }
  else if ((key == 't')&&(temperature < 32)) {
    temperature += 3;
    println("up to: "+temperature);
  }
  else if ((key == 'b')&&(temperature >= 5)) {
    temperature -= 3;
    println("down to: "+temperature);
  }
  else if (key == 'g') {
    println("t, t0, TEMPVAR: "+temperature+" "+temperature0+" "+TEMPVAR);
  }

  /// testing light
  if (((key == 'u')||(key == 'm'))&&(light <=0)) {
    light = 250;
    println("up to: "+light);
  }
  else if ((key == 'u')&&(light < 915)) {
    light += 5;
    println("up to: "+light);
  }
  else if ((key == 'm')&&(light >= 255)) {
    light -= 5;
    println("down to: "+light);
  }
  else if (key == 'j') {
    println("l, l0, NUMHAIR: "+light+" "+light0+" "+NUMHAIR);
  }

  /// testing humidity
  if (((key == 'e')||(key == 'c'))&&(humidity <=0)) {
    humidity = 500;
    println("up to: "+humidity);
  }
  else if ((key == 'e')) {
    humidity += 200;
    humidity = (humidity<1200)?humidity:1200;
    println("up to: "+humidity);
  }
  else if ((key == 'c')) {
    humidity -= 200;
    humidity = (humidity>0)?humidity:0;
    println("down to: "+humidity);
  }
  else if (key == 'd') {
    println("l, l0, HAIRLENGTH: "+humidity+" "+humidity0+" "+HAIRLENGTH);
  }
}

