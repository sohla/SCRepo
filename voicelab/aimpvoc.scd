


(
SynthDef(\aimpvoc, {|buffer = 0, frq = 100, amp = 1|

	var player,voco,kernal;
	var a = 0;

	kernal = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1);
	player = SinOsc.ar(frq,amp);

	15.do ({arg i;
		x = HPF.ar(LPF.ar(player,75*(1.5**i)),50*(1.5**i));
		z = HPF.ar(LPF.ar(kernal,75*(1.5**i)),50*(1.5**i));
		z = PeakFollower.ar(z, 0.1);
		x = x*z;
		a = a+x; });

	Out.ar(0,[a,a]);

}).send(s);
)

c = Buffer.read(s, "~/Music/sounds/darkforest.wav".standardizePath);
(
x = Synth(\aimpvoc,[\buffer,c]).autogui(specs:
	(
		\frq: [100,1000,\exp,1,0],
		\amp: [0,1,\lin,0.1,0],
));
)