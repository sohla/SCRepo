

(
	SynthDef(\playBuffer, {|buffer = 0, note = 69, amp = 1.0|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		) * amp;
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
	    SendReply.kr(imp, '/onPlayLevel', [0,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player,player,player]);

	}).send(s);

	SynthDef(\micInput, {|buffer = 0, channel = 0|
		var player = SoundIn.ar(channel);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onPlayLevel', [1,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[0,0,player,player]);

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

	player = In.ar([0,1,2,3],4);//PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;

		kernal = LFTri.kr(frq,0,mul,add);

		a= FreqShift.ar(player,kernal);

		dly = CombN.ar((a).dup,0.3,[delay,delay+0.01],decay)*0.5;

			ReplaceOut.ar(0,[dly,dly,dly,dly]);

	}).send(s);


	SynthDef(\ringme, {|buffer = 0, pitch = 51, range = 1,delay = 0.04, decay = 0.19|

		var player,sel,fol;
		var modulator;
		var notes = #[0,4,7];
		var root = 42;
		var dly;
		//player = SoundIn.ar(0);
		player = In.ar(0,4);//PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
		fol = (PeakFollower.ar(player,0.01) * range).lag(0,0.1);

		modulator = SinOsc.ar( pitch.midicps + fol.midicps,0,player) ;

		dly = CombN.ar((modulator).dup,0.3,[delay,delay+0.01],decay) * 0.8;
	ReplaceOut.ar(0,[dly,dly,dly,dly]);

	}).send(s);

	SynthDef(\pitchme, {|buffer = 0, pitch = 1.0,frq = 2.4, amp = 0.2, add = 0.3,delay = 0.004, decay = 0.019|

		var player,sq;
		var grainSize = 0.4;
		var dly;
		//player = SoundIn.ar(0);
		player = In.ar(0,4);//PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;
		sq = PitchShift.ar(player, grainSize,pitch,SinOsc.ar(frq,0,amp,add)).dup;
		dly = CombN.ar(sq,0.3,[delay,delay+0.01],decay);

		ReplaceOut.ar(0,[dly,dly,dly,dly]);

	}).send(s);


	// simple disk out
	SynthDef(\diskOut, {|bufnum|
	    DiskOut.ar(bufnum, In.ar(0,1));
	}).send(s);

	SynthDef(\recordInput, {|bufnum = 0|
		var p = SoundIn.ar(0,2);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onRecordLevel', [1,Amplitude.kr(p), K2A.ar(Peak.ar(p, delimp).lag(0, 1))]);

		 DiskOut.ar(bufnum, p);

		 //Out.ar(0,[0,0,p,p]);
		 //Out.ar(0,[0,p]);
	}).send(s);


	SynthDef(\listenToMic, {
		var p = SoundIn.ar(0);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onListenLevel', [1,Amplitude.kr(p), K2A.ar(Peak.ar(p, delimp).lag(0, 1))]);

		 Out.ar(0,[0,0,p,p]);
	}).send(s);

	(
	SynthDef(\cfstring1, { arg i_out, freq = 160, gate = 1, pan, amp=0.1, lf = 50,hf = 12000, atk = 0.001,dcy = 1;
		    var out, eg, fc, osc, a, b, w;
		    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, lf, hf);
		    osc = Mix.fill(4, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.1;
		    eg = EnvGen.kr(Env.asr(atk, 1, dcy), gate, doneAction:2);
		    out = eg * RLPF.ar(osc, fc, 0.1);
		    #a, b = out*0.4;
			//c = Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3]));
		    Out.ar(i_out, [ a,b,a,b]);
	}).send(s);
	)

)


