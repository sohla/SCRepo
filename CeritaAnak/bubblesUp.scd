(
{
	var out, lfoDepth, lfoRate, freq, filtered;
	lfoDepth = MouseY.kr(20, 8000, 1);
	lfoRate = MouseX.kr(0.1, 1, 1);
	freq = LFSaw.kr(lfoRate, 0, lfoDepth, lfoDepth * 1.2);
	filtered = RLPF.ar({WhiteNoise.ar(0.03)}.dup, freq, 0.1);
	out = CombN.ar(filtered, 0.6, 0.6, 5, 1, filtered);
	out
}.play;
)
