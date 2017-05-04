(
    var width = Window.screenBounds.width, height = Window.screenBounds.width / 3, rate = 0.005;
    var w, u, v, cube, top, device, spiral, gryo, alt;
	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0;
	var pattern, player;
	var vv;

w = Window("3d canvas demo", Rect(0, 0, width, height), false)
        .front;



gryo = OSCFunc({ arg msg, time, addr, recvPort;
	gyroPitch = (msg[1].asFloat + pi.half);
	gyroRoll = (msg[2].asFloat + pi.half);
	gyroYaw = (msg[3].asFloat + pi.half);
}, '/gyrosc/gyro');

rrate = OSCFunc({ arg msg, time, addr, recvPort;
	rrateX = (msg[1].asFloat);
	rrateY = (msg[2].asFloat);
	rrateZ = (msg[3].asFloat);

}, '/gyrosc/rrate');

alt = OSCFunc({ arg msg, time, addr, recvPort;
	altValue = (msg[1].asFloat);
}, '/gyrosc/alt');

	
	vv = UserView(w,500,500);

    u = Canvas3D(w, Rect(0, 0, 500, 500))
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
		Canvas3D.mTranslate(-2.4,0,0)

        ];



};


z = CompositeView(w, Rect(500, 0, 490, height)).background_(Color.rand(0.7)).resize_(5);
a = Plotter("plot", parent: z).value_({[0, 1, 2, 3, 4].scramble * 100}.dup(3));

w.onClose = {
	player.stop;
	gryo.free;
	alt.free;
	rrate.free;
};
CmdPeriod.doOnce({w.close});


)



(
a = Plotter("the plot", Rect(600, 30, 600, 400));
a.value = (0..100).normalize(0, 8pi).sin;
)

a.value = { |i| (0..90) % (i + 12) + ( (0..90) % (i + 2 * 1) ) }.dup(3);
a.value = (0..12).squared;
a.plotMode = \points; a.refresh;
a.plotMode = \levels; a.refresh;
a.plotMode = \plines; a.refresh;

a