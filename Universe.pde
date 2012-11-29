class Universe {
  ArrayList balls;
  float maxGravity = 0.5;
  float maxRadius = 20;
  float distFactor = 1.0;
  float centerX, centerY;

  Universe(int ulen, float df, float cx, float cy) {
    balls = new ArrayList();
    distFactor = df;
    centerX = cx;
    centerY = cy;


    for (int i=0; i<ulen; i++) {
      int pn = (((int)random(0, 100))%2);

      //float tx = (float)(width/2)+random(-50,50);
      float tx = random(centerX-df*(width/2), centerX+df*(width/2));
      float ty = random(centerY-df*(height/2), centerY+df*(height/2));

      float massRadius = random(7, maxRadius);


      balls.add(new Ball(random(tx-df*(width/2), tx+df*(width/2)), random(ty-df*(height/2), ty-df*(height/2)), tx, ty, 
      massRadius, random(0, maxGravity), massRadius));
    }
  }

  void display() {
    for (int i=0; i<balls.size(); i++) {
      Ball b = (Ball) balls.get(i);
      b.update();
      b.display();
    }
  }

  void display(float tv) {
    for (int i=0; i<balls.size(); i++) {
      Ball b = (Ball) balls.get(i);
      b.update(tv);
      b.display();
    }
  }
}

