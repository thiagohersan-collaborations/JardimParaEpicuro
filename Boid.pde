class Boid {
  private static final float SPEEDVAR = 0.1;
  private static final float RADVAR   = 0.3;

  private static final float RADMAX   = 20.0;
  private static final float FREQMAX  = 6.0;
  private static final float AMPMAX   = 20.0;


  private PVector pos;
  private PVector posO;
  private PVector vel;
  private PVector acc;

  private PVector amp;
  private float freq;
  private float angle;

  private float rad;
  private float maxSpeed;

  private color boidColor;

  // for smoke type...
  public Boid(PVector xy, color bc) {
    pos  = xy.get();
    posO = xy.get();
    vel = new PVector(0, 0);
    amp  = new PVector(random( -AMPMAX*2/3, AMPMAX*2/3), random( -AMPMAX, AMPMAX));
    rad    = random(RADMAX/2, RADMAX);
    freq   = random(-FREQMAX, FREQMAX);
    angle = 0.0;
    boidColor = bc;
    maxSpeed = FREQMAX*5;
  }

  // for smoke type:
  //   pass the previous boid
  private void updateSmokeBoid(Boid b) {
    // update position
    PVector bv;
    if (b != null) {
      bv = b.getPos().get();
    }
    // head
    else {
      bv = posO.get();
      amp.x = 8;
      amp.y = 5;
      freq = 1;
    }
    float ox = pos.x;
    float oy = pos.y;

    pos.x = bv.x+cos(radians(angle))*amp.x;
    pos.y = bv.y+sin(radians(angle))*amp.y;

    vel.x = pos.x-ox;
    vel.y = pos.y-oy;

    vel.limit(maxSpeed);

    // update angle
    angle += freq;
    // fix position
    this.reachAround();
  }
  public void displayBoid(Boid b) {
    this.updateSmokeBoid(b);
    // draw
    fill(boidColor, vel.mag()/maxSpeed*255.0);
    fill(lerpColor(color(#ffc200), boidColor, vel.mag()/maxSpeed*2), vel.mag()/maxSpeed*255.0);
    fill(lerpColor(color(#ffc200), boidColor, vel.mag()/maxSpeed*2), 50);
    noStroke();
    ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2*rad, 2*rad);
    ellipse(pos.x, pos.y, 2*rad, rad*2);
  }

  //
  private PVector getPos() {
    return pos;
  }

  // basic constructor
  public Boid(PVector xy, float r, float ms, color bc) {
    // get initial x,y
    pos = xy.get();

    // radius of boid    
    rad = random((1.0-RADVAR)*abs(r), (1.0+RADVAR)*abs(r));

    // max speed with some variation
    maxSpeed = random((1.0-SPEEDVAR)*abs(ms), (1.0+SPEEDVAR)*abs(ms));

    // color
    boidColor = bc;
  }

  // new max speed, with some variation
  public void updateMaxSpeed(float ms) {
    maxSpeed = random((1.0-SPEEDVAR)*abs(ms), (1.0+SPEEDVAR)*abs(ms));
  }

  // for dealing with edges of screen
  private void reachAround() {
    if (pos.x <      0) pos.x += width;
    if (pos.y <      0) pos.y += height;
    if (pos.x >  width) pos.x -= width;
    if (pos.y > height) pos.y -= height;
  }


  private void updateBoid(ArrayList<Boid> boids) {
    // separation
    // alignment
    // cohesion
    this.reachAround();
  }

  public void displayBoid(ArrayList<Boid> boids) {
    // update boid location
    this.updateBoid(boids);

    // draws
    // pick color based on velocity. the faster the more colorful...
    fill(lerpColor(color(#ffffff), boidColor, vel.mag()/maxSpeed), 10);
    noStroke();
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 2*rad, 2*rad);
  }
}

