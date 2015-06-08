import DMXlib.*;
import deadpixel.keystone.*;


/*For MacOS execute the following command in the terminal:

sudo route -nv add -net 224.1.1.1 -interface en3

for -interface choose the appropriate network interface 
where the controller is connected
*/

//Low-Res Screen
DMXController dmx;
LEDScreen screen1, screen2, screen3, screen4, screen5, screen6, screen7, screen8, screen9, screen10, screen11, screen12, screen13, screen14, screen15, screen16;
PGraphics pg, pg1;
ArrayList<LEDScreen> screenList = new ArrayList<LEDScreen>();
int [][] map = {{1,1,1,1},{1,1,1,1},{1,1,1,1},{1,1,1,1}};


//High-Res Screen
Keystone ks;
ArrayList<CornerPinSurface> surfaceList = new ArrayList<CornerPinSurface>();
ArrayList<PGraphics> offscreenList = new ArrayList<PGraphics>();
int HR_WIDTH = 80;
int HR_HEIGHT = 80;
int HR_AMOUNT = 4;
int[] displaySize = {1,1,1,1};
int [][] beamerMap = {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}};

//User Study Content
ArrayList<PImage> studyPics;
int ctr_study = 0;

void setup()
{
 
  size(800, 600, P3D);
  
  /*new LEDScreen(width,height,start,direction)
  start = "LU" -> Lower Left
        = "LO" -> Higher Left
        = "RU" -> Lower Right
        = "RO" -> Higher Right
  direction = "H" -> Horizontal
            = "V" -> Vertical
  */ 
  

  screen1 = new LEDScreen(4, 4, "LO", "H");
  screen2 = new LEDScreen(4, 4, "LO", "H");
  screen3 = new LEDScreen(4, 4, "LO", "V");
  screen4 = new LEDScreen(4, 4, "LO", "H");  
  screen5 = new LEDScreen(4, 4, "LO", "H");
  screen6 = new LEDScreen(4, 4, "LO", "H");
  screen7 = new LEDScreen(4, 4, "LO", "V");
  screen8 = new LEDScreen(4, 4, "LO", "H");
  screen9 = new LEDScreen(4, 4, "LO", "H");
  screen10 = new LEDScreen(4, 4, "LO", "H");
  screen11 = new LEDScreen(4, 4, "LO", "V");
  screen12 = new LEDScreen(4, 4, "LO", "H");  
  screen13 = new LEDScreen(4, 4, "LO", "H");
  screen14 = new LEDScreen(4, 4, "LO", "H");
  screen15 = new LEDScreen(4, 4, "LO", "V");
  screen16 = new LEDScreen(4, 4, "LO", "H");
  
  /*Add Screen to ArrayList of Screens*/
  screenList.add(screen1);
  screenList.add(screen2);
  screenList.add(screen3);
  screenList.add(screen4);
  screenList.add(screen5);
  screenList.add(screen6);
  screenList.add(screen7);
  screenList.add(screen8);
  screenList.add(screen9);
  screenList.add(screen10);
  screenList.add(screen11);
  screenList.add(screen12);
  screenList.add(screen13);
  screenList.add(screen14);
  screenList.add(screen15);
  screenList.add(screen16);


  
  /*Instance of DMX Controller
  new DMXController(IP, PORT, ID);
  appropriate ID is displayed on the controller
  */
  dmx = new DMXController("224.1.1.1", 5026, 4);  

  /*Add screens to the controller
  DMXController.add(int Controller_PORT, int Number, LEDSreen screen);
  Controller_Port from 0 bis 7
  */
  dmx.add(1, 0, screen1);
  dmx.add(1, 1, screen2);
  dmx.add(1, 2, screen3);
  dmx.add(1, 3, screen4);
  dmx.add(1, 4, screen1);
  dmx.add(1, 5, screen2);
  dmx.add(1, 6, screen3);
  dmx.add(1, 7, screen4);
  dmx.add(1, 8, screen1);
  dmx.add(2, 9, screen2);
  dmx.add(2, 10, screen3);
  dmx.add(2, 11, screen4);
  dmx.add(2, 12, screen1);
  dmx.add(2, 13, screen2);
  dmx.add(2, 14, screen3);
  dmx.add(2, 15, screen4);
  dmx.add(2, 16, screen4);
  

  //Init KeyStone for the High-Res Screen
  ks = new Keystone(this);
  
  for(int i=0; i<HR_AMOUNT; i++){
  surfaceList.add(ks.createCornerPinSurface(HR_WIDTH, HR_HEIGHT, 20));
  }
  
  
  //User Study Content
 pg = createGraphics(80,80);
 studyPics = new ArrayList<PImage>();

 new Thread(new Runnable() {
   public void run() {
     loadStudyPics();
   }
 }).start();   
 
}

void draw(){
  
  background(0);
    
  /*Draw User Study Content
  and Change Icon after a period of time
  */
  if(frameCount%100==0){
    if(ctr_study<9){
    ctr_study++;
    }else{
      ctr_study = 0;
    }  
  }
 
  pg.beginDraw();
  pg.image(studyPics.get(ctr_study),0,0);
  pg.endDraw();
  

  /*
  Draw ob LED-Screen
  */
  int ctr = 0;
  PImage sendGr = pg.get(0, 0, pg.width, pg.height);
  sendGr.resize(16,16);
  
  for(int ix=0; ix<map.length; ix++){
   for(int iy=0; iy<map[ix].length; iy++){
     
     if(map[ix][iy]==1){
       ctr++;
       PGraphics pgS = createGraphics(4,4,JAVA2D);
       pgS.beginDraw();
       pgS.clear();
       pgS.image(sendGr.get(ix*4,iy*4,4,4),0,0);
       pgS.endDraw();
       image(pgS,ix*4,iy*4);
       //Update LED-Screen
       screenList.get(ctr-1).update(pgS);
     }
   }
  }  
  
  //Send updated Screen to the DMX-Controller
  dmx.send();
  
  /*
  KeyStone
  */
  PVector surfaceMouse = surfaceList.get(0).getTransformedMouse();

  int count=0;
  for(int ix=0; ix<beamerMap.length; ix++){
    for(int iy=0; iy<beamerMap[ix].length; iy++){
      if(beamerMap[ix][iy]==1){
        surfaceList.get(count).render(pg.get(0,0,80,80));
        count++;       
      }
    }
  }

}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}

void loadStudyPics(){
  File file = new File("/Users/mariushoggenmuller/Documents/Processing/UserStudy_2/study/");
  println(file);
     
  int count = 0;
  for(String fileName : file.list()){
    if(fileName.contains("pic")){
      count++;
    }
  }
  
  println(count);
  
  for(int j=0; j<count; j++){
       studyPics.add(loadImage(file+"/"+"pic"+j+".png"));
  }
  
}

