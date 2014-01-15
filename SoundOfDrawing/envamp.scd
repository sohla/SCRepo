
	d = Buffer.read(s,"sounds/adventure.wav");


(
// use input amplitude to control SinOsc frequency - use headphones to prevent feedback.
{

	var pb,sn,sc,cmp,si;
	
	si = SoundIn.ar(0);
	
	pb = PlayBuf.ar(
			2, 
			d, 
			BufRateScale.kr(d), 
			loop: 1)
		/*
		 * 
	
			Amplitude.kr(
				si,
				0.01,
				0.01,
				1,
				0
			)
	*/
	;
	
	sc = HenonC.ar(
	
		//MouseX.kr(20, SampleRate.ir)
			Amplitude.kr(
				si,
				0.01,
				0.01,
				SampleRate.ir*20,
				10
			)
		
	) * 0.2;	

	sn = SinOsc.ar(
			Amplitude.kr(
				si,
				0.01,
				0.01,
				1000,
				100
			),
			0,
			Amplitude.kr(
				si,
				0.01,
				0.01,
				1,
				0
			)
		);
	
/*
	sn = SinOsc.ar(
			Amplitude.kr(
				si,
				0.01,
				0.01,
				1200,
				1000
			),
		0,
		0.5
		);
		
*/		
	cmp = Compander.ar(pb, sn,
		thresh: 0.04,
		slopeBelow: 8,
		slopeAbove: 1,
		clampTime: 0.3,
		relaxTime: 0.1
	);

		
	[cmp,cmp]
	



}.play;
)



d.free;

