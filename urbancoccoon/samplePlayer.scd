(
	SynthDef("monoSamplePlayer", { 
		
		|out=0,gate = 1 ,foh=0.5,head=0.5, attack = 0.001, release = 0.001,
		bufnum|
	
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum));
		var mix = buf * envelope;
	    Out.ar( [0,1], mix * head) + 	Out.ar( [2,3], mix * foh)

	}).send(s);

)

(
	SynthDef("stereoSamplePlayer", { 
		|out=0,gate = 1 ,foh=0.5,head=0.5, attack = 0.001, release = 0.001,
		bufnum|
			
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
		var mix = buf * envelope;
	    Out.ar( [0], mix * head) + Out.ar( [2], mix * foh);
	}).send(s);


)

s.sendMsg("/b_allocRead",111,"sounds/memo1.wav");
s.sendMsg("/s_new", "monoSamplePlayer", 2003, 1, 1,"bufnum",111,"channels",2);
s.sendMsg("/n_set",2003,"head",0.03);
s.sendMsg("/n_set",2003,"foh",3);
s.sendMsg("/n_set",2003,"foh",1);
	

s.sendMsg("/b_allocRead",111,"sounds/SC_130306_133611.aiff");
s.sendMsg("/s_new", "stereoSamplePlayer", 2003, 1, 1,"bufnum",111);
s.sendMsg("/n_set",2003,"head",0.01);
s.sendMsg("/n_set",2003,"foh",3);
s.sendMsg("/n_set",2003,"foh",1);

f = SoundFile.collect("sounds/*");

