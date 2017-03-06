(
{
	var root, scale, s;
			// wind chords
	var trig, p, n, exc, x, base, range;
		//root = rrand(3,6);
		root = 14;
		scale = #[0,19,11];
		n = 5;
		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 1.25, -0.25));
		s = (Klank.ar(`[Array.fill(n, {(scale.choose  + root).midicps}),nil,Array.fill(n, {rrand(0.1,2.0)})], exc) * 0.2).softclip;

		10.do({ s = AllpassN.ar(s, 0.05, [0.05.rand, 0.05.rand], 3) });
		s = LeakDC.ar(s) * 0.4
}.play;
)
