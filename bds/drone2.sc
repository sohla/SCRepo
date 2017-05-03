(
	SynthDef(\cabinDrone, {arg note = 64;

		var trig, p, sig, exc, x, freq, flt;

		freq = note.midicps;
		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));

		flt = LPF.ar(exc,MouseX.kr(50,20000,\exponential));

		sig = (DynKlank.ar(`[
				Array.series(12, freq, freq),
				Array.geom(12,1,rrand(0.7,0.9)),
				Array.fill(12, {rrand(0.001,0.01)}) * MouseY.kr(1.0,100)
			], flt) * 0.7).softclip * 0.7 * MouseButton.kr(1,0) * MouseY.kr(1.0,0.5);
		Out.ar(0,sig);

	}).send(s);

)


(

	var make,brake;

	make = { |name,params|

		x = Synth(name,params);
		[params].postln;

	};

	make.(\cabinDrone,[\note,82]);
	make.(\cabinDrone,[\note,40]);
)


x = Synth(\cabinDrone,[\note,52]);
x.free

