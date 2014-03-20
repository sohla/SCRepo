(


SynthDef(\pullstretch, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5;
	var pos;
	var mx,my;
	var sp,verb;

	mx = LFSaw.kr( (1.0/6.0) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);

	my = MouseY.kr(0.001,1,1.0);//splay


	sp = Splay.arFill(24,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * 0.5;


	Out.ar(0,sp);
}).send(s);

)
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/darkforest.wav");
x = Synth(\pullstretch,[\buffer,c,\ws,0.3,\pch,1.0]);

x.free;
c.free;

