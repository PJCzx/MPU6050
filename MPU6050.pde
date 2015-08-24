import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port
int PORT_RATE = 115200;

float[] val_diff;
int[] val_now;
boolean justInitialized;
boolean firstContact = false;
float yaw, pitch, roll;
float[] offsets = new float[6];
float offsetBase = 300;
int loop = 0;

void setup() 
{
  size(200, 200, P3D);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  println("This scketch is ment to be connected with Arduino \"MPU6050_DMP6\" (115200 bauds) or \"MPU6050_RAW\" (38400 bauds). Current Bauds Rate is: ", PORT_RATE);
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    println(i, ports[i]);
  }
  String portName = Serial.list()[7];
  myPort = new Serial(this, portName, PORT_RATE);
  val_diff = new float[6];
  val_now = new int[6];
  for(int i = 0; i < val_now.length; i++) {
    val_now[i] = 0;
  }
  for(int i = 0; i < val_diff.length; i++) {
    val_diff[i] = 0;
  }
  for(int i = 0; i < offsets.length; i++) {
    offsets[i] = 0;
  }
  justInitialized = true;
}

void draw()
{
  background(255);             // Set background to white
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    println(val);
    if(val != null) {
      fill(0);                 // set fill to light gray
      
      String[] stringArray = val.split("\t");
      if(stringArray != null && stringArray.length == 4 && stringArray[0].equals("ypr")) {
          yaw = parseFloat(stringArray[1]);
          pitch = parseFloat(stringArray[2]);
          roll = parseFloat(stringArray[3]);
          
          text("yaw:\t" + yaw, 5, 15);
          text("pitch:\t" + pitch, 5, 30);
          text("roll:\t" + roll, 5, 45);
          
          translate(width/2, height/2);
          rotateX(roll);
          rotateY(pitch);
          rotateZ(yaw);
    
          rect(-26, -26, 52, 52);
      }
      
      if(stringArray != null && stringArray.length == 7 && stringArray[0].equals("offsets")) {
          println("Offsets received, nothing implemented");
      }
      
      
      if(stringArray != null && stringArray.length == 7 && stringArray[0].equals("a/g:")) {
        for(int i = 0; i < val_diff.length; i++) {
          val_diff[i] = parseInt(stringArray[i+1]) - offsets[i];
          //val_now[i] += val_diff[i];
         }
        
         if(loop <= offsetBase) {
           println(loop, "of", offsetBase);
            for(int i = 0; i < offsets.length; i++) {
              offsets[i] += val_diff[i]/offsetBase;
              println(i, offsets[i]);
            }
          }
          if(loop == offsetBase) {
              for(int i = 0; i < val_diff.length; i++) {
                val_diff[i] = 0;
              }
          }
                
          text("ax:\t" + val_diff[0], 5, 15);
          text("ay:\t" + val_diff[1], 5, 30);
          text("az:\t" + val_diff[2], 5, 45);
    
          text("gx:\t" + val_diff[3], 5, 60);
          text("gy:\t" + val_diff[4], 5, 75);
          text("gz:\t" + val_diff[5], 5, 90);
        }     
      } else { 
        fill(0);                   // set fill to black
    } 
  }
  //rect(50, 50, 100, 100);
  loop++;
}
void keyPressed() {
  println("Sending char");
  if (firstContact == false) {
    myPort.clear();
    //firstContact = true;
    myPort.write("A");
  }
  loop = 0;
}
