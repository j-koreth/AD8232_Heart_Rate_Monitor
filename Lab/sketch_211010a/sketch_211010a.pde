import processing.javafx.*;
import controlP5.*;
import processing.serial.*;
import org.gicentre.utils.stat.*;    // For chart classes.
import java.io.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
ControlP5 cp5;

Textfield age;
Chart myChart;
Chart myChart3;

boolean analyze = false;
Button rhB;
Button startWorkOut;
Button startArb;
boolean workout = false;

Chart myChart2;
int rangeLimit = 40;
Textlabel textRHB;
Button meditate;
Textlabel textMedidate;



void setup()
{
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 115200);
  File file = new File("Arnav ECG data.txt");
  try{
    BufferedReader br = new BufferedReader(new FileReader(file));
  }
  catch(Exception e){
    println("file load failed");
  }
  
  size(600, 500);
  
  cp5 = new ControlP5(this);
  PFont font;
  font = createFont("Verdana-Bold", 10); //_ select a font
  cp5.setFont(font);
  
   myChart = cp5.addChart("Respiration")
    .setPosition(50, 0)
    .setSize(200, 100)
    .setRange(0, 1000)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(5)
    .setColorCaptionLabel(color(250));
      myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[100]);
   
   myChart3 = cp5.addChart("ecg")
    .setPosition(50, 125)
    .setSize(200, 100)
    .setRange(0, 1000)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(5)
    .setColorCaptionLabel(color(250));
      myChart3.addDataSet("incoming");
  myChart3.setData("incoming", new float[100]);
  
   startArb = cp5.addButton("startArb")
     .setPosition(50,300)
     .setSize(50,25)
     .setLabel("Play")
     ;
     
  
  
  cp5.addKnob("respiratoryrate")
    .setPosition(50, 350)
    .setRadius(35)
    .setRange(0, 100)
    .setValue(0)
    .setColorForeground(color(255))
    .lock();

  cp5.addKnob("heartbeatmeter")
    .setPosition(180, 350)
    .setRadius(35)
    .setRange(0, 250)
    .setValue(0)
    .setColorForeground(color(255))
    .lock();    
    
   rhB = cp5.addButton("getBaseline")
     .setPosition(350,20)
     .setSize(200,25)
     .setLabel("Get Baseline")
     ;
     
     
   textRHB = cp5.addTextlabel("textRHB")
     .setText("Resting Heart Rate: ")
     .setPosition(350,60);
     
    age = cp5.addTextfield("age")
      .setPosition(350,115)
      .setSize(100,25);
      
     startWorkOut = cp5.addButton("startWorkOut")
     .setPosition(475,115)
     .setSize(50,25)
     .setLabel("Play")
     ;
     
      myChart2 = cp5.addChart("")
           .setPosition(350, 175)
           .setSize(200, 200)
           .setRange(0, rangeLimit)
           .setView(Chart.BAR) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
           .setColorCaptionLabel(color(250));
           ;
      
      myChart2.setStrokeWeight(1.5);
      
      meditate = cp5.addButton("startMedidate")
     .setPosition(350,400)
     .setSize(100,25)
     .setLabel("medidate")
     ;
       
     textMedidate = cp5.addTextlabel("textMedidate")
     .setText("__________")
     .setPosition(475,400);
}

//Resting Respitaroy Rate
double prevavg = 0;
boolean setBase = false;
int count = 0;
String breathingStatus = "Inhaling";
int breathChange = 0;

//Arb
boolean startedArbResp = false;
boolean stopArbResp = false;

//Meditation
boolean meditation = false; 
float inhaleCount = 0;
float exhaleCount = 0;
int breathConsecutive = 0;



void draw()
{
  background(0);
  
  if ( myPort.available() > 1)
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    if (val != null) {
        if (val.substring(0, 2).equals("B:")) {
          String[] values = val.split(",");
          float breathing = Float.parseFloat(values[0].substring(2));
          float ecg = Float.parseFloat(values[1].substring(3));
          float time = Float.parseFloat(values[2].substring(3));
          //print(val);
          myChart.push("incoming", breathing);
          myChart3.push("incoming", ecg);
          
          //RespBase
          if(setBase){
            if(prevavg == 0){
              prevavg = breathing;
            }
            else if(breathing > 10 + prevavg){
              if(!breathingStatus.equals("Inhaling")){
                breathChange++;
              }
              breathingStatus = "Inhaling"; 
            }
            else if(breathing < prevavg - 10){
              if(!breathingStatus.equals("Exhaling")){
                breathChange++;
              }
              breathingStatus = "Exhaling";
            }
            prevavg = breathing;
            println(breathingStatus);
            
            count++;
            
            if(count >= 120){
              println(breathChange);
              textRHB.setText("Respiratory Rate: " + breathChange * 2);
              breathChange = 0;
              count = 0;
              prevavg = 0;
              rhB.unlock();
              setBase = false; 
            }
          }   
          
          
          //ArbResp
          if(startedArbResp){
            if(prevavg == 0){
              prevavg = breathing;
            }
            else if(breathing > 10 + prevavg){
              if(!breathingStatus.equals("Inhaling")){
                breathChange++;
              }
              breathingStatus = "Inhaling"; 
            }
            else if(breathing < prevavg - 10){
              if(!breathingStatus.equals("Exhaling")){
                breathChange++;
              }
              breathingStatus = "Exhaling";
            }
            prevavg = breathing;
            println(breathingStatus);
            
            
            if(stopArbResp){
              println(breathChange);
              cp5.get("respiratoryrate").setValue(breathChange * 2);
              breathChange = 0;
              prevavg = 0;
              startedArbResp = false;
              stopArbResp = false;
            }
          }
          
          //Meditation
          if(meditation) {
            if(prevavg == 0){
              prevavg = breathing;
            }
            else if(breathing > 10 + prevavg){
              if(!breathingStatus.equals("Inhaling")){
                if(!(inhaleCount <= exhaleCount / 3)){
                  breathConsecutive++;
                  println("1");
                }
                inhaleCount = 0;
                exhaleCount = 0;
              }
              inhaleCount+=1;
              breathingStatus = "Inhaling"; 
            }
            else if(breathing < prevavg - 10){
              exhaleCount+=1;
              breathingStatus = "Exhaling";
            }
            prevavg = breathing;
            println(breathingStatus);
            println(inhaleCount);
            println(exhaleCount);
            if(breathConsecutive >= 4){
              println(breathChange);
              prevavg = 0;
              meditate.unlock();
              meditation = false;
              textMedidate.setText("Failed");
              meditate.unlock();
            }
          }
        }
      }
    }
}



public void getBaseline(int value){
  setBase = true;
  rhB.lock();
}

public void startMedidate(int value){
  meditation = true;
  meditate.lock();
}

public void startArb(int value){
  if(startedArbResp){
    startArb.setLabel("Play");
    stopArbResp = true;
  }
  else{
    startArb.setLabel("Pause");
    startedArbResp = true;
  }
}

public void startWorkOut(int theValue){
  if(workout){
      startWorkOut.setLabel("Play");
      workout = false;
  }
  else{
      workout = true;
      startWorkOut.setLabel("Pause");
  }
}
