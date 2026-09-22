float gravityMultiplier = 9.81;
float rAngForce = 0.001; // Angular Force
float rThrForce = 0.1; // Thruster Force

float restitution = 0.05; // bouncyness
float friction = 0.5;
float mass = 1.0;
float inverseMass = 1.0 / mass;
float momentOfInertia = 500.0; // basically rotational mass
float inverseInertia = 1.0 / momentOfInertia;

PVector gravityOrigin = new PVector(960, 540); // Center of gravity

PVector rPos = new PVector(960, 100); // Position
PVector rVel = new PVector(0, 0); // Velocity

float rAng = 0; // Angle
float rAngVel = 0; // Angular Velocity

boolean left = false;
boolean right = false;
boolean up = false;

float pSize = 200; // Radius
float pRotation = 0;
float pRotationSpeed = 0.001;

void setup() {
  size(1920, 1080);
  frameRate(60);
}

void draw() {
  background(0);

  // -------------------- Planet
  pRotation += pRotationSpeed;
  drawPlanet();

  // -------------------- Debugging
  String dText = "Velocity: " + String.valueOf(rVel.mag()) + "\nRoational Velocity: " + String.valueOf(rAngVel);
  textSize(30);
  fill(255);
  text(dText, 0, 30);

  // -------------------- Input Display
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

  // -------------------- Rocket Handler
  rocketLogic();
  drawRocket();
}

void rocketLogic() {
  // Gravity calculation
  PVector movementVector = PVector.sub(gravityOrigin, rPos).normalize();
  movementVector.mult(gravityMultiplier * 0.003);

  // Thruster calculation
  if (up) {
    movementVector.add(new PVector(0, -rThrForce).rotate(rAng));
  }

  rVel.add(movementVector);
  rPos.add(rVel);
  
  // Rotation  
  if (left && right) {
  } else if (left) {
    rAngVel -= rAngForce;
    if (rAngVel < -1) rAngVel = -1;
  } else if (right) {
    rAngVel += rAngForce;
    if (rAngVel > 1) rAngVel = 1;
  }
  rAng += rAngVel;

  // Collision
  float closestDist = Float.MAX_VALUE;
  PVector closestCord = new PVector(0, 0);
  PVector closestCordLocal = new PVector(0, 0);
  PVector[] collisionPoints = new PVector[] {
    new PVector(-15, 40),
    new PVector(15, 40),
    new PVector(0, -25),
  };

  for (PVector point : collisionPoints) {
    PVector globalPos = localToWorld(point);
    PVector distanceVec = PVector.sub(globalPos, gravityOrigin);
    float distance = distanceVec.mag();

    if (distance < closestDist) {
      closestDist = distance;
      closestCord = globalPos;
      closestCordLocal = point;
    }
  }

  if (closestDist < pSize) {
    PVector normal = PVector.sub(closestCord, gravityOrigin).normalize();
    float penetrationDistance = pSize - closestDist;

    rPos.add(PVector.mult(normal, penetrationDistance));

    // Recalculate contact point after moving the rocket
    closestCord = localToWorld(closestCordLocal);
    PVector contactOffset = PVector.sub(closestCord, rPos);

    PVector angularVelocity = new PVector(
      -rAngVel * contactOffset.y,
      rAngVel * contactOffset.x
    ); // v = ω * r

    PVector contactVelocity = rVel.copy();
    contactVelocity.add(angularVelocity);
    
    PVector planetOffset = PVector.sub(closestCord, gravityOrigin);

    PVector surfaceVelocity = new PVector(
      -pRotationSpeed * planetOffset.y,
      pRotationSpeed * planetOffset.x
    ); // Velocity from planet surface

    PVector relativeVelocity = PVector.sub(contactVelocity, surfaceVelocity);
    float normalVelocity = relativeVelocity.dot(normal); // Velocity into surface
    
    // ---------------------------------------------------------------------------- I don't really understandthe math here, I followed a explanation on how physics calculations work from ChatGPT (I still applied it myself)
    float torque = contactOffset.x * normal.y - contactOffset.y * normal.x;
    float impulseDenominator = inverseMass + (torque * torque) * inverseInertia;
    float impulseMagnitude = 0;

    if (normalVelocity < 0) {
      impulseMagnitude = -(1 + restitution) * normalVelocity / impulseDenominator;
    }
    // ----------------------------------------------------------------------------

    PVector impulse = normal.copy().mult(impulseMagnitude);

    rVel.add(PVector.mult(impulse, inverseMass));
    
    float angularImpulse =
      contactOffset.x * impulse.y -
      contactOffset.y * impulse.x;

    rAngVel += angularImpulse * inverseInertia;
    
    // Friction
    PVector tangent = new PVector(-normal.y, normal.x); // Vector going to the sie of the surface

    // Recalculate contact velocity after collision impulse
    angularVelocity = new PVector(
      -rAngVel * contactOffset.y,
      rAngVel * contactOffset.x
    );

    contactVelocity = rVel.copy();
    contactVelocity.add(angularVelocity);

    relativeVelocity = PVector.sub(contactVelocity, surfaceVelocity);

    float tangentVelocity = relativeVelocity.dot(tangent);
    
    float frictionTorque =
      contactOffset.x * tangent.y -
      contactOffset.y * tangent.x;
    
    float frictionDenominator =
      inverseMass + (frictionTorque * frictionTorque) * inverseInertia;
    
    float frictionMagnitude = -tangentVelocity / frictionDenominator;
    
    // Coulomb friction
    float normalImpulse = max(
      abs(impulseMagnitude),
      abs(movementVector.dot(normal)) * mass
    );
    
    float maxFriction = normalImpulse * friction;
    
    frictionMagnitude = constrain(
      frictionMagnitude,
      -maxFriction,
      maxFriction
    );

    PVector frictionImpulse = tangent.copy().mult(frictionMagnitude);

    rVel.add(PVector.mult(frictionImpulse, inverseMass));

    float frictionAngularImpulse =
      contactOffset.x * frictionImpulse.y -
      contactOffset.y * frictionImpulse.x;

    rAngVel += frictionAngularImpulse * inverseInertia;
  }
}

