

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

SynthDef(\fshift, {|buffer = 0, frq = 189, mul = 76, add = 232|

	var in,voco,kernal;
	var a = 0;


			in = In.ar(0,2);
		// use ReplaceOut to overwrite the previous contents of the bus.

	kernal = LFTri.kr(frq,0,mul,add);

	a= FreqShift.ar(in,kernal);
		ReplaceOut.ar(0, a);

}).send(s);
)

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/Original Intro and Questions.aif");
(

y = Synth(\playBuffer,[\buffer,c]);
x = Synth.tail(nil,\fshift,[\buffer,c]);
)
