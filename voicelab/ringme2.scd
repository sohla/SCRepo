(
SynthDef(\ringme, {|buffer = 0, pitch = 24, range = 210,delay = 0.04, decay = 0.19|

	var player,sel,fol;
	var modulator;
	var notes = #[0,4,7];
	var root = 42;
	var dly;
	//player = SoundIn.ar(0);
	player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
	fol = (PeakFollower.ar(player,0.01) * range).lag(0,0.1);

	modulator = SinOsc.ar( pitch.midicps + fol.midicps,0,player) ;

	dly = CombN.ar((modulator).dup,0.3,[delay,delay+0.01],decay);
	Out.ar(0,dly);

}).send(s);
)
p = "~/Music/sounds/Original Intro and Questions.aif".standardizePath;

c = Buffer.read(s,p);
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/memo1.wav");


(
x = Synth(\ringme,[\pitch,34,\range,60]);


)

(
x = Synth(\ringme,[\buffer,c]).autogui(specs:
	(
		\pitch: [10,100,\lin,1,24],
		\range: [0,400.0,\lin,1,210],
		\delay: [0.001,0.3,\lin,0.001,0.04],
		\decay: [0.001,0.5,\lin,0.001,0.19]
));
)
s.boot


(
{
    CombN.ar(
        SinOsc.ar(500.rrand(1000), 0, 0.2) * Line.kr(1, 0, 0.1),
        0.3,
        0.25,
        0.1
    )
}.scope;
)
