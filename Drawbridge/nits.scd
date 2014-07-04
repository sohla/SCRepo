(
{

	Splay.arFill(10,{ |i|

	var trigs, durscale, son, resfreq,rf;
		trigs = GaussTrig.kr(MouseX.kr(0,15),MouseY.kr(0,1.0));
	durscale = TRand.kr(0.1,2.0, trigs); // vary duration between default 20ms and 30ms
	resfreq = TExpRand.kr(100, 1000, trigs); // different resonant frequency for each one
	son = WhiteNoise.ar * EnvGen.ar(Env.perc(0, 0.001, curve: 0), trigs, timeScale: durscale);
		son = HPF.ar(son,MouseX.kr(10000,100) + (i.rand * 1000)) + BPF.ar(son, resfreq, 20);

	});
}.play
)

