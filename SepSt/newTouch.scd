
(

	SynthDef("simpleEnvSample",{

		|bufnum,gate = 1, pch = 1.0,amp=1.0, pan = 0.5, release = 1.0|

		var sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) *
			EnvGen.kr(Env.adsr(releaseTime:release),gate, doneAction: 2) * amp;
			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)
(
var parts = Array.new(8);
var arduino;
var titles = [
	"countdown.wav",
	"countdown.wav",
	"launch.wav",
	"driveintern.aif",
	"carrev.aif",
	"carwont.aif",
	"smallstep.wav",
	"airduct.wav",
	"ding.wav"
];
var nodes = [0,0,0,0,0,0,0,0];



arduino = Rduino(SerialPort.devices.last,115200);
arduino.start;

arduino.onCallback = {|index|

	("ON:"++index).postln;

	p = ("~/Music/sounds/"++titles[index]).standardizePath;
	b = Buffer.read(s, p);
	n = Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,1.0]);
	nodes = nodes.put(index,n);

};

arduino.offCallback = {|index|

	("OFF:"++index).postln;
	nodes[index].set(\gate,0,\release,2.0);
	nodes = nodes.put(index,0);

};


// p = ("~/Music/sounds/"++titles[8]).standardizePath;
// b = Buffer.read(s, p);
// Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,1.0]);


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