(
SynthDef(\ringme, {|buffer = 0, pitch = 40, range = 100|

	var player,sel,fol;
	var modulator;
	var notes = #[0,4,7];
	var root = 42;

	player = SoundIn.ar(0);
	//player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
	fol = (PeakFollower.ar(player,0.01) * range).lag(0,0.1);

	modulator = SinOsc.ar( pitch.midicps + fol.midicps,0,player) ;

	Out.ar(0,(player).dup);

}).send(s);
)

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/Original Intro and Questions.aif");
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/memo1.wav");


(
x = Synth(\ringme,[\pitch,34,\range,60]);


)
