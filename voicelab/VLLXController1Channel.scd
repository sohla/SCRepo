(
	var w = Window.new("VoiceLab LX Channel Controller").front;
	var diameter = 200;
	var radius = diameter.half;
	var origin = Point(radius,radius);
	var numOfPixels = diameter * diameter;
	var baseRect = Rect(0,0,diameter,diameter);
	var fps = 1.0/30.0;
	var arduino;

	var channels = Array[
		Dictionary.newFrom(Array[
			\point,Point(radius,radius),
			\pointDelta,Point(radius,radius),
			\color,Color(),
			\compView,CompositeView(w,baseRect),
			\bgView,nil,
			\view,nil])
	// ,
	// Dictionary.newFrom(Array[
	// 	\point,Point(radius,radius),
	// 	\pointDelta,Point(radius,radius),
	// 	\color,Color(),
	// 	\compView,CompositeView(w,baseRect),
	// 	\bgView,nil,
	// \view,nil]),
	// Dictionary.newFrom(Array[
	// 	\point,Point(radius,radius),
	// 	\pointDelta,Point(radius,radius),
	// 	\color,Color(),
	// 	\compView,CompositeView(w,baseRect),
	// 	\bgView,nil,
	// \view,nil])
	];

	var channelView = UserView(w,baseRect.bounds);
	var lockButton = Button(w,Rect(20,10,150,40))
		.states_([
			["Lock Off",Color.black],
			["Lock On",Color.red]
	])
	.action_{|b|
	};

	var autoButton = Button(w,Rect(20,60,150,40))
		.states_([
			["Auto Off",Color.black],
			["Auto On",Color.red]
	])
	.action_{|b|
			case
			{ b.value == 0}{
				~autoRun.stop;
			}
			{ b.value == 1}{
				~autoRun = Routine{ |in|
				inf.do{|i|
					var r = 40;
					var x = r.half + (diameter - r).rand;
					var y = r.half + (diameter - r).rand;

					channels.do{|lc,li| lc.[\point].set(x,y)};

					3.wait;
				}
			};
			~autoRun.play(AppClock);
		}
	};
	var calculateColorForPoint = ({|x,y|
		var angle = atan2(x - radius, y - radius);
		var hue = ((angle + pi) / 2pi);
		var sat = origin.dist(Point(x,y))  / (radius * 0.78);
		var val = 1;
		if( sat > 1.25, {hue = 1.0;val=0},{});
		if( sat > 1.25, {sat = 1.0;},{});

		if( hue > 0.999, {hue = 0.0},{});
		if( sat > 0.999, {sat = 1.0;},{});

		Color.hsv(hue,sat,val,1)
	});

	//--------------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------------

	try{
		arduino = RduinoDMX(SerialPort.devices.last,115200);
	}{|error|
		[\Connecting:error.errorString].postln;
	};


	//--------------------------------------------------------------------------------

	channels.do{|channel,i|

		var viewRect = baseRect;//channel[\view].bounds;


		channel[\compView].bounds_(viewRect.moveBy((i+1)*diameter,0));
		channel[\view] = UserView(channel[\compView],baseRect);
		channel[\bgView] = UserView(channel[\compView],viewRect);


		w.bounds_(Rect(0,100,diameter*(i+2),diameter));

		channel[\bgView].mouseDownAction = {|v,x,y|
			//[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;
			case
			{ lockButton.value == 0}{
				channel[\point].set(x,y);
			}
			{ lockButton.value == 1}{
				channels.do{|lc,li| lc.[\point].set(x,y)};
			}

		};
		 channel[\bgView].mouseMoveAction = channel[\bgView].mouseDownAction;

		channel[\bgView].drawFunc = ({
		numOfPixels.do{|p|
			var j = p % diameter;
			var k = floor(p / diameter);
			Pen.strokeColor = calculateColorForPoint.(j,k);
			Pen.moveTo(j@k);
			Pen.lineTo(j+1@k);
			Pen.stroke;
		};
		});

	channel[\view].drawFunc = {|w|
		var size = 30;
		Pen.width = 1.0;
		Pen.strokeColor = Color.black;
		Pen.fillColor = channel[\color];
		Pen.translate(channel[\pointDelta].x,channel[\pointDelta].y);
		Pen.addOval(Rect(size.half.neg,size.half.neg,size,size));
		Pen.fillStroke;
		Pen.translate(channel[\pointDelta].x.neg,channel[\pointDelta].y.neg);
		channel[\pointDelta].tween(channel[\point]);
	};
	channel[\view].animate_(true);

	channel[\pointDelta].addUniqueMethod(\tween,{|self,point|
		var friction = 0.01;
		self.x = (friction * point.x) + ((1 - friction) * self.x);
		self.y = (friction * point.y) + ((1 - friction) * self.y);
	});



	};

	//--------------------------------------------------------------------------------

	w.onClose = {
		arduino!?{
			3.do({|i|arduino.dmxc_(i+1,0,0,0)});
			arduino.close;
		};

		~routine.stop;
		~autoRun.stop;

	};

	//--------------------------------------------------------------------------------



//--------------------------------------------------------------------------------

	~routine = Routine{ |in|
		inf.do{|i|
		 channels.do{|channel,i|

			channel[\color] = calculateColorForPoint.(channel[\pointDelta].x.asInt,channel[\pointDelta].y.asInt);

			//[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;
				arduino!?{
					r = 255;
					c = channel[\color];
					arduino.dmxc_(i+1,c.red*r,c.green*r,c.blue*r);
				};
			};
			fps.wait;


		}
	};

	~routine.play(AppClock);


)
