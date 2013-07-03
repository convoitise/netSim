//Each instance represents a node
class Node {

  int ID;  //Node #
  int LC=0;  //Node's Logical Clock
  boolean isPrimary=false;  //Primary node
  ArrayList incoming;  //List of incoming messages - Used for Error detection (more than 1 messages received/round)
  ArrayList outgoing;  //List of outgoing messages

  //Constructor
  Node(int nodeNumber) {
    ID=nodeNumber;
    if (ID!=primaryNode)isPrimary=false;
    else isPrimary=true;
    incoming = new ArrayList();
    outgoing = new ArrayList();
  }

  //FUNCTIONS
  void receiveMessage(Message msg_) {
    if (incoming.size()<1) {
      println("message "+nf(msg_.content, 6)+" by: "+msg_.sender+", originaly by: "+(msg_.LC%1)+" RECEIVED by: "+ID);
      incoming.add(msg_);
    }
    else {    //CASE: More than one incoming messages per round
      incoming.add(msg_);
      Message msg__ = (Message) incoming.get(0);
      Log(nf(t, 0));
      Log("msg "+nf(msg_.content, 6)+" by: "+msg_.sender+", originaly by: "+(msg_.LC%1)+", FAILED (Queue full - "+incoming.size()+") at: "+ID);
      Log("m1 origin: "+msg__.sender+", LC: "+msg__.LC+",  m2 origin: "+msg_.sender+", LC: "+msg_.LC+"\n");
    }
  }


  //PROTOCOL FUNCTIONS
  //BASIC PROTOCOL: CHECK for Outgoing Messages
  Message basicCheck() {
    if (outgoing.size()==0)basicCreateMessage();  //If there is not one, Create  [Primary Node]
    return basicSendMessage();      //Else, send it
  }

  //PIPELINE PROTOCOL: CHECK for Outgoing Messages
  Message pipeCheck() {    
    if (ID==primaryNode && outgoing.size()==0)createMessage();  //CREATES NEW MESSAGE [Primary Node]
    else if (ID!=prePrimary && outgoing.size()==0 && incoming.size()!=0)reTransmitMessage((Message) incoming.get(0));  //SENDS TO NEXT NODE [Primary and Nth Nodes excluded]
    else return null;  //  [N-th node]
    return basicSendMessage();
  }

  //TREE PROTOCOL: CHECK for Outgoing Messages
  Message treeCheck() {
    if (ID==primaryNode && outgoing.size()==0)createTree();  //CREATES NEW MESSAGE TREE [Primary Node]
    else if (outgoing.size()==0 && incoming.size()!=0)createBranch((Message) incoming.get(0));  //SENDS TO NEXT NODE - CREATE NEW BRANCH
    else if (outgoing.size()!=0) return basicSendMessage();
    return null;
  }


  //THROUGHTPUT PROTOCOL: CHECK
  Message throuCheck() {
    if (ID==N-1&&outgoing.size()==0) {
      uniCast();  //If there is not one, Create  [N-th Node]
    }
    else if (ID==(t%(N-1))) {
      multiCast();
    }
    if (outgoing.size()!=0) return basicSendMessage();
    else {
      return null;
    }
  }

  //LATENCY PROTOCOL CHECK
  Message lateCheck() {
    if ((ID==t%N)&&outgoing.size()==0) multiCast();
    if (outgoing.size()!=0) return basicSendMessage(); 
    else return null;
  }



  //BASIC PROTOCOL: CREATE Message
  void basicCreateMessage() {
    uniMessages++;
    LC = LC + 1;  //increase LogicalClock
    float LC_ = LC + ID/1000;  //Message Attached with Special Lamport Clock, decimal indicates original sender
    int content_ = int(random(1000000));
    for (int destination = 0; destination<N ; destination++) if (destination!=ID) outgoing.add(new Message(LC_, ID, destination, content_));  //Add messages to outgoing queue
  }

  //PIPELINE PROTOCOL: CREATE Message
  void createMessage() {
    int destination;
    if (ID==N-1)destination = 0;
    else destination = ID+1; 

    uniMessages++;
    LC = LC + 1;
    float LC_ = LC + ID/1000;
    int content_ = int(random(1000000));

    outgoing.add(new Message(LC_, ID, destination, content_));  //Add messages to outgoing queue
  }

  //TREE PROTOCOL: CREATE TREE (Messages from the primary node)
  void createTree() {

    uniMessages++;  //counter of unique messages

    int destination;  //destination of each message
    float LC_ ;    //message Logical Clock

    StrTemp=("round: "+t +", "+ID+"-> ");
    for (int i =0; i<100; i++) {
      destination = (int) pow(2, i);  //destination = ID+2^i
      if (destination>N-1)break;
      if (destination==ID)continue;    //CASE: Primary Node != 0
      LC_ = 1+ i + ID/1000;
      LC++;                    //Node's LC
      int content_ = int(random(1000000));
      outgoing.add(new Message(LC_, ID, destination, content_));  //Add messages to outgoing queue
      StrTemp+=(", "+destination+"-"+LC_);
    }
    if (extended) {
      Log(StrTemp);
      if (manualRounds&&N<10)addInfo(StrTemp);
    }
  }

  //TREE CREATE BRANCH
  void createBranch(Message msg_) {

    int destination;    //destination
    float LC_ = msg_.LC;    //message's LC
    int source_ = msg_.sender;  //message source
    int origin_ = int(msg_.LC%1);  //original source
    StrTemp=("round: "+t +", "+ID+"-> ");

    for (int i = floor(LC_); i<100; i++) {
      destination = ID + int(pow(2, i));
      if (destination>N-1)break;
      LC_++;
      LC++;
      outgoing.add(new Message(LC_, ID, destination, msg_.content));  //Add messages to outgoing queue
      StrTemp+=(", "+destination+"-"+LC_);
    }
    if (extended) {
      Log(StrTemp);
      if (manualRounds&&N<10)addInfo(StrTemp);
    }
  }

  //PIPELINE RETRANSMIT MESSAGE
  void reTransmitMessage(Message msg_) {
    int destination;
    if (ID==N-1)destination = 0;
    else destination = ID+1;

    LC = LC + 1;
    float LC_ = msg_.LC+1;

    outgoing.add(new Message(LC_, ID, destination, msg_.content));  //Add messages to outgoing queue
  }

  //MuLTICAST: CREATE Message
  void multiCast() {
    uniMessages++;
    int content_ = int(random(1000000));
    LC = LC + (N-1);  //increase LogicalClock
    float LC_ = LC + ID/1000;  //Message Attached with Special Lamport Clock, decimal indicates original sender
    outgoing.add(new Message(LC_, ID, ID, content_));  //Add messages to outgoing queue [Sender=Recipient for multicast]
  }


  //THROUGHPUT: CREATE UNICAST Message  
  void uniCast() {
    uniMessages++;
    LC = LC + (N-1);  //increase LogicalClock
    float LC_ = LC + ID/1000;  //Message Attached with Special Lamport Clock, decimal indicates original sender
    int content_ = int(random(1000000));
    for (int destination = 0; destination<N ; destination++) if (destination!=ID) outgoing.add(new Message(LC_, ID, destination, content_));  //Add messages to outgoing queue
  }







  //BASIC PROTOCOL: SEND Message
  Message basicSendMessage() {
    Message msg_ = (Message) outgoing.get(0);
    outgoing.remove(0);
    return msg_;
  }
}

