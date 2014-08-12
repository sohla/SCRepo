(
	// sample and hold liquidities
	// mouse x controls clock rate, mouse y controls center frequency
{
	var clockRate, clockTime, clock, centerFreq, freq, panPos, patch;
	var pitches = #[0],mix;

	clockRate = MouseX.kr(0.5, 200, 1);
	clockTime = clockRate.reciprocal;
	clock = Impulse.kr(clockRate, 0.4);

	centerFreq = MouseY.kr(41-12, 100, 12);
	freq = Latch.kr((centerFreq + pitches.choose).midicps, clock);
	panPos = Latch.kr(WhiteNoise.kr, clock);


	patch = Array.fill(1, {
		CombN.ar(
			Pan2.ar(
				SinOsc.ar(
					Latch.kr((centerFreq + pitches.choose).midicps, clock),
					0,
					Decay2.kr(clock, 0.1 * clockTime, 0.9 * clockTime)
				),
				panPos
			),
			0.3, 0.3, 2
		)*0.1
	});



	mix = Mix.ar(patch);

	[mix*1.9,mix*1.8,
	mix*2,mix*2.2,
	mix/4,mix/4,
	mix*2.9,mix*2.9]



}.play;
)
	