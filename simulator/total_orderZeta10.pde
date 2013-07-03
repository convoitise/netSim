//Secondary Variables
String StrTemp = new String();  //All-purpose string
int IntTemp =0;  //All-purpose integer
PFont Georgia24, Courrier24, Dill22;  //fonts
Button[] butt = new Button[6];  //0-2 test modes, 3-4 protocols, 5 reset
int currButton;  //button pressed
XML xml;  //XML Setting
PrintWriter output;  //Logger output



//Logical Variables
int N=0;        //machines
int t=0;        //current round (time)
//ArrayList LC = new ArrayList();    //Logical Clocks

//Program Variables
int phase=1;    //indicating program stage
boolean paused = false;
ArrayList nodes;  //List of Nodes
Router router;  //Network
int primaryNode=0;  //Selected node (Default: 0 - 1st Node)
int prePrimary=3;  //Node prior to primary (Default: 3 - Set at setup)
boolean manualRounds = false;  //Rounds Mode 1
boolean autoRounds = false; 
int autoFreq = 30;  //Rounds Mode 2
boolean timedRounds = false; 
int timeR = 1000;  //Rounds Mode 3
boolean modeInitialized = false;  //Selected Mode is Initialized


//Logging Variables
boolean extended = false;  //Used for detailed logging
long uniMessages =0;  //Counter of UNIQUE messages created
long totMessages =0;  //Counter of TOTAL messages created
long traMessages =0;  //Counter of TOTAL messages transmited
long delMessages = 0;  //Counter of TOTAL messages delivered
String tempMode;



void setup() {
  size(800, 600);
  Georgia24 = createFont("Georgia", 24);
  Courrier24 = createFont("CourrierNew", 24);
  Dill22 = createFont("Dill22", 16);
  loadXMLConfig();
  println("nodes:  "+N);
  initializeNodes();
  initializeLogger();
  router = new Router();
}


//Each Draw Function during the simulation run (manual & automatic mode) represents a round
void draw() {
  background(255);

  if (phase==1) {
    selectMode();  //Mode Select
    if (!modeInitialized) {
      if (manualRounds)initManualMode();
      else if (autoRounds) initAutoMode();
      else if (timedRounds) initTimedMode();
    }
  }
  else if (autoRounds) {        //Automatic Rounds Mode
    if (phase>1&&phase<7)step();      //Commits Test: Basic
    else if (phase==7)reset();
    else if (phase>1)print("non-mapped state"+phase);
    else println("no phase");
  }
  else if (manualRounds) {
    stepManualMode();
  }
  else if (timedRounds) {
    while (t<timeR-1)
      step();    //run on background
    stepManualMode();  //run last round & show results
  }
}

