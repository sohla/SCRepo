(

// local sc server
m = NetAddr(NetAddr.localAddr.ip, NetAddr.localAddr.port); // loopback

// listen to a OSC message. this time set it manually
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, \ls, m);



Pbind(
	\instrument,\cfstring1,
	\tempo,4,
    \note, Pseq([0, 5, 4],inf),
    \sustain, Pseq([1, 0.5, 1],inf),
	\amp, Pseq([1,0.4,0.1],inf),
    \dur, Pseq([1.5, 0.8, 0.8],inf),
	\finish, { currentEnvironment.postln },
	// \ls, Pfunc({|e| m.sendMsg(\ls, e.amp.value)}),
	).play;
)

o.free;
