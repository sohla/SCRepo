NetAddr.langPort; // retrieve the current port SC is listening to

NetAddr.localAddr; // retrieve the current IP and port

NetAddr.disconnectAll
n = NetAddr.new("192.168.0.116", 58100); // create the NetAddr
// create the OSCresponderNode
o = OSCresponderNode.new(nil, "/cue/1/start", { arg time, resp, msg; [time,resp,msg].postln; } ).add;


o.remove; // remove the OSCresponderNode when you are done.


o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/goodbye', n);
o.free;    // remove the OSCFunc when you are done.


OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false);


// simple example passing everything over OSC : msg needs to contain path with /server
(
	o = OSCresponderNode.new(nil, "/server", { |time, resp, msg|

		msg.postln;
		msg.removeAt(0);
		s.listSendMsg(msg);

	}).add;

)


o.remove;




(
a = [\default];
d = Dictionary.new;
a.do({|item,i|

	n = Synth(item, [\freq, 440]).nodeID;
	s.sendMsg(\n_run,n,1);
	d.add(item -> Dictionary.newFrom(List[
		\id,n
	]));


});


)
// OSC command /patch1 /set /volume 3

thisProcess.openPorts




//sending msg with ip/port
b = NetAddr.new("169.254.191.114", 7772);    // create the NetAddr
b.sendMsg("/go",66);    // send the application the message "





b = NetAddr.new("192.168.0.177 ", 7774);    // create the NetAddr
b.sendMsg("/ard/aaa");    // send the application the message "
