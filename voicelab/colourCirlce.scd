(
	var w = Window("Slider2D", Rect(10, 500, 400, 400));
	var diameter = w.bounds.width;

	var radius = diameter / 2;
	var origin = Point(radius,radius);

	var numOfPixels = diameter * diameter;

w.drawFunc = ({
	numOfPixels.do({|i|

		var j = i % diameter;
		var k = floor(i / diameter);
		var angle = atan2(j - radius, k - radius);
		var hue = min(((angle + pi) / 2pi),0.999);
		var sat = min(origin.dist(Point(j,k))/radius,0.999);
		var c = Color.hsv(hue,sat,1,1);
		Pen.strokeColor = c;
		Pen.moveTo(j@k);
		Pen.lineTo(j+1@k);
		Pen.stroke;

	});
});

w.refresh;
w.front;
)
