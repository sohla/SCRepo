(

SynthDef(\echoShifter, { |buffer = 0, shift = 0.1|

	var sig = 0;
	var in, trig, delayTime, a, freq, playBuf;
	in = AudioIn.ar([1,2], 0.5);
	a = Diwhite(0, 1000, inf);

	trig = Impulse.kr(MouseX.kr(1, 10, 0.1));

	freq = 0.001 + ((Demand.kr(trig, 0, a) / 1000) * shift);

	playBuf = PlayBuf.ar(2, buffer, BufRateScale.kr(buffer), doneAction:2);


	sig = CombC.ar(
		playBuf,
		shift,
		freq,
		0.005,
		1
	);

	Out.ar(0,sig);

}).send(s);

)


p = ("~/Music/sounds/emilyCasual.wav").standardizePath;
b = Buffer.read(s, p);
z = Synth(\echoShifter,[\buffer,b,'\shift',1]);
