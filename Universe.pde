class Universe {
  ArrayList holes;
  float maxGravity = 0.5;
  float maxRadius = 20;
  float distFactor = 1.0;
  float centerX, centerY;

  Universe(int ulen, float df, float cx, float cy) {
    holes = new ArrayList();
    distFactor = df;
    centerX = cx;
    centerY = cy;


    for (int i=0; i<ulen; i++) {
      int pn = (((int)random(0, 100))%2);

      //float tx = (float)(width/2)+random(-50,50);
      float tx = random(centerX-df*(width/2), centerX+df*(width/2));
      float ty = random(centerY-df*(height/2), centerY+df*(height/2));

      float massRadius = random(7, maxRadius);


      holes.add(new Hole(random(tx-df*(width/2), tx+df*(width/2)), random(ty-df*(height/2), ty-df*(height/2)), tx, ty, 
      massRadius, random(0, maxGravity), massRadius));
    }
  }

  void display() {
    for (int i=0; i<holes.size(); i++) {
      Hole h = (Hole) holes.get(i);
      h.update();
      h.display();
    }
  }

  void display(float tv) {
    for (int i=0; i<holes.size(); i++) {
      Hole h = (Hole) holes.get(i);
      h.update(tv);
      h.display();
    }
  }
}

