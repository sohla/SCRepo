
//28,40,52
(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq,notes,mx,my,notesBuffer,envelope;
		

		root = rrand(3,126);
		root = 	26+(12*2);
		scale = #[0];
		mx = MouseX.kr(0, 15);
		my = 0.2-MouseY.kr(0.001, 0.2,0.9);
		notes = FloatArray[0,2,3,5,7,8,10];
		notesBuffer = Buffer.alloc(s,notes.size,1,{|b|b.setnMsg(0,notes)});


		freq =  DegreeToKey.kr(notesBuffer.bufnum,0,12,1,root).midicps;
		envelope = EnvGen.kr(Env.asr(5,1.0,5, curve: \sin), 1, doneAction:2);

		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
		s = (DynKlank.ar(`[
				Array.series(12, Lag.kr(freq,0.8), Lag.kr(freq,0.9)),
				Array.geom(12,1,rrand(0.7,0.9)),
				Array.fill(12, {rrand(1.0,3.0)})
			], exc) * 0.3 * my).softclip * envelope;
}.play;
)



(
	SynthDef(
		"string",{
			arg gate=1,pitch;
var root, scale;
		var trig, p, s, exc, x, freq,notes,mx,my,notesBuffer,envelope;
		

		root = rrand(3,126);
		root = 	pitch;
		scale = #[0];
		mx = MouseX.kr(0, 15);
		my = 0.2-MouseY.kr(0.001, 0.2,0.9);
		notes = FloatArray[0,2,3,5,7,8,10];
		notesBuffer = Buffer.alloc(s,notes.size,1,{|b|b.setnMsg(0,notes)});


		freq =  DegreeToKey.kr(notesBuffer.bufnum,0,12,1,root).midicps;
		envelope = EnvGen.kr(Env.asr(0.01,1.0,5, curve: \sin), gate);

		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
		s = (DynKlank.ar(`[
				Array.series(12, Lag.kr(freq,0.8), Lag.kr(freq,0.9)),
				Array.geom(12,1,rrand(0.7,0.9)),
				Array.fill(12, {rrand(1.0,3.0)})
			], exc) * 0.3 * my).softclip * envelope;
			
		Out.ar(0,s*envelope);
		}
		
		
	).send(s);
)

s.sendMsg("/s_new", "string", s.nextNodeID, 1, 1,"pitch",38);
s.sendMsg("/n_set",2000,"gate",0);
