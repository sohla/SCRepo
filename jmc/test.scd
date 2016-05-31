(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\sin_grain_test, {arg gate = 1, amp = 1, envbuf;
    var pan, env, freqdev;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    // use WhiteNoise and mouse y to control deviation from center pitch
    freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: 2);
    Out.ar(0,
        GrainSin.ar(2, Impulse.kr(100), 0.1, 440 + freqdev, pan, envbuf) * env)
    }).add;

)
s.scope
// use built-in env
x = Synth(\sin_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);
[60].midicps


(
{

	GrainSin.ar(2,Impulse.kr(MouseX.kr(1,100)),0.03,[60,72].choose.midicps, (WhiteNoise.kr(1000) - 2000) / 1000   )
}.play
)


plot({ Decay.ar(Impulse.ar(1), 0.01) });
