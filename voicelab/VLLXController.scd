(
	var w = Window.new("VoiceLab LX Channel Controller").front;
	var diameter = 200;
	var radius = diameter.half;
	var origin = Point(radius,radius);
	var numOfPixels = diameter * diameter;
	var baseRect = Rect(0,0,diameter,diameter);
	var fps = 1.0/30.0;
	var arduino;
	var brightness = 30;

	var channels = Array[
		Dictionary.newFrom(Array[
			\point,Point(radius,radius),
			\pointDelta,Point(radius,radius),
			\color,Color(),
			\compView,CompositeView(w,baseRect),
			\bgView,nil,
			\view,nil])
	];

	var channelView = UserView(w,baseRect.bounds);
	var onButton = Slider(w,Rect(20,10,150,40))
		.value_(brightness/255)
		.action_{|b|
			brightness = 255 * b.value.asFloat;
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
					var angle = 360.0.rand;
					var range = 10;
					var x = diameter.half + (sin( (pi/180) * angle) * diameter.half * 0.95);
					var y = diameter.half + (cos( (pi/180) * angle ) * diameter.half * 0.95);

					channels.do{|lc,li| lc.[\point].set(x,y)};

					5.wait;
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

	var connectDMX = {
		try{
			arduino = RduinoDMX(SerialPort.devices.last,115200);
		}{|error|
			[\Connecting:error.errorString].postln;
		};
	};
	connectDMX.value();

	//--------------------------------------------------------------------------------

	channels.do{|channel,i|

		var viewRect = baseRect;//channel[\view].bounds;


		channel[\compView].bounds_(viewRect.moveBy((i+1)*diameter,0));
		channel[\view] = UserView(channel[\compView],baseRect);
		channel[\bgView] = UserView(channel[\compView],viewRect);


		w.bounds_(Rect(0,100,diameter*(i+2),diameter));

		channel[\bgView].mouseDownAction = {|v,x,y|
			//[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;
				var dist = origin.dist(Point(x,y));
				if((dist <= radius),{channel[\point].set(x,y)},{});


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
			channels.do({|channel,i|arduino.dmxc_(i+1,0,0,0)});
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

			onButton.background_(Color.new255(
				channels[0][\color].red * brightness,
				channels[0][\color].green * brightness,
				channels[0][\color].blue * brightness,
				1.0
			));

			//[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;
				arduino!?{
					c = channel[\color];
					arduino.dmxc_(
						i+1,
						c.red * brightness,
						c.green * brightness,
						c.blue * brightness

					);
				};
			};
			fps.wait;


		}
	};

	~routine.play(AppClock);

	autoButton.valueAction  = 1;
)
