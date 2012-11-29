class Flock {
  private static final int FLOCK_SIZE = 100;

  private ArrayList<Boid> boids;
  private color flockColor;
  private float scaleF;

  // original radius and speed
  private float originalR;
  private float originalS;

  // which kind
  private boolean isSmoke;

  // init the list of boids
  // non smoke kind
  public Flock(float r, float s, color fc) {
    isSmoke = false;
    boids = new ArrayList<Boid>();
    originalR = r;
    originalS = s;
    flockColor = fc;

    // initialize flock with boids
    for (int i=0; i<FLOCK_SIZE; i++) {
      boids.add(new Boid(new PVector(random(0.375, 0.625)*width, random(0.375, 0.625)*height), originalR, originalS, flockColor));
    }
  }

  // init the list of smoke boids
  public Flock(PVector xy, color fc, float sf) {
    isSmoke = true;
    boids = new ArrayList<Boid>();
    flockColor = fc;
    scaleF = sf;

    // initialize flock with boids
    for (int i=0; i<FLOCK_SIZE; i++) {
      boids.add(new Boid(xy, fc, sf));
    }
  }

  // update state and location, and display each boid
  public void updateFlock(float sf) {
    scaleF = sf;
    if (isSmoke == true) {
      Boid p = null;
      for(int i=1; i<boids.size(); i++) {
        Boid b = boids.get(i);
        b.displayBoid(p, sf);
        p = boids.get(i);
      }
    }
    // not smoke kind
    else {
      for (int i=0; (i<boids.size()); i++) {
        Boid b = boids.get(i);
        b.displayBoid(boids);
      }
    }
  }

  // update the max number of boids
  public void updateNum(int nob) {
    while (boids.size () < nob) {
      this.addBoid();
    }
    while (nob < boids.size ()) {
      boids.remove(boids.size()-1);
    }
  }

  // update the max speed for each boid
  public void updateSpeed(float ns) {
    // update original speed. not really original now....
    originalS = ns;

    for (int i=0; (i<boids.size()); i++) {
      Boid b = boids.get(i);
      b.updateMaxSpeed(ns);
    }
  }

  // add boid to flock
  public void addBoid() {
    if (isSmoke == true) {
      boids.add(new Boid(new PVector(0,0), flockColor, scaleF));
    }
    else {
      boids.add(new Boid(new PVector(random(0.375, 0.625)*width, random(0.375, 0.625)*height), originalR, originalS, flockColor));
    }
  }

  //
}

