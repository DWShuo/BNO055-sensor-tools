#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

int BNO055_SAMPLERATE_DELAY_MS = 250;

Adafruit_BNO055 bno = Adafruit_BNO055(55);

void setup(void){
  Serial.begin(115200);
  //Serial.println("Orientation Sensor Test"); Serial.println("");

  /* Initialise the sensor */
  if (!bno.begin()){
    Serial.print("BNO055 not detected");
    while (1);
  }
}

void loop(void){
  //VECTOR_ACCELEROMETER, VECTOR_MAGNETOMETER, VECTOR_GYROSCOPE 
  //VECTOR_EULER, VECTOR_LINEARACCEL, VECTOR_GRAVITY
  sensors_event_t ACC, EUL, LIN, GRA, GYR, MAG;
 // bno.getEvent(&ACC, Adafruit_BNO055::VECTOR_ACCELEROMETER);
//  bno.getEvent(&EUL, Adafruit_BNO055::VECTOR_EULER);
    bno.getEvent(&LIN, Adafruit_BNO055::VECTOR_LINEARACCEL);
//  bno.getEvent(&GRA, Adafruit_BNO055::VECTOR_GRAVITY);
//  bno.getEvent(&GYR, Adafruit_BNO055::VECTOR_GYROSCOPE);
//  bno.getEvent(&MAG, Adafruit_BNO055::VECTOR_MAGNETOMETER);
  
  //printEvent(&ACC, "ACC");
//  printEvent(&EUL, "EUL");
    printEvent(&LIN, "LIN");
//  printEvent(&GRA, "GRA");
//  printEvent(&GYR, "GYR");
//  printEvent(&MAG, "MAG");
  
    delay(BNO055_SAMPLERATE_DELAY_MS);
}

void printEvent(sensors_event_t* event, const char type[]) {
  double x = -1000000, y = -1000000 , z = -1000000; //dumb values, easy to spot problem
  //Serial.print("| ");
  if (event->type == SENSOR_TYPE_ORIENTATION) {
    Serial.print(type);
    x = event->orientation.x;
    y = event->orientation.y;
    z = event->orientation.z;
  }
  else if (event->type == SENSOR_TYPE_ACCELEROMETER) {
    Serial.print(type);
    x = event->acceleration.x;
    y = event->acceleration.y;
    z = event->acceleration.z;
  }
  else if (event->type == SENSOR_TYPE_MAGNETIC_FIELD) {
    Serial.print(type);
    x = event->magnetic.x;
    y = event->magnetic.y;
    z = event->magnetic.z;
  }
  else if ((event->type == SENSOR_TYPE_GYROSCOPE) || (event->type == SENSOR_TYPE_ROTATION_VECTOR)) {
    Serial.print(type);
    x = event->gyro.x;
    y = event->gyro.y;
    z = event->gyro.z;
  }
  Serial.print("| x= ");
  Serial.print(x);
  Serial.print(" | y= ");
  Serial.print(y);
  Serial.print(" | z= ");
  Serial.println(z);
}
