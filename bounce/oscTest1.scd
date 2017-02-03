(

n = s.nextNodeID;
s.sendMsg("/s_new", "default", n, 0, 0, "freq", 200);

o = OSCFunc({ arg msg, time, addr, recvPort;

	//[msg, time, addr, recvPort].postln;

	((msg[2].asFloat + 1pi) / 1 ).postln;

	// s.sendMsg("/n_set", n, "freq", 100 + (80 * msg[3].asFloat) );
	// s.sendMsg("/n_set", n, "amp", 0.1 +  (msg[2].asFloat + 1pi) / 2pi );

}, '/gyro');

)
o.free;
s.sendMsg("/n_free", n);

s.queryAllNodes;


// talking to QLAb

b = NetAddr.new("10.1.1.3", 53000);    // create the NetAddr
b.sendMsg("/qlab", "go");    // send the application the messa

b.sendMsg("/select/1", "");    // send the application the messa
b.sendMsg("/cue/2/start", "");    // send the application the messa
b.sendMsg("/cue/1/start", "");    // send the application the messa
b.sendMsg("/cue/1/stop", "");    // send the application the messa

b.sendMsg("/cue/2/translationX -100", "");    // send the application the messa


o = OSCMonitor.new;     // make one
o.enable;            // turn it on
o.show;                // show them on gui, no po
o.watchStatus = true;
s.boot;
o.verbose = true;

o.disable;
o.watchStatus = false;

NetAddr.langPort;
