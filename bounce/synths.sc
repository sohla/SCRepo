SynthDef(\xylo, { |out=0, freq=440, gate=1, amp=0.3, sustain=0.2, pan=0, patch=1, attack = 0.001|
	var sig = StkBandedWG.ar(freq, instr:patch, mul:20);
	var env = EnvGen.kr(Env.adsr(attack, sustain, sustain, 1.3), gate, doneAction:2);
	Out.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;




SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0, position = 0.5 attack = 0.001|
    var env = Env.new([0,1, 1, 0],[attack,0.006, 0.005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked.ar(freq, amp, gate,position,1,c3,inp);
	var sig = 0, verb = 0;
    //Out.ar(out, Pan2.ar(son * 0.1, pan));
	sig = Pan2.ar(son * 0.1, pan);
	//verb = FreeVerb2.ar(sig[0],sig[1],0.3,200);
    //DetectSilence.ar(sig, 0.001, doneAction:2);

	Out.ar(out,sig);
}).add;
