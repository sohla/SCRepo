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
Ê Ê Ê Ê Ê Ê Ê Ê sp,
Ê Ê Ê Ê Ê Ê Ê Ê 26,
Ê Ê Ê Ê Ê Ê Ê Ê 2.24,
Ê Ê Ê Ê Ê Ê Ê Ê 0.5,
Ê Ê Ê Ê Ê Ê Ê Ê0.15,
Ê Ê Ê Ê Ê Ê Ê Ê 15,
Ê Ê Ê Ê Ê Ê Ê Ê -70.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê -22.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê -17.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê 26, 0.5);
		
	Out.ar(0,
		sp+verb
	);	
}).send(s);

)
c = Buffer.read(s, "sounds/bellsDemo2.aif");
c = Buffer.read(s, "sounds/celestesingle.aif");
c = Buffer.read(s, "sounds/celestes.aif");

c = Buffer.read(s, "sounds/ahthewind.wav");

c = Buffer.read(s, "sounds/bellsDemo.aif");
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,1.0]);
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,0.5]);
x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,0.25]);
	
x.free;
c.free;



{LFSaw.kr(1.0,1,0.5,0.5)}.plot(1.0,minval:-1.0,maxval:1.0)