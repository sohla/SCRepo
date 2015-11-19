(
// analog bubbles
{
	f = LFSaw.kr(0.05, 0, 40, LFSaw.kr([8,7.12], 0, 3, 80)).midicps; // glissando function
	CombN.ar(SinOsc.ar(f, 0, MouseY.kr(0.0,0.02)), 0.2, 0.2, 4) // echoing sine wave
}.play)
