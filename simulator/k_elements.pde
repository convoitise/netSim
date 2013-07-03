//Each instance represents a message
class Message {

  float LC;  //Message's Logical Clock
  int content;  //The actual message
  public int sender;  //origin
  public int recipient;  //destination (==sender for multicast)

  Message(float LogClock, int sender_, int recipient_, int content_) {
    LC = LogClock;    //Set by the sender
    recipient = recipient_;  //Set by the sender
    sender = sender_;
    content = content_;  //Random Int 0-999999
    totMessages++;
  }
}


//Network
class Router {

  ArrayList messages = new ArrayList();


  //Checks for new messages according to protocol (begin of the round)
  void receiveMessages() {
    Node node_;
    if (phase==2) {  //BASIC MODE
      node_ = (Node) nodes.get(primaryNode);
      messages.add(node_.basicCheck());
    }
    else if (phase==3)  //PIPELINE MODE
      for (int n_=0;n_<N;n_++) {
        node_ = (Node) nodes.get(n_);
        Message msg_ = (Message) node_.pipeCheck();
        if (msg_!=null) messages.add(msg_);
      }
    else if (phase==4)  //TREE MODE
      for (int n_=0;n_<N;n_++) {
        node_ = (Node) nodes.get(n_);
        Message msg_ = (Message) node_.treeCheck();
        if (msg_!=null) messages.add(msg_);
      }
    else if (phase==5)  //THROUPUT MODE
      for (int n_=0;n_<N;n_++) {
        node_ = (Node) nodes.get(n_);
        Message msg_ = (Message) node_.throuCheck();
        if (msg_!=null) messages.add(msg_);
      }
    else if (phase==6)  //LATENCY MODE
      for (int n_=0;n_<N;n_++) {
        node_ = (Node) nodes.get(n_);
        Message msg_ = (Message) node_.lateCheck();
        if (msg_!=null) messages.add(msg_);
      }
  }

  //Transmits pending messages (end of round)
  void transmitMessages() {
    for (int sender_ = 0; sender_<nodes.size(); sender_++) {//Checks and transmits one message/sender...
      for (int recipient_ =0; recipient_<nodes.size(); recipient_++) {//.... and one message/recipient...
        for (int i = messages.size()-1; i>=0; i--) {
          Message msg_ = (Message) messages.get(i);
          if (msg_.recipient == recipient_ && msg_.sender == sender_) {
            if (recipient_!=sender_) {  //unicast
              Node node_ = (Node) nodes.get(recipient_);
              node_.receiveMessage(msg_);
              traMessages++;
              messages.remove(i);
              println("Transmited at round: "+t+"   sent by: "+sender_+"   at: "+recipient_+"    content: "+msg_.content);
              break;  //"break" used to avoid sending two messages to the same recipient during one round
            }
            else {//multicast
              for (int ii=0;ii<N;ii++) {
                if (ii!=recipient_) {
                  Node node_ = (Node) nodes.get(ii);
                  node_.receiveMessage(msg_);
                  traMessages++;
                  println("Transmited at round: "+t+"   sent by: "+sender_+"   at: multicast  content: "+msg_.content);
                  continue;  //"break" used to avoid sending two messages to the same recipient during one round}
                }
              }
              messages.remove(i);
            }
          }
        }
      }
    }
  }
}

