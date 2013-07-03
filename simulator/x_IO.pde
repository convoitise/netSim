void loadXMLConfig() {
  XML tempXML;
  //Loading settings
  xml = loadXML("config.xml");
  //--Number of nodes
  N = int(xml.getChild("nodes").getContent());
  //--Mode
  if (xml.getChild("manual").getContent().equals("TRUE"))manualRounds=true;
  else {
    tempXML = xml.getChild("auto");
    if (tempXML.getContent().equals("TRUE")) {
      autoRounds=true;
      autoFreq=tempXML.getInt("frequency");
    }
    else {
      tempXML =xml.getChild("timed"); 
      if (tempXML.getContent().equals("TRUE")) {
        timedRounds=true;
        timeR=tempXML.getInt("rounds");
      }
    }
  }
  if (xml.getChild("detailed").getContent().equals("TRUE"))extended=true;
}


void Log(String message) {
  output.println("["+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+"] \t"+message);
  output.flush();
}

void initializeLogger() {
  output = createWriter("Log"+day()+"-"+month()+"-"+year()+"_"+hour()+"-"+minute()+".txt");
  output.println("["+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+"] \t"+"Logger Initialized");
  output.println("["+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+"] \t"+"Simulating Distributed System of "+N+" Nodes (Processes)");
  output.flush();
}

void closeLog() {
  output.println("["+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+"] \t"+"Terminating Simulator...\n \n");
  output.println("Total Rounds Run: "+t);
  output.println("Messages, Created (TOTAL): "+totMessages+"  Created (UNIQUE): "+uniMessages+"  Transmitted (TOTAL): "+traMessages+"  Delivered: "+delMessages);
  output.println("Messages en route at the time of Exit: "+router.messages.size());  //Indicates msg sent, but not received yet
  output.flush();
  output.close();
}


void pause() {
  if (!paused) { 
    paused = true; 
    noLoop(); 
    Log("! Simulation Paused !");
  }
  else {
    paused = false; 
    loop(); 
    Log("Resuming...");
  }
}

