
(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain_test, {arg gate = 1, amp = 0.1, envbuf;
� � � � var pan = 0, env, freqdev,car,freq;
� � � � // use mouse x to control panning
� � � � car = MouseX.kr(1, 10);
� � � � // use WhiteNoise and mouse y to control deviation from center pitch
� � � � freqdev = WhiteNoise.kr(80);
		freq = MouseY.kr(12, 100).midicps;
� � � � env = EnvGen.kr(
� � � � � � � � Env([0, 1, 0], [0.03, 0.03], \sin, 1),
� � � � � � � � gate,
� � � � � � � � levelScale: amp,
� � � � � � � � doneAction: 2);
� � � � Out.ar(0,
� � � � � � � � GrainFM.ar(2, Impulse.kr(100.9), 0.1,  freq + freqdev, car, LFNoise1.kr.range(1, 10),
� � � � � � � � � � � � pan, envbuf) * env)
� � � � }).send(s);

)

// use built-in env
x = Synth(\fm_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);
