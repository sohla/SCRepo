 s.boot
s.queryAllNodes
s.queryAllBuffers
Buffer.freeAll
(

	SynthDef("dbSampler",{ |bufnum,gate = 1 ,amp=0.2, freq = 64 pan = 0.5, degree = 0, atk = 0.1, dcy = 0.4 |

	var delay = 0.04, decay = 0.19;

	var sig = PlayBuf.ar(1, bufnum, (BufRateScale.kr(bufnum) * (freq/64) ), doneAction:2)
	* EnvGen.kr(Env.adsr(atk,dcy,gate)) *
						amp;

	// sig = CombN.ar((sig).dup,0.3,[delay,delay+0.01],decay);
			Out.ar(0,Pan2.ar(sig,pan));
		}
	).add;

)



p = ("~/Music/sounds/nitwalk.wav").standardizePath;
b = Buffer.read(s, p);
z = Synth(\dbSampler,[\bufnum, b.bufnum,\degree,0]);

Server.default.makeGui


(
	var w,u,slid;
	var bufnums = Array.new(10);

	w = Window("tempo control test", Rect(100,100,200,40));
	slid = Slider(w, Rect(0,0,200,20));

	w.front;

	TempoClock.default.tempo = 1;

	slid.action_({
	TempoClock.default.tempo = (50 * slid.value) + 1;
	});

	10.do({ |i|
	p = ("~/Music/sounds/laugh"++i++".wav").standardizePath;
	p.postln;
		b = Buffer.read(s, p);
		bufnums.add(b.bufnum);
	});



	c = Pbind(
	\degree,Prand([1], inf),
			\dur,Prand([3], inf),
			\amp, 0.07,
			\octave, 3.0,
			\instrument, \dbSampler,
			\bufnum, Prand(bufnums,inf),
			\atk, 0.01,
			\dcy, [0.1,0.01,1]).play;


	d = Pbind(
		    \degree,Prand([1,2], inf),
			\dur,Prand([4], inf),
			\amp, 0.07,
			\octave, 3.0,
			\instrument, \dbSampler,
			\bufnum, Prand(bufnums,inf),
			\atk, 0.01,
			\dcy, [0.1,0.01,1]).play;
)

