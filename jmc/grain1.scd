(

var winenv;
winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\warp, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5;
	var pos;
	var mx,my;
	var sp,verb;

	mx = LFSaw.kr( (1.0/10.0) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);

	my = MouseY.kr(0.001,1,1.0);//splay


	sp = Splay.arFill(24,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * 0.15;

	verb = GVerb.ar(
		sp,
		26,
		2.24,
		0.5,
		0.15,
		15,
		-70.dbamp,
		-22.dbamp,
		-17.dbamp,
		26, 0.5);

	Out.ar(0,
		sp+verb
	);
}).send(s);

)

p = ("~/Music/SCSamples/130525__stomachache__f-hi-2.wav").standardizePath;

x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,1.0]);
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,0.5]);
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,8]);

x.free;
c.free;



{LFSaw.kr(1.0,1,0.5,0.5)}.plot(1.0,minval:-1.0,maxval:1.0)