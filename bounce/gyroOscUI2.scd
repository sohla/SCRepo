(
    var width = Window.screenBounds.width, height = Window.screenBounds.height , rate = 0.005;
    var w, u, v, cube, top, device, spiral, gryo, alt;
	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0;
	var oscBroadcaster, broadcastRoutine;
	var pattern, player;
	var vv, labelView, controlView;
	var dataSize = 100;
	var dc = DataCollector.new("test");
	var plotter1, plotter2, plotter3;
	var plotter4,plotter5,plotter6;
	var pitchStore = Array.new(dataSize);

QtGUI.palette = QPalette.dark; 

w = Window("gyro osc tester", Rect(0, height, width, height), false)
        .front;


vv = UserView(w,Rect(0,0,width,height));

plotter1 = Plotter("plot1", Rect(600,(height/6) * 0,200,height/6),vv);
plotter2 = Plotter("plot2", Rect(600,(height/6) * 1,200,height/6),vv);
plotter3 = Plotter("plot3", Rect(600,(height/6) * 2,200,height/6),vv);

plotter4 = Plotter("plot4", Rect(800,(height/6) * 0,200,height/6),vv).value_((0..dataSize));
plotter5 = Plotter("plot5", Rect(800,(height/6) * 1,200,height/6),vv).value_((0..dataSize));
plotter6 = Plotter("plot6", Rect(800,(height/6) * 2,200,height/6),vv).value_((0..dataSize));

GUI.skin.plot.gridLinePattern = FloatArray[1, 0];
GUI.skin.plot.gridColorX = Color.yellow(0.5);
GUI.skin.plot.gridColorY = Color.yellow(0.5);
GUI.skin.plot.background = Color.black;

labelView = UserView(w,Rect(500,0,100,height/2)).background_(Color.black);
labelView.layout = VLayout(

	Button()
		.states_([["🔵 PITCH",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
      		plotter4.setProperties(\plotColor, Color.green).refresh;

		}),
	Button()
		.states_([["🔵 ROLL",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
    		plotter5.setProperties(\plotColor, Color.red).refresh;

		}),
	Button()
		.states_([["🔵 YAW",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
    		plotter6.setProperties(\plotColor, Color.blue).refresh;

		}),
);

controlView = UserView(w,Rect(1000,0,width/4,height/2)).background_(Color.black);
controlView.layout = VLayout(
	Button()
		.states_([["🔴 ALL",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
			plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
			plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
      		plotter4.setProperties(\plotColor, Color.green).refresh;
    		plotter5.setProperties(\plotColor, Color.red).refresh;
    		plotter6.setProperties(\plotColor, Color.blue).refresh;

		}),
);

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

	

    u = Canvas3D(w, Rect(0, 0, 500, height/2))
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

		plotter1.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]})).addAll([-pi,pi]);
      	plotter1.setProperties(\plotColor, Color.green).refresh;

		plotter2.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]})).addAll([-pi,pi]);
    	plotter2.setProperties(\plotColor, Color.red).refresh;

		plotter3.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]})).addAll([-pi,pi]);
    	plotter3.setProperties(\plotColor, Color.blue).refresh;

     	dc.collection = dc.getLast(dataSize); // limit size of collected samples


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


oscBroadcaster = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

broadcastRoutine = Routine {|i|

	var p=r=y=0;


	loop {

		i=i+0.01;

		p = (i.mod(pi).twice) - pi;
		r = (i.mod(pi).twice) - pi;
		y = (i.mod(pi).twice) - pi;
		//r = (i*10).sin * 0.8;
		//y = (i*40).cos * 0.8;

		oscBroadcaster.sendMsg("/gyrosc/gyro",p,r,y);
		0.03.yield;
	}
}.play(AppClock);


w.onClose = {
	broadcastRoutine.stop;
	player.stop;
	gryo.free;
	alt.free;
	rrate.free;
};
CmdPeriod.doOnce({w.close});


)


