(

	SynthDef(
		"simpleSine",
		{
			arg note=60,amp=0.1;
		    var sig = SinOsc.ar(note.midicps,0,amp) * EnvGen.kr(Env.linen(0.01,0.3,0.5), doneAction: 2);

			Out.ar(0,FreeVerb.ar(sig,0.6,0.5,0.5))
		}
	).send(s);

)


s.sendMsg("/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "note", 60, "amp", 0.2);

(
	var p1,p2;

	a = Rduino(SerialPort.devices.last,115200);
	a.start;
	a.capCallback = {|i|

		var notes = #[86,0,74,0,50,0,62,0];
	var octave = #[0,2,4,6];

		var note = notes[i];
		i.postln;
	s.sendMsg("/s_new", "simpleSine", x = s.nextNodeID, 1, 1, "note", 12 + note + octave.choose, "amp", 0.1);
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



	p1 = Pbind(
		    [\degree, \dur],
			Pseq([[0, 0.1], [2, 0.2], [4, 0.2], [5, 0.1], [2, 0.1]], inf),
			\amp, 0.07,
			\octave, [4,5,6,7,8].choose,
			\instrument, \cfstring1,
			\mtranspose, [0,2,4],
			\atk, 0.1,
			\dcy, [0.2,0.1,0.8]);
	p2 = Pbind(
		    [\degree, \dur],
			Pseq([[0, 4], [2, 3], [5, 5], [1, 4], [4, 3]], inf),
			\amp, [0.1,0.2,0.5],
			\octave, [2,4,6].choose,
			\instrument, \cfstring1,
			\mtranspose, [0,2,4,7].choose,
			\hf,[90,200,400],
			\atk, 2,
			\dcy, 3);

a.play

b.play