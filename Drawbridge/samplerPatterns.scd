s.boot
s.queryAllNodes
s.queryAllBuffers
Buffer.freeAll
(

	SynthDef("dbSampler",{ |bufnum,gate = 1 ,amp=0.2, freq = 64 pan = 0.5, degree = 0, atk = 0.1, dcy = 0.4 |

	var sig = PlayBuf.ar(1, bufnum, (BufRateScale.kr(bufnum) * (freq/64) ), doneAction:2)
	* EnvGen.kr(Env.adsr(atk,dcy,gate)) *
						amp;

			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)



p = ("~/Music/sounds/nitwalk.wav").standardizePath;
b = Buffer.read(s, p);
z = Synth(\dbSampler,[\bufnum, b.bufnum,\degree,0]);


(
	var w,u,slid;

	w = Window("tempo control test", Rect(100,100,200,40));
	slid = Slider(w, Rect(0,0,200,20));

	w.front;

	slid.action_({u.tempo_(2*(slid.value)+1)});

	TempoClock.default.tempo = 322/60;

	p = ("~/Music/sounds/nitwalk.wav").standardizePath;
	b = Buffer.read(s, p);

	c = Pbind(
		    \degree,Prand([4,5.2,6.1,7.3], inf),
			\dur,Prand([1.1,1.3,1.7], inf),
			\amp, 0.07,
			\octave, 2.1,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]).play;

	d = Pbind(
		    \degree,Prand([4.2,5.1,6.4,7.2], inf),
			\dur,Prand([1.8,1.9,1.7], inf),
			\amp, 0.07,
			\octave, 2,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]).play;

	e = Pbind(
		    \degree,Prand([4.2,5.1,6.4,7.2], inf),
			\dur,Prand([1.8,1.9,1.7], inf),
			\amp, 0.07,
			\octave, 2.7,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]).play;
)
