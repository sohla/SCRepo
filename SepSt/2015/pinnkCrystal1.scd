s.prepareForRecord
s.record
s.stopRecording
(
{
		var mix, out, n=4;
		r = LFNoise0.kr(rrand(2.8,30.0), 1,1).squared * MouseX.kr;
		mix = Klank.ar(
			`[
				Array.fill(n, { exprand(1.0,20.0) }),
				nil,
				Array.fill(n, { 0.4.rand })
			],
			Blip.ar(r, [rrand(2,20),rrand(2,25)], 0.1)
		).fold2(0.2).cubed * 12;
		mix = Mix.arFill(3, { CombL.ar(mix, 0.1, 0.03.linrand, 4.0.linrand) });
		out = mix.distort * 0.5;
		6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
		out = LeakDC.ar(out);
}.play
)
