class Hair {
  ArrayList particles;
  int hlen;
  float maxMass = 3;
  float maxGravity = 10;

  float tx, ty, xoff, yoff;

  int pcnt;

  short isDead;

  PImage img;

  float[][] PVX;
  float[][] PVY;

  Hair(int s, float[][] pvx, float[][] pvy, int ttx, int tty, PImage img_) {
    particles = new ArrayList();
    hlen = s;
    PVX = pvx;
    PVY = pvy;
    pcnt = 0;
    isDead = 0;
    img = img_;

    for (int i=0; i<hlen; i++) {
      particles.add(new Particle(random(0, width), random(0, height), random(1, maxMass), random(1, maxGravity), PVX, PVY, img));
    }

    tx = (float)ttx;
    ty = (float)tty;
    xoff = 0;
    yoff = 0;
  }


  void display() {
    int dcnt = 0;
    for (int i=0; (i<particles.size())&&(isDead == 0); i++) {
      Particle p = (Particle) particles.get(i);
      if (i==0) {
        p.update(tx, ty);
        p.display();
      }
      else {
        Particle p_ = (Particle) particles.get(i-1);

        p.update (p_.x, p_.y);
        p.display(p_.x, p_.y);
      }
      dcnt += p.isDead;
    }

    if (dcnt > (particles.size()-1)) {
      isDead = 1;
    }
  }

  void clear() {
    for (int i=particles.size()-1; i>=0; i--) {
      particles.remove(i);
    }
  }

  void setLength(int len) {

    if (len != hlen) {

      while (len > particles.size ()) {
        particles.add(new Particle(random(0, width), random(0, height), random(1, maxMass), random(1, maxGravity), PVX, PVY, img));
      }

      while((particles.size () > len)&&(particles.size() > 0)) {
        particles.remove(particles.size()-1);
      }    
      hlen = len;
    }
  }
}

