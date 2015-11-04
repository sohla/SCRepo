(

var winenv;
winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\voiceMidule, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5, vol = 0.5;
	var pos;
	var mx,my;
	var sp;

	mx = LFSaw.kr( (1.0/50.0) * MouseX.kr(0.01, 1.0) ,1,0.5,0.5);
	my = MouseY.kr(0.001,1,1.0);

	sp = Splay.arFill(24,
			{ |i| Warp1.ar(1, buffer, mx, pch,my, envbuf, 8, 0.1, 2)  },
			1,
			1,
			0
		) * vol;

	a = Out.ar(0,sp);


}).send(s);

)
p = ("~/Music/SCSamples/iAmWatchingYou4.MP3").standardizePath;
b = MP3.readToBuffer(s, p);

z = Synth(\voiceMidule,[\buffer,b,\ws,0.3,\pch,(69).midicps / 435.0]);



p = ("~/Music/SCSamples/spookySinging.wav").standardizePath;
c = Buffer.read(s, p);
z = Synth(\voiceMidule,[\buffer,c,\ws,0.3,\pch,(69).midicps / 435.0,\vol,0.5]);




Server.default.makeGui