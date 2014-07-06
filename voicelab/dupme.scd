(
SynthDef(\pitchit, {|buffer = 0, pitch = 1.0,frq = 2.4, amp = 0.2, add = 0.3,delay = 0.004, decay = 0.019|

	var player,sq;
	var grainSize = 0.4;
	var dly;
	//player = SoundIn.ar(0);
	player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
	sq = PitchShift.ar(player, grainSize,pitch,SinOsc.ar(frq,0,amp,add)).dup;
	dly = CombN.ar(sq,0.3,[delay,delay+0.01],decay);

	Out.ar(0,sq);

}).send(s);
)
p = "~/Music/sounds/Original Intro and Questions.aif".standardizePath;

c = Buffer.read(s,p);


 (
x = Synth(\pitchit,[\buffer,c]).autogui(specs:
	(
		\pitch: [0.25,2,\lin,0.1,1.3],
		\frq: [0.1,1000,\lin,0.1,2.4],
		\amp: [0,1.0,\lin,0.001,0.2],
		\add: [0,1.0,\lin,0.001,0.3],
		\delay: [0.001,0.3,\lin,0.001,0.004],
		\decay: [0.001,0.5,\lin,0.001,0.019]
		));
)
s.boot

x = {Squiz.ar(SinOsc.ar, MouseX.kr(1, 10, 1), zcperchunk: MouseY.kr(1, 10), mul:0.1).dup}.play(s);




