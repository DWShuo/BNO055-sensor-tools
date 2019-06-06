import peasy.*;
PeasyCam cam;
import processing.serial.*;

Serial  myPort;
String  port = "/dev/ttyUSB0";
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication

ArrayList<Float> var_x = new ArrayList<Float>();
ArrayList<Float> var_y = new ArrayList<Float>();
ArrayList<Float> var_z = new ArrayList<Float>();

float x_axis, y_axis, z_axis;

int timerStart;
int resetTimer = 20000;

void setup (){
  println(" Connecting to -> " + "ttyUSB0");
  myPort = new Serial(this, port, 115200);
  myPort.clear();
  myPort.bufferUntil(lf);
  
  size(100, 100, P3D);
  cam = new PeasyCam(this, 512);
  cam.setFreeRotationMode();
  x_axis = width/2;
  y_axis = -height/2;
  z_axis = height/2;
  
  delay(1000);
  timerStart = millis();
}

void draw(){
  if( resetTimer > timerStart){
    var_x.clear();
    var_y.clear();
    var_z.clear();
    timerStart = millis();
  }
  
  background(128);
  axis();

  for (int i = 0; i < var_x.size(); i++){
    pushMatrix();
    translate(var_x.get(i), var_y.get(i), var_z.get(i));
    stroke(mapColor(var_x.get(i), var_y.get(i), var_z.get(i)));
    //stroke(color(random(255), random(255), random(255)));
    sphere(1);   
    popMatrix();
  }
}

color mapColor(float _x, float _y, float _z){
  int r = int(map(_x, 0, x_axis, 0, 255));
  int g = int(map(_y, 0, y_axis, 0, 255));
  int b = int(map(_z, 0, z_axis, 0, 255));
  return color(r, g, b);
}

void axis(){
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, x_axis, 0, 0);
  text("X axis", x_axis +1 , 0, 0);
  
  stroke(0, 255, 0);
  line(0, 0, 0, 0, y_axis, 0);
  text("Y axis", 0, y_axis+1, 0);
  
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, z_axis);
  text("Z axis", 0, 0, z_axis+1);
}

void serialEvent(Serial p) {
  inString = (myPort.readString());
  //get rid of empty lines
  if (inString.equals("") || inString.equals("\n")){
    return;
  }
  
  try {
    print(inString);
    // Parse the data
    String[] dataStrings = split(inString, '|');
    //println(dataStrings[0]);
    //println(dataStrings[1]);
    //println(dataStrings[2]);
    //println(dataStrings[3]);
    String dataType = dataStrings[0];
    if (dataType.equals("LIN")){
      var_x.add(float(split(dataStrings[1],'=')[1]));
      var_y.add(float(split(dataStrings[2],'=')[1]));
      var_z.add(float(split(dataStrings[3],'=')[1]));
    }
  } catch (Exception e) {
      println("Caught Exception");
  }
}
