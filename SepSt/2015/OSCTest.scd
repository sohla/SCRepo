

// simple example passing everything over OSC : msg needs to contain path with /server
// message form eg: /sc /s_new default 1000 1 1 pitch 39
(
	o = OSCresponderNode.new(nil, "/sc", { |time, resp, msg|

		msg.removeAt(0);
		msg.postln;
		s.listSendMsg(msg);

	}).add;

)

o.remove;


//
// global dictioanry of samples with buffers
//
// sample root path
// list of samples to load
//


(

var gf = 220.0;

	SynthDef("\sin_wave", { |frq=440.0 ,db=(-12.0)|

		var sig;
		sig = SinOsc.ar(gf, 0.0, db.dbamp);

		Out.ar(0, [sig,sig]);

	}).play(s);

)


//
//


s.sendMsg("/b_allocRead",1002,"/Users/soh_la/Music/sounds/emilyCasual.wav")

s.sendMsg("/s_new","\echoShifter",1111,1,1);

s.sendMsg("/b_free",1002)

s.queryAllBuffers

s.freeAll
//
//

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


