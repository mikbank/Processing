import peasy.*;

// Variable setup
float r = 200; //Sphere size
float xRotation ; // rotation variable
float xRVel = 0.001; // velocity of rotation
Table table; // table for storing loaded .csv data
PImage earth; //variable for storing texture for the sphere
PShape globe; //variable for storing the sphere shape
//Constant x axis vector
static final PVector X_AXIS = new PVector(1, 0, 0);

PeasyCam cam;

void setup () {
  size (600, 600, P3D);
  earth = loadImage("Earth.jpg");
  table = loadTable("C:/Users/mikh/Desktop/InputforGlobe.csv", "header");
  noStroke();
  globe = createShape(SPHERE, r);
  globe.setTexture(earth);
  cam = new PeasyCam(this, 600);
}

// draw the basic scene, set rotation and load coordinates.
void draw() {
 
   // Create the sphere
  background (51);
  //translate (width/2, height/2);
  rotateY(xRotation);
  xRotation += xRVel;
  lights();
  fill(200);

  //sphere(r);
  shape(globe);
// ----------------------------------------------

  
  //function to load coordinate table
  for (TableRow row : table.rows()) {
  
   PVector latlong = new PVector(row.getFloat("latitude"), row.getFloat("longitude"));
    drawPlace(latlong, 60, (float) 10); //<>//
    
  }
  
 
}

// compute cartesian coordinates to sphere coordinates and place markers on sphere
  void drawPlace(PVector latlong, color col, float boxHeight) {

    //Convert latitude and longitude into radians
    float lat = radians(latlong.x);
    float lon = radians(latlong.y);

    //offset altitude by half the intended box height so it's drawn right on Earth's surface
    // (boxes will "grow" from their center)
    float alt = r + boxHeight / 2;

    //Direct geographic to cartesian coordinates transform 
    // https://vvvv.org/blog/polar-spherical-and-geographic-coordinates#geographic-coordinates
    float cx = alt * cos(lat) * cos(lon);
    float cy = alt * cos(lat) * sin(lon);
    float cz = alt * sin(lat);

    //Fix computer graphics axis not inline with typical cartesian system => gx = cx, gy = -cz, gz = -cy 
    // plus on Nasa texture, [0°, 0°] at center instead of middle-left <=> rotated 180° around gy => x = -gx, y = gy, z = -gz
    // so x = -cx, y = -cz, z = cy
    float x = -cx, y = -cz, z = cy;

    //Compute box rotation angle and axis from x unit vector 
    // (box will be stretched along x axis, then rotated accordingly)
    PVector dir = new PVector(x, y, z);
    float xAngle = PVector.angleBetween(X_AXIS, dir);
    PVector rotAxis = X_AXIS.cross(dir); //Rotation axis obtained by cross-product

  //Apply transforms, draw box and revert
  pushMatrix();
  translate(x, y, z);
  rotate(xAngle, rotAxis.x, rotAxis.y, rotAxis.z);
  fill(col, 128);
  box(boxHeight, 10, 10);
  popMatrix();
}
//----------------------------------------------------------------------
