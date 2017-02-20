

(

	// straight forward playing of a buffer and sending levels out
	SynthDef(\playBuffer, {|buffer = 0, note = 69, amp = 1.0|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			2,
			buffer,
			pitch,
			doneAction:2
		) * amp;

		var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);

		SendReply.kr(imp, '/onPlayLevel', [0,Amplitude.kr(player[0]), K2A.ar(Peak.ar(player[0], delimp).lag(0, 1))]);

		//Out.ar(0,Pan2.ar(player,[0,0],[0.03,0.03,1,1]));
		Out.ar(0,[player[0]*0.05,player[1]*0.05,player[0],player[1]]);

	}).send(s);

	// background player with routing to all buses
	SynthDef(\playBG, {|buffer = 0, note = 69, amp = 1.0|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		) * amp;

		Out.ar(0,[player,player,player,player]);

	}).send(s);

	// pass mic input
	SynthDef(\micInput, {|buffer = 0, channel = 0|
		var player = SoundIn.ar(channel) * 3.0;
		Out.ar(0,[player*0.1,player*0.1,player*1.5,player*1.5]);

	}).send(s);

	// sin impulse for testing
	SynthDef(\sinImpulse,{|freq=440,amp=0.8|
			var trg = Decay2.ar(Impulse.ar(2,0,0.3), 0.01, 0.3);
			var sig = SinOsc.ar(freq,0,trg*amp);
			Out.ar(0,[sig,sig])
		}
	).send(s);


	SynthDef(\shiftme, {|buffer = 0, frq = 52, mul = 131, add = 0.4,delay = 0.04, decay = 0.19|

		var player,voco,kernal;
		var a = 0,dly;

		player = In.ar(0,1);
		kernal = LFTri.kr(frq,0,mul,add);
		a= FreqShift.ar(player,kernal);
		dly = CombN.ar((a).dup,0.3,[delay,delay+0.01],decay)*1.0;
		ReplaceOut.ar(0,[dly,dly,dly*17,dly*17]);

	}).send(s);


	SynthDef(\ringme, {|buffer = 0, pitch = 51, range = 1,delay = 0.04, decay = 0.19|

		var player,sel,fol;
		var modulator;
		var notes = #[0,4,7];
		var root = 42;
		var dly;

		player = In.ar(0,1);
		fol = (PeakFollower.ar(player,0.01) * range).lag(0,0.1);
		modulator = SinOsc.ar( pitch.midicps + fol.midicps,0,player) ;
		dly = CombN.ar((modulator).dup,0.3,[delay,delay+0.01],decay) * 1.3;
		ReplaceOut.ar(0,[dly,dly,dly*16,dly*16]);

	}).send(s);

	SynthDef(\pitchme, {|buffer = 0, pitch = 1.0,frq = 2.4, amp = 0.2, add = 0.3,delay = 0.004, decay = 0.019|

		var player,sq;
		var grainSize = 0.4;
		var dly;

		player = In.ar(0,1);
		sq = PitchShift.ar(player, grainSize,pitch,SinOsc.ar(frq,0,amp,add)).dup;
		dly = CombN.ar(sq,0.3,[delay,delay+0.01],decay) * 1.6;

		ReplaceOut.ar(0,[dly,dly,dly*17,dly*17]);

	}).send(s);


	// simple disk out
	SynthDef(\diskOut, {|bufnum|
	    DiskOut.ar(bufnum, In.ar(0,1));
	}).send(s);

	SynthDef(\recordInput, {|bufnum = 0|
		var p = SoundIn.ar(1);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		SendReply.kr(imp, '/onRecordLevel', [1,Amplitude.kr(p), K2A.ar(Peak.ar(p, delimp).lag(0, 1))]);

		 DiskOut.ar(bufnum, p);
	}).send(s);

	SynthDef(\listenToMic, {
		var p = SoundIn.ar(1);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onListenLevel', [1,Amplitude.kr(p), K2A.ar(Peak.ar(p, delimp).lag(0, 1))]);

		 Out.ar(0,[p,p,0,0]);
	}).send(s);


)

