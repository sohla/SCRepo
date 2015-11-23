(
	var w = Window("Slider2D", Rect(10, 500, 400, 400));
	var colorView = UserView().resize_(5);
	var sliderView = UserView().resize_(5);
	var diameter = w.bounds.width;
	var radius = diameter / 2;
	var origin = Point(radius,radius);
	var numOfPixels = diameter * diameter;
	var point = Point(0,0);
	var size = 30;

	var calculateColorForPoint;


	calculateColorForPoint = ({|x,y|
			var angle = atan2(x - radius, y - radius);
			var hue = min(((angle + pi) / 2pi),0.999);
			var sat = min(origin.dist(Point(x,y))/radius,0.999);
			Color.hsv(hue,sat,1,1)
	});

	sliderView.background = Color.clear;

	w.layout = StackLayout(colorView,sliderView).mode_(\stackAll).index_(1);


	sliderView.mouseDownAction = ({|v,x,y|
		point.set(x,y);
		v.refresh();

	});
	sliderView.mouseMoveAction = sliderView.mouseDownAction;

	sliderView.drawFunc = ({

		Pen.strokeColor = Color.white;
		Pen.fillColor = calculateColorForPoint.value(point.x,point.y);
		Pen.translate(point.x,point.y);
		Pen.addOval(Rect(size.half.neg,size.half.neg,size,size));
		Pen.fillStroke;
		Pen.translate(point.x.neg,point.y.neg);
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

	colorView.refresh;
	w.front;
)
