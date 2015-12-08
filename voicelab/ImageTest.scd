(
	var w = Window.new.front;
	var diameter = 200;
	var radius = diameter.half;
	var origin = Point(radius,radius);
	var numOfPixels = diameter * diameter;

	var imagePath = "~/Music/VoiceLab/color_wheel.png".asAbsolutePath;
	var image = Image.new(diameter,diameter);

	var fps = 1.0/30.0;
	var arduino;

	var channels = Array[
		Dictionary.newFrom(Array[
			\point,Point(radius,radius),
			\pointDelta,Point(radius,radius),
			\color,Color(),
			\view,UserView(w,image.bounds)]),
		Dictionary.newFrom(Array[
			\point,Point(radius,radius),
			\pointDelta,Point(radius,radius),
			\color,Color(),
			\view,UserView(w,image.bounds)]),
		Dictionary.newFrom(Array[
			\point,Point(radius,radius),
			\pointDelta,Point(radius,radius),
			\color,Color(),
			\view,UserView(w,image.bounds)])
	];

	var channelView = UserView(w,image.bounds);

	var calculateColorForPoint = ({|x,y|
		var angle = atan2(x - radius, y - radius);
		var hue = ((angle + pi) / 2pi);
		var sat = origin.dist(Point(x,y))  / (radius * 0.9);
		var val = 1;

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
    image.draw({ arg image;

		numOfPixels.do{|i|

			var j = i % diameter;
			var k = floor(i / diameter);
			Pen.strokeColor = calculateColorForPoint.(j,k);
			Pen.moveTo(j@k);
			Pen.lineTo(j+1@k);
			Pen.stroke;

		};
    });
	//--------------------------------------------------------------------------------

	channels.do{|channel,i|

		var viewRect = channel[\view].bounds;

	channel[\view].bounds_(viewRect.moveBy((i+1)*diameter,0));
		channel[\view].backgroundImage_(image, 1,1,image.bounds);
		w.bounds_(Rect(0,100,diameter*(i+2),diameter));

		channel[\view].mouseDownAction = {|v,x,y|
			channel[\point].set(x,y);
			[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;

		};
		 channel[\view].mouseMoveAction = channel[\view].mouseDownAction;



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


	channel[\pointDelta].addUniqueMethod(\tween,{|self,point|
		var friction = 0.05;
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
		image.free;
	};

	//--------------------------------------------------------------------------------

	~routine = Routine{ |in|
		inf.do{|i|
			channels.do{|channel,i|
				channel[\color] = Color.fromHexString(
					image.getPixel(channel[\pointDelta].x.asInt,channel[\pointDelta].y.asInt).asHexString(6)
				);
			channel[\color] = calculateColorForPoint.(channel[\pointDelta].x.asInt,channel[\pointDelta].y.asInt);
				//[\x,channel[\pointDelta].x,\y,channel[\pointDelta].y,\color,channel[\color]].postln;
				arduino!?{
					r = 255;
					c = channel[\color];
					arduino.dmxc_(i+1,c.red*r,c.green*r,c.blue*r);
				};
			};
			w.refresh();
			fps.wait;


		}
	};

	~routine.play(AppClock);


)
