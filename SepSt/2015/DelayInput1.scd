(
// echo input
{
	var in;
	in = AudioIn.ar([1,2], 0.5);
	CombL.ar(
		in,
		0.5, 				// max delay time
		MouseX.kr(0,0.5),	// mouse x controls delay time
		0.005,				// echo 60 dB decay time in seconds
		1
	)
}.play
)




(
// echo input
{
	var in;
	in = AudioIn.ar([1,2], 0.5);
	DelayC.ar(
		in,
		2.0,
		LFBrownNoise0.ar(3, 1, 2, 1.4, 0.6)
	)
}.play
)



(
SynthDef("help-LFNoise0", { arg out=0;
    Out.ar(out,
        SinOsc.ar(
            LFBrownNoise0.ar(4, 1, 2, 400, 800),
            0, 0.2
        )
    )
}).play;
)



(
// shift echo input
{
	var in, trig, delayTime, a, freq;
	in = AudioIn.ar([1,2], 0.5);
	a = Diwhite(0, 1000, inf);

	trig = Impulse.kr(MouseX.kr(1, 100, 1));

	freq = 0.001 + Demand.kr(trig, 0, a) / 2000;

	CombL.ar(
		in,
		0.5, 				// max delay time
		freq,	// mouse x controls delay time
		0.005,				// echo 60 dB decay time in seconds
		1
	)
}.play
)

