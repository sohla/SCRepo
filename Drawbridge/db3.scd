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
	).add;

)


(
	var parts = Array.new(8);
	var numDevices, arduinoA,arduinoB;
	var titles = [
	["childLaugh1.wav","childLaugh2.wav","childLaugh3.wav"],
	["silence.wav"],
	["silence.wav"],
	["silence.wav"],
	["silence.wav"],
	["silence.wav"],
	["silence.wav"],
		["silence.wav"]

];

	numDevices = SerialPort.devices.size;


	//---------------------------------------------------------
	//
	//---------------------------------------------------------

	arduinoA = Rduino(SerialPort.devices[numDevices-1],115200);
	arduinoB = Rduino(SerialPort.devices[numDevices-2],115200);

	arduinoA.start;
	arduinoB.start;


	//---------------------------------------------------------
	//
	//---------------------------------------------------------

	arduinoA.onCallback = {|index|

		("A ON:"++index).postln;

		p = ("~/Music/sounds/"++titles[index].choose).standardizePath;
		b = Buffer.read(s, p);
		Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,0.5,1,1.2].choose.midiratio]);
	};

	arduinoA.offCallback = {|index|

		("A OFF:"++index).postln;

	};


	//---------------------------------------------------------
	//
	//---------------------------------------------------------
	arduinoB.onCallback = {|index|

		("B ON:"++index).postln;

		p = ("~/Music/sounds/"++titles[1]).standardizePath;
		b = Buffer.read(s, p);
		Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,0,3,3,7,7,9,9].at(index).midiratio]);
	};

	arduinoB.offCallback = {|index|

		("B OFF:"++index).postln;

	};

	//---------------------------------------------------------
	r = Task.new({ inf.do({
		arduinoA.readCap();
		arduinoB.readCap();
	    0.01.wait;
		})
	}).play;



	//---------------------------------------------------------


	CmdPeriod.doOnce ({
		r.stop;
		r.free;
		arduinoA.close;
		arduinoB.close;

	});

)









