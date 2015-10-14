(
var a, c, d, s, z, y;
// reverberated sine percussion
d = 16; // number of percolators
c = 5; // number of comb delays
a = 14; // number of allpass delays

play({
		// sine percolation sound :
	s = Mix.ar(Array.fill(d, { Resonz.ar(Dust.ar(2/d, 50), ([60,67,72,79,84]+24).choose.midicps, 0.003)}) );

		// reverb predelay time :
	z = DelayN.ar(s, 0.148);

		// 7 length modulated comb delays in parallel :
	y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(c,{0.02.rand}), 0.04, 0.05), 15));

		// chain of 4 allpass delays on each of two channels (8 total) :
	a.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

		// add original sound to reverb and play it :
	s+(0.2*y)
}))

