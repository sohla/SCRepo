s.boot
(
SynthDef(\convol, {|buffer = 0, root = 48, mix = 0.2, hpf = 800, time = 0.1|

	var player,voco,kernal,comb,verb,verb2;
	var notes = #[0,7,12,16,19,24];
	var sel;

	//player = SoundIn.ar(0);
	 player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1)*0.1;
	kernal = Saw.ar((root+notes).midicps,0.5).dup;
	//verb = GVerb.ar(HPF.ar(player,hpf),16,time,0.41,0.19,15,-48,-9,-11);
	voco = Vocoder.ar(kernal,player,164);
	sel = LinSelectX.ar(mix,[voco,HPF.ar(player,hpf)]) * 0.06;
	verb2 = GVerb.ar(sel,20,1.1,0.42,0.19,15,-23,-9,-13);
	Out.ar(0,verb2);

}).send(s);
)

p = "~/Music/sounds/Original Intro and Questions.aif".standardizePath;
c = Buffer.read(s, p);
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/memo1.wav");


(
x = Synth(\convol,[\buffer,c]).autogui(specs:
	(
		\root: [20,90,\lin,1,48],
		\mix: [0,1.0,\lin,0.01,0.6],
		\size: [1,80.0,\lin,1,800],
		\time: [0.01,2.0,\lin,0.01,0.4],
));
)



{ Saw.ar(XLine.kr(40,4000,6),0.2) }.play;
{ SinOsc.ar(XLine.kr(40,4000,6),0.2) }.play;
a = Pbind(
    [\degree, \dur],
	Pseq([[0, 1], [2, 2], [4, 2], [5, 1], [2, 1]], inf),
	\amp, 0.07,
	\octave, [4,5,6],
	\instrument, \cfstring1,
	\mtranspose, [0,2,4],
	\atk, 2.01,
	\dcy, [2.2,4.1,8]).play;

b = Pbind(
    [\degree, \dur],
	Pseq([[0, 8], [2, 6], [5, 9], [1, 10], [4, 8]], inf),
	\amp, [0.1,0.2,0.5],
	\octave, [1,2,3],
	\instrument, \cfstring1,
	\mtranspose, [0],
	\hf,[90,200,400],
	\atk, 2,
	\dcy, 3).play;
});
