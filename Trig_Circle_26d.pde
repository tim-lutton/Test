import controlP5.*; // Imports controlP5 librabry 

ControlP5 gui; // Declares class 'gui' 

// ----- Varibables controlling program flow -----
int frameNumber = 0; // The frame number 
boolean run = false; // Boolean switch to runs main functions when the "Create" button is pressed 
int numTris = 50; // Maximum number of triangles that can be drawn at any time

// ----- Variables controlling the PGraphics window -----
PGraphics drawingCanvas; // Declares PGraphics buffer where shapes are drawn
int drawingCanvasWidth = 600; // Width of drawingCanvas
int drawingCanvasHeight = 600; // Height of drawingCanvas
float offX, offY; // Variables to allow the PGraphics window to be drawn at the centre of the screen 

// ----- Variables for setting up each circle -----
float radius = 100; // Radius of circle that defines where each triangle is drawn
float diameter = radius*2; 
float maxChordDist = diameter; // Used to ensure that the side length of a triangle is never the same as the diameter
int numPoints = 20; // Number of points on the circle 
float minDist; // Used to ensure that the side length of a triangle is never the any less that this
float nextCentreX = 0; // Variable to store the next position of circle centre
float nextCentreY = 0; // Variable to store the next position of circle centre

// ----- Arrays to store points on the circle -----
float[] xPointOnCircle = new float[numPoints]; // Array to hold all x points of a circle 
float[] yPointOnCircle = new float[numPoints]; // Array to hold all y points of a circle 

// ----- Selecting three points on the circle -----
int r, circleIndex1, circleIndex2, circleIndex3; // Hold values from 0 - 20 used as the index values for "pointOnCircle" arrays
int[] pointOnCircleIndex = new int[3]; // Stores the values of the above "circleIndex" variables in their own array

// ----- The points of each triangle -----
float xP1, yP1, xP2, yP2, xP3, yP3; // Points of the triangle

float chordX1, chordY1; // First point of chord on triangle which helps define the next centre
float chordX2, chordY2; // Second point of chord on triangle which helps define the next centre

float[] xTriPointArray = new float[3]; // Stores the x points of the triangle
float[] yTriPointArray = new float[3]; // Stores the y points of the triangle
int pointIndex1, pointIndex2; // Integers used to access the TriPointArrays

// ----- Checking for max/min values -----
float currentMinX, currentMaxX, currentMinY, currentMaxY; // Variables to assess the current max/min values
int buffer = 300; // Variable that stops triangles from being drawn if they exceed the drawing area of the PGraphics window

// ----- Color Variables -----
int hue1; // Hue of the triangles
int maxSat; // Maximum saturation value
int minSat; // Minimum saturation value
int maxBri; // Maximum brightness value
int minBri; // Minimum brightness value
color color1; // Resulting color from the above parameters

// ----- Variables involved in image export -----
int imageNo; // Adds the image number when an image is saved

void setup() {

  size(700, 700); // Size of window
  pixelDensity(2); // Creates a high resolution screen draw
  colorMode(HSB, 360, 100, 100); // Changes the color mode
  background(200);

  // Initialises PGraphics buffer
  drawingCanvas = createGraphics(drawingCanvasWidth, drawingCanvasHeight);

  // Defining all elements used in the GUI
  gui = new ControlP5(this);
  gui.addButton("Create")
    .setValue(0)
    .setPosition(10, 10)
    .setSize(100, 50);

  gui.addButton("Save")
    .setValue(0)
    .setPosition(width-110, 10)
    .setSize(100, 50);

  gui.addSlider("numTris")
    .setPosition(10, 100)
    .setRange(0, 100)
    .setValue(50);

  gui.addSlider("radius")
    .setPosition(10, 150)
    .setRange(10, 100)
    .setValue(50);

  gui.addSlider("hue1")
    .setPosition(10, 200)
    .setRange(0, 360)
    .setValue(180);

  gui.addSlider("minSat")
    .setPosition(10, 250)
    .setRange(0, 100)
    .setValue(54);

  gui.addSlider("maxSat")
    .setPosition(10, 300)
    .setRange(0, 100)
    .setValue(100);

  gui.addSlider("minBri")
    .setPosition(10, 350)
    .setRange(0, 100)
    .setValue(70);

  gui.addSlider("maxBri")
    .setPosition(10, 400)
    .setRange(0, 100)
    .setValue(100);
}


