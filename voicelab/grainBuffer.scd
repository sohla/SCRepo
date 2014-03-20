(
SynthDef(\grainBuffer, {arg buffer = 0, envbuf = -1;
	var pos;
	var mx,my,px;
	var sp;
	var pointer;
	var player;

	mx = MouseX.kr(20, 100);
	px = MouseX.kr(0.5, 2);

	my = MouseY.kr(0.005,0.08);//splay

	pointer = Line.kr(0, 1, 15);


	//player = PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1);
	player = SoundIn.ar(0);

		sp = Splay.arFill(24,{ |i|

		var p = PitchShift.ar(player,0.1,px);
		GrainIn.ar(2,Impulse.kr(mx), my,p,0.0,envbuf)

		},
			1.0.rand,
			1.0.rand,
			0
		) ;


	Out.ar(0,sp);
}).send(s);
)
g = SynthDefAutogui(\grainBuffer) ;
c = Buffer.read(s, "Applications/SuperCollider3.6/sounds/darkforest.wav");
x = Synth(\grainBuffer,[\buffer,c]);

var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

x.set(\envbuf, z)

x.free;
c.free;
