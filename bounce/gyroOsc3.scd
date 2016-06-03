(

SynthDef(\situationsynth,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff=8000 rq=0.8 lfowidth=0.001 lforate= 3.3 pan=(-0.1)|

	var pulse, filter, env, filterenv, lfo;

	lfo = LFTri.kr(lforate,Rand(0,2.0)!2);

	pulse = Mix(Pulse.ar((((freq.cpsmidi)+[0,0.14])+(lfo*lfowidth)).midicps,[0.5,0.51]+(lfowidth*lfo)))*0.5;

	filterenv = EnvGen.ar(Env([0.0,1.0,0.0,0.0],[0.005,0.57,0.0],-3));

	filter =  RLPF.ar(pulse,100+(filterenv*cutoff),rq);

	env = EnvGen.ar(Env.adsr(0.002,0.57,1.0,1.3),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp,pan));

}).add;
)
(
    var width = 500, height = 400, rate = 0.005;
    var w, u, v, cube, top, device, spiral, gryo, alt;
	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0;
	var pattern, player;

~lforate = 3.1;
~lfowidth = 0.04;
~cutoff = 5000;
~rq = 0.5;

	pattern = Pbind(
		\instrument,\situationsynth,
		\midinote,Pseq([0,2,4,5,7,9,11,12]+40,inf),
		\dur,Pseq([1],inf),
		\lforate,Pfunc{~lforate},
		\lfowidth,Pfunc{~lfowidth},
		\cutoff,Pfunc { ~cutoff },
		\rq,Pfunc { ~rq },
		\pan,-0.1,
		\amp,0.3
	);


	player = pattern.play;
	TempoClock.default.tempo = 1;

w = Window("3d canvas demo", Rect(128, 64, width, height), false)
        .front;



gryo = OSCFunc({ arg msg, time, addr, recvPort;
	gyroPitch = (msg[1].asFloat + pi.half);
	gyroRoll = (msg[2].asFloat + pi.half);
	gyroYaw = (msg[3].asFloat + pi.half);


	~cutoff = 100 + (gyroPitch * 10000);
	~rq = gyroRoll.mod(0.9);
}, '/gyrosc/gyro');

rrate = OSCFunc({ arg msg, time, addr, recvPort;
	rrateX = (msg[1].asFloat);
	rrateY = (msg[2].asFloat);
	rrateZ = (msg[3].asFloat);

	TempoClock.default.tempo = (rrateX+rrateY+rrateZ).abs;
}, '/gyrosc/rrate');

alt = OSCFunc({ arg msg, time, addr, recvPort;
	altValue = (msg[1].asFloat);
}, '/gyrosc/alt');

    u = Canvas3D(w, Rect(0, 0, width, height))
        .scale_(200)
		.background_(Color.gray)
        .perspective_(0.5)
        .distance_(2);


    // add a red cube
    u.add(cube = Canvas3DItem.cube
	        .color_(Color.red(0.8))
        .width_(1)
    );

	u.add(top = Canvas3DItem.grid(4)
	.color_(Color.green(0.9))
        .width_(1)
    );


	u.add(device = Canvas3DItem.grid(2)
	.color_(Color.blue(0.9))
        .width_(1)
    );


// animate
    u.animate(60) {|t|

	cube.transforms = [ // spin the red cube
			Canvas3D.mScale(1,0.5,0.05),
            Canvas3D.mRotateX(gyroRoll),
            Canvas3D.mRotateY(gyroYaw.neg),
            Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
			Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

        ];



	top.transforms = [ // spin the red cube
		Canvas3D.mScale(1,1,0.05),
		Canvas3D.mTranslate(0,0,0.05),
			Canvas3D.mScale(1,0.5,0.05),
            Canvas3D.mRotateX(gyroRoll),
            Canvas3D.mRotateY(gyroYaw.neg),
            Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
			Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

        ];

	device.transforms = [ // spin the red cube
		Canvas3D.mScale(0.01,(rrateX+rrateY+rrateZ) / 20,1.0),
		// Canvas3D.mRotateX(gyroRoll),
		// Canvas3D.mRotateY(gyroYaw.neg),
		// Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
		 Canvas3D.mTranslate(-2.4,0,0)

        ];



};

w.onClose = {
	player.stop;
	gryo.free;
	alt.free;
	rrate.free;
};
CmdPeriod.doOnce({w.close});


)

