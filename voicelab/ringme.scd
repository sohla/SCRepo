(
SynthDef(\ringme, {|buffer = 0, mix = 0.2|

	var player,sel,fol;
	var modulator;
	var notes = #[0,4,7];
	var root = 42;

	//player = SoundIn.ar(0);
	player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
	fol = (PeakFollower.ar(player,0.01) * 100).round;

	modulator = SinOsc.ar( 30.midicps + fol.midicps,0,MouseY.kr(0,1));

	Out.ar(0,(player * modulator).dup);

}).send(s);
)

c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/darkforest.wav");
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/memo1.wav");


(
x = Synth(\ringme,[\buffer,c]).autogui(specs:
	(
		\mix: [0,1.0,\lin,0.01,0.2],
));
)
