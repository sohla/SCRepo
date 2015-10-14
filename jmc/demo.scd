(
SynthDef(\sawFilt, { |out = 0, freq = 440, amp = 0.1, gate = 1, cf =
100, wobble = 3, t_bd, t_sd, pw = 0.4|
    var base = Splay.ar(RLPF.ar(Pulse.ar(freq *
[0.99,0.5,1.01],pw),cf.lag(0.05),0.3).madd(SinOsc.ar(wobble).range(0.5,4)).sin)
* amp;
    var env = Linen.kr(gate, attackTime: 0.05, releaseTime: 0.15,
doneAction: 2);
    var sig = base * env;
    var bd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_bd,SampleDur.ir),1000),30,0.5,5).sin*2);
    var sd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_sd,SampleDur.ir),1000),120,0.75,PinkNoise.ar(2!2)).sin*2);
    sd = HPF.ar(sd,60);
    sig = tanh(GVerb.ar(HPF.ar(base * env,30), 70, 11, 0.15)*0.5 + sig
+ bd + sd);
    Out.ar(out, sig);
}).add;
)

(
p = Pfset({
    s.bind {
        ~id = Synth(\sawFilt);
        ~amp = 0.05;
    };
    },
        Ppar([
        Pbind(\type, \set,
            \args, #[freq,amp],
            \freq, Pseq([49,47,50,48]-12,inf).midicps,
            \dur, 4,
        ),
        Pbind(\type, \set,
            \args, #[cf],
            \cf, Pseq([100,Prand([700,400,1100],3)],inf),
            \stutter, Prand([1,2,4,8],inf),
            \dur, PdurStutter(Pkey(\stutter)*2, 2),
        ),
        Pbind(\type, \set,
            \args, #[wobble],
            \wobble, Pxrand([3,1.5,6],inf),
            \dur, Prand([2,1],inf),
        ),
        Pbind(\type, \set,
            \args, #[t_bd],
            \t_bd, Pseq([1,0,0,1],inf),
            \dur, 0.5,
        ),
        Pbind(\type, \set,
            \args, #[t_sd],
            \t_sd, Pseq([0,0,1,0],inf),
            \dur, 0.5,
        ),
        Pbind(\type, \set,
            \args, #[pw],
            \pw, Prand([0.4,0.3,0.5],inf),
            \dur, 2,
        ),
    ]),
    {
        s.bind {
            ~id.release;
        }
    }
).play;
)

