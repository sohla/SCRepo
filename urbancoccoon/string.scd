
//28,40,52
(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq,notes,mx,notesBuffer;
		

		root = rrand(3,126);
		root = 	38;
		scale = #[0];
		mx = MouseX.kr(0, 15);
		notes = FloatArray[0,2,3,5,7,8,10];
		notesBuffer = Buffer.alloc(s,notes.size,1,{|b|b.setnMsg(0,notes)});


		freq =  DegreeToKey.kr(notesBuffer.bufnum,mx,12,1,root).midicps;

		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
		s = (DynKlank.ar(`[
				Array.series(12, Lag.kr(freq,0.8), Lag.kr(freq,0.9)),
				Array.geom(12,1,rrand(0.7,0.9)),
				Array.fill(12, {rrand(1.0,3.0)})
			], exc) * 0.1).softclip;
}.play;
)

