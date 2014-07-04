s.boot
s.quit
s.queryAllNodes

(


	SynthDef(
		"simpleSine",
		{
			arg gate=1,note=60,amp=0.1;
		    var sig = SinOsc.ar(note.midicps,0,amp) * EnvGen.kr(Env.adsr,gate, doneAction: 2);

			Out.ar(0,FreeVerb.ar(sig!2,0.6,0.5,0.5))
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

(

SynthDef("simpleEnvSample",{ |bufnum,gate = 1, pch = 1.0,amp=1.0, pan = 0.5|
		    var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) * EnvGen.kr(Env.adsr,gate, doneAction: 2) * amp;

			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)
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


(
var parts = Array.new(8);
var pink;
	var titles = [
		"ding.wav",
		"scrape.wav",
		"SFX_1021_23.wav",
		"ding.wav"

	];


	TempoClock.default.tempo = 320/60;

// p = ("~/Music/sounds/scrape.wav").standardizePath;
// b = Buffer.read(s, p);

	c = Pbind(
		    [\degree, \dur],
			Pseq([[0, 1], [2, 1], [4, 1], [5, 1], [2, 1]], inf),
			\amp, 0.07,
			\octave, [4,5],
			\instrument, \cfstring1,
			\mtranspose, [0,2,4],
			\atk, 0.01,
			\dcy, [1.2,1.1,2]).play;
	parts.add(c);
	parts[0].stop;

	d = Pbind(
		    [\degree, \dur],
			Pseq([[0, 4], [2, 4], [4, 4], [5, 4], [2, 4]], inf),
			\amp, 0.07,
			\octave, [7,8],
			\instrument, \cfstring1,
			\mtranspose, [0,2,4],
			\atk, 1.01,
			\hf,200,
			\dcy, [1.2,1.1,2]).play;
	parts.add(d);
	parts[1].stop;


a = Rduino(SerialPort.devices.last,115200);
	a.start;

	a.onCallback = {|index|
		("ON:"++index).postln;
		//pink = Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,2,4,7].choose.midiratio]);
		//parts[index].play;
		 p = ("~/Music/sounds/"++titles[0]).standardizePath;
		b = Buffer.read(s, p);
	Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,[0,0,3,3,7,7,9,9].at(index).midiratio]);
	};
	a.offCallback = {|index|
		("OFF:"++index).postln;
		//pink.set(\gate, 0);
		//parts[index].pause;

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
[1,2,36,4].at(2)