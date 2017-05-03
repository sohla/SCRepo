

(

var winenv;
winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
z = Buffer.sendCollection(s, winenv.discretize, 1);


SynthDef("help-Diskout", {arg bufnum;
	DiskOut.ar(bufnum, In.ar(0,2));
}).send(s);

SynthDef(\warp, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 1.0;
	var pos;
	var mx=0,my=0;
	var sp,verb;
	var splayCount = 1;

	mx = LFSaw.kr( (1.0/(20.0)) * MouseX.kr(-1.01, 1.0) ,1,0.5,0.5);

	my = MouseY.kr(0.01,0.999,1.0);//splay

	sp = Splay.arFill(splayCount,
		{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
		1,
		1,
		 MouseX.kr(-1.0, 1.0),//splayCount.rand.linlin(0,splayCount,-1.0,1.0),
	) * 0.2 ;


	//sp = LPF.ar(sp,MouseY.kr(15000,150,1.0));
	Out.ar(0,sp);
}).send(s);

)



p = ("~/Music/SCSamples/cabin_kids.wav").standardizePath;
c = Buffer.read(s, p);

x = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(67).midicps / 440.0]);
z = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(61).midicps / 440.0]);
y = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(64).midicps / 440.0]);

