

(
{
	var root,scale,freqs, ringtimes,trig,dec,out;
		root = 78;
		scale = #[0,2,4,5,7,9,11];

		freqs = Array.fill(12, {(scale.choose  + root).midicps});
//		freqs = Array.rand(12, 400.0, 14000.0) + SinOsc.kr(0.1, 0.0,5.0);
		ringtimes = [1, 1, 1, 1] * 9;
		trig = Impulse.kr(MouseY.kr(0.1, 100, 'exponential'), 0, 1);
		dec = EnvGen.kr(Env.perc(0.03), trig, 0.2, doneAction: 0);
	
	Ê Ê Êout = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.2;
	
		6.do({ out = AllpassN.ar(out, 0.1, [0.1.rand, 0.1.rand], 3) });
		out = LeakDC.ar(out);

}.play;
)
