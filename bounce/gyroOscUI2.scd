(
    var width = Window.screenBounds.width, height = Window.screenBounds.width / 3, rate = 0.005;
    var w, u, v, cube, top, device, spiral, gryo, alt;
	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0;
	var pattern, player;
	var vv, controlView;
	var dc = DataCollector.new("test");
	var plotter1, plotter2, plotter3;
	var plotterSize = 400;

w = Window("gyro osc tester", Rect(0, height, width, height), false)
        .front;

vv = UserView(w,Rect(0,0,width,height));

plotter1 = Plotter("plot1", Rect(500,(height/3) * 0,400,height/3),vv);
plotter2 = Plotter("plot2", Rect(500,(height/3) * 1,400,height/3),vv);
plotter3 = Plotter("plot2", Rect(500,(height/3) * 2,400,height/3),vv);

controlView = UserView(w,Rect(900,0,width-900,height));

gryo = OSCFunc({ |msg, time, addr, recvPort|
	gyroPitch = (msg[1].asFloat + pi.half);
	gyroRoll = (msg[2].asFloat + pi.half);
	gyroYaw = (msg[3].asFloat + pi.half);


}, '/gyrosc/gyro');

rrate = OSCFunc({ |msg, time, addr, recvPort|
	rrateX = (msg[1].asFloat);
	rrateY = (msg[2].asFloat);
	rrateZ = (msg[3].asFloat);

}, '/gyrosc/rrate');

alt = OSCFunc({ |msg, time, addr, recvPort|
	altValue = (msg[1].asFloat);
}, '/gyrosc/alt');

	

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
    	
    	dc.addData([gyroPitch,gyroRoll,gyroYaw],t);

		plotter1.value = (dc.getLast(plotterSize).asArray.collect({|a,i| a[\data][0]})).addAll([-pi,pi]);
    	plotter1.setProperties(\plotColor, Color.green).refresh;

		plotter2.value = (dc.getLast(plotterSize).asArray.collect({|a,i| a[\data][1]})).addAll([-pi,pi]);
    	plotter2.setProperties(\plotColor, Color.red).refresh;

		plotter3.value = (dc.getLast(plotterSize).asArray.collect({|a,i| a[\data][2]})).addAll([-pi,pi]);
    	plotter3.setProperties(\plotColor, Color.blue).refresh;

    	dc.collection = dc.getLast(plotterSize); // limit size of collected samples


		cube.transforms = [ // spin the red cube
			Canvas3D.mScale(1,0.5,0.05),
            Canvas3D.mRotateX(gyroRoll),
            Canvas3D.mRotateY(gyroYaw.neg + pi.half),
            Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
			Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

        ];



		top.transforms = [ // spin the red cube
			Canvas3D.mScale(1,1,0.05),
			Canvas3D.mTranslate(0,0,1.0),
			Canvas3D.mScale(1,0.5,0.05),
            Canvas3D.mRotateX(gyroRoll),
            Canvas3D.mRotateY(gyroYaw.neg + pi.half),
            Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
			Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

        ];

		device.transforms = [ // spin the red cube
			Canvas3D.mScale(0.01,(rrateX+rrateY+rrateZ) / 20,1.0),
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
