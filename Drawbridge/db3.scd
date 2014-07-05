s.boot
s.quit
s.queryAllNodes


(

	SynthDef("simpleEnvSample",{

		|bufnum,gate = 1, pch = 1.0,amp=1.0, pan = 0.5|

		var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) *
					EnvGen.kr(Env.adsr,gate, doneAction: 2) * amp;


	Out.ar(0,[0,0,0,0,sig,sig]);
		}
	).add;

)


		p = ("~/Music/sounds/"++"ding.wav").standardizePath;
		b = Buffer.read(s, p);
		Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,0.5,1,1.2].choose.midiratio]);

SerialPort.devices

(
	var parts = Array.new(8);
	var numDevices, arduinoA,arduinoB;
	var titles = [
	["ding.wav"],
	["scrape.wav"],
	["ding.wav"],
	["scrape.wav"],
	["silence.wav"],
	["drum.wav"],
["laugh1.wav","laugh2.wav","laugh3.wav","laugh4.wav","laugh5.wav","laugh6.wav","laugh7.wav","laugh8.wav","laugh9.wav","laugh10.wav","laugh11.wav"],
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

	p = ("~/Music/sounds/"++titles[index+1][0]).standardizePath;
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