void drawRocket() {
  pushMatrix();
  translate(rPos.x, rPos.y);
  rotate(rAng);

  // --------------------- Legs
  stroke(255);
  strokeWeight(2);
  line(-3, 20, -15, 40);
  line(3, 20, 15, 40);
  stroke(200);
  line(20, 40, 15, 40);
  line(-20, 40, -15, 40);

  // --------------------- Flame
  if (up) {
    strokeWeight(0);
    fill(66, 123, 245);
    ellipse(0, 30, 5, 40);
    fill(235, 239, 247);
    ellipse(0, 25, 3, 30);
  }

  // --------------------- Body
  stroke(255);
  strokeWeight(5);
  fill(255);
  rect(-2, -25, 4, 50);

  // --------------------- Tip
  stroke(200);
  fill(200);
  strokeWeight(5);
  rect(-3, -25, 6, 10);

  // -------------------- Draw
  popMatrix();
}

void drawPlanet() {
  pushMatrix();
  translate(gravityOrigin.x, gravityOrigin.y);
  rotate(pRotation);

  // -------------------- Surface
  fill(224, 151, 67);
  stroke(0);
  ellipse(0, 0, pSize * 2, pSize * 2);

  // -------------------- Crater
  fill(133, 100, 62);
  stroke(133, 100, 62);
  ellipse(-70, -20, 18, 18);
  ellipse(-35, -68, 22, 22);
  ellipse(52, -55, 24, 24);
  ellipse(76, -15, 14, 14);
  ellipse(55, 22, 20, 20);
  ellipse(25, 58, 18, 18);
  ellipse(-82, 5, 12, 12);
  ellipse(-45, 5, 20, 20);
  ellipse(35, -20, 18, 18);
  ellipse(5, 25, 22, 22);

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

PVector localToWorld(PVector local) { // translates local rocket coordinates to global coordinates
  PVector rotated = local.copy().rotate(rAng); // applies angle
  rotated.add(rPos); // applying position
  return rotated;
}
