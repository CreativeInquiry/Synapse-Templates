//
// see the Synapse OSC spec for more details:
// http://synapsekinect.tumblr.com/post/6307752257/maxmsp-jitter
//

import java.util.Map;
import java.util.Iterator;
import java.util.HashMap;
import oscP5.*;
import netP5.*;

// ***************************************

// a single tracked joint
class Joint {
  
  // **** VARIABLES **** 
  
  // joint name, one of:
  //
  //          head
  //          neck
  //  leftshoulder  rightshoulder
  //  rightelbow    leftelbow
  //  righthand     lefthand
  //          torso
  //  lefthip       righthip
  //  rightknee     leftknee
  //  rightfoot     leftfoot
  //
  //       closesthand
  //
  // closesthand is a copy of either the left or right hand
  //
  String name;
  
  // xyz position
  //
  // only 1 is active at a time
  //
  // see Skeleton.getJointPosBody(), Skeleton.getJointPosWorld(), &
  //     Skeleton.getJointPosScreen() to request a diff type
  //
  PVector posWorld = new PVector();  // world space in mm
  PVector posBody = new PVector();   // relative to the torso in mm
  PVector posScreen = new PVector(); // screen space (640x480) in mm
  
  // has a hit been detected?
  // things such as a punch moving forward, etc
  boolean hitUp, hitDown, hitLeft, hitRight, hitForward, hitBack;
  
  // how far the joint must move in mm before a hit is detected
  float hitRequiredLen;
  
  // how many points are being tracked for hit detection
  int hitPointHistorySize;
  
  // request data for this joint from Synapse?
  boolean requestData = true;
  
  // **** FUNCTIONS **** 
  
  Joint(String name){
    this.name = name;
  }
  
  // was a hit detected?
  boolean hitDetected() {
     return hitUp || hitDown || hitLeft || hitRight || hitBack || hitForward;
  }
  
  // reset the hit detection
  void resetHit() {
    hitUp = false;
    hitDown = false;
    hitLeft = false;
    hitRight = false;
    hitBack = false;
    hitForward = false;
  }
  
  // should we ask Synapse for this joint's data?
  void requestData(boolean yesno) {
    requestData = yesno;  
  }
  
  // returns true if a message was handled
  boolean parseOSC(OscMessage m) {     

    // hit detection
    if(m.checkAddrPattern("/"+name)) {
      String hit = m.get(0).stringValue();
      if(hit.equals("up"))
        hitUp = true;
      else if(hit.equals("down"))
        hitDown = true;
      else if(hit.equals("left"))
        hitLeft = true;
      else if(hit.equals("right"))
        hitRight = true;
      else if(hit.equals("back"))
        hitBack = true;
      else if(hit.equals("forward"))
        hitForward = true;
      return true;
    }
    else if(m.checkAddrPattern("/"+name+"_requiredlength")) {
      hitRequiredLen = m.get(0).floatValue();
      return true;
    }
    else if(m.checkAddrPattern("/"+name+"_pointhistoryszie")) {
      hitRequiredLen = m.get(0).intValue();
      return true;
    }
    
    // pos
    else if(m.checkAddrPattern("/"+name+"_pos_world")) {
        posWorld.x = m.get(0).floatValue();
        posWorld.y = m.get(1).floatValue();
        posWorld.z = m.get(2).floatValue();
        return true;
    }
    else if(m.checkAddrPattern("/"+name+"_pos_body")) {
        posBody.x = m.get(0).floatValue();
        posBody.y = m.get(1).floatValue();
        posBody.z = m.get(2).floatValue();
        return true;
    }
    else if(m.checkAddrPattern("/"+name+"_pos_screen")) {
        posScreen.x = m.get(0).floatValue();
        posScreen.y = m.get(1).floatValue();
        posScreen.z = m.get(2).floatValue();
        return true;
    }
    
    return false;
  }
  
  // get the current joint values as a string (includes end lines)
  String toString() {
    return name + ":\n"
           + "  posWorld:"+posWorld.x+" "+posWorld.y+" "+posWorld.z+"\n"
           + "  posBody:"+posBody.x+" "+posBody.y+" "+posBody.z+"\n"
           + "  posScreen:"+posScreen.x+" "+posScreen.y+" "+posScreen.z+"\n"
           + "  hit: "+hitDown+" "+hitUp+" "+hitLeft+" "+hitRight+" "+hitBack+" "+hitForward+"\n"
           + "  hit move len: "+hitRequiredLen+"\n"
           + "  hit history size: "+hitPointHistorySize+"\n";
  }
  
};

// ***************************************

// a single tracked skeleton from Synapse
class Skeleton {
  
  // **** VARIABLES **** 
  
  HashMap joints;
  
  // is a skeleton being tracked?
  boolean tracking = false;
  
  // what joint positions should we ask Synapse for?
  // 1: body pos, 2: world pos, 3: screen pos
  int jointPosType = 3;
  
  // used for data request timing
  // since Synapse must be pinged every so often or 
  // it will stop sending data
  long lastRequestTimestamp = 0;
  int requestDelayTime = 2000;  // in ms
  
  // where to send data requests
  // the port is always 12346
  NetAddress synapseAddr;
  
  // **** FUNCTIONS **** 

  Skeleton() {
    synapseAddr = new NetAddress("127.0.0.1", 12346);
    makeJoints();
  }
  
