


(
SynthDef(\cfstring1, { arg i_out, freq = 160, gate = 1, pan, amp=0.1, lf = 50,hf = 12000, atk = 0.001,dcy = 1;
	    var out, eg, fc, osc, a, b, w;
	    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, lf, hf);
	    osc = Mix.fill(4, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.1;
	    eg = EnvGen.kr(Env.asr(atk, 1, dcy), gate, doneAction:2);
	    out = eg * RLPF.ar(osc, fc, 0.1);
	    #a, b = out;
	    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;
)
(
p = Pbind(
    [\degree, \dur], Pseq([[0, 0.1], [2, 0.1], [4, 0.1], [5, 0.1], [2, 0.1]], inf),
	    \amp, 0.07, \octave, [4,5,6], \instrument, \cfstring1, \mtranspose, [0,2,4], \atk, 0.01,\dcy, [0.2,1.1,2]).play;
q = Pbind(
    [\degree, \dur], Pseq([[0, 8], [2, 6], [5, 9], [1, 10], [4, 8]], inf),
	    \amp, [0.3,0.4,0.5], \octave, [1,2,3], \instrument, \cfstring1, \mtranspose, [0], \hf,[90,200,400], \atk, 2,\dcy, 3).play;


)
