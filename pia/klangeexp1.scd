(
// change freqs and ringtimes with mouse
{ Ê Ê Ê 
	var freqs, ringtimes,trig,dec,out;

//		freqs = [800, 1071, 1153, 1723].normalize(100,10000) * MouseX.kr(0.5, 2, 1);
		freqs = Array.fill(10, { |i| 440 + (10000.0.linrand * i)} )* MouseX.kr(1, 1.05, 1);
		ringtimes = [1, 1, 1, 1] * 9;
		trig = Impulse.kr(MouseY.kr(0.05, 10, 1), 0, 0.1);
		dec = Decay2.kr(trig, 0.3 * trig, 0.9 * trig);
	
	Ê Ê Êout = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.1;
	
		6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
		out = LeakDC.ar(out);
			
}.play;
)
		