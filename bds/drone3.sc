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
			], flt) * 0.5).softclip * 0.5 * MouseButton.kr(1,0) * MouseY.kr(1.0,0.3);
		Out.ar(0,sig);

	}).send(s);

)



s.sendMsg(\s_new,\cabinDrone,s.nextNodeID,0,1,\note,76)

s.queryAllNodes

s.sendMsg(\n_free,1180)

(
w = Window.new.front;

v = ListView(w,Rect(10,10,120,70))
    .items_([ "SinOsc", "Saw", "LFSaw", "WhiteNoise", "PinkNoise", "BrownNoise", "Osc" ])
    .background_(Color.clear)
    .hiliteColor_(Color.green(alpha:0.6))
    .action_({ arg sbs;
        [sbs.value, v.items[sbs.value]].postln; // .value returns the integer
    });
)