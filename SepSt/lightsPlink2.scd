

(
	// sample and hold liquidities
	// mouse x controls clock rate, mouse y controls center frequency
{
	var clockRate, clockTime, clock, centerFreq, freq, panPos, patch;
	var pitches = #[0,5,7],mix;
	var index = 0;

	clockRate = MouseX.kr(0.5, 12, 1);
	clockTime = clockRate.reciprocal;
	clock = Impulse.kr(clockRate, 0.4);

	centerFreq = MouseY.kr(0,12, 12);

	index = MouseY.kr(0,1.0) * 6.0;


	panPos = Latch.kr(WhiteNoise.kr, clock);


	patch = Array.fill(3, { arg i;

			clock = Impulse.kr(clockRate , 0.4);

		CombN.ar(
			Pan2.ar(
				SinOsc.ar(
					Latch.kr(( (0 + 28 + (12 * index.round)) + pitches.choose ).midicps, clock),
					0,
					Decay2.kr(clock, 0.1 * clockTime, 0.9 * clockTime)
				),
				panPos
			),
			0.3, 0.3, 2
		)*0.03
	});



	mix = Mix.ar(patch);

	[mix*1.9,mix*1.8,
	mix*2,mix*2.2,
	mix/4,mix/4,
	mix*2.9,mix*2.9]



}.play;
)

