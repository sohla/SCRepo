

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

	mx = LFSaw.kr( (1.0/(4.0)) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);

	my = MouseY.kr(0.001,0.1);//splay

	sp = Splay.arFill(30,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * 0.2 ;


	//sp = HPF.ar(sp,MouseY.kr(5000,50,1.0));
	Out.ar(0,
		sp;
	);
}).send(s);

)

p = ("~/Music/sounds/iam2.wav").standardizePath;
b = Buffer.read(s, p);
z = Synth(\warp,[\buffer,b,\ws,0.3,\pch,(69).midicps / 440.0]).autogui;


Server.default.makeGui