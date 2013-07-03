//ERROR MIXING STATIC ACTIVE MODES
void runBasic() {
  if (!modeInitialized) {
    if (manualRounds)initManualMode();
    else if (autoRounds) initAutoMode();
    else if (timedRounds) initTimedMode();
  }
  else {
    if (autoRounds)step();
  }
  // phase=21;  //2.1 is Basic Simulation Base Stage
}


//Method for creating nodes
void initializeNodes() {
  nodes = new ArrayList();
  for (int i =0; i<N; i++) {
    nodes.add(new Node(i));
  }
  for (int i = 0; i<N; i++)
    println(nodes.get(i));

  if (primaryNode==0)prePrimary=(N-1);
  else prePrimary = primaryNode-1;
}


//Initializing "Manual" Mode
void initManualMode() {
  println("MODE: Manual Mode");
  Log("Simulator MODE: Manual Rounds");
  showWindow();
  modeInitialized=true;
}

void stepManualMode() {
  println("Starting Round: "+t);
  router.receiveMessages();
  deliverMessages();
  router.transmitMessages();
  showWindow();
  showInfo();
  noLoop();
  t++;
}


//Initializing "Automatic" Mode
void initAutoMode() {
  println("MODE: Auto Mode; Frequency: "+autoFreq);
  frameRate(autoFreq);
  modeInitialized=true;
}

//Step during  "Automatic" Mode
void step() {
  println("Starting Round: "+t);
  router.receiveMessages();
  deliverMessages();
  router.transmitMessages();


  t++;
}


//Initializing "Timed" Mode
void initTimedMode() {
  println("MODE: Timed Mode; Time: "+timeR);
}




//During End-of-Round pending messages are delivered
void deliverMessages() {
  Node tmp_;
  for (int i = 0; i<nodes.size(); i++) {
    tmp_ = (Node) nodes.get(i);
    int iT= tmp_.incoming.size()-1;
    if (iT==0) {
      tmp_.incoming.remove(0);
      delMessages++;
    }
    else if (iT>0) {
      tmp_.incoming.remove(0);
      delMessages++;
      Log("Too many ("+iT+") enqueued incoming messages at round: "+t+"Node: "+i);
    }
  }
}
