//
// a template for receiving kinect skeleton tracking osc messages from
// Ryan Challinor's Synapse for Kinect application:
// http://synapsekinect.tumblr.com/post/6307790318/synapse-for-kinect
//
// this example includes a class to abstract the Skeleton data
//
// 2012 Dan Wilcox danomatika.com
// for the IACD Spring 2012 class at the CMU School of Art
//
import oscP5.*;
OscP5 oscP5;

// our Synapse tracked skeleton data
Skeleton skeleton = new Skeleton();

void setup() {
  size(640, 480);
  frameRate(30);

  oscP5 = new OscP5(this, 12345);
}

void draw() {  
  background(255);
  rectMode(CENTER);
  
  // update and draw the skeleton if it's being tracked
  skeleton.update(oscP5);
  if(skeleton.isTracking()) {

      PVector v;  // a temp vector to use for joint positions
      Joint j = null;    // a temp Joint
      stroke(0);
      strokeWeight(2);
      noFill();
      
      // head
      v = skeleton.getJoint("head").posScreen;
      ellipse(v.x, v.y, 100, 100);
      
      // torso
      beginShape();
        v = skeleton.getJoint("leftshoulder").posScreen;
        vertex(v.x, v.y);
         v = skeleton.getJoint("rightshoulder").posScreen;
        vertex(v.x, v.y);
         v = skeleton.getJoint("righthip").posScreen;
        vertex(v.x, v.y);
        v = skeleton.getJoint("lefthip").posScreen;
        vertex(v.x, v.y);
      endShape(CLOSE);
      
      // left arm
      beginShape(LINES);
        v = skeleton.getJoint("leftshoulder").posScreen;
        vertex(v.x, v.y);
        v = skeleton.getJoint("leftelbow").posScreen;
        vertex(v.x, v.y);
        vertex(v.x, v.y);
        j = skeleton.getJoint("lefthand");
        v = j.posScreen;
        vertex(v.x, v.y);
      endShape(); 
      // draw a green hand if a hit movement was detected
      if(j.hitDetected())
        fill(0, 255, 0);
      else
        noFill();
      rect(v.x, v.y, 20, 20);
      
      // right arm
      beginShape(LINES);
        v = skeleton.getJoint("rightshoulder").posScreen;
        vertex(v.x, v.y);
        v = skeleton.getJoint("rightelbow").posScreen;
        vertex(v.x, v.y);
        vertex(v.x, v.y);
        j = skeleton.getJoint("righthand");
        v = j.posScreen;
        vertex(v.x, v.y);
      endShape();
      // draw a green hand if a hit movement was detected
      if(j.hitDetected())
        fill(0, 255, 0);
      else
        noFill();
      rect(v.x, v.y, 20, 20);
      
      // legs
      beginShape(LINES);
        v = skeleton.getJoint("lefthip").posScreen;
        vertex(v.x, v.y);
        v = skeleton.getJoint("leftknee").posScreen;
        vertex(v.x, v.y);
        vertex(v.x, v.y);
        v = skeleton.getJoint("leftfoot").posScreen;
        vertex(v.x, v.y);
      endShape();
      rect(v.x, v.y, 40, 20);
      beginShape(LINES);
        v = skeleton.getJoint("righthip").posScreen;
        vertex(v.x, v.y);
        v = skeleton.getJoint("rightknee").posScreen;
        vertex(v.x, v.y);
        vertex(v.x, v.y);
        v = skeleton.getJoint("rightfoot").posScreen;
        vertex(v.x, v.y);
      endShape();
      rect(v.x, v.y, 40, 20);
      
    // draw a red circle on the closest hand
    noStroke();
    fill(255, 0, 0);
    v = skeleton.getJoint("closesthand").posScreen;
    ellipse(v.x, v.y, 10, 10);
    
    println(skeleton.toString());
  }
}

// OSC CALLBACK FUNCTIONS

void oscEvent(OscMessage m) {
  skeleton.parseOSC(m);
}
