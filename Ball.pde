class Ball {
  float vx, vy; // The x- and y-axis velocities
  float x, y; // The x- and y-coordinates
  float gx, gy;
  float mass;
  float radius = 1;

  //float oldx, oldy;

  float targetX, targetY;
  float vmax;

  Ball(float xpos, float ypos, float tx, float ty, float m, float g, float r) {
    x = xpos;
    y = ypos;
    mass = m;
    gy = -g;
    gx = random(-g,g);
    radius = r;

    float tvx = (width*width/4)/(mass*mass);
    float tvy = (height*height/4)/(mass*mass);
    vmax = tvx*tvx+tvy*tvy;
    
    targetX = tx;
    targetY = ty;

  }

  void update() {
    float forceX = (1.0*targetX - x);
    //forceX += gx;
    //forceX /= 4;
    float ax = 1.0*(forceX / mass);
    vx = 1.0*(vx + ax);
    x += vx*0.05;

    float forceY = (1.0*targetY - y);
    //forceY += gy;
    //forceY /= 4;
    float ay = 1.0*(forceY / mass);
    vy = 1.0*(vy + ay);
    y += vy*0.05;
  }

  // vFactor := (0,1]
  void update(float vFactor) {
    
    float tf = vFactor*0.5+1.0;
    float af = vFactor*4.0+1.0;
    
    float forceX = (tf*targetX - x);
    //forceX += gx;
    //forceX /= 4;
    float ax = af*(forceX / mass);
    vx = 1.0*(vx + ax);
    x += vx*0.05;

    float forceY = (tf*targetY - y);
    //forceY += gy;
    //forceY /= 4;
    float ay = af*(forceY / mass);
    vy = 1.0*(vy + ay);
    y += vy*0.05;
  }


  void display() {

    float vmag = (vx*vx+vy*vy);
    fill((vmag/vmax)*250+20);
    noStroke();
    ellipse(x, y, radius, radius);
  }
}

