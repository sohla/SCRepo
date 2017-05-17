
(
	var window;
    var width = Window.screenBounds.width, height = Window.screenBounds.height ;
	var startup, shutdown, buildUI;

	var createPlotterGroup, createGyroCanvas, createAccelCanvas;
	var startOSCListening, stopOSCListening;

    var gryoListner, rrateListener, accelListener, altListener;

    // data
	var gyroPitch = 0, gyroRoll = 0, gyroYaw = 0;

	var gyroEvent = (); 

	var altValue = 0;
	var rrateX = 0, rrateY = 0, rrateZ = 0, rotateRateSum = 0;
	var aaccelX = 0, aaccelY = 0, aaccelZ = 0, accelRateSum = 0;
	
	var broadcastRoutine;
	var pattern, player;

	var dataSize = 100;
	var dc = DataCollector.new("test");
	var dataPath = "~/Develop/SuperCollider/Projects/SCRepo/bounce/data/";

	var tween;



//------------------------------------------------------------	
// synths
//------------------------------------------------------------	

SynthDef(\xylo, { |out=0, freq=440, gate=1, amp=0.3, sustain=0.2, pan=0, patch=1, attack = 0.001|
	var sig = StkBandedWG.ar(freq, instr:patch, mul:20);
	var env = EnvGen.kr(Env.adsr(attack, sustain, sustain, 1.3), gate, doneAction:2);
	Out.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;

Pdef(\pat1).set(\octave,4);
Pdef(\pat1).set(\dur,0.25);
Pdef(\pat1).set(\gtranspose,0);
Pdef(\pat1).set(\patch,0);
Pdef(\pat1).set(\attack,0.8);

Pdef(\pat1,
	Pbind(
		\instrument, \xylo,
        \degree, Pseq([0, 7, 4, 5, 2], inf),
		\amp, Pexprand(0.1,0.4,inf),
		\pan, 0
));


//------------------------------------------------------------	
// 
//------------------------------------------------------------	
startup = {

	DataCollector.makeBackupFolder();
	DataCollector.folder = PathName.new(dataPath).fullPath;

};

//------------------------------------------------------------	
// 
//------------------------------------------------------------	
shutdown = {

	//dc.saveTo(PathName.new(dataPath).fullPath+/+Date.getDate.asSortableString);
	
	Pdef(\pat1).stop;
	
	broadcastRoutine.stop;
	player.stop;

	stopOSCListening.();
};

//------------------------------------------------------------	
// 
//------------------------------------------------------------	
buildUI = {


	QtGUI.palette = QPalette.dark; 

	GUI.skin.plot.gridLinePattern = FloatArray[1, 0];
	GUI.skin.plot.gridColorX = Color.yellow(0.5);
	GUI.skin.plot.gridColorY = Color.yellow(0.5);
	GUI.skin.plot.background = Color.black;
	GUI.skin.plot.plotColor = Color.white;

	window = Window("gyro osc tester", Rect(0, height, width, height), false).front;

	window.onClose = {
		shutdown.();
	};
	CmdPeriod.doOnce({window.close});

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

	createGyroCanvas.();
	createAccelCanvas.();

};



//------------------------------------------------------------	
// Plotters
//------------------------------------------------------------	

createPlotterGroup = {|bounds, plotters|

	var plotterView = UserView(window,bounds).background_(Color.black).animate_(true);
	var size = plotters.size;
	var pw = bounds.width;
	var ph = bounds.height / size;

		plotterView.drawFunc_({});

	plotters.do{ |specs,i|
		var max = 0;
		var plotter = Plotter(specs[0], Rect(pw*0.3,ph*i,pw*0.7,ph),plotterView)
			.value_((0..dataSize))
			.refresh;


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

			{
				var val = specs[2].(plotter).value[0].round(1e-4);
				st.string_(val);

				if(val > max, {max = val});

				su.string_("max :"+max);
				plotter.minval_(-pi);
				plotter.maxval_(pi);

				plotter.setProperties(\plotColor, specs[1]).refresh;

			}.defer(0.1);// need to delay to allow for construction 
		}
	};


};

//------------------------------------------------------------	
// Gyro Canvas
//------------------------------------------------------------	

createGyroCanvas = {
	var graph1;
	var cube, top, rate;
	
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
		.color_(Color.black(0.9))
	    .width_(1)
	);

	// animate
	graph1.animate(60) {|t|

		graph1.background_(Color.hsv((gyroYaw + pi)/pi.twice,0.4,0.9,1));

		Pdef(\pat1).set(\patch,((gyroYaw + pi).div(pi.twice/4.0)).floor);
		Pdef(\pat1).set(\gtranspose,12 + [0,7,12,24].at(((gyroRoll + pi).div(pi.twice/4.0)).floor));
		Pdef(\pat1).set(\dur,Array.geom(8, 1, 2).at(((rrateX.abs+rrateY.abs+rrateZ.abs).sqrt).floor).reciprocal);

		dc.addData([gyroPitch,gyroRoll,gyroYaw,aaccelY.neg,aaccelZ,aaccelX],t);


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

};


//------------------------------------------------------------	
// Accel Canvas
//------------------------------------------------------------	
createAccelCanvas = {
	
    var graph2, spot, accelRate, accelX, accelY, accelZ;

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
		.color_(Color.black(0.9))
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
		Pdef(\pat1).set(\attack,(1.0 + aaccelY.abs+aaccelZ.abs+aaccelX.abs).pow(4).reciprocal);
		
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

};
//------------------------------------------------------------	
// 
//------------------------------------------------------------	

tween = {|input,history,friction = 0.5|
	(friction * input + ((1 - friction) * history))
};


//------------------------------------------------------------	
// osc listneners
//------------------------------------------------------------	

startOSCListening = {

	gryoListner = OSCFunc({ |msg, time, addr, recvPort|
		gyroPitch = (msg[1].asFloat);
		gyroRoll = (msg[2].asFloat);
		gyroYaw = (msg[3].asFloat);

		gyroEvent.pitch = msg[1].asFloat;
		gyroEvent.roll = msg[2].asFloat;
		gyroEvent.yaw = msg[3].asFloat;

	}, '/gyrosc/gyro');

	rrateListener = OSCFunc({ |msg, time, addr, recvPort|
		rrateX = msg[1].asFloat;
		rrateY = msg[2].asFloat;
		rrateZ = msg[3].asFloat;
	}, '/gyrosc/rrate');



	accelListener = OSCFunc({ |msg, time, addr, recvPort|
		aaccelX = msg[1].asFloat;
		aaccelY = msg[2].asFloat;
		aaccelZ = msg[3].asFloat;
	}, '/gyrosc/accel');

	altListener = OSCFunc({ |msg, time, addr, recvPort|
		altValue = (msg[1].asFloat);
	}, '/gyrosc/alt');
		

};

stopOSCListening = {
	gryoListner.free;
	altListener.free;
	rrateListener.free;
	accelListener.free;

};





//------------------------------------------------------------	
// 
//------------------------------------------------------------	

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


		aaccelY = (i*60).sin + (i*51).cos * 0.3;
		aaccelX = (i*30).cos + (i*81).sin * 0.3;
		aaccelZ = (i*130).cos + (i*181).sin * 0.2;

		0.03.yield;
	}
};

//------------------------------------------------------------	
// 
//------------------------------------------------------------	

startup.();
buildUI.();
Pdef(\pat1).play;

startOSCListening.();
//broadcastRoutine.reset().play(AppClock);

)


// a = (\x:4,\y:-5)
// a = ()
// a.x= 1


// a.sum
// a.mean
// a.product
// a.sumabs


// [1,2,3].sum
// [1,2,4].mean
// [1,2,5].product
// [1.2,2.3,-4.4].sumabs

// [1,2,3].normalize(0,10)

// [1,2,3].normalizeSum
