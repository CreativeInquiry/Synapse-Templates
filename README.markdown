Synapse Templates
------------------

2012 [Dan Wilcox](http://danomatika.com), et al.

for the [Spring 2012 IACD class](http://golancourses.net/2012spring/) at the [CMU School of Art](http://www.cmu.edu/art/)

Templates for receiving skeleton tracking [Open Sound Control](http://opensoundcontrol.org/introduction-osc) messages from Ryan Challinor's [Synapse for Kinect](http://synapsekinect.tumblr.com/post/6307790318/synapse-for-kinect) application

Download [Synapse for Kinect](http://synapsekinect.tumblr.com/post/6305020721/download) and get started with a template project for one of the following creative coding environments:  

* [Processing](http://processing.org/)
	* requires the [OscP5 library](http://www.sojamo.de/libraries/oscP5/)
	
<!--
* [OpenFrameworks](http://www.openframeworks.cc/)
	* currently requires OF version 007
	* make sure to copy the SynapseReceiver folder into the openframeworks/apps/myApps folder (it must be 3 levels deep)
* [Max](http://cycling74.com/)
	* requires the [CNMAT Everything for Max package](http://cnmat.berkeley.edu/downloads) for the (OSC-route) object
* [Pure Data Extended](http://puredata.info/)
	* requires Pd-Extended for the [OSCroute] and [udpreceive] objects (part of the mrpeach external included in Pd-Extended)
-->

Make sure your kinect is plugged in and Synapse is running. You will need to make the [Kinect psi pose](https://www.google.com/search?q=kinect+psi+pose&hl=en&prmd=imvns&tbm=isch&tbo=u&source=univ&sa=X&ei=qP4qT6HNBIOChQfN0KTRCg&ved=0CDgQsAQ&biw=1463&bih=1016) for the skeleton tracker to find you and start sending joint data.

Further info:

* the Windows install requires some [specific driver steps](http://synapsekinect.tumblr.com/post/6698860570/windows-install-instructions)
* Synapse uses ports 12345 & 12347 by default for outbound OSC communication, 2 outbound ports to support 2 simulataneous applications
* Synapse receives OSC on port 12346 and joint positions must be requested periodically (every 2-3 seconds)
* the Synapse window size is 640 x 480, useful in realtion to joint coordinate positions
* here is the [Synapse OSC communication spec](http://synapsekinect.tumblr.com/post/6307752257/maxmsp-jitter)