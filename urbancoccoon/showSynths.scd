(
	SynthDef("monoSamplePlayer", { 
		
		|out=0,gate = 1 ,foh=0.5,head=0.5, attack = 0.001, release = 0.001,
		bufnum|
	
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum));
		var mix = buf * envelope;
	    Out.ar( [0,1], mix * head) + 	Out.ar( [2,3], mix * foh)

	}).writeDefFile();

)

(
	SynthDef("stereoSamplePlayer", { 
		|out=0,gate = 1 ,foh=0.5,head=0.5, attack = 0.001, release = 0.001,
		bufnum|
			
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
		var mix = buf * envelope;
	    Out.ar( [0], mix * head) + Out.ar( [2], mix * foh);
	}).writeDefFile();


)


(

	SynthDef("streetscape", { 
		
		|out=0,gate = 1 ,foh=0.5,head=0.5, attack = 0.001, release = 0.001,
		bufnum, hpf=300.0f, filterfrq=15000, filteramp = 1.0, decaytime=0.01,chaosfreq=0,chaosamp=400|
	
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum));
		var sampleplayer = buf * envelope * 4;
		var verb;
		var eq;
		var comp;
		var filter;
		var mix;
		
		comp =     Compander.ar(sampleplayer,sampleplayer
				        thresh: 0.9,
				        slopeBelow: 1,
				        slopeAbove: 0.3,
				        clampTime: 0.01,
				        relaxTime: 0.01
				    );

		filter = HPF.ar(comp,hpf);
		
		eq = MoogFF.ar(filter,Lag.ar(LorenzL.ar(chaosfreq),3e-3)*chaosamp+filterfrq, filteramp);

		mix = [eq,DelayN.ar(eq,0.01,0.01)];
		Out.ar( [0], mix * head) + Out.ar( [2], mix * foh);


	}).writeDefFile();


)