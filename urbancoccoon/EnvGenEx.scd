(
SynthDef(\env_help, { | out, gate = 1 ,attack = 0.001, release = 0.001|
� � var envelope, z;
� � envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
	z = SinOsc.ar(240, 0, envelope);
� � Out.ar(out, z)
}).add;
)

a = Synth(\env_help);
a.set("attack", 1);

a.set("gate", 0, "release", 2.0);
