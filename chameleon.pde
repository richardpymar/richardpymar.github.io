Ball[] balls;
int numBalls = 10;

int neighbour;
int found;
int rad=18;
float critAng = PI/numBalls; //cutoff point for selection
float theta;
float phi;
float cenX;
float cenY;
float sc = 0.7;
color[] c = new color[numBalls];
float err = 5.0;
int globalOn = 0;
boolean toWhite = false;
boolean toRed = false;


void setup() {
  c[0]=#FF0000;
  c[1]=#ffffff;
  c[2]=#ffffff;
  c[3]=#000000;
  c[4]=#000000;
  c[5]=#FF0000;
  c[6]=#ffffff;
  c[7]=#ffffff;
  c[8]=#000000;
  c[9]=#ffffff;  
  size(400, 400);
  cenX = width/2;
  cenY = height/2;
  balls = new Ball[numBalls]; //creating the balls
  for (int i =0; i<balls.length; i++) {
    float beta = i*TWO_PI/numBalls;
    balls[i] = new Ball(cenX+sc*cenX*cos(beta+.5), cenY+sc*cenY*sin(beta+.5), c[i], i); //giving their initial positions, the .5 is so that dont get one ball directly above other as then code for moving breaks..
  }
}

void draw() {
  globalOn=0;
  for (int i=0; i<numBalls; i++) {
    globalOn+=balls[i].on;
  }
  float r2 = pow(cenY-mouseY, 2)+pow(cenX-mouseX, 2);
  float r1 = pow(r2, .5);
  float zeta = acos((mouseX-cenX)/r1);
  if (mouseY>cenY) {
    zeta*=-1;
  }
  //println(zeta);
  theta = atan((cenY-mouseY)/(cenX-mouseX)); // angle of the mouse wrt x axis
  if (mouseX>cenX) {
    theta*=-1; // change values for positive x
  }
  phi = atan(-(cenX-mouseX)/(cenY-mouseY)); // angle of the mouse wrt y axis
  if (mouseY>cenY) {
    phi*=-1;
  }
  //println(theta);
  background(#b4b4b4);
  //print(balls[1].dir);
  //print(globalOn);
  for (int i=0; i<balls.length; i++) {
    balls[i].display(); // draw the balls
    balls[i].move(); // move them
    float ballAng = acos(balls[i].x/(.7*cenX)-1/.7);
    if (balls[i].y>cenY) {
      ballAng*=-1;
    }
    float r = atan((cenY-balls[i].y)/(cenX-balls[i].x)); // compute angle of the balls wrt x axis
    if (balls[i].x>cenX) {
      r*=-1;
    }
    float s = atan(-(cenX-balls[i].x)/(cenY-balls[i].y)); // compute angle of balls wrt y axis
    if (balls[i].y>cenY) {
      s*=-1;
    }
    
    //depinking
    if(balls[i].ballcol==#ffbcbc&&globalOn==0&&toRed==true){
      balls[i].ballcol=#FF0000;
    }
     if(balls[i].ballcol==#ffbcbc&&globalOn==0&&toWhite==true){
      balls[i].ballcol=#ffffff;
    }
    
    // if angle between balls and mouse is small in both axes, then select
    if (((ballAng-zeta<=2*critAng&&ballAng-zeta>=0*critAng)||(-zeta+TWO_PI+ballAng>=0*critAng&&-zeta+TWO_PI+ballAng<=2*critAng))&&globalOn==0) {
      balls[i].select1(); // select here
      if (mousePressed==true) { // if click then start to move them

        if (balls[i].ballcol==#ffffff) {
          found=0;
          for (int j=0; j<balls.length; j++) {
            if ((balls[j].pos==(balls[i].pos+1)%numBalls)&&(balls[j].ballcol==#FF0000)) {
              balls[i].pinken();
              balls[j].pinken();
              found=1;
            }
          }
          if (found==0&&balls[i].on==0) {
            balls[i].startL();
          }
        } else if (balls[i].ballcol==#FF0000) {
          found=0;
          for (int j=0; j<balls.length; j++) {
            if ((balls[j].pos==(balls[i].pos+1)%numBalls)&&(balls[j].ballcol==#ffffff)) {
              balls[i].pinken();
              balls[j].pinken();
              found=1;
            }
          }
          if (found==0&&balls[i].on==0) {

            balls[i].startL();
          }
        } else if (balls[i].ballcol!=#FF0000&&balls[i].ballcol!=#ffffff&&balls[i].on==0) {

          balls[i].startL();
        }
      }
    } else if (((zeta-ballAng<=2*critAng&&zeta-ballAng>=0*critAng)||(zeta+TWO_PI-ballAng>=0*critAng&&zeta+TWO_PI-ballAng<=2*critAng))&&globalOn==0) {
      balls[i].select2(); // select here
      if (mousePressed==true) {  // if click then start to move them

        if (balls[i].ballcol==#ffffff) {
          found=0;
          for (int j=0; j<balls.length; j++) {
            if ((balls[j].pos==(balls[i].pos-1+numBalls)%numBalls)&&(balls[j].ballcol==#FF0000)) {
              balls[i].pinken();
              balls[j].pinken();
              found=1;
            }
          }
          if (found==0&&balls[i].on==0) {
            balls[i].startR();
          }
        } else if (balls[i].ballcol==#FF0000) {
          found=0;
          for (int j=0; j<balls.length; j++) {
            if ((balls[j].pos==(balls[i].pos-1+numBalls)%numBalls)&&(balls[j].ballcol==#ffffff)) {
              balls[i].pinken();
              balls[j].pinken();
              found=1;
            }
          }
          if (found==0&&balls[i].on==0) {

            balls[i].startR();
          }
        } else if (balls[i].ballcol!=#FF0000&&balls[i].ballcol!=#ffffff&&balls[i].on==0) {

          balls[i].startR();
        }
      }
    }
  }
}

void keyPressed() {
  if ((key == 'W') || (key == 'w')) {
    toWhite = true;
  }
   if ((key == 'R') || (key == 'r')) {
    toRed = true;
  }
}

void keyReleased() {
  toWhite=false;
  toRed=false;
}



class Ball {
  float x, y;
  color ballcol;
  int on=0; // only move when this is 1
  int count = 0;
  int dir = 0;
  float w0, w1, z0, z1, a, c, d;
  float xRef, yRef;
  int pos;




  Ball(float xpos, float ypos, color col, int initpos) {
    x = xpos;
    y=ypos;
    ballcol=col;
    pos=initpos;
  }
  void display() {
    noStroke();
    fill(ballcol);
    ellipse(x, y, 2*rad, 2*rad);
  }

  void move() {
    if (on ==1&&count<60) {
      if (dir==1) {
        x= cenX+(x-cenX)*cos(TWO_PI/(60*numBalls))-(y-cenY)*sin(TWO_PI/(60*numBalls)); // move by incrementing their angle
        y= cenY+(y-cenY)*cos(TWO_PI/(60*numBalls))+(x-cenX)*sin(TWO_PI/(60*numBalls));
      }
      if (dir==-1) {
        x= cenX+(x-cenX)*cos(TWO_PI/(60*numBalls))+(y-cenY)*sin(TWO_PI/(60*numBalls));
        y= cenY+(y-cenY)*cos(TWO_PI/(60*numBalls))-(x-cenX)*sin(TWO_PI/(60*numBalls));
      }
      if (dir==2) {
        xRef= cenX+(xRef-cenX)*cos(2*TWO_PI/(60*numBalls))-(yRef-cenY)*sin(2*TWO_PI/(60*numBalls)); // move by incrementing their angle
        yRef= cenY+(yRef-cenY)*cos(2*TWO_PI/(60*numBalls))+(xRef-cenX)*sin(2*TWO_PI/(60*numBalls));
        d=(xRef+(yRef-c)*a)/(1+pow(a, 2));
        x=2*d-xRef;
        y=2*d*a-yRef+2*c;
      }
      if (dir==-2) {
        xRef= cenX+(xRef-cenX)*cos(2*TWO_PI/(60*numBalls))+(yRef-cenY)*sin(2*TWO_PI/(60*numBalls));
        yRef= cenY+(yRef-cenY)*cos(2*TWO_PI/(60*numBalls))-(xRef-cenX)*sin(2*TWO_PI/(60*numBalls));
        d=(xRef+(yRef-c)*a)/(1+pow(a, 2));
        x=2*d-xRef;
        y=2*d*a-yRef+2*c;
      }

      count++;
    
    
    }
    if (count ==60||(count==20&&dir==0)) {
      on=0;
      count=0;
      for (int j=0; j<numBalls; j++) {  // do a check that balls are where they should be (rounding errors move them!)
        if (abs(x-(cenX+sc*cenX*cos(j*TWO_PI/numBalls+.5)))<err&&abs(y-(cenY+sc*cenY*sin(j*TWO_PI/numBalls+.5)))<err) {
          x=cenX+sc*cenX*cos(j*TWO_PI/numBalls+.5);
          y=cenY+sc*cenY*sin(j*TWO_PI/numBalls+.5);
        }
      }
    }
  }


  void startL() {
    on =1;
    dir=1;
    pos=(pos+1+numBalls)%numBalls;
  }


  void startR() {
    on=1;
    dir=-1;
    pos=(pos-1+numBalls)%numBalls;
  }
  void select1() {
    strokeWeight(2);
    stroke(#5c6bdb);
    ellipse(x, y, 2*rad, 2*rad);
  }
  void select2() {
    strokeWeight(2);
    stroke(#5c6bdb);
    ellipse(x, y, 2*rad, 2*rad);
  }
  void pinken() {
    ballcol=#ffbcbc;
    on=1;
    dir=0;
  }
}