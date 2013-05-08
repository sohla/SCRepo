(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq;
		root = rrand(3,126);
		root = 	28;
		scale = #[0,4,7];
			freq =  root.midicps;
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
			s = (Klank.ar(`[
					Array.series(12, freq, freq),
					Array.geom(12,1,rrand(0.7,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip;
}.play;
)

