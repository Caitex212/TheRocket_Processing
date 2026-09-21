int gravityMultiplier = 1;

PVector gravityOrigin = new PVector(960,540);

PVector rPos = new PVector(960, 100);
PVector rVel = new PVector(0, 0);
int rRot = 0;

void setup() {
  size(1920,1080);
  frameRate(60);
  background(0);
}

void draw() {
  //rocketLogic();
  drawRocket();
}

void rocketLogic() {
  PVector movementVector = PVector.sub(gravityOrigin, rPos).normalize();
  movementVector.mult(gravityMultiplier);
  
  rPos.add(movementVector);  
}

void drawRocket() {
  pushMatrix();
  translate(rPos.x, rPos.y);
  rotate(rRot);
  
  stroke(255);
  strokeWeight(5);
  line(0, 0, 0, 20);
  
  popMatrix();
}
