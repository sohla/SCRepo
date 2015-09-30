s.boot
s.queryAllNodes
s.queryAllBuffers
s.freeAll;
Buffer.freeAll
s.quit;



(

	SynthDef("dbSampler",{ |bufnum,gate = 1 ,amp=0.2, freq = 64 pan = 0.5, degree = 0, atk = 0.1, dcy = 0.4 |

	var sig = PlayBuf.ar(2, bufnum, (BufRateScale.kr(bufnum) * (freq/64) ), doneAction:2)
	* EnvGen.kr(Env.adsr(atk,dcy,gate)) * amp;

	Out.ar(0,Pan2.ar(sig,pan));

	}).send(s);

)

(
	SynthDef("fbVerb",{ | out = 0, maxDly = 0.29, verbDcy = 5.0, feedback = 0.9|

	var sig = In.ar(out,2);


	Splay.arFill(10,{
		sig = AllpassN.ar(sig,maxDly,Rand(0.001,maxDly),verbDcy)},1,1,0);

	// 10.do{
	// 	sig = AllpassN.ar(sig,maxDly,Rand(0.001,maxDly),verbDcy)
	// };

	LocalOut.ar(sig,feedback);
	Out.ar(out,[sig,sig]);


	},[0, 0, 0]).send(s);
)



p = ("~/Music/SCSamples/130525__stomachache__f-hi-2.wav").standardizePath;
b = Buffer.read(s, p);
z = Synth(\dbSampler,[\bufnum, b.bufnum,\atk,5.5]);


(
	TempoClock.default.tempo = 100/60;

	p = ("~/Music/SCSamples/130525__stomachache__f-hi-2.wav").standardizePath;
	b = Buffer.read(s, p);

	c = Pbind(
		    \degree,Prand([4,5.2,6.1,7.3], inf),
			\dur,Prand([1.1,1.3,1.7]*1, inf),
			\amp, 0.07,
			\octave, 4.0,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]);

	d = Pbind(
		    \degree,Prand([4,5.2,6.1,7.3], inf),
			\dur,Prand([1.1,1.3,1.7]*2, inf),
			\amp, 0.07,
			\octave, 5,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]);

	e = Pbind(
		    \degree,Prand([4,5.2,6.1,7.3], inf),
			\dur,Prand([1.1,1.3,1.7]*8, inf),
			\amp, 0.07,
			\octave, 3.0,
			\instrument, \dbSampler,
			\bufnum, b.bufnum,
			\atk, 0.01,
			\dcy, [0.1,0.01,1]);

	Ppar([c,d,e]).play;
)




(

	TempoClock.default.tempo = 1;
	t = 0.038;//0.075;
	r = 3;
	p = ("~/Music/SCSamples/slowboo.wav").standardizePath;
	b = Buffer.read(s, p);


	c = Pbind(
	   	\type, \on,
		\instrument, \dbSampler,
		\bufnum, b.bufnum,
		\octave, 3.0 + r,
		\degree,Prand([0,1,2]-t, inf),
	 	\dur,Prand([1,2,3]*2, inf),
		\amp, 0.07,
		\dcy, [0.1,0.01,1]);


	d = Pbind(
	   	\type, \on,
		\instrument, \dbSampler,
		\bufnum, b.bufnum,
		\octave, 2.0 + r,
		\degree,Prand([0,4,5,6]-t, inf),
	 	\dur,Prand([1,2,3]*2, inf),
		\amp, 0.07,
		\dcy, [0.1,0.01,1]);


	e = Pbind(
	   	\type, \on,
		\instrument, \dbSampler,
		\bufnum, b.bufnum,
		\octave, 1.0 + r,
		\degree,Prand([0,1,5]-t, inf),
	 	\dur,Prand([1,2,3]*8, inf),
		\amp, 0.07,
		\dcy, [0.1,0.01,1]);


	g = Pbind(
	   	\type, \on,
		\instrument, \dbSampler,
		\bufnum, b.bufnum,
		\octave, 0 + r,
		\degree,Prand([0]-t, inf),
	 	\dur,Prand([1,2]*16, inf),
		\amp, 0.07,
		\dcy, [0.1,0.01,1]);


	m = Ppar([c,d,e,g]);

	f = Pfx(m,\fbVerb).play;



)
s.freeAll;
Buffer.freeAll
