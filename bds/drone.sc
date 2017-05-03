(
	SynthDef(\cabinDrone, {arg note = 64;

	var trig, p, sig, exc, x, freq;
		freq = note.midicps;
		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
		sig = (Klank.ar(`[
				Array.series(12, freq, freq),
				Array.geom(12,1,rrand(0.7,0.9)),
				Array.fill(12, {rrand(1.0,3.0)})
			], exc) * 0.1).softclip * 0.5;
	Out.ar(0,sig);

}).send(s);

)



(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq;
		root = 28+(12*0);
		scale = #[0,6,13];
			freq = (scale.choose + root).midicps;
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
			s = (Klank.ar(`[
					Array.series(12, freq, freq),
					Array.geom(12,1,rrand(0.7,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip * 0.5;
}.play;
)

