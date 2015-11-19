
	SynthDef("\sin_wave", { |frq=16000.0 ,db=(-28.0)|

		var sig;
		sig = SinOsc.ar(frq, 0.0, db.dbamp);

		Out.ar(0, [sig,sig,0,0,sig,sig]);

	}).play(s);