(
	SynthDef("samplePlayer", { |out=0,bufnum,gate = 1 ,attack = 0.001, release = 0.001|
	
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(bufnum.numChannels, bufnum, BufRateScale.kr(bufnum));
	    Out.ar( out, buf * envelope)
	}).send(s);


)

s.sendMsg("/b_allocRead",111,"sounds/memo1.wav");
s.sendMsg("/s_new", "samplePlayer", 2003, 1, 1,"bufnum",111);
	

s.sendMsg("/b_allocRead",111,"sounds/SC_130306_133611.aiff");
s.sendMsg("/s_new", "samplePlayer", 2003, 1, 1,"bufnum",111);

f = SoundFile.collect("sounds/*");

