(
// analog bubbles
{
	//f = LFSaw.kr(0.49, 0, 24, LFSaw.kr([1,1.23], 0, 2, 50)).midicps; // glissando function
	f = LFSaw.ar(MouseY.kr(0.1,3),0,20.5,MouseX.kr(40,80)).midicps;

	CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4)!2 // echoing sine wave
}.play)