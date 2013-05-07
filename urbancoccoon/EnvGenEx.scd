(
SynthDef(\env_help, { | out, gate = 1 ,attack = 0.001, release = 0.001|
Ê Ê var envelope, z;
Ê Ê envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
	z = SinOsc.ar(240, 0, envelope);
Ê Ê Out.ar(out, z)
}).add;
)

a = Synth(\env_help);
a.set("attack", 1);

// turn off
a.set(\gate, 0);






// it does not matter to what value the gate is set, as long as it is > 0
a.set(\gate, 2);

a.free;
