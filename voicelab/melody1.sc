


(
SynthDef(\cfstring1, { arg i_out, freq = 160, gate = 1, pan, amp=0.1, lf = 50,hf = 18000, atk = 0.001,dcy = 1;
	    var out, eg, fc, osc, a, b, w,verb;
	    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, lf, hf);
	    osc = Mix.fill(4, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.1;
	    eg = EnvGen.kr(Env.asr(atk, 1, dcy), gate, doneAction:2);
	    out = eg * RLPF.ar(osc, fc, 0.1);
	    #a, b = out;
		verb = FreeVerb2.ar(a, b, 0.7, 0.85, 0.5, 1.0);
		Out.ar(i_out,verb);
}).add;
)


(

	r = Pbind(
	[\degree, \dur], Pseq([[0, 0.1], [2, 0.1], [4, 0.1], [5, 0.1], [2, 0.1]], inf),
	\amp, 0.04, \octave, [8,9,10], \instrument, \cfstring1, \mtranspose, [0,2,4], \atk, 0.01,\dcy, [1.2,1.1,1]).play;

p = Pbind(
    [\degree, \dur], Pseq([[0, 1], [2, 2], [4, 2], [5, 1], [2, 1]], inf),
	    \amp, 0.07, \octave, [4,5,6], \instrument, \cfstring1, \mtranspose, [0,2,4], \atk, 2.01,\dcy, [2.2,4.1,8]).play;

q = Pbind(
    [\degree, \dur], Pseq([[0, 8], [2, 6], [5, 9], [1, 10], [4, 8]], inf),
	    \amp, [0.3,0.2,0.1], \octave, [2,4,5], \instrument, \cfstring1, \mtranspose, [0], \hf,[300,1600,2000], \atk, 4,\dcy, 7).play;



)
	arpSynth = Pbind(
	[\degree, \dur], Pseq([[0, 0.1], [2, 0.1], [4, 0.1], [5, 0.1], [2, 0.1]], inf),
	\amp, 0.04, \octave, [4,5,6], \instrument, \cfstring1, \mtranspose, [0,2,4], \atk, 0.01,\dcy, [0.2,1.1,2]).play;
