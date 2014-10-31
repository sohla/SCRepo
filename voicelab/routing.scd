
s.boot
(
	SynthDef(
		"piaKlang",{
			arg amp=0.0,density=1.0,note = 64;
			var freqs, ringtimes,trig,dec,out;
		
			freqs = Array.fill(10, { |i| note.midicps + (i.linrand)} );
			ringtimes = [1, 1, 1, 1] * 9;
			trig = Impulse.kr(density, 0, 0.1);
			dec = Decay2.kr(trig, 0.3 * trig, 0.9 * trig);
		
			out = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.05 * amp;
		
			6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
			out = LeakDC.ar(out);
			Out.ar(0,[0,0,out,out])
		}
	).send(s);
)

a = Synth(\piaKlang,[\amp,0.5,\density,1.0,\note,57]);


