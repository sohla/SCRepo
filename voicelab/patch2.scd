(
	SynthDef(\playBuffer, {|buffer = 0, note = 69|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		);
		Out.ar(0,[player,player]);

	}).send(s);

	SynthDef(\micin, {|buffer = 0|
	var player = SoundIn.ar(0);
		Out.ar(0,[player,player]);

	}).send(s);

	// sin impulse for testing
	SynthDef(\sinImpulse,{|freq=440,amp=0.8|
			var trg = Decay2.ar(Impulse.ar(2,0,0.3), 0.01, 0.3);
			var sig = SinOsc.ar(freq,0,trg*amp);
			Out.ar(0,[sig,sig])
		}
	).send(s);

	// simple disk out
	SynthDef(\diskOut, {arg bufnum;
	    DiskOut.ar(bufnum, In.ar(0,1));
	}).send(s);

)


(

	m = Synth(\sinImpulse);//tester
	b = Buffer.alloc(s,65536,1);
b.bufnum.postln;
	p = PathName.new("~/Music/SuperColliderRecordings");


	r = Synth(\diskOut,["bufnum",b.bufnum],m.group,\addToTail);

	b.write(p.asAbsolutePath ++"/test1.aiff","aiff","int16",leaveOpen:true);


)
s.queryAllNodes
(
	b.close;
	r.free;
	b.free;
m.free;
)