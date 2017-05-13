(
    var width = Window.screenBounds.width, height = Window.screenBounds.height ;
    var window, graph1, cube, top, rate, spiral, gryo, alt;
    var graph2, spot;

	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0, altValue = 0, rotateRateSum = 0;
	var rrate, rrateX = 0, rrateY = 0, rrateZ = 0, accelRateSum = 0;
	var accel, accelRate,accelX, accelY, accelZ, aaccelX = 0, aaccelY = 0, aaccelZ = 0;
	var broadcastRoutine;
	var pattern, player;
	var controlView;
	var dataSize = 100;
	var dc = DataCollector.new("test");
	var pitchStore = Array.new(dataSize);
	var dataPath = "~/Develop/SuperCollider/Projects/SCRepo/bounce/data/";
	var friction = 0.2;
	var tween;

	var createGUI;

	var createPlotterGroup;


QtGUI.palette = QPalette.dark; 

window = Window("gyro osc tester", Rect(0, height, width, height), false)
        .front;

DataCollector.makeBackupFolder();
DataCollector.folder = PathName.new(dataPath).fullPath;



createPlotterGroup = {|bounds, plotters|

	var plotterView = UserView(window,bounds).background_(Color.black).drawFunc_({}).animate_(true);
	var size = plotters.size;
	var pw = bounds.width;
	var ph = bounds.height / size;

	plotters.do{ |specs,i|
		var max = 0;
		var p = Plotter(specs[0], Rect(pw*0.3,ph*i,pw*0.7,ph),plotterView).value_((0..dataSize));

		var st = StaticText(plotterView,Rect(pw*0.15,ph*i,pw*0.15,ph/2))
			.string_(specs[0])
			.align_(\center)
			.stringColor_(specs[1])
			.background_(Color.black);

		var su = StaticText(plotterView,Rect(pw*0.15,(ph*i)+(ph/2),pw*0.15,ph/2))
			.string_(max)
			.align_(\center)
			.stringColor_(specs[1])
			.background_(Color.black)
			.mouseUpAction_({max = 0});

		StaticText(plotterView,Rect(0,ph*i,pw*0.15,ph/2))
			.string_(specs[0])
			.align_(\center)
			.stringColor_(specs[1])
			.background_(Color.black);


		plotterView.drawFunc = plotterView.drawFunc <> {

			var val = specs[2].(p).value[0].round(1e-4);
			st.string_(val);

			if(val > max, {max = val});

			su.string_("max :"+max);
			p.minval_(-pi);
			p.maxval_(pi);
			p.setProperties(\plotColor, specs[1]).refresh;
		}
	};


};

createPlotterGroup.(Rect(500,0,600,height-50),[
	["pitch",Color.red,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}));
	}],
	["roll",Color.green,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}));
	}],
	["yaw",Color.blue,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}));
	}],
	["aaccelX",Color.cyan,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][3]}));
	}],
	["accelY",Color.magenta,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][4]}));
	}],
	["accelZ",Color.yellow,{|p|
		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][5]}));
	}],
]);



GUI.skin.plot.gridLinePattern = FloatArray[1, 0];
GUI.skin.plot.gridColorX = Color.yellow(0.5);
GUI.skin.plot.gridColorY = Color.yellow(0.5);
GUI.skin.plot.background = Color.black;
GUI.skin.plot.plotColor = Color.white;

// controlView = UserView(window,Rect(1000,0,width/4,height/2)).background_(Color.grey);
// controlView.layout = VLayout(

// 	Button()
// 		.states_([
// 			["📱 SIM",Color.white(0.9),Color.grey()],
// 			["📱 SIM",Color.white(0.9),Color.green(0.8)]
// 		])
// 		.maxWidth_(80)
// 		.action_({|b|
// 			if (b.value == 0){ 
// 				gryo.enable();
// 				broadcastRoutine.stop();
// 			}{
// 				gryo.disable();
// 				broadcastRoutine.reset().play(AppClock);
// 			};
// 		}),	
// 	Button()
// 		.states_([["🔴 SNAP",Color.red(0.9)]])
// 		.maxWidth_(80)
// 		.action_({
// 			dc.backup();
// 		}),
// 	Button()
// 		.states_([["▶︎ PLAY",Color.green(0.9)]])
// 		.maxWidth_(80)
// 		.action_({
// 			dc.recover();
// 			// plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
// 			// plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
// 			// plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
//    //    		plotter4.setProperties(\plotColor, Color.red).refresh;
//    //  		plotter5.setProperties(\plotColor, Color.green).refresh;
//    //  		plotter6.setProperties(\plotColor, Color.blue).refresh;
// 		}),
// 	Button()
// 		.states_([["🔴 ALL",Color.green(0.9)]])
// 		.maxWidth_(80)
// 		.action_({
// 			// plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
// 			// plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
// 			// plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
//    //    		plotter4.setProperties(\plotColor, Color.red).refresh;
//    //  		plotter5.setProperties(\plotColor, Color.green).refresh;
//    //  		plotter6.setProperties(\plotColor, Color.blue).refresh;

// 		}),
// 	// Button()
// 	// 	.states_([["🔵 PITCH",Color.green(0.9)]])
// 	// 	.maxWidth_(80)
// 	// 	.action_({
// 	// 		plotter4.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}).addAll([-pi,pi]);
//  //      		plotter4.setProperties(\plotColor, Color.red).refresh;

// 	// 	}),
// 	// Button()
// 	// 	.states_([["🔵 ROLL",Color.green(0.9)]])
// 	// 	.maxWidth_(80)
// 	// 	.action_({
// 	// 		plotter5.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}).addAll([-pi,pi]);
//  //    		plotter5.setProperties(\plotColor, Color.green).refresh;

// 	// 	}),
// 	// Button()
// 	// 	.states_([["🔵 YAW",Color.green(0.9)]])
// 	// 	.maxWidth_(80)
// 	// 	.action_({
// 	// 		plotter6.value = dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}).addAll([-pi,pi]);
//  //    		plotter6.setProperties(\plotColor, Color.blue).refresh;

// 	// 	}),
// );

tween = {|input,history,friction = 0.5|
	(friction * input + ((1 - friction) * history))
};

gryo = OSCFunc({ |msg, time, addr, recvPort|
	gyroPitch = (msg[1].asFloat);
	gyroRoll = (msg[2].asFloat);
	gyroYaw = (msg[3].asFloat);
}, '/gyrosc/gyro');

rrate = OSCFunc({ |msg, time, addr, recvPort|
	rrateX = msg[1].asFloat;//tween.(msg[1].asFloat,rrateX,0.03);
	rrateY = msg[2].asFloat;//tween.(msg[2].asFloat,rrateY,0.03);
	rrateZ = msg[3].asFloat;//tween.(msg[3].asFloat,rrateZ,0.03);
}, '/gyrosc/rrate');



accel = OSCFunc({ |msg, time, addr, recvPort|
	aaccelX = msg[1].asFloat;//tween.(msg[1].asFloat,aaccelX,0.2);
	aaccelY = msg[2].asFloat;//tween.(msg[2].asFloat,aaccelY,0.2);
	aaccelZ = msg[3].asFloat;//tween.(msg[3].asFloat,aaccelZ,0.2);
}, '/gyrosc/accel');

alt = OSCFunc({ |msg, time, addr, recvPort|
	altValue = (msg[1].asFloat);
}, '/gyrosc/alt');
	





graph1 = Canvas3D(window, Rect(0, 0, 500, height/2))
    .scale_(200)
	.background_(Color.gray)
    .perspective_(0.5)
    .distance_(2);

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


