(
// moto rev
{
	RLPF.ar(
		LFPulse.ar(
			SinOsc.kr(0.2, 0, 10, 21)
			, 0.1)
		, 200, 0.1).clip2(0.4)!2
}.play)

(
// moto rev
{
	RLPF.ar(
		LFPulse.ar(
			MouseX.kr(0.2,100,1.0)
			, 0.1)
		, 100, 0.1).clip2(0.4)!2
}.play)
