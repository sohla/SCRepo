(

var winenv;
winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\warp, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5;
	var pos;
	var mx,my;

//	mx = MouseX.kr(0.0, 1);//pos
//	mx = Line.kr(0.0,1.0,6*60);

	mx = LFSaw.kr( (1.0/6.0) * MouseX.kr(0.01, 1.0)
				,1,0.5,0.5);
		
	my = MouseY.kr(0.001,1,1.0);//splay
	
	Out.ar(0,
		Splay.arFill(24,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * 0.5
	);	
}).send(s);

)

c = Buffer.read(s, "sounds/darkforest.wav");
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,1.0]);
	
x.free;
c.free;



{LFSaw.kr(1.0,1,0.5,0.5)}.plot(1.0,minval:-1.0,maxval:1.0)