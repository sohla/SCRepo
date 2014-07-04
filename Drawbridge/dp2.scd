s.boot
s.quit
s.queryAllNodes


(

	SynthDef("simpleEnvSample",{

		|bufnum,gate = 1, pch = 1.0,amp=1.0, pan = 0.5|

		var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) *
					EnvGen.kr(Env.adsr,gate, doneAction: 2) * amp;
			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)


(
	var parts = Array.new(8);
	var arduino;
	var titles = [
		"ding.wav",
		"scrape.wav",
		"SFX_1021_23.wav",
		"ding.wav"

	];

	arduino = Rduino(SerialPort.devices.last,115200);
	arduino.start;

	arduino.onCallback = {|index|

		("ON:"++index).postln;

		p = ("~/Music/sounds/"++titles[0]).standardizePath;
		b = Buffer.read(s, p);
		Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,0,3,3,7,7,9,9].at(index).midiratio]);
	};

	arduino.offCallback = {|index|

		("OFF:"++index).postln;

	};

	r = Task.new({ inf.do({
		arduino.readCap();
	    0.01.wait;
		})
	}).play;

	CmdPeriod.doOnce {
		r.stop;
		r.free;
		arduino.close;

	};

)