void draw() {

  // Increases frame number
  frameNumber = frameNumber + 1;

  // If statement will only run when the "Create" button is pressed
  if (run==true) {

    // Clears PGraphics window and resets variables 
    resetProgram();

    // Loop is responsible for drawing a certain number of triangles into the PGraphics window
    // numTris will change depending on the value of the slider
    for (int i = 0; i <= numTris; i++) {
      // Calculates the location of next circle and its points
      circleDraw();
      // Calculates location of next triangle points on the above circle
      trianglePointCalculation();
      // Tests to check that the triangle doesn't leave the PGraphics window
      maxMinCalculation();
      // When the triangle is in the PGraphics window, it is drawn
      if ( currentMaxX <= buffer && currentMinX >= -1*buffer && currentMaxY <= buffer && currentMinY >= -1*buffer) {
        // Picks the random colors for the triangle based on the users input 
        colorSelection();
        // Draws the triangle to the PGraphics window
        triangleDraw();
        // The centre of the circle is calculated 
        nextCircleCentre();

        // When the triangle is outside the graphics window, the triangle is not drawn and the loop exits
      } else {
        // Statement exits the loop
        run =! run;
      }
    }
    // Statement exits the loop
    run = !run;
  }

  //Draw the PGraphic buffer to the centre of the screen
  offX = width/2; 
  offY = height/2;
  imageMode(CENTER);
  image(drawingCanvas, offX, offY);

  // Draw a circle that updates with the color of the hue next to the hue slider
  fill(hue1, 100, 100);
  ellipse(150, 205, 15, 15);
}


// Function for controlP5 button "Create"
public void Create() {
  // Controls whether the function to draw the triangles to the screen is run or stopped
  run = !run;
}

// Function for controlP5 button "Save"
public void Save() {
  // Saves image in the PGraphics buffer into sketch folder
  drawingCanvas.save("TessellateSavedImage" + imageNo +".png");
  imageNo = imageNo + 1;
}

// Function to reset the program so a new graphic can be drawn
void resetProgram() {
  // Clear the drawingCanvas
  drawingCanvas.beginDraw();
  drawingCanvas.background(200);
  drawingCanvas.endDraw();

  // Reset all the variables 
  nextCentreX = 0;
  nextCentreY = 0;
  currentMinX = 0;
  currentMaxX = 0;
  currentMinY = 0;
  currentMaxY = 0;
}

// Function to calculate the circle coordinate system
void circleDraw() {

  float angleOff = TWO_PI/numPoints; // Angle between each point on the circle
  float angle = 0; // Starting value for angle calculations to take place
  float circlePointsX, circlePointsY; // Positions on the circle's circumference

  // Calculate points around cirle with a centre at (nextCentreX, nextCentreY) and store them in array "xPointOnCircle" and array "yPointOnCircle"
  for (int i = 0; i <= numPoints - 1; i = i+1) {

    // Calculate the x position of each point on the circle's circumference
    circlePointsX = nextCentreX + radius * cos(angle);
    // Store the point in array
    xPointOnCircle[i] = circlePointsX;
    // Calculate the y position of each point on the circle's circumference
    circlePointsY =  nextCentreY + radius * sin(angle);
    // Store the point in array
    yPointOnCircle[i] = circlePointsY;
    // Increment the angle to ensure the points are at a different location each time through the loop
    angle += angleOff;
  }
}

// Calculate the points which make up the triangle
void trianglePointCalculation() {

  float chordLength1; // The first chord length of the circle (i.e. the distance between the first two points on the triangle
  float chordLength2; // The second chord length of the circle
  float chordLength3; // The third chord length of the circle


  // ----- Calculates the first two points of the triangle -----

  // Calculate minimum chord length 
  minDist = dist(xPointOnCircle[0], yPointOnCircle[0], xPointOnCircle[3], yPointOnCircle[3]);

  if (frameNumber == 1) {
    // Calculation of first two random values 
    // The random values are used as the indexes to access the arrays containing the coordinates of the points on the circle
    // The random values generated are stored in the array 'pointOnCircleIndex' 

    r = 0; // Variable 'r' steps through the indexes of the array

    // Picks a random value to correspond with a point on the circle - this will become the first point of the triangle
    circleIndex1 = int(random(0, numPoints));  
    // Stores the random value in pointOnCircleIndex
    pointOnCircleIndex[r]=circleIndex1; 

    // Increment 'r' to move along pointOnCircleIndex
    r = r+1; 

    // Picks a random value to correspond with a point on the circle - this will become the second point of the triangle
    circleIndex2 = int(random(0, numPoints)); 
    // Calculates the distance between the first point that was picked and the second point that was picked
    // Note that the actual coordinates are gained by accessing the PointOnCircle arrays with the randomly picked index value
    chordLength1 = dist(xPointOnCircle[circleIndex1], yPointOnCircle[circleIndex1], xPointOnCircle[circleIndex2], yPointOnCircle[circleIndex2]);

    // While statement prevents the value of circleIndex2 from equaling circleIndex1
    // While statement also ensures point selected by circleIndex2 is a minimum distance from circleIndex1
    // While statement also prevents the points being draw create a chord the length of the diameter
    while (chordLength1 <= minDist || chordLength1 >= maxChordDist) { 
      // A new random value is picked if the minimum and maximum distance requirements are not met
      circleIndex2 = int(random(0, numPoints)); 
      // Re-calculates the distance between the first point that was picked and the second point that was picked 
      chordLength1 = dist(xPointOnCircle[circleIndex1], yPointOnCircle[circleIndex1], xPointOnCircle[circleIndex2], yPointOnCircle[circleIndex2]);
    }

    pointOnCircleIndex[r] = circleIndex2; // Stores the random value in pointOnCircleIndex

    // Converts the first two points of the circle from being held in the arrays to being held by a variable for easier access later
    xP1 = xPointOnCircle[circleIndex1]; 
    yP1 = yPointOnCircle[circleIndex1];
    xP2 = xPointOnCircle[circleIndex2];
    yP2 = yPointOnCircle[circleIndex2];

    // If the code has been run more than once there will already be a triangle that exists
    // Therefore the first two values of the next triangle will also exist
    // This statement defines these points
  } else if (frameNumber > 1) {
    r = 0;
    xP1 = chordX1; 
    yP1 = chordY1; 
    xP2 = chordX2; 
    yP2 = chordY2; 

    // Resets the values in the pointOnCircleIndex array
    pointOnCircleIndex[r] = 0;
    r = r+1;
    pointOnCircleIndex[r] = 1;
  }

  r = r+1; // Increment 'r' to move along pointOnCircleIndex

  // ----- Calculates the third point of the triangle -----

  // Picks a random value to correspond with a point on the circle - this will become the third point of the triangle 
  circleIndex3 = int(random(0, numPoints));
  // Calculates the second chord length (i.e. the length of the triangle's second side)
  chordLength2 = dist(xP2, yP2, xPointOnCircle[circleIndex3], yPointOnCircle[circleIndex3]);
  // Calculates the third chord length (i.e. the length of the triangle's third side)
  chordLength3 = dist(xPointOnCircle[circleIndex3], yPointOnCircle[circleIndex3], xP1, yP1);

  // While statement prevents the value of circleIndex3 from equaling circleIndex2 or circleIndex1
  // While statement also ensures point selected by circleIndex3 is a minimum distance from circleIndex2 and circleIndex1
  while (chordLength2 <= minDist || chordLength3 <= minDist) {
    // A new random value is picked if the minimum distance requirement is not met
    circleIndex3 = int(random(0, numPoints)); 
    // Re-calculates the second chord length (i.e. the length of the triangle's second side)
    chordLength2 = dist(xP2, yP2, xPointOnCircle[circleIndex3], yPointOnCircle[circleIndex3]);
    // Re-calculates the third chord length (i.e. the length of the triangle's third side)
    chordLength3 = dist(xPointOnCircle[circleIndex3], yPointOnCircle[circleIndex3], xP1, yP1);
  }

  // Stores the random value in pointOnCircleIndex 
  pointOnCircleIndex[r]=circleIndex3;

  // Converts the third point of the circle from being held in the arrays to being held by a variable for easier access later
  xP3 = xPointOnCircle[circleIndex3];
  yP3 = yPointOnCircle[circleIndex3];

  // ----- Put all the triangle point values into their own array -----
  xTriPointArray[0] = xP1;
  yTriPointArray[0] = yP1;
  xTriPointArray[1] = xP2;
  yTriPointArray[1] = yP2;
  xTriPointArray[2] = xP3;
  yTriPointArray[2] = yP3;
}

void maxMinCalculation() {

  // Finds the max and min values in the arrays that store the points of the triangle
  currentMaxX = max(xTriPointArray);
  currentMinX= min(xTriPointArray);

  currentMaxY = max(yTriPointArray);
  currentMinY= min(yTriPointArray);
}

// Function to define the color of the shapes draw to the PGraphics window
void colorSelection() {
  // User sets hue, and max/min brightness and saturation values
  // A random brightness and random saturation value are then picked from this range
  color1 = color(hue1, random(minSat, maxSat), random(minBri, maxBri));
}

// Function to draw the triangle to the PGraphics window
void triangleDraw() {
  // Draws the triangle based on the the points and color defined earlier 
  drawingCanvas.beginDraw();
  drawingCanvas.translate(drawingCanvasWidth/2, drawingCanvasHeight/2);
  drawingCanvas.noStroke();
  drawingCanvas.fill(color1);
  drawingCanvas.beginShape();
  drawingCanvas.vertex(xP1, yP1);
  drawingCanvas.vertex(xP2, yP2); 
  drawingCanvas.vertex(xP3, yP3); 
  drawingCanvas.endShape(CLOSE);
  drawingCanvas.endDraw();
}

// Function to calculate where the next circle will be drawn 
// The next circle defines the next set of the coordinates with which the next trinagle can be drawn 
// For this to be possible we need to find an angle and a distance 
void nextCircleCentre() {
  PVector a = new PVector(1, 0); // PVector 'a' represents a stationary point which has a y value of 0 and an x value of 1 (it is meant to represent the x axis)
  PVector b = new PVector(-1, 0); // PVector 'b' represents a point that will move  
  float angleGenerated; // The value of the angle between point a and point b (this will always be obtuse)
  float angleAcute; // The equivalent value of the angleGenerated expressed as an acute angle from the x axis 


  // Creates two random values to index the "TriPointArrays"
  pointIndex1 = int(random(0, 3));
  pointIndex2 = int(random(0, 3));

  // Pick a chord that isn't the one that was drawn first
  // Because the values of the triangle points are stored in chronological order within the "TriPointArrays" we know that the first two points are stored at index numbers 0 and 1
  // Because these points have already been used to define a circle, we must ensure that they are picked in combination of each other
  while (pointIndex1 == pointIndex2 || pointIndex1 == 0 && pointIndex2 == 1 || pointIndex1 == 1 && pointIndex2 == 0) {
    // Re defines the pointIndex values
    pointIndex1 = int(random(0, 3));
    pointIndex2 = int(random(0, 3));
  }

  // Store data from array into a variable for easier use
  chordX1 = xTriPointArray[pointIndex1];
  chordY1 = yTriPointArray[pointIndex1];
  chordX2 = xTriPointArray[pointIndex2];
  chordY2 = yTriPointArray[pointIndex2];

  // Calculate the midpoint of the chord
  float chordMidPointX = lerp(chordX1, chordX2, 0.5); // Midpoint of chord x coordinate
  float chordMidPointY = lerp(chordY1, chordY2, 0.5); // Midpoint of chord y coordinate

  // Calculate the distance from the midpoint to the centre of the current circle
  // The centre of the current circle is stores as the nextcentre from the previous calculation
  float chordDistCentre = dist(chordMidPointX, chordMidPointY, nextCentreX, nextCentreY);

  // Calculate angle between (chordMidPointX, chordMidPointY) and the centre of the current circle
  // Change PVector b to location on midpoint of chord
  b.set(chordMidPointX, chordMidPointY); 
  // Calculate the angle btw the new location of PVector 'b' and PVector 'a' (which is at 0 degrees)
  angleGenerated = PVector.angleBetween(a, b); 

  // Double chordDistCentre to find the distance from the current centre that the next centre will be at
  float distBetweenCircleCentres = 2*chordDistCentre;

  // Series of 'if' statements ensure calculated angle is always expressed as an acute angle with reference to the x axis
  if ( b.x >= 0 && b.y <= 0) {
    angleAcute = angleGenerated;
    nextCentreX = distBetweenCircleCentres*cos(angleAcute);
    nextCentreY = -1*(distBetweenCircleCentres*sin(angleAcute));
  } else if (b.x <= 0 && b.y <= 0) {
    angleAcute = PI - angleGenerated;
    nextCentreX = -1*(distBetweenCircleCentres*cos(angleAcute));
    nextCentreY = -1*(distBetweenCircleCentres*sin(angleAcute));
  } else if (b.x <= 0 && b.y >= 0) {
    angleAcute = PI - angleGenerated;
    nextCentreX = -1*(distBetweenCircleCentres*cos(angleAcute));
    nextCentreY = distBetweenCircleCentres*sin(angleAcute);
  } else if (b.x >= 0 && b.y >= 0) {
    angleAcute = angleGenerated;
    nextCentreX = distBetweenCircleCentres*cos(angleAcute);
    nextCentreY = distBetweenCircleCentres*sin(angleAcute);
  }
}
