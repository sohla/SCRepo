(
	
	// this will record to the disk
	SynthDef("help-Diskout", {|bufnum|
		DiskOut.ar(bufnum, In.ar(0,2));
	}).send(s);



	SynthDef("\saw_wave", { |frq=440.0 ,db=(-3.0)|
	
		var sig;
		sig = Saw.ar(frq, db.dbamp);
		
		Out.ar(0, [sig,sig]);
	
	}).send(s);

	SynthDef("\sin_wave", { |frq=440.0 ,db=(-3.0)|
	
		var sig;
		sig = SinOsc.ar(frq, 0.0, db.dbamp);
		
		Out.ar(0, [sig,sig]);
	
	}).send(s);

	SynthDef("\blip_wave", { |frq=440.0, numharm=2 ,db=(-3.0)|
	
		var sig;
		sig = Blip.ar(frq, numharm, db.dbamp);
		
		Out.ar(0, [sig,sig]);
	
	}).send(s);


	SynthDef("\brown_wave", { |db=(-3.0)|
	
		var sig;
		sig = BrownNoise.ar(db.dbamp);
		Out.ar(0, [sig,sig]);
	
	}).send(s);

	SynthDef("\pink_wave", { |db=(-3.0)|
	
		var sig;
		sig = PinkNoise.ar(db.dbamp);
		Out.ar(0, [sig,sig]);
	
	}).send(s);

	SynthDef("\white_wave", { |db=(-3.0)|
	
		var sig;
		sig = WhiteNoise.ar(db.dbamp);
		
		Out.ar(0, [sig,sig]);
	
	}).send(s);


	
	SynthDef(\trig_demo, { |freq, gate = 1, t_trig = 1|	// t_trig here
		var	env = Decay2.kr(t_trig, 0.1, 1.0),
			sig = SinOsc.ar(freq, 0, env)
				* Linen.kr(gate, 0.01, 1.0, 0.1, doneAction: 2);
		Out.ar(0, sig ! 2)
	}).send(s);

)