// animate
graph1.animate(60) {|t|





	dc.addData([gyroPitch,gyroRoll,gyroYaw,aaccelY.neg,aaccelZ,aaccelX],t);
	//dc.addData([aaccelY.neg,aaccelZ,aaccelX],t);

	// plotter1.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]})).addAll([-pi,pi]);
 //  	plotter1.setProperties(\plotColor, Color.red).refresh;

	// plotter2.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]})).addAll([-pi,pi]);
	// plotter2.setProperties(\plotColor, Color.green).refresh;

	// plotter3.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]})).addAll([-pi,pi]);
	// plotter3.setProperties(\plotColor, Color.blue).refresh;

 	dc.collection = dc.getLast(dataSize); // limit size of collected samples

	rotateRateSum = tween.((rrateX.abs+rrateY.abs+rrateZ.abs).half / 3.0,rotateRateSum,0.08);
	rate.transforms = [ 
		Canvas3D.mScale(0.01,rotateRateSum ,1.0),
		Canvas3D.mTranslate(-2.2,0,0)

    ];


	cube.transforms = [ 
		Canvas3D.mScale(1,0.5,0.05),
        Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
		//Canvas3D.mTranslate(rrateX,rrateY,rrateZ)
    ];



	top.transforms = [ 
		Canvas3D.mScale(1,1,0.05),
		Canvas3D.mTranslate(0,0,1.0),
		Canvas3D.mScale(1,0.5,0.05),
        Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
		Canvas3D.mTranslate(0,altValue.neg * 1  ,0)

    ];

};



graph2 = Canvas3D(window, Rect(0, height/2, 500, height/2))
    .scale_(200)
	.background_(Color.gray)
    .perspective_(0.5)
    .distance_(2);

graph2.add(spot = Canvas3DItem.cube
    .color_(Color.red(0.8))
    .width_(1)
);

graph2.add(accelRate = Canvas3DItem.grid(2)
	.color_(Color.yellow(0.9))
    .width_(1)
);

graph2.add(accelX = Canvas3DItem.regPrism()
	.color_(Color.red(0.9))
    .width_(1)
);
graph2.add(accelY = Canvas3DItem.regPrism()
	.color_(Color.green(0.9))
    .width_(1)
);
graph2.add(accelZ = Canvas3DItem.regPrism()
	.color_(Color.blue(0.9))
    .width_(1)
);


graph2.animate(60) {|t|
	
	accelRateSum = tween.((aaccelY.abs+aaccelZ.abs+aaccelX.abs).half,accelRateSum,0.08);
	
	spot.transforms = [ 

		Canvas3D.mScale(1.0,0.5,0.05),
	    Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
		 Canvas3D.mTranslate(aaccelY.neg.half,aaccelZ.half,aaccelX.half)

    ];
	accelRate.transforms = [ 
		Canvas3D.mScale(0.01,accelRateSum ,1.0),
		Canvas3D.mTranslate(-2.2,0,0)

    ];

	accelX.transforms = [

		Canvas3D.mScale(0.01,(aaccelX),0.01),
        Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
    ];
	accelY.transforms = [ 
		Canvas3D.mScale((aaccelY),0.01,0.01),
        Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
    ];
	accelZ.transforms = [ 
		Canvas3D.mScale(0.01,0.01,(aaccelZ)),
        Canvas3D.mRotateX(gyroRoll + pi.half),
        Canvas3D.mRotateY(gyroYaw.neg),
        Canvas3D.mRotateZ(gyroPitch.neg),
    ];

};


//oscBroadcaster = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

broadcastRoutine = Routine {
	var i=0;
	loop {

		i=i+0.01;

		//gyroPitch = (i.mod(pi).twice) - pi;
		//gyroRoll = (i.mod(pi).twice) - pi;
		gyroYaw = (i.mod(pi).twice) - pi;
		gyroPitch = (i*10).sin + (i*11).cos;
		gyroRoll = (i*12).sin * 0.8 + (i*21).sin * 0.4;
		//gyroYaw = (i*5).cos * 2.0;

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
CmdPeriod.doOnce({window.close});


)





