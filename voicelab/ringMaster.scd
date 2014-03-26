

(

var winenv;
winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
z = Buffer.sendCollection(s, winenv.discretize, 1);


SynthDef("help-Diskout", {arg bufnum;
    DiskOut.ar(bufnum, In.ar(0,2));
}).send(s);

SynthDef(\warp, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5;
	var pos;
	var mx=0,my=0;
	var sp,verb;

	mx = LFSaw.kr( (1.0/(11.0)) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);

	my = 0.8;//MouseY.kr(0.5,1,1.0);//splay

	sp = Splay.arFill(30,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * 0.7 * MouseY.kr(0.1,1,1.0);


	sp = HPF.ar(sp,MouseY.kr(5000,50,1.0));
	Out.ar(0,
		sp;
	);
}).send(s);

)

p = PathName.new("~/Music/SuperCollider Recordings");
s.sendMsg("/b_alloc", 0, 65536, 2); // Buffer number is 0
s.sendMsg("/b_write", 0, p.asAbsolutePath + "/test.aiff", "aiff", "int16", 0, 0, 1);

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/overTheWavesShort.wav");
z = Synth(\warp,[\buffer,c,\ws,0.3,\pch,(64).midicps / 440.0]);
s.sendMsg("/s_new", "help-Diskout", 99, 1, 1, "bufnum", 0);


s.sendMsg("/b_close", 0);
s.sendMsg("/b_free", 0);



"~/Music/Sounds".standardizePath.isFolder;


(
var myPath;
myPath = PathName.new("~/Music/SuperCollider Recordings");
myPath.isFolder.postln;
myPath.asAbsolutePath;
)