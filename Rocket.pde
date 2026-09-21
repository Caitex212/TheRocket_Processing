float gravityMultiplier = 9.81;
float rRotForce = 0.001; // Rotational Force

PVector gravityOrigin = new PVector(960,540); // Center of gravity

PVector rPos = new PVector(960, 100); // Position
PVector rVel = new PVector(0, 0); // Velocity

float rRot = 0; // Orientation/Rotation
float rRotVel = 0; // Rotaional Velocity

boolean left = false;
boolean right = false;
boolean up = false;

void setup() {
  size(1920,1080);
  frameRate(60);
}

void draw() {
  background(0);
  
  // Debugging
  String dText = "Velocity: " + String.valueOf(rVel.mag()) + "\nRoational Velocity: " + String.valueOf(rRotVel);
  textSize(30);
  fill(255);
  text(dText, 0, 30);
  
  // Input Display
  String inputs = "";
  if (left) {
    inputs += "LEFT \n";
  }
  if (right) {
    inputs += "RIGHT \n";
  }
  if (up) {
    inputs += "UP \n";
  }
  textSize(30);
  fill(255);
  text(inputs, 0, 100);
  
  rocketLogic();
  drawRocket();
}

void rocketLogic() {
  // Gravity Calculation
  PVector movementVector = PVector.sub(gravityOrigin, rPos).normalize();
  movementVector.mult(gravityMultiplier * 0.003);
  rVel.add(movementVector);
  
  rPos.add(rVel);
  
  if (left && right) {
  }
  else if (left) {
    rRotVel -= rRotForce;
  }
  else if (right) {
    rRotVel += rRotForce;
  }
  rRot += rRotVel;
}

void drawRocket() {
  pushMatrix();
  translate(rPos.x, rPos.y);
  rotate(rRot);
  
  stroke(255);
  strokeWeight(5);
  line(0, 0, 0, -20);
  line(0, 0, 0, 20);
  
  popMatrix();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT)  left = true;
    if (keyCode == RIGHT) right = true;
    if (keyCode == UP)    up = true;
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT)  left = false;
    if (keyCode == RIGHT) right = false;
    if (keyCode == UP)    up = false;
  }
}
