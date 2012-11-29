class Particle {
  float vx, vy; // The x- and y-axis velocities
  float x, y; // The x- and y-coordinates
  float gx, gy;
  float mass;
  float radius = 1;
  float stiffness = 0.3;
  float damping = 0.7;

  float[][] PVX;
  float[][] PVY;

  PImage img;

  float oldx, oldy;
  float ocnt;

  short isDead;

  Particle(float xpos, float ypos, float m, float g, float[][] pvx, float[][] pvy, PImage img_) {
    x = xpos;
    y = ypos;
    mass = m;
    gy = -g;
    gx = random(-g,g);
    radius = 1;

    PVX=pvx;
    PVY=pvy;

    img = img_;

    oldx = x;
    oldy = y;
    ocnt = 0;
    isDead = 0;
  }


  ///////////
  void update() {

    float ffx = 0;
    float ffy = 0;
    if((x<width)&&(y<height)&&(x>=0)&&(y>=0)) {
      ffx = PVX[(int)y][(int)x];
      ffy = PVY[(int)y][(int)x];

      if((ffx>1)||(ffx<-1))
        ffx = 0;

      if((ffy>1)||(ffy<-1))
        ffy = 0;
    }

    //float forceX = (targetX - x) * stiffness;
    //forceX += gx+ffx;
    float forceX = ffx*18;
    float ax = forceX / mass;
    vx = damping * (vx + ax);
    x += vx;

    //float forceY = (targetY - y) * stiffness;
    //forceY += gy+ffy;
    float forceY = ffy*18;
    float ay = forceY / mass;
    vy = damping * (vy + ay);
    y += vy;

    if((x == oldx)&&(y == oldy)) {
      ocnt++;
    }
    else {
      oldx = x;
      oldy = y;
      ocnt = 0;
    }

    if(ocnt > 50) {
      isDead = 1;
    }
  }

  /////////


  void update(float targetX, float targetY) {

    float ffx = 0;
    float ffy = 0;
    if((x<width)&&(y<height)&&(x>=0)&&(y>=0)) {
      ffx = PVX[(int)y][(int)x];
      ffy = PVY[(int)y][(int)x];

      if((ffx>1)||(ffx<-1))
        ffx = 0;

      if((ffy>1)||(ffy<-1))
        ffy = 0;
    }


    float forceX = (targetX - x) * stiffness;
    forceX += ffx*18+gx;
    float ax = forceX / mass;
    vx = damping * (vx + ax);
    x += vx;

    float forceY = (targetY - y) * stiffness;
    forceY += ffy*18+gy;
    float ay = forceY / mass;
    vy = damping * (vy + ay);
    y += vy;

    if((abs(x-oldx)<1)&&(abs(y-oldy)<1)) {
      ocnt++;
    }
    else {
      oldx = x;
      oldy = y;
      ocnt = 0;
      isDead = 0;
    }

    if(ocnt > 50) {
      isDead = 1;
    }
  }

  void display(float nx, float ny) {
    noStroke();

    img.loadPixels();
    color c0 = img.get((int)x,(int)y);
    color c1 = img.get((int)nx,(int)ny);

    float tc0 = red(c0);
    float tc1 = red(c1);
    float nc = (tc0+tc1)/2;

  if(nc>232){
    stroke(nc, 0);
  }
  else{
    stroke(nc, 255);
  }

    //ellipse(x, y, 1, 1);    
    line(x, y, nx, ny);
  }

  void display() {
    //noStroke();
    //ellipse(x, y, radius*1, radius*1);
    //stroke(0);
    //line(x, y, nx, ny);
  }
}

