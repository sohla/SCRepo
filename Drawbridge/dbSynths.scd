
(

	SynthDef("simpleEnvSample",{

		|bufnum,gate = 1, pch = 1.0,amp=1.0, pan = 0.5|

		var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) *
					EnvGen.kr(Env.adsr,gate, doneAction: 2) * amp;
			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)

