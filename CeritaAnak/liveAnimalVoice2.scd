(
// ring modulated and resonant filtered input
{
	var input, modulator,sn;
	input = AudioIn.ar([1,2],0.8);
	sn = PeakFollower.ar(input,0.01);

	modulator = SinOsc.ar(
				MouseX.kr(10,4000,'exponential'),	// mouse x controls ring mod freq
				[0,0.5pi]						// offset phase ofone osc by 90 degrees
			);
	RLPF.ar(
		(input * 0.2) + (input * modulator * 0.8), 					// do ring modulation
		MouseY.kr(100, 12000, 'exponential'), 	// mouse y controls cutoff freq
		0.1)								// bandwidth ratio = 1/Q
}.play
)