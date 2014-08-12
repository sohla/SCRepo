

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
	var splayCount = 2;

	mx = LFSaw.kr( (1.0/(180.0)) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);

	my = 0.8;//MouseY.kr(0.5,1,1.0);//splay

	sp = Splay.arFill(splayCount,
			{ |i| Warp1.ar(2, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			splayCount.rand.linlin(0,splayCount,-1.0,1.0),
		) * 0.7 * MouseY.kr(0.1,1,1.0);


	sp = HPF.ar(sp,MouseY.kr(5000,50,1.0));
	Out.ar(0,
		sp;
	);
}).send(s);

)
p = ("~/Music/sounds/speech.wav").standardizePath;
c = Buffer.read(s, p);
z = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(69).midicps / 440.0]);
y = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(57).midicps / 440.0]);



x.free;
c.free;



{LFSaw.kr(1.0,1,0.5,0.5)}.plot(1.0,minval:-1.0,maxval:1.0)