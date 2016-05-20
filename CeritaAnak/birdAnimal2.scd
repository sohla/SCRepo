(
{

		Pan2.ar(
		RLPF.ar(LFPulse.ar(exprand(50,600), 2pi.rand, 0.5,

			Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
			* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand])).abs
		), exprand(100,2000), 0.2), 1.0.rand2);
}.play;
)