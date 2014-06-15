(
SynthDef(\cfstring1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1,rel = 1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(0.1, 1, rel), gate, doneAction:2);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

)

(
	e = Pbind(
    \degree, Pseq((0..12), inf),
    \dur, 0.2,
    \instrument, \cfstring1
).play; // returns an EventStream
)


(
f = Pbind(
    \degree, Pseq((-12..0), inf),
    \dur, 0.4,
    \instrument, \cfstring1
).play; // returns an EventStream
)

(
e.stream = Pbind(
    \degree, Pseq([0, 1, 2, 4, 6, 3, 4, 8], inf),
    \dur, Prand([0.2, 0.4, 0.8], inf),
    \amp, 0.05, \octave, 5,
    \instrument, \cfstring1, \ctranspose, 0,
\rel,0.01
).asStream;
)

(
e.stream = Pbind(
    \degree, Pseq([0, 1, 2, 4, 6, 3, 4, 8], inf),
    \dur, Prand([0.1, 0.2, 0.3,0.3,0.3], inf),
    \amp, 0.05, \octave, 5,
    \instrument, \cfstring1, \ctranspose, 0
).asStream;
)

( 
e.stream = Pbind(
    \degree, Pxrand([0, 1, 2, 4, 6, 3, 5, 7, 8], inf),
    \dur, Prand([0.2, 0.4, 0.8], inf), \amp, 0.05,
    \octave, 5, \instrument, \cfstring1
).asStream;
)

//////


(
p = Pbind(
    \degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 2),
    \dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 2)
).play;
)


(
p = Pbind(
    \degree, Pslide((-6, -4 .. 12), 2, 6, 1, 0),
    \dur, Pseq(#[0.1, 0.1, 0.2], inf),
    \sustain, 0.15
).play;
)


(
p = Pbind(
    \degree, Prand([0, 1, 2, 4, 5], inf),
    \dur, 0.125 / 4
).play;
)

(
p = Pbind(
    \degree, Ptuple([
        Pseries(7, -7, 8),
        Pseq([9, 7, 7, 7, 4, 4, 2, 2], 1),
        Pseq([4, 4, 4, 2, 2, 0, 0, -3], 1)
    ], inf),
    \dur, 0.125
).play;
)

(
p = Pbind(
    \degree, Pseries(-7, 1, 15),
    \dur, Pgeom(0.5, 0.89140193218427, 15)
).play;
)


(
p = Pbind(
    \degree, Pseq([
        0, 1, 2, 0, 0, 1, 2, 0,
        2, 3, 4, \rest, 2, 3, 4, \rest
    ]),
    \dur, 0.25
).play;
)

(
	p = Pbind(
    \degree, Pif(
        0.5.loop.coin,
        Rest,
        Pseries(0, 1, inf).fold(-7, 7)
    ),
    \dur, 0.125
).play;
)


p = Pbind(\degree, Pwhite(0, 7, inf), \dur, 0.25, \legato, 1).play;
p.stop;

p = Pmono(\default, \degree, Pwhite(0, 7, inf), \dur, 0.25).play;
p.stop;

(
SynthDef(\harpsi, { |outbus = 0, freq = 440, amp = 0.1, gate = 1|
    var out;
    out = EnvGen.ar(Env.adsr, gate, doneAction: 2) * amp *
        Pulse.ar(freq, 0.25, 0.75);
    Out.ar(outbus, out ! 2);
}).add;    // see below for more on .add
)
(
p = Pbind(
        // Use \harpsi, not \default
    \instrument, \harpsi,
    \degree, Pseries(0, 2, 8),
    \dur, 0.125
).play;
)