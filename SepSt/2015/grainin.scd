

(


var winenv;
// a custom envelope


winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);



SynthDef(\in_grain_test, {arg gate = 1, amp = 1, envbuf;
	var pan, env;
	// use mouse x to control panning


	pan = MouseX.kr(-1, 1);
	env = EnvGen.kr(
		Env([0, 1, 0], [1, 1], \sin, 1),
		gate,
		levelScale: amp,
		doneAction: 2);
	Out.ar(0,
		GrainIn.ar(2, Impulse.kr(MouseY.kr(1,100)), 0.03,AudioIn.ar(1), pan, envbuf) * env)
	}).send(s);

)



// use built-in env


x = Synth(\in_grain_test, [\envbuf, -1])
