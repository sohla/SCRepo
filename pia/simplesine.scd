(

	SynthDef(
		"simpleSine2",
		{
			arg freq=440,amp=0.1,sig;
			var trg;
			
			trg = Decay2.ar(Impulse.ar(2,0,0.3), 0.01, 0.3);

			sig = SinOsc.ar(freq,0,trg*amp);
			
			Out.ar(0,[sig,sig])
		}
	).send(s);

)
(
// define an echo effect
SynthDef("echo", { arg delay = 0.2, decay = 4;
	var in;
	in = In.ar(0,2);
	// use ReplaceOut to overwrite the previous contents of the bus.
	ReplaceOut.ar(0, CombN.ar(in, 0.5, delay, decay, 1, in));
}).send(s);
)


// dic

d = Dictionary[];
d.put("Scene 1",["/s_new", "simpleSine2", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2]);
d.put("Scene 2",["/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3]);


s.listSendMsg(d.at("Scene 1"));
s.listSendMsg(d.at("Scene 2"));


g = List["Scene 1","Scene 2"];



f = Dictionary[];

f.put("Scene 1",[
				["/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2],
				["/s_new", "simpleSine", z = s.nextNodeID, 1, 1, "freq", 840, "amp", 0.2]
				]);

f.put("Scene 2",[
				["/n_set", x, "freq", 600],
				["/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3]
				]);


s.listSendBundle(0.1,f.at("Scene 1"));


s.listSendBundle(0.1,f.at("Scene 2"));



// list
l = List[];
l.add(["/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2]);
l.add(["/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3]);


l.postln;


l.at(0).at(1).postln

s.listSendMsg(l.at(1));


l.do({arg item,i;
	s.listSendMsg(item);
});



//environment

e = Environment.make({
	~a = ["/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2];
	~b = ["/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3];
	});



e.use({~a}).postln
	

s.listSendBundle(0.01,
	[e.use({~a}),e.use({~b})]
	);



// bundles
s.listSendBundle(0.01,
	[["/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2],
	["/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3]]
	);

// simple
s.sendMsg("/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "freq", 440, "amp", 0.2);
s.sendMsg("/s_new", "echo", y = s.nextNodeID, 1, 1, "delay", 0.3, "decay", 3);


s.sendMsg("/n_set", x, "freq",700).postln;
s.sendMsg("/n_set", x, "freq", 440);

s.sendMsg("/n_free", x);
s.sendMsg("/n_free", y);

