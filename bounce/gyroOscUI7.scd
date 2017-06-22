
	(
	    var width = Window.screenBounds.width, height = Window.screenBounds.height ;
		var startup, shutdown, buildUI;
		var playRoutine;

		var contentView = View().background_(Color.grey(0.2));

		var names = ["george","harry"];

		var reloadButton;

		var createPlotterGroup, createGyroCanvas, createAccelCanvas, createTransportView;
		var createWindowView, addDeviceView;
		var startOSCListening, stopOSCListening, enableOSCListening, disableOSCListening;

		var addDevice, removeDevice;

	    var gryoListner, rotMatListner, rrateListener, accelListener, altListener, ampListener;
	    var buttonListener;

		var devices = Dictionary();

	    // data
		var deviceProto = (
			\ip: "127.0.0.1",
			\port: "57120",
			\gyroEvent: (\pitch:0,\roll:0,\yaw:0),
			\rrateEvent: (\x:0,\y:0,\z:0),
			\rrateMass: 0,
			\accelEvent: (\x:0,\y:0,\z:0),
			\ampValue: 0,
			\name: "george",
			\env: nil,
			\rout: nil
			);

		var loadPersonality;
		var createRout;

		var accelEvent = (\x:0,\y:0,\z:0);

		var ampValue = 0;
		
		var broadcastRoutine;
		var replayRoutine;

		var pattern, player;

		var dataSize = 100;
		var dc = DataCollector.new("test");
		var lc = nil;
		var dataPath = "~/Develop/SuperCollider/Projects/SCRepo/bounce/data/";

		var tween;

		var oldRollStep = 0,oldPitchStep = 0;


		var pos3D = [0,0,0];

		var isSimulating = {|yes,no|

			if(false,{
				yes.();
			},{
				no.();
			});
		};

	//------------------------------------------------------------	
	// midi
	//------------------------------------------------------------	

	// MIDIClient.init;
	// MIDIClient.destinations;
	// m = MIDIOut(0);

	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	

	loadPersonality = {|name|

		var path = PathName.new("~/Develop/SuperCollider/Projects/SCRepo/bounce/"++name++".sc");
		var file = File.new(path.asAbsolutePath,"r");
		var str = file.readAllString;
		var env = Environment.make {interpret(str)};

		env
	};

	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	
	createRout = {|d|

		Routine { 
			var i=0;
			loop{ 
				d.env.use{
					~next.(i,d);
					(~fps.()).yield;
					i=i+1;
				};
			}
		};

	};

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

		devices.keysValuesDo({|k,v|
			v.env.use{ ~deinit.() };
			v.rout.stop();
		});

		broadcastRoutine.stop;
		playRoutine.stop;
		replayRoutine.stop;
		player.stop;

		stopOSCListening.();
	};
	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	

	addDevice = { |ip|

		var d = Event.new(proto:deviceProto);
		
		d.ip = ip;
		d.gyroEvent.pitch = 0.0;//•?

		//• need to compare names with devices.name to find unused personality
		//• currently loading from proto
		d.env = loadPersonality.(d.name);
		d.env.use{ ~init.() };
		d.rout = createRout.(d);
		d.rout.reset.play(AppClock);

		devices.put(ip,d);
		
		d // return the device (data)
	};
	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	
	buildUI = {
		
		var window;

		QtGUI.palette = QPalette.dark; 

		GUI.skin.plot.gridLinePattern = FloatArray[1, 0];
		GUI.skin.plot.gridColorX = Color.yellow(0.5);
		GUI.skin.plot.gridColorY = Color.yellow(0.5);
		GUI.skin.plot.background = Color.black;
		GUI.skin.plot.plotColor = Color.white;

		window = Window("gyro osc tester", Rect(0, height, width, height/2 + 70), false).front;
		window.view.keyDownAction_({|view,char,mods,uni,code,key|
			if(uni==82,{
				reloadButton.doAction();
			});
		});

		window.onClose = {
			shutdown.();
		};
		CmdPeriod.doOnce({window.close});
		
		createWindowView.(window);

	};

	createWindowView = {|view|

		var scroll = ScrollView(view,Rect(0,0,width,height/2 + 70)).background_(Color.yellow);
		contentView.layout_(VLayout());
		contentView.layout.add(nil);
		scroll.canvas = contentView;

		// set this for quick connection to device
		addDeviceView.(contentView, addDevice.("192.168.0.100"));
	};

	addDeviceView = { |view, d|

		var header;
		var va,vb;
		var stackView, stackLayout;

		var reload = {

			// stop personality
			d.rout.stop;
			d.env.use{ ~deinit.() };

			// start new personality
			d.env = loadPersonality.(d.name);
			d.env.use{ ~init.() };
			d.rout = createRout.(d);
			d.rout.reset.play(AppClock);

		};
		header = View(view).layout_( HLayout(
			
					Button(view)
				.minWidth_(120)
				.states_([
					["Attitude"],	
					["Accelerometer"]
				])
				.action_({|b|
					stackLayout.index = b.value;
				}),

			StaticText(view)
				.stringColor_(Color.gray(0.8))
				.font_(Font(size:14))
				.minWidth_(500)
				.string_("📡  ip ["+d.ip+"] port ["+d.port+"]"),

	

			reloadButton = Button(view)
			.maxWidth_(60)
			.states_([
				["Reload"],	
			])
			.action_({|b|
				reload.();
			}),

			PopUpMenu(view)
					.minWidth_(200)
					.items_(names)
					.valueAction_(names.find([d.name]))
					.action_({|b|

						d.name = names.at(b.value);
						reload.();
					}),

			Button(view)
				.maxWidth_(100)
				.states_([
					["Disconect",Color.red(0.5)],	

				])
				.action_({|b|
					header.remove();
					stackView.remove();
					
					// stop personality
					d.env.use{ ~deinit.() };
					d.rout.stop;

					devices.removeAt(d.ip);

				})

		).setAlignment(0,\left).setAlignment(3,\left));




		view.layout.add(stackView = View().background_(Color.yellow).minHeight_(height/2).layout_( stackLayout = StackLayout(
				va = View().background_(Color.cyan(0.2)),
				vb = View().background_(Color.blue(0.2))
				)
			);
		);	



		// createPlotterGroup.(va, Rect(500,0,400,height/2), [
		// 	["pitch",Color.red,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][0]}));
		// 	}],
		// 	["roll",Color.green,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][1]}));
		// 	}],
		// 	["yaw",Color.blue,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][2]}));
		// 	}],
		// ]);

		// createPlotterGroup.(vb, Rect(500,0,400,height/2), [
		// 	["aaccelX",Color.cyan,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][6]}));
		// 	}],
		// 	["accelY",Color.magenta,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][7]}));
		// 	}],
		// 	["accelZ",Color.yellow,{|p|
		// 		p.value = (dc.getLast(dataSize).asArray.collect({|a,i| a[\data][8]}));
		// 	}],
		// ]);


		createGyroCanvas.(va,d);
		createAccelCanvas.(vb,d);

		

	};

	//------------------------------------------------------------	
	// Plotters
	//------------------------------------------------------------	

	createPlotterGroup = {|view, bounds, plotters|

		var plotterView = UserView(view,bounds).background_(Color.black).animate_(true);
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

	createGyroCanvas = { |view, data|
		var graph1;
		var cube, top, rate, loc, ico;
		var p1,p2,p3;
		var t = (1.0 + (5.0).sqrt) / 2.0;

		graph1 = Canvas3D(view, Rect(0, 0, 500, height/2))
		    .scale_(200)
			.background_(Color.gray)
		    .perspective_(0.5)
		    .distance_(2.5);


		// graph1.view.drawFunc= graph1.view.drawFunc<>{
		// 	("[data"+"}-->".scramble).draw
		// };
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

		graph1.add(loc = Canvas3DItem.regPrism(3)
			.color_(Color.blue(0.9))
		    .width_(1)
		    //
		);


     graph1.add(p1 = Canvas3DItem.grid(2)
        .color_(Color.black)
		.fill_(false)
        .width_(1)
		.transform(Canvas3D.mScale(1,t,1))
		//.transform(Canvas3D.mRotateY(pi/2))
    );
    graph1.add(p2 = Canvas3DItem.grid(2)
        .color_(Color.black)
        .width_(1)
		.fill_(false)
		.transform(Canvas3D.mScale(t,1,1))
		.transform(Canvas3D.mRotateY(pi/2))
    );
    graph1.add(p3 = Canvas3DItem.grid(2)
        .color_(Color.black)
        .width_(1)
		.fill_(false)
		.transform(Canvas3D.mScale(t,1,t))
		.transform(Canvas3D.mRotateX(pi/2))
    );


		 graph1.add(ico = Canvas3DItem()
	        .color_(Color.blue.alpha_(0.1))
    	    .width_(2)
			.fill_(true)
			.paths_([
				[p1.paths[0][0],p1.paths[0][1],p2.paths[0][1]],
	 			[p2.paths[0][1],p3.paths[0][0],p1.paths[0][0]],
			    [p1.paths[0][1],p3.paths[0][1],p2.paths[0][1]],
			   	[p1.paths[0][0],p2.paths[0][0],p1.paths[0][1]],
		    	[p1.paths[0][1],p3.paths[1][1],p2.paths[0][0]],
	    		[p1.paths[0][0],p3.paths[1][0],p2.paths[0][0]],

			   	[p1.paths[1][0],p2.paths[1][0],p1.paths[1][1]],
	    		[p1.paths[1][1],p3.paths[1][1],p2.paths[1][0]],
			    [p1.paths[1][0],p3.paths[1][0],p2.paths[1][0]],
			    [p1.paths[1][0],p2.paths[1][1],p1.paths[1][1]],
		    	[p1.paths[1][1],p3.paths[0][1],p2.paths[1][1]],
		    	[p1.paths[1][0],p3.paths[0][0],p2.paths[1][1]],

			    [p2.paths[0][1],p3.paths[0][0],p2.paths[1][1]],
			    [p2.paths[0][1],p3.paths[0][1],p2.paths[1][1]],

			    [p2.paths[0][0],p3.paths[1][1],p2.paths[1][0]],
			    [p2.paths[0][0],p3.paths[1][0],p2.paths[1][0]],

			    [p3.paths[0][0],p1.paths[1][0],p3.paths[1][0]],
			    [p3.paths[0][0],p1.paths[0][0],p3.paths[1][0]],

			    [p3.paths[0][1],p1.paths[1][1],p3.paths[1][1]],
			    [p3.paths[0][1],p1.paths[0][1],p3.paths[1][1]],
			])
	    );

		loc.transform(Canvas3D.mScale(0.02,0.02,0.2));

		// animate
		graph1.animate(30) {|t|
			

			var sx,sy,sz;

			// store data
/*
			dc.addData([
				gyroEvent.pitch,gyroEvent.roll,gyroEvent.yaw,
				accelEvent.y.neg,accelEvent.z,accelEvent.x,
				rrateEvent.x,rrateEvent.y,rrateEvent.z
				],t);


		 	dc.collection = dc.getLast(dataSize); // limit size of collected samples
*/
	    	pos3D = [0,0,0];
	        pos3D = Canvas3D.vectorMatrixMul(pos3D, Canvas3D.mScale(1,0.5,0.05));
	        pos3D = Canvas3D.vectorMatrixMul(pos3D, Canvas3D.mTranslate(0,0,1.5));
	        pos3D = Canvas3D.vectorMatrixMul(pos3D, Canvas3D.mRotateX(data.gyroEvent.roll + pi.half));
	        pos3D = Canvas3D.vectorMatrixMul(pos3D, Canvas3D.mRotateY(data.gyroEvent.yaw.neg));
	       	pos3D = Canvas3D.vectorMatrixMul(pos3D, Canvas3D.mRotateZ(data.gyroEvent.pitch.neg));


	        loc.transforms = [
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
	        	Canvas3D.mTranslate(pos3D[0],pos3D[1],pos3D[2]),
	        ];


			sx = ((pos3D[0] + 1.5) * ( 2.0 / 3.0)).floor;
			sy = ((pos3D[1] + 1.5) * ( 2.0 / 3.0)).floor;
			sz = ((pos3D[2] + 1.5) * ( 2.0 / 3.0)).floor;

			//( (sz*4) + (sy*2) + sx).postln;
			graph1.background_(Color.hsv(( ( (sz*4) + (sy*2) + sx) / 8.0 ),0.8,0.8,1));

			cube.transforms = [ 
				Canvas3D.mScale(1,0.5,0.05),
				Canvas3D.mTranslate(0,0,1.5),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
		    ];

			top.transforms = [ 
				Canvas3D.mScale(1,1,0.05),
				Canvas3D.mScale(1,0.5,0.05),
				Canvas3D.mTranslate(0,0,1.5),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
				//Canvas3D.mTranslate(0,altValue.neg * 1  ,0)
		    ];

		    ico.transforms = [ 
				//Canvas3D.mScale(0.6,0.6,0.6),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
				//Canvas3D.mTranslate(0,altValue.neg * 1  ,0)
		    ];
		    
		    p1.transforms=ico.transforms;
			p2.transforms=ico.transforms;
			p3.transforms=ico.transforms;

			rate.transforms = [ 
				Canvas3D.mScale(0.01,data.rrateMass.half ,1.0),
				Canvas3D.mTranslate(-2.2,0,0)

		    ];


		};

	};


	//------------------------------------------------------------	
	// Accel Canvas
	//------------------------------------------------------------	
	createAccelCanvas = { |view, data|
		
	    var graph2, spot, accelRate, accelX, accelY, accelZ;

		graph2 = Canvas3D(view, Rect(0, 0, 500, height/2))
		    .scale_(200)
			.background_(Color.black)
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
			

			spot.transforms = [ 
				Canvas3D.mScale(1.0,0.5,0.05),
			    Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
				 Canvas3D.mTranslate(accelEvent.y.neg.half,accelEvent.z.half,accelEvent.x.half)
		    ];

			accelRate.transforms = [ 
				Canvas3D.mScale(0.01,accelEvent.mass ,1.0),
				Canvas3D.mTranslate(-2.2,0,0)
		    ];

			accelX.transforms = [
				Canvas3D.mScale(0.01,(accelEvent.x),0.01),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
		    ];

			accelY.transforms = [ 
				Canvas3D.mScale((accelEvent.y),0.01,0.01),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
		    ];
			accelZ.transforms = [ 
				Canvas3D.mScale(0.01,0.01,(accelEvent.z)),
		        Canvas3D.mRotateX(data.gyroEvent.roll + pi.half),
		        Canvas3D.mRotateY(data.gyroEvent.yaw.neg),
		        Canvas3D.mRotateZ(data.gyroEvent.pitch.neg),
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


		buttonListener = OSCFunc({ |msg, time, addr, recvPort|

			if(msg[1].asFloat == 1.0, {
				if(devices.at(addr.ip) == nil,{
					{
						var d = addDevice.(addr.ip);
						addDeviceView.(contentView, d)
					}.defer;
				},{
					devices.removeAt(addr.ip);
				});
				 //devices.postln;
			});

		}, '/gyrosc/button');

		gryoListner = OSCFunc({ |msg, time, addr, recvPort|
			// gyroEvent.pitch = msg[1].asFloat;
			// gyroEvent.roll = msg[2].asFloat;
			// gyroEvent.yaw = msg[3].asFloat;

			if(devices.at(addr.ip) != nil,{

				devices.at(addr.ip).gyroEvent = (
					\pitch:msg[1].asFloat,
					\roll:msg[2].asFloat,
					\yaw:msg[3].asFloat);
			});
		
		}, '/gyrosc/gyro');


		// rotMatListner = OSCFunc({ |msg, time, addr, recvPort|
		// 	// gyroEvent.pitch = msg[1].asFloat;
		// 	// gyroEvent.roll = msg[2].asFloat;
		// 	// gyroEvent.yaw = msg[3].asFloat;
		// 	//rotMatEvent = msg[1..].clumps([4]);
		// 	//rotMatEvent.postln;
		// }, '/gyrosc/rotmat');


		rrateListener = OSCFunc({ |msg, time, addr, recvPort|
			// rrateEvent.x = msg[1].asFloat;
			// rrateEvent.y = msg[2].asFloat;
			// rrateEvent.z = msg[3].asFloat;

			if(devices.at(addr.ip) != nil,{

				devices.at(addr.ip).rrateEvent = (
					\x:msg[1].asFloat,
					\y:msg[2].asFloat,
					\z:msg[3].asFloat);
			});

		}, '/gyrosc/rrate');



		accelListener = OSCFunc({ |msg, time, addr, recvPort|
			accelEvent.x = msg[1].asFloat;
			accelEvent.y = msg[2].asFloat;
			accelEvent.z = msg[3].asFloat;
		}, '/gyrosc/accel');

		// altListener = OSCFunc({ |msg, time, addr, recvPort|
		// 	altValue = (msg[1].asFloat);
		// }, '/gyrosc/alt');
			
		ampListener = OSCFunc({ |msg, time, addr, recvPort|
			ampValue = (msg[1].asFloat);
		}, '/gyrosc/amp');

	};

	stopOSCListening = {
		buttonListener.free;
		ampListener.free;
		gryoListner.free;
		// altListener.free;
		rrateListener.free;
		//rotMatListner.free;
		accelListener.free;
	};

	enableOSCListening = {
		buttonListener.enable;
		ampListener.enable;
		gryoListner.enable;
		// altListener.enable;
		rrateListener.enable;
		//rotMatListner.enable;
		accelListener.enable;
	};

	disableOSCListening = {
		buttonListener.disable;
		ampListener.disable;
		gryoListner.disable;
		//altListener.disable;
		rrateListener.disable;
		//rotMatListner.disable;
		accelListener.disable;
	};

	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	

	broadcastRoutine = Routine {
		var i=0,j=0,k=0;
		loop {

			i=i+0.01;
			j=j+0.022;
			k=k+0.034;

			// gyroYaw = (i.mod(pi).twice) - pi;
			// gyroPitch = (i*10).sin + (i*11).cos;
			// gyroRoll = (i*12).sin * 0.8 + (i*21).sin * 0.4;
			//gyroYaw = (i*5).cos * 2.0;

			//gyroEvent.yaw = (i.mod(pi).twice) - pi;
			// gyroEvent.pitch = (k.mod(pi).twice) - pi;//((i*10).sin + (i*11).cos) * 2.0;
			// gyroEvent.roll =  (j.mod(pi).twice) - pi;

			accelEvent.y = (i*60).sin + (i*51).cos * 0.09;
			accelEvent.x = (i*30).cos + (i*81).sin * 0.06;
			accelEvent.z = (i*130).cos + (i*181).sin * 0.07;

			// rrateEvent.x =  (i.mod(pi).twice) - pi;
			// rrateEvent.y =  (j.mod(pi).twice) - pi;
			// rrateEvent.z =  (i.mod(pi).twice) - pi;

			(1.0/60.0).yield;

// 
		}
	};

	replayRoutine = Routine {
		var i=0;
		loop {

			var data = [];

			i = (i+1).mod(lc.collection.size);

			data = lc.collection.reverse[i][\data];

			// gyroEvent.pitch = data[0];
			// gyroEvent.roll = data[1];
			// gyroEvent.yaw = data[2];
			accelEvent.y = data[3];
			accelEvent.z = data[4];
			accelEvent.x = data[5];
			// rrateEvent.x = data[6];
			// rrateEvent.y = data[7];
			// rrateEvent.z = data[8];

			(1.0/60.0).yield;
		}
	};

	//------------------------------------------------------------	
	// 
	//------------------------------------------------------------	


	startup.();
	buildUI.();
	startOSCListening.();
	isSimulating.({broadcastRoutine.reset().play(AppClock);disableOSCListening.();},{});

	)

