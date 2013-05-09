
(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain_test, {arg gate = 1, amp = 1, envbuf;
Ê Ê Ê Ê var pan, env, freqdev;
Ê Ê Ê Ê // use mouse x to control panning
Ê Ê Ê Ê pan = MouseX.kr(-1, 1);
Ê Ê Ê Ê // use WhiteNoise and mouse y to control deviation from center pitch
Ê Ê Ê Ê freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
Ê Ê Ê Ê env = EnvGen.kr(
Ê Ê Ê Ê Ê Ê Ê Ê Env([0, 1, 0], [1, 1], \sin, 1),
Ê Ê Ê Ê Ê Ê Ê Ê gate,
Ê Ê Ê Ê Ê Ê Ê Ê levelScale: amp,
Ê Ê Ê Ê Ê Ê Ê Ê doneAction: 2);
Ê Ê Ê Ê Out.ar(0,
Ê Ê Ê Ê Ê Ê Ê Ê GrainFM.ar(2, Impulse.kr(50), 0.1, 10440 + freqdev, 10200, LFNoise1.kr.range(1, 10),
Ê Ê Ê Ê Ê Ê Ê Ê Ê Ê Ê Ê pan, envbuf) * env)
Ê Ê Ê Ê }).send(s);

)

// use built-in env
x = Synth(\fm_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);
