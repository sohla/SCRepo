(
	SynthDef("pulsop", { |freq=278,amp=1.0,rate=5.0|
		var trg,sig;
		trg = Decay2.ar(Impulse.ar(rate,0,0.3), 0.1, 0.2);
		sig = Pulse.ar(freq,0.5,trg*amp);
		Out.ar(0, [sig,sig]);
	}).send(s);
)

s.sendMsg("/s_new", "pulsop", 2003, 1, 1);

s.sendMsg("/n_set",2003,"freq",440);
s.sendMsg("/n_set",2003,"rate",8);
s.sendMsg("/n_set",2003,\freq,240,\rate,3);


a = ["/n_set",2003];
a.asRawOSC

a.class
s.listSendMsg(a);
s.sendMsg(*a);

s.listSendBundle(0.0,[["/n_set",2003,\freq,840]]);




a = [1,2,3,4]
a.asCompileString


s.addr
//OSCFunc.trace(true); // Turn posting on




a = ["/n_set",2003,\freq,1840];
s.listSendMsg(a);
a.asRawOSC

c = Array.newFrom(a)