  // specify Synapse's ip address
  // useful if it's running on another computer
  Skeleton(String address) {
    synapseAddr = new NetAddress(address, 12346);
    makeJoints();
  }

  // is a skeleton being tracked?
  boolean isTracking()  {
    return tracking;
  }
  
  // get a joint by name
  // returns null if you're using the wrong name ...
  Joint getJoint(String name) {
    Joint j = (Joint) joints.get(name);
    if(j == null) {
        println("Skeleton: getJoint: Sorry, I can't find joint \""+name+"\"");
        return null;
    }
    return j;
  }
  
  // should we ask Synapse to send data for a joint?
  // all joints are requested by default
  //
  // turning unneeded joints off saves comm bandwidth
  void requestDataForJoint(String name, boolean yesno) {
    Joint j = (Joint) joints.get(name);
    if(j == null) {
        println("Skeleton: requestDataForJoint: Sorry, I can't find joint \""+name+"\"");
        return;
    }
    j.requestData(yesno);
  }
  
  // are we currently requesting data for this joint?
  boolean isRequestingDataForJoint(String name) {
    Joint j = (Joint) joints.get(name);
    if(j == null) {
        println("Skeleton: isRequestingDataForJoint: Sorry, I can't find joint \""+name+"\"");
        return false;
    }
    return j.requestData;
  }
  
  // request all the joints
  void requestAllJoints() {
    Iterator iter = joints.entrySet().iterator();
    while(iter.hasNext()) {
      Map.Entry pair = (Map.Entry) iter.next();
      Joint j = (Joint) pair.getValue();
      j.requestData = true;
    }
  }
  
  // don't request any joints
  void requestNoJoints() {
    Iterator iter = joints.entrySet().iterator();
    while(iter.hasNext()) {
      Map.Entry pair = (Map.Entry) iter.next();
      Joint j = (Joint) pair.getValue();
      j.requestData = false;
    }
  }
  
  // get joint pos in the body coordinates
  void getJointPosBody()  {jointPosType = 1;}
  
  // get joint pos in the world coordinates
  void getJointPosWorld()  {jointPosType = 2;}
  
  // get joint pos in the screen coordinates (default)
  void getJointPosScreen() {jointPosType = 3;}

  // send periodic requests for data to Synapse
  // !! you must call this in order to get data !!
  void update(OscP5 oscP5) {
    
    // send a request for data every now and then
    if(millis() - lastRequestTimestamp > requestDelayTime) {
      
      // request each joint pos
      OscBundle bundle = new OscBundle();
      Iterator iter = joints.entrySet().iterator();
      while(iter.hasNext()) {
        Map.Entry pair = (Map.Entry) iter.next();
        Joint j = (Joint) pair.getValue();
        if(j.requestData) {
          OscMessage msg = new OscMessage("/"+j.name+"_trackjointpos");
          msg.add(jointPosType);
          bundle.add(msg);
        }
        j.resetHit();  // reset the hit detection
      }
      if(bundle.size() > 0) {
        oscP5.send(bundle, synapseAddr);
      }
      
      lastRequestTimestamp = millis();
    }
  }

  // parse an OSC message from Synapse
  // returns true if a message was handled
  boolean parseOSC(OscMessage m) {
    
    if(m.checkAddrPattern("/tracking_skeleton")) {
      tracking = boolean(m.get(0).intValue());
      return true;
    }
    
    boolean handled = false;
    Iterator iter = joints.entrySet().iterator();
    while(!handled && iter.hasNext()) {
      Map.Entry pair = (Map.Entry) iter.next();
      Joint j = (Joint) pair.getValue();
      handled = j.parseOSC(m);
    }
    
    // if synapse was running when we started the sketch,
    // we woudldn't receive the intital tracking_skeleton = true
    // so if a message has come in, assume we are tracking
    if(!tracking && handled) {
      tracking = true;
    }
    
    return handled;
  }
  
  // get the current face values as a string (includes end lines)
  String toString() {
    
    String s = "tracking: " + tracking + "\n";
    
    if(tracking) {
      Iterator iter = joints.entrySet().iterator();
      while(iter.hasNext()) {
        Map.Entry pair = (Map.Entry) iter.next();
        Joint j = (Joint) pair.getValue();
        s += j.toString();
      }
    } 
      return s;
  }
  
  // populate the joint array list
  private void makeJoints() {
    joints = new HashMap();
    joints.put("head", new Joint("head"));
    joints.put("neck", new Joint("neck"));
    joints.put("rightshoulder", new Joint("rightshoulder"));
    joints.put("leftshoulder", new Joint("leftshoulder"));
    joints.put("rightelbow", new Joint("rightelbow"));
    joints.put("leftelbow", new Joint("leftelbow"));
    joints.put("righthand", new Joint("righthand"));
    joints.put("lefthand", new Joint("lefthand"));
    joints.put("torso", new Joint("torso"));
    joints.put("rightknee", new Joint("rightknee"));
    joints.put("leftknee", new Joint("leftknee"));
    joints.put("righthip", new Joint("righthip"));
    joints.put("lefthip", new Joint("lefthip"));
    joints.put("rightfoot", new Joint("rightfoot"));
    joints.put("leftfoot", new Joint("leftfoot"));
    joints.put("closesthand", new Joint("closesthand")); 
  }
  
};
