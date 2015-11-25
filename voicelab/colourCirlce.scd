(
	var w = Window("Colour Circle", Rect(10, 500, 520, 420));
	var colorView = UserView().resize_(5).bounds_(Rect(0,0,400,400));
	var slider2DView = UserView().resize_(5);
	var sliderView = Slider().maxWidth_(90);
	var diameter = 400;
	var radius = diameter / 2;
	var origin = Point(radius,radius);
	var numOfPixels = diameter * diameter;
	var point = Point(radius,radius);
	var pointDelta = Point(radius,radius);
	var size = 60;
	var brightness = 1.0;

	var calculateColorForPoint,tween;
	var fps = 1.0/30.0;
	var friction = 0.02;

	pointDelta.addUniqueMethod(\tween,{|self,point|
	self.x = (friction * point.x) + ((1 - friction) * self.x);
	self.y = (friction * point.y) + ((1 - friction) * self.y);
	});

	calculateColorForPoint = ({|x,y|
		var angle = atan2(x - radius, y - radius);
		var hue = ((angle + pi) / 2pi);
		var sat = origin.dist(Point(x,y)) / radius;

		if( hue > 0.999, {hue = 0.0},{});
		if( sat > 0.999, {sat = 0.0},{});

		Color.hsv(hue,sat,brightness,1)
	});


	sliderView.action = ({|v|
		brightness = v.value;
		slider2DView.refresh();
		v.background_(calculateColorForPoint.value(point.x,point.y));

	});
	sliderView.valueAction_(brightness);
	sliderView.background_(Color.white);
	sliderView.mouseMoveAction = sliderView.mouseDownAction;

	slider2DView.mouseDownAction = ({|v,x,y|
		var dist = origin.dist(Point(x,y));
		if((dist <= radius),{point.set(x,y)},{});
	});
	slider2DView.mouseMoveAction = slider2DView.mouseDownAction;
	slider2DView.background = Color.clear;

	slider2DView.drawFunc = ({

		var color = calculateColorForPoint.value(pointDelta.x,pointDelta.y);


		Pen.strokeColor = Color.white;
		Pen.fillColor = Color.black.alpha_(brightness.linlin(0,1,1,0));
		Pen.addOval(Rect(0,0.neg,diameter,diameter));
		Pen.fillStroke;


		Pen.strokeColor = Color.white;
		Pen.fillColor = color;

		Pen.translate(pointDelta.x,pointDelta.y);

		Pen.addOval(Rect(size.half.neg,size.half.neg,size,size));
		Pen.fillStroke;
		Pen.translate(pointDelta.x.neg,pointDelta.y.neg);

		sliderView.background_(color);

		pointDelta.tween(point);
	});

	colorView.drawFunc = ({
		numOfPixels.do({|i|

			var j = i % diameter;
			var k = floor(i / diameter);
			Pen.strokeColor = calculateColorForPoint.value(j,k);
			Pen.moveTo(j@k);
			Pen.lineTo(j+1@k);
			Pen.stroke;

		});
	});

	w.layout = HLayout(
				StackLayout(colorView,slider2DView).mode_(\stackAll).index_(1),
				sliderView
	);

	w.layout.spacing = 10;
	w.layout.margins = [10,10,10,10];
	w.front;

	~routine = Routine{ |in|
		inf.do{|i|
			slider2DView.refresh();
			fps.wait;
		}
	};


	~routine.play(AppClock);

)
