// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import java.util.Arrays;
import controlP5.*;
import processing.serial.*;

/*====================== SETTINGS BEGIN ======================*/
// Serial port to connect to
String serialPortName = "/dev/ttyUSB0";
// If you want to debug the plotter without using a real serial port set this to true
/*====================== SETTINGS END =======================*/

/*====================== Init data structs ==================*/
Serial serialPort; // Serial port object
// interface stuff
ControlP5 cp5;
// Settings for the plotter are saved in this file
JSONObject plotterConfigJSON;
// helper for saving the executing path
String topSketchPath = "";
int  lf = 10;       //ASCII linefeed

// plots
Graph xLineGraph = new Graph(225, 70, 600, 200, color(20, 20, 200));
Graph yLineGraph = new Graph(225, 380, 600, 200, color (20, 20, 200));
Graph zLineGraph = new Graph(225, 690, 600, 200, color (20, 20, 200));

float[][] xlineGraphValues = new float[6][100];
float[][] ylineGraphValues = new float[6][100];
float[][] zlineGraphValues = new float[6][100];
float[] lineGraphSampleNumbers = new float[100];
color[] graphColors = new color[6];

float x_acc, y_acc, z_acc;
/*====================== Init data structs ==================*/

void setup() {
  surface.setTitle("Data plotter");
  size(890, 950);
  // settings save file
  topSketchPath = sketchPath();
  plotterConfigJSON = loadJSONObject(topSketchPath+"/plotter_config.json");
  // gui
  cp5 = new ControlP5(this);

  // set line graph colors
  graphColors[0] = color(131, 255, 20);
  graphColors[1] = color(232, 158, 12);
  graphColors[2] = color(255, 0, 0);
  graphColors[3] = color(62, 12, 232);
  graphColors[4] = color(13, 255, 243);
  graphColors[5] = color(200, 46, 232);
  
  // init charts
  for (int i=0; i<xlineGraphValues.length; i++) {
    for (int k=0; k<xlineGraphValues[0].length; k++) {
      xlineGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  }
  for (int i=0; i<ylineGraphValues.length; i++) {
    for (int k=0; k<ylineGraphValues[0].length; k++) {
      ylineGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  }
  for (int i=0; i<zlineGraphValues.length; i++) {
    for (int k=0; k<zlineGraphValues[0].length; k++) {
      zlineGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  }
  
  // start serial communication
  serialPort = new Serial(this, serialPortName, 115200);
  serialPort.clear();
  serialPort.bufferUntil(lf);

  // build the gui
  int x = 170;
  int y = 60;
  cp5.addTextfield("xAxisMinY").setPosition(x, y).setText(getPlotterConfigString("xAxisMinY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xAxisMaxY").setPosition(x, y=y+195).setText(getPlotterConfigString("xAxisMaxY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yAxisMinY").setPosition(x, y=y+115).setText(getPlotterConfigString("yAxisMinY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yAxisMaxY").setPosition(x, y=y+195).setText(getPlotterConfigString("yAxisMaxY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zAxisMinY").setPosition(x, y=y+115).setText(getPlotterConfigString("zAxisMinY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zAxisMaxY").setPosition(x, y=y+195).setText(getPlotterConfigString("zAxisMaxY")).setWidth(40).setAutoClear(false);
  
  cp5.addTextlabel("on/off0").setText("on/off").setPosition(x=13, y=20).setColor(0);
  cp5.addTextlabel("xmultipliers").setText("xmultipliers").setPosition(x=55, y).setColor(0);
  cp5.addTextfield("xMultiplier1").setPosition(x=60, y=30).setText(getPlotterConfigString("xMultiplier1")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xMultiplier2").setPosition(x, y=y+40).setText(getPlotterConfigString("xMultiplier2")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xMultiplier3").setPosition(x, y=y+40).setText(getPlotterConfigString("xMultiplier3")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xMultiplier4").setPosition(x, y=y+40).setText(getPlotterConfigString("xMultiplier4")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xMultiplier5").setPosition(x, y=y+40).setText(getPlotterConfigString("xMultiplier5")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("xMultiplier6").setPosition(x, y=y+40).setText(getPlotterConfigString("xMultiplier6")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addToggle("xVisible1").setPosition(x=x-50, y=30).setValue(int(getPlotterConfigString("xVisible1"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[0]);
  cp5.addToggle("xVisible2").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("xVisible2"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[1]);
  cp5.addToggle("xVisible3").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("xVisible3"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[2]);
  cp5.addToggle("xVisible4").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("xVisible4"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[3]);
  cp5.addToggle("xVisible5").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("xVisible5"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[4]);
  cp5.addToggle("xVisible6").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("xVisible6"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[5]);

  cp5.addTextlabel("on/off1").setText("on/off").setPosition(x=13, y=y+100).setColor(0);
  cp5.addTextlabel("ymultipliers").setText("ymultipliers").setPosition(x=55, y).setColor(0);
  cp5.addTextfield("yMultiplier1").setPosition(x=60, y=y+10).setText(getPlotterConfigString("yMultiplier1")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yMultiplier2").setPosition(x, y=y+40).setText(getPlotterConfigString("yMultiplier2")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yMultiplier3").setPosition(x, y=y+40).setText(getPlotterConfigString("yMultiplier3")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yMultiplier4").setPosition(x, y=y+40).setText(getPlotterConfigString("yMultiplier4")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yMultiplier5").setPosition(x, y=y+40).setText(getPlotterConfigString("yMultiplier5")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("yMultiplier6").setPosition(x, y=y+40).setText(getPlotterConfigString("yMultiplier6")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addToggle("yVisible1").setPosition(x=x-50, y=340).setValue(int(getPlotterConfigString("yVisible1"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[0]);
  cp5.addToggle("yVisible2").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("yVisible2"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[1]);
  cp5.addToggle("yVisible3").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("yVisible3"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[2]);
  cp5.addToggle("yVisible4").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("yVisible4"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[3]);
  cp5.addToggle("yVisible5").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("yVisible5"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[4]);
  cp5.addToggle("yVisible6").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("yVisible6"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[5]);
  
  cp5.addTextlabel("on/off2").setText("on/off").setPosition(x=13, y=y+100).setColor(0);
  cp5.addTextlabel("zmultipliers").setText("zmultipliers").setPosition(x=55, y).setColor(0);
  cp5.addTextfield("zMultiplier1").setPosition(x=60, y=y+10).setText(getPlotterConfigString("zMultiplier1")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zMultiplier2").setPosition(x, y=y+40).setText(getPlotterConfigString("zMultiplier2")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zMultiplier3").setPosition(x, y=y+40).setText(getPlotterConfigString("zMultiplier3")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zMultiplier4").setPosition(x, y=y+40).setText(getPlotterConfigString("zMultiplier4")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zMultiplier5").setPosition(x, y=y+40).setText(getPlotterConfigString("zMultiplier5")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("zMultiplier6").setPosition(x, y=y+40).setText(getPlotterConfigString("zMultiplier6")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  
  cp5.addToggle("zVisible1").setPosition(x=x-50, y=650).setValue(int(getPlotterConfigString("zVisible1"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[0]);
  cp5.addToggle("zVisible2").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("zVisible2"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[1]);
  cp5.addToggle("zVisible3").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("zVisible3"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[2]);
  cp5.addToggle("zVisible4").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("zVisible4"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[3]);
  cp5.addToggle("zVisible5").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("zVisible5"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[4]);
  cp5.addToggle("zVisible6").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("zVisible6"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[5]);
}

byte[] inBuffer = new byte[100]; // holds serial message
void draw() {
  //========================handle input======================================
  /* Read serial and update values */
  if (serialPort.available() > 0) {
    String inString = "";
    inString = (serialPort.readString());
    //get rid of empty lines
    if (inString.equals("") || inString.equals("\n")){ return; }
    try {
      print(inString);
      // Parse the data
      String[] dataStrings = split(inString, '|');
      String dataType = dataStrings[0];
      if (dataType.equals("LIN")){
        x_acc = float(split(dataStrings[1],'=')[1]);
        y_acc = float(split(dataStrings[2],'=')[1]);
        z_acc = float(split(dataStrings[3],'=')[1]);
      }
    } catch (Exception e) {
      println("Caught Exception");
    }
    
    // split the string at delimiter (space)
    Float[] xData = new Float[6];
    Float[] yData = new Float[6];
    Float[] zData = new Float[6]; 
    Arrays.fill(xData,x_acc);
    Arrays.fill(yData,y_acc);
    Arrays.fill(zData,z_acc);


  //========================handle input======================================
    
    // count number of bars and line graphs to hide
    int numberOfInvisibleLineGraphs = 0;
    for (int i=0; i<6; i++) {
      if (int(getPlotterConfigString("yVisible"+(i+1))) == 0) {
        numberOfInvisibleLineGraphs++;
      }
    }
    // build a new array to fit the data to show
    // update line graph
    for (int i=0; i<xData.length; i++) {
      try {
        if (i < xlineGraphValues.length) {
          for (int k=0; k<xlineGraphValues[i].length-1; k++) {
            xlineGraphValues[i][k] = xlineGraphValues[i][k+1];
          }
          xlineGraphValues[i][xlineGraphValues[i].length-1] = xData[i]*float(getPlotterConfigString("xMultiplier"+(i+1)));
        }
      } 
      catch (Exception e){}
    
      try {
        if (i < ylineGraphValues.length) {
          for (int k=0; k < ylineGraphValues[i].length-1; k++) {
            ylineGraphValues[i][k] = ylineGraphValues[i][k+1];
          }
          ylineGraphValues[i][ylineGraphValues[i].length-1] = yData[i]*float(getPlotterConfigString("yMultiplier"+(i+1)));
        }
      } 
      catch (Exception e){}
    
      try {
        if (i < zlineGraphValues.length) {
          for (int k=0; k < zlineGraphValues[i].length-1; k++) {
            zlineGraphValues[i][k] = zlineGraphValues[i][k+1];
          }

          zlineGraphValues[i][zlineGraphValues[i].length-1] = zData[i]*float(getPlotterConfigString("zMultiplier"+(i+1)));
        }
      }   
      catch (Exception e){}
    }
  }
  // draw the line graphs
  background(255); 
  xLineGraph.DrawAxis();
  for (int i=0;i<xlineGraphValues.length; i++) {
    xLineGraph.GraphColor = graphColors[i];
    if (int(getPlotterConfigString("xVisible"+(i+1))) == 1)
      xLineGraph.LineGraph(lineGraphSampleNumbers, xlineGraphValues[i]);
  }
  yLineGraph.DrawAxis();
  for (int i=0;i<ylineGraphValues.length; i++) {
    yLineGraph.GraphColor = graphColors[i];
    if (int(getPlotterConfigString("yVisible"+(i+1))) == 1)
      yLineGraph.LineGraph(lineGraphSampleNumbers, ylineGraphValues[i]);
  }
  zLineGraph.DrawAxis();
  for (int i=0;i<zlineGraphValues.length; i++) {
    zLineGraph.GraphColor = graphColors[i];
    if (int(getPlotterConfigString("zVisible"+(i+1))) == 1)
      zLineGraph.LineGraph(lineGraphSampleNumbers, zlineGraphValues[i]);
  }
}

// called each time the chart settings are changed by the user 
void setChartSettings() {
  xLineGraph.xLabel=" Samples ";
  xLineGraph.yLabel="X axis readings";
  xLineGraph.Title="";  
  xLineGraph.xDiv=20;  
  xLineGraph.xMax=0; 
  xLineGraph.xMin=-100;  
  xLineGraph.yMax=int(getPlotterConfigString("xAxisMinY")); 
  xLineGraph.yMin=int(getPlotterConfigString("xAxisMaxY"));
  
  yLineGraph.xLabel=" Samples ";
  yLineGraph.yLabel="Y axis readings";
  yLineGraph.Title="";  
  yLineGraph.xDiv=20;  
  yLineGraph.xMax=0; 
  yLineGraph.xMin=-100;  
  yLineGraph.yMax=int(getPlotterConfigString("yAxisMinY")); 
  yLineGraph.yMin=int(getPlotterConfigString("yAxisMaxY"));
  
  zLineGraph.xLabel="Samples ";
  zLineGraph.yLabel="Z axis readings";
  zLineGraph.Title="";  
  zLineGraph.xDiv=20;  
  zLineGraph.xMax=0; 
  zLineGraph.xMin=-100;  
  zLineGraph.yMax=int(getPlotterConfigString("zAxisMinY")); 
  zLineGraph.yMin=int(getPlotterConfigString("zAxisMaxY"));
}

// handle gui actions
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class) || theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class)) {
    String parameter = theEvent.getName();
    String value = "";
    if (theEvent.isAssignableFrom(Textfield.class))
      value = theEvent.getStringValue();
    else if (theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class))
      value = theEvent.getValue()+"";

    plotterConfigJSON.setString(parameter, value);
    saveJSONObject(plotterConfigJSON, topSketchPath+"/plotter_config.json");
  }
  setChartSettings();
}

// get gui settings from settings file
String getPlotterConfigString(String id) {
  String r = "";
  try {
    r = plotterConfigJSON.getString(id);
  } 
  catch (Exception e) {
    r = "";
  }
  return r;
}
