(
SynthDef(\sin, {
    arg out=0, amp=1, gate=1, freq=440;
    var ou;
    var env, envctl;
    env = Env([0,1,0,0,0], [0.2,0.2,0,0]).asArray;
    envctl = \env.kr(env);
    ou = SinOsc.ar(freq);
    ou = ou * EnvGen.kr(envctl, gate, doneAction:2);
    Out.ar(out, ou!2 * amp)
}).add;
)



(
p = Pbind(
        \type, \on,
        \instrument, \sin,
        \env, Pseq([
                [[0, 1, 0], [0.1, 0.4]],
                [[0, 0, 0, 0, 0], [0.1, 0.1, 0.1, 0.1]]
        ], inf).collect { |x| [Env(*x).asArray] },
    \dur, 1
).trace.play;
)


