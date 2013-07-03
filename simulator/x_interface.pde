//KEY-MOUSE
void keyPressed() {

  int keyIndex = key;

  if (key=='X' || key=='x') {  //EXIT
    closeLog();
    exit();
  }

  if (key=='p' || key=='P') {     //PAUSE & SHOW
    showWindow(); 
    showInfo(); 
    if (paused==false)pause();
  }

  if (key=='R' || key=='r') reset();    //RESET

  if (key==10 || key==13) if (manualRounds &&(phase<7 && phase>1))    //NEXT STEP (in manual mode)
    loop();
}

void mousePressed() {
  if (phase==1) {
    if (currButton==5) {
      closeLog();
      exit();
    }
    else if (currButton>-1)phase=currButton+2;  //2=Basic, 3=Pipeline, 4=Tree, 5=Throughput, 6=Latency
  }
}

void mouseReleased() {
  if (manualRounds &&(phase<7 && phase>1))
    loop();
}


//SHOW INFO SCREEN
void showWindow() {
  stroke(153);
  fill(171, 236, 180, 0.5f);
  rect(width/2, height/2, width-10, height-10, 10);
}


String[] infoText = new String[20];  //To be shown on screen
String[] extraText = new String[10]; //To be shown on screen (on detailed reports)
String infoString; 
Node tempN_;

void showInfo() {

  //Visual Settings
  fill(200, 50, 50);
  textFont(Courrier24);
  textAlign(CENTER);
  text("CURRENT SIMULATION STATS:\n", width/2, 30);
  fill(0);    
  textFont(Dill22);    


  //Information to be Shown
  infoText[0] = "Messages, Created (TOTAL): "+totMessages+",  Created (UNIQUE): "+uniMessages+",  Transmitted (TOTAL): "+traMessages+",  Delivered: "+delMessages;
  infoText[1] = "Current Messages en route: "+router.messages.size();
  int p=2;
  if (N<17)while (p<N+2) {
    tempN_ = (Node) nodes.get(p-2);
    infoText[p]="Node no."+(p-2)+", Outgoing msg: "+tempN_.outgoing.size()+", Incoming: "+tempN_.incoming.size()+", LC: "+tempN_.LC;
    p++;
  }

  for (int i=0; i<extraText.length; i++)
    if (extraText[i]!=null) {
      infoText[p]=extraText[i];
      extraText[i]=null;
      p++;
    }



  //String Array Padding
  int k_=19;    
  while (infoText[k_]==null&&k_>0) {
    infoText[k_]=" ";
    k_--;
  }

  //Print on screen
  text(join(infoText, "\n"), width/2, 56);



  fill(100);
  textFont(Courrier24);
  textSize(16);
  line(10, height-30, width-10, height-30);
  textAlign(LEFT);
  if (manualRounds)text("Click or Press Return, for Next Round", 20, height-12);
  else text("P to Pause/Resume;", 20, height-12);
  textAlign(RIGHT);
  text("Press X to Exit; R to Reset", width-20, height-12);
  textAlign(CENTER);
  text(N+" Nodes "+tempMode+" Mode Running. Round: "+t, width/2, height-40); 
  fill(0);
  textFont(Dill22);
}

void addInfo(String info) {
  int i=0;
  while (i<10&& (extraText[i]!=null))i++;
  if (i<10)extraText[i]=info;
}


//MODE SELECT 
void selectMode() {
  rectMode(CENTER);
  if (butt[5]==null) {
    for (int i = 0; i<6; i++) {
      if (i<3) butt[i]=new Button(width/3, ((i+2)*height/6), i);
      else butt[i]=new Button(2*width/3, (i%3+2)*height/6, i);
    }
  }  
  else {
    updateMouse();
    textFont(Courrier24);
    textAlign(CENTER);
    for (int i = 0; i<6; i++) {
      fill(100f);
      rect(butt[i].posX, butt[i].posY, 200, 80, 10);
      fill(255);
      switch(i) {
      case 0:        
        text("Basic", butt[i].posX, butt[i].posY);  
        break;
      case 1:        
        text("Pipeline", butt[i].posX, butt[i].posY);  
        break;
      case 2:        
        text("Tree", butt[i].posX, butt[i].posY);  
        break;
      case 3:        
        text("Protocol 1", butt[i].posX, butt[i].posY);  
        break;
      case 4:        
        text("Protocol 2", butt[i].posX, butt[i].posY);  
        break;
      case 5:       
        text("EXIT", butt[i].posX, butt[i].posY);  
        break;
      default:        
        Log("buttons?");
      }
    }
  }
}

class Button { 
  int posX, posY, wid=200, hei=80, radi=7, value; 
  Button (int a, int b, int v) {
    posX=a;
    posY=b;
    value=v;
  } 
  void update() {
  }
}



//MOUSE CHECK
void updateMouse() {

  if (phase==1) {  //Case Select Mode
    for (int i=0; i<butt.length; i++) {
      if (mouseX<=butt[i].posX+butt[i].wid/2 && mouseX>=butt[i].posX-butt[i].wid/2 && mouseY>=butt[i].posY-butt[i].hei/2 && mouseY<=butt[i].posY+butt[i].hei/2) {
        fill(0);
        textSize(18);
        if (i==0) {
          text("Latency = 3 rounds \n Throughput = 1/3", width/2, 40); 
          currButton = i;
          tempMode = "Basic";
        }
        else if (i==1) {
          text("Latency = 2 rounds \n Throughput = 1/2", width/2, 40); 
          currButton = i;
          tempMode="Tree";
        }
        else if (i==2) {
          text("Latency = 3 rounds \n Throughput = 1", width/2, 40); 
          currButton = i;
          tempMode="Pipeline";
        }
        else if (i==3) {
          text("Median Latency ~ 1.3 Rounds \n Throughput = 4/3", width/2, 40); 
          currButton = i;
          tempMode="Throughput Optimized (For N Senders)";
        }
        else if (i==4) {
          text("Latency = ? Rounds \n 1Throughput = ?", width/2, 40); 
          currButton = i;
          tempMode="Latency Optimized";
        }
        else if (i==5) {
          text("CLOSE", width/2, 40); 
          currButton = i;
          tempMode=null;
        }
      }
    }
  }
}








void reset() {

  output.println("Reseting Simulator.... \n Printing final data...\n");  //Logger output
  closeLog();

  StrTemp = null; 
  IntTemp =0;
  currButton = 0;
  xml = null;

  N=0; 
  t=0; 
  phase=1;
  paused = false;
  nodes = new ArrayList();
  router = new Router();

  primaryNode=0; 
  prePrimary=3;
  manualRounds = false; 
  autoRounds = false; 
  timedRounds = false;
  autoFreq = 30; 
  int timeR = 1000;
  modeInitialized = false;

  uniMessages =0; 
  totMessages =0; 
  traMessages =0; 
  delMessages = 0;

  frameRate(10);
  loop();
  setup();
}

