(
// harmonic tumbling
play({
	var f, p, z, trig,my;
	f = (55).midicps;	// fundamental frequency
	p = 20;	// number of partials per channel
	z = 0.0;	// start of oscil daisy chain
	my = MouseY.kr(0.1,20.0);
	trig = XLine.kr([10,10], 0.1, 60);	// trigger probability decreases over time
	p.do({ arg i;
		z = FSinOsc.ar(
				f * (i+1), 		// freq of partial
				0,
				Decay2.kr(
					Dust.kr(
						my,		// trigger rate
						0.02		// trigger amplitude
					),
					0.1.rand, 	// grain attack time
					0.3.rand	// grain decay time
				),
				z
		)
	});
	//z

	CombN.ar(z, 0.2, 0.2, 4)
}))