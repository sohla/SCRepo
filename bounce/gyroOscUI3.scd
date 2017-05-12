(
    var width = Window.screenBounds.width, height = Window.screenBounds.height ;
    var window, graph1, cube, top, rate, spiral, gryo, alt;
    var graph2, spot;

	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0;
	var accel,accelX, accelY, accelZ, aaccelX = 0, aaccelY = 0, aaccelZ = 0;
	var broadcastRoutine;
	var pattern, player;
	var plotterView, labelView, controlView;
	var dataSize = 100;
	var dc = DataCollector.new("test");
	var plotter1, plotter2, plotter3;
	var plotter4,plotter5,plotter6;
	var pitchStore = Array.new(dataSize);
	var dataPath = "~/Develop/SuperCollider/Projects/SCRepo/bounce/data/";
	var friction = 0.2;
	var tween;

	var createGUI;

QtGUI.palette = QPalette.dark; 



window = Window("gyro osc tester", Rect(0, height, width, height), false)
        .front;

DataCollector.makeBackupFolder();
DataCollector.folder = PathName.new(dataPath).fullPath;




plotterView = UserView(window,Rect(0,0,width,height));

plotter1 = Plotter("plot1", Rect(600,(height/6) * 0,200,height/6),plotterView);
plotter2 = Plotter("plot2", Rect(600,(height/6) * 1,200,height/6),plotterView);
plotter3 = Plotter("plot3", Rect(600,(height/6) * 2,200,height/6),plotterView);

plotter4 = Plotter("plot4", Rect(800,(height/6) * 0,200,height/6),plotterView).value_((0..dataSize));
plotter5 = Plotter("plot5", Rect(800,(height/6) * 1,200,height/6),plotterView).value_((0..dataSize));
plotter6 = Plotter("plot6", Rect(800,(height/6) * 2,200,height/6),plotterView).value_((0..dataSize));

GUI.skin.plot.gridLinePattern = FloatArray[1, 0];
GUI.skin.plot.gridColorX = Color.yellow(0.5);
GUI.skin.plot.gridColorY = Color.yellow(0.5);
GUI.skin.plot.background = Color.black;

labelView = UserView(window,Rect(500,0,100,height/2)).background_(Color.black);
labelView.layout = VLayout(
	StaticText().stringColor_(Color.red).string_("Pitch"),
	StaticText().stringColor_(Color.green).string_("Roll"),
	StaticText().stringColor_(Color.blue).string_("Yaw")
);

controlView = UserView(window,Rect(1000,0,width/4,height/2)).background_(Color.grey);
controlView.layout = VLayout(

	Button()
		.states_([
			["📱 SIM",Color.white(0.9),Color.grey()],
			["📱 SIM",Color.white(0.9),Color.green(0.8)]
		])
		.maxWidth_(80)
		.action_({|b|
			if (b.value == 0){ 
				gryo.enable();
				broadcastRoutine.stop();
			}{
				gryo.disable();
				broadcastRoutine.reset().play(AppClock);
			};
		}),	
	Button()
		.states_([["🔴 SNAP",Color.red(0.9)]])
		.maxWidth_(80)
		.action_({
			dc.backup();
		}),
	Button()
		.states_([["▶︎ PLAY",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			dc.recover();
			plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
			plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
			plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
      		plotter4.setProperties(\plotColor, Color.red).refresh;
    		plotter5.setProperties(\plotColor, Color.green).refresh;
    		plotter6.setProperties(\plotColor, Color.blue).refresh;
		}),
	Button()
		.states_([["🔴 ALL",Color.green(0.9)]])
		.maxWidth_(80)
		.action_({
			plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
			plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
			plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
      		plotter4.setProperties(\plotColor, Color.red).refresh;
    		plotter5.setProperties(\plotColor, Color.green).refresh;
    		plotter6.setProperties(\plotColor, Color.blue).refresh;

		}),
	// Button()
	// 	.states_([["🔵 PITCH",Color.green(0.9)]])
	// 	.maxWidth_(80)
	// 	.action_({
	// 		plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
 //      		plotter4.setProperties(\plotColor, Color.red).refresh;

	// 	}),
	// Button()
	// 	.states_([["🔵 ROLL",Color.green(0.9)]])
	// 	.maxWidth_(80)
	// 	.action_({
	// 		plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
 //    		plotter5.setProperties(\plotColor, Color.green).refresh;

	// 	}),
	// Button()
	// 	.states_([["🔵 YAW",Color.green(0.9)]])
	// 	.maxWidth_(80)
	// 	.action_({
	// 		plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
 //    		plotter6.setProperties(\plotColor, Color.blue).refresh;

	// 	}),
);
tween = {|input,history,friction = 0.5|
	(friction * input + ((1 - friction) * history))
};

gryo = OSCFunc({ |msg, time, addr, recvPort|
	gyroPitch = (msg[1].asFloat + pi.half);
	gyroRoll = (msg[2].asFloat + pi.half);
	gyroYaw = (msg[3].asFloat + pi.half);
}, '/gyrosc/gyro');

rrate = OSCFunc({ |msg, time, addr, recvPort|
	rrateX = tween.(msg[1].asFloat,rrateX,0.03);
	rrateY = tween.(msg[2].asFloat,rrateY,0.03);
	rrateZ = tween.(msg[3].asFloat,rrateZ,0.03);
}, '/gyrosc/rrate');



accel = OSCFunc({ |msg, time, addr, recvPort|
	aaccelX = tween.(msg[1].asFloat,aaccelX,0.2);
	aaccelY = tween.(msg[2].asFloat,aaccelY,0.2);
	aaccelZ = tween.(msg[3].asFloat,aaccelZ,0.2);
}, '/gyrosc/accel');

alt = OSCFunc({ |msg, time, addr, recvPort|
	altValue = (msg[1].asFloat);
}, '/gyrosc/alt');
	

graph1 = Canvas3D(window, Rect(0, 0, 500, height/2))
    .scale_(200)
	.background_(Color.gray)
    .perspective_(0.5)
    .distance_(2);

graph2 = Canvas3D(window, Rect(0, height/2, 500, height/2))
    .scale_(200)
	.background_(Color.gray)
    .perspective_(0.5)
    .distance_(2);

graph2.add(spot = Canvas3DItem.cube
    .color_(Color.red(0.8))
    .width_(1)
);

// u.view.clearOnRefresh= false;
//     u.view.drawFunc= {
//         Pen.fillColor= Color.grey(1, 0.1);    //alpha set trail amount
//         Pen.fillRect(Rect(0, 0, width, height));
//     }<>u.view.drawFunc;

graph1.add(cube = Canvas3DItem.cube
    .color_(Color.red(0.8))
    .width_(1)
);

graph1.add(top = Canvas3DItem.grid(4)
	.color_(Color.green(0.9))
    .width_(1)
);


graph1.add(rate = Canvas3DItem.grid(2)
	.color_(Color.yellow(0.9))
    .width_(1)
);

graph1.add(accelX = Canvas3DItem.regPrism()
	.color_(Color.red(0.9))
    .width_(1)
);
graph1.add(accelY = Canvas3DItem.regPrism()
	.color_(Color.green(0.9))
    .width_(1)
);
graph1.add(accelZ = Canvas3DItem.regPrism()
	.color_(Color.blue(0.9))
    .width_(1)
);

graph2.animate(60) {|t|
	spot.transforms = [ 

		Canvas3D.mScale(1.0,0.5,0.05),
	    Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
		 Canvas3D.mTranslate(aaccelY.neg,aaccelZ,aaccelX)

    ];

};

// animate
graph1.animate(60) {|t|
	
	dc.addData([gyroPitch,gyroRoll,gyroYaw],t);

	plotter1.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]})).addAll([-pi,pi]);
  	plotter1.setProperties(\plotColor, Color.red).refresh;

	plotter2.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]})).addAll([-pi,pi]);
	plotter2.setProperties(\plotColor, Color.green).refresh;

	plotter3.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]})).addAll([-pi,pi]);
	plotter3.setProperties(\plotColor, Color.blue).refresh;

 	dc.collection = dc.getLast(dataSize); // limit size of collected samples


	cube.transforms = [ 
		Canvas3D.mScale(1,0.5,0.05),
        Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
		//Canvas3D.mTranslate(rrateX,rrateY,rrateZ)
    ];



	top.transforms = [ 
		Canvas3D.mScale(1,1,0.05),
		Canvas3D.mTranslate(0,0,1.0),
		Canvas3D.mScale(1,0.5,0.05),
        Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
		Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

    ];

	rate.transforms = [ 
		Canvas3D.mScale(0.01,(rrateX.abs+rrateY.abs+rrateZ.abs) ,1.0),
		Canvas3D.mTranslate(-2.2,0,0)

    ];
	accelX.transforms = [

		Canvas3D.mScale(0.01,(aaccelX),0.01),
        Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
    ];
	accelY.transforms = [ 
		Canvas3D.mScale((aaccelY),0.01,0.01),
        Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
    ];
	accelZ.transforms = [ 
		Canvas3D.mScale(0.01,0.01,(aaccelZ)),
        Canvas3D.mRotateX(gyroRoll),
        Canvas3D.mRotateY(gyroYaw.neg + pi.half),
        Canvas3D.mRotateZ(gyroPitch.neg + pi.half),
    ];
};


//oscBroadcaster = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

broadcastRoutine = Routine {
	var i=0;
	loop {

		i=i+0.01;

		//gyroPitch = (i.mod(pi).twice) - pi;
		gyroRoll = (i.mod(pi).twice) - pi;
		//gyroYaw = (i.mod(pi).twice) - pi;
		//gyroRoll = (i*30).sin * 0.5;
		gyroYaw = (i*40).cos * 0.3;

		0.03.yield;
	}
};

window.onClose = {
	//dc.saveTo(PathName.new(dataPath).fullPath+/+Date.getDate.asSortableString);
	broadcastRoutine.stop;
	player.stop;
	gryo.free;
	alt.free;
	rrate.free;
};
CmdPeriod.doOnce({w.close});


)

