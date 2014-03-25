

(
SynthDef(\convol, {|buffer = 0, root = 44, mix = 0.2, size = 80, time = 1|

	var player,voco,kernal,comb,verb;
	var notes = #[0,5,10];
	// var dlys = #[0.5,0.52]*delay;
	// var dcys = #[0.543,0.523]*decay;
	var sel;

	//player = SoundIn.ar(0);
	 player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1)*0.01;
	kernal = Saw.ar((root+notes).midicps,0.5).dup;
	verb = GVerb.ar(player,16,time,0.41,0.19,15,-48,-9,-11);
	// comb = CombN.ar(player,dlys,dlys,dcys);
	voco = Vocoder.ar(kernal,verb,164);
	sel = LinSelectX.ar(mix,[voco,player]);
	Out.ar(0,sel);

}).send(s);
)

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/Original Intro and Questions.aif");
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/memo1.wav");


(
x = Synth(\convol,[\buffer,c]).autogui(specs:
	(
		\root: [20,90,\lin,1,44],
		\mix: [0,1.0,\lin,0.01,0.2],
		\size: [1,80.0,\lin,1,80],
		\time: [0.1,4.0,\lin,0.01,1],
));
)



{ Saw.ar(XLine.kr(40,4000,6),0.2) }.play;
{ SinOsc.ar(XLine.kr(40,4000,6),0.2) }.play;
