
s.freeAll
s.quit

s.queryAllNodes
s.boot

(
	SynthDef(\playBuffer, {|buffer = 0, note = 69|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
	    SendReply.kr(imp, '/onPlayLevel', [0,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player]);

	}).send(s);

	SynthDef(\micInput, {|buffer = 0|
		var player = SoundIn.ar(0);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onPlayLevel', [1,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player]);

	}).send(s);

	// sin impulse for testing
	SynthDef(\sinImpulse,{|freq=440,amp=0.8|
			var trg = Decay2.ar(Impulse.ar(2,0,0.3), 0.01, 0.3);
			var sig = SinOsc.ar(freq,0,trg*amp);
			Out.ar(0,[sig,sig])
		}
	).send(s);

	SynthDef(\fshift, {|frq = 189, mul = 76, add = 232|

		var in,voco,kernal;
		var a = 0;

		in = In.ar(0,2);
		// use ReplaceOut to overwrite the previous contents of the bus.

		kernal = LFTri.kr(frq,0,mul,add);

		a= FreqShift.ar(in,kernal);
		ReplaceOut.ar(0, a);

	}).send(s);


	// simple disk out
	SynthDef(\diskOut, {|bufnum|
	    DiskOut.ar(bufnum, In.ar(0,1));
	}).send(s);

	SynthDef(\recordInput, {|bufnum = 0|
		var player = SoundIn.ar(0);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onRecordLevel', [1,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		 DiskOut.ar(bufnum, player);
	}).send(s);

)

