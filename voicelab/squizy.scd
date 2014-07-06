(
SynthDef(\squizy, {|buffer = 0, frq = 52, mul = 131, add = 0.4|

	var player,sq;

	player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;

	sq = Squiz.ar(player, MouseX.kr(1, 100, 1), zcperchunk: MouseY.kr(1, 10), mul:0.5).dup;
	Out.ar(0,sq);

}).send(s);
)
p = "~/Music/sounds/Original Intro and Questions.aif".standardizePath;
c = Buffer.read(s,p);

(
x = Synth(\squizy,[\buffer,c]).autogui(specs:
	(
		\frq: [0.001,400,\lin,0.01,52],
		\mul: [0,1400,\lin,1,131],
		\add: [0.1,10,\lin,0.1,0.4]
));
)

