float gravityMultiplier = 9.81;
float rRotForce = 0.001; // Rotational Force
float rThrForce = 0.1; // Thruster Force

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
  // Gravity calculation
  PVector movementVector = PVector.sub(gravityOrigin, rPos).normalize();
  movementVector.mult(gravityMultiplier * 0.003);
  
  //Thruster calculation
  if (up) {
    movementVector.add(new PVector(0, -rThrForce).rotate(rRot));
  }
  
  rVel.add(movementVector);  
  rPos.add(rVel);
  
  if (left && right) {
  }
  else if (left) {
    rRotVel -= rRotForce;
    if (rRotVel < -1) rRotVel = -1;
  }
  else if (right) {
    rRotVel += rRotForce;
    if (rRotVel > 1) rRotVel = 1;
  }
  rRot += rRotVel;
}

void drawRocket() {
  pushMatrix();
  translate(rPos.x, rPos.y);
  rotate(rRot);
  
  // --------------------- Legs
  stroke(255);
  line(-3, 20, -15, 40);
  line(3, 20, 15, 40);
  stroke(200);
  line(20, 40, 15, 40);
  line(-20, 40, -15, 40);
  // ---------------------
  
  // --------------------- Flame
  if (up) {
    stroke(66, 123, 245);
    ellipse(0, 30, 3, 20);
    stroke(235, 239, 247);
    ellipse(0, 25, 2, 10);
  }
  // ---------------------
  
  // --------------------- Body
  stroke(255);
  fill(255);
  rect(-3, -25, 6, 50);
  // ---------------------
  
  // --------------------- Tip
  stroke(200);
  fill(200);
  strokeWeight(5);
  rect(-3, -25, 6, 10);
  // ---------------------
  
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
