
(
{
	var root, scale, s;
			// wind chords
	var trig, p, n, exc, x, base, range;
		//root = rrand(3,6);
		root = 52;
		scale = #[0,7,9,14,16];
		n = 5;
		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 1.25, -0.25));
		s = (Klank.ar(`[Array.fill(n, {(scale.choose  + root).midicps}),nil,Array.fill(n, {rrand(0.1,2.0)})], exc) * 0.2).softclip;

		60.do({ s = AllpassN.ar(s, 0.05, [0.05.rand, 0.05.rand], 3) });
		s = LeakDC.ar(s) * 0.2;
}.play;
)


(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq;
		root = 28;
		scale = #[0];
			freq = (scale.choose + root).midicps;
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
			s = (Klank.ar(`[
					Array.series(12, freq, freq),
					Array.geom(12,1,rrand(0.7,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip * 0.2;
}.play;
)
