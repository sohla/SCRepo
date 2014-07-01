(


	SynthDef(
		"simpleSine",
		{
			arg gate=1,note=60,amp=0.1;
		    var sig = SinOsc.ar(note.midicps,0,amp) * EnvGen.kr(Env.linen(0.01,0.3,0.5), doneAction: 2);

			Out.ar(0,FreeVerb.ar(sig,0.6,0.5,0.5))
		}
	).send(s);

)
(
SynthDef(\env_help, { |out, gate = 1, amp = 0.1, release = 0.01|
    var env = Env.adsr(0.02, release, amp);
    var gen = EnvGen.kr(env, gate, doneAction: 2);
    Out.ar(out, PinkNoise.ar(1 ! 2) * gen)
}).send(s);
);




s.sendMsg("/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "note", 60, "amp", 0.2);

(
	var p1,p2;

	a = Rduino(SerialPort.devices.last,115200);
	a.start;
	a.capCallback = {|i|

		var notes = #[86,0,74,0,50,0,62,0];
	var octave = #[0,1,2,3];

		var note = notes[i];
		i.postln;
	s.sendMsg("/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "note", note + octave.choose - 24, "amp", 0.1);
		//if(i==0,{p1.play;{p1.stop}.defer(1.0)});

	};

	r = Task.new({ inf.do({
		a.readCap();
	    0.1.wait;
		})

	}).play;

	CmdPeriod.doOnce {
		r.stop;
		r.free;
		a.close;
	};
)

(
	var pink;

	a = Rduino(SerialPort.devices.last,115200);
	a.start;
// a.capCallback = {|index,state|
// 	(" Index:"++index++" State:"++state).postln;
//
// };
	a.onCallback = {|index|
		("ON:"++index).postln;
		pink = Synth(\env_help);

	};
	a.offCallback = {|index|
		("OFF:"++index).postln;
		pink.set(\gate, 0);

	};

	r = Task.new({ inf.do({
		a.readCap();
	    0.01.wait;
		})
	}).play;

	CmdPeriod.doOnce {
		r.stop;
		r.free;
		a.close;

	};

)