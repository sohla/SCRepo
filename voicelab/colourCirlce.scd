(
	var w = Window("Slider2D", Rect(10, 500, 400, 400));
	var diameter = w.bounds.width;

	var radius = diameter / 2;
	var origin = Point(radius,radius);

	var numOfPixels = diameter * diameter;

// w.drawFunc = ({
// 	numOfPixels.do({|i|
//
// 		var j = i % diameter;
// 		var k = floor(i / diameter);
// 		var angle = atan2(j - radius, k - radius);
// 		var c = Color.hsv(((angle + pi) / 2pi),origin.dist(Point(j,k))/radius,1,1);
// 		Pen.strokeColor = c;
// 		Pen.moveTo(j@k);
// 		Pen.lineTo(j+1@k);
// 		Pen.stroke;
//
// 	});
// });
// w.refresh;

//w.background_(Color.white);




t = Slider2D(w, w.view.bounds)
.x_(0.5) // initial location of x
.y_(1)   // initial location of
.background_(Color.clear)
.action_({|sl|

	var point = Point(t.x * diameter, t.y * diameter);
	var angle = atan2((t.x * diameter) - radius, (t.y * diameter) - radius) ;

	var c = Color.hsv(((angle + pi) / 2pi),origin.dist(point)/radius,1,1);




	//sl.background_(c);


	//[\center,origin.dist(point)/radius,\degrees,((angle + pi) / 2pi) * 360].postln;



});
w.front;
)
