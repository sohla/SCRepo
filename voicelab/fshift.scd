

(
SynthDef(\fshift, {|buffer = 0, frq = 100, mul = 1, add = 0|

	var player,voco,kernal;
	var a = 0;

	 player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1);
	//player = SoundIn.ar(0);
	kernal = LFTri.kr(frq,0,mul,add);

	a= FreqShift.ar(player,kernal);
	Out.ar(0,[a,a]);

}).send(s);
)

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/Original Intro and Questions.aif");
(
x = Synth(\fshift,[\buffer,c]).autogui(specs:
	(
		\frq: [10,1000,\exp,1,0],
		\amp: [0,10,\lin,0.1,0],
		\mul: [0,1000,\lin,1,0],
		\add: [0,1000,\lin,1,0],
));
)
