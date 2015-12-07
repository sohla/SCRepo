(
var w, e, m;
e = EnvelopeView()
    .value_([[0.4,0.5,0.55,],[0.5,0.55,0.4]])
    .strings_(["lx1", "lx2", "lx3",])
    .thumbWidth_(60)
    .style_(\dots)
.grid_(Point(0.2,0.2))
.gridOn_(true)
.gridColor_(Color.grey.alpha_(0.1))
.selectionColor_(Color.green)
.connect(0,[1,2])
	.drawLines_(true);
m = PopUpMenu()
    .items_(["Dot Style", "Rect Style"])
    .action_({e.style = m.value});
w = Window()
    .layout_(VLayout(m,e))
    .front;

3.do{|i| e.selectIndex(i)};
)


pixelToColor


p = "~/Music/VoiceLab/largeColorWheel.png".asAbsolutePath;
p = SCDoc.helpSourceDir +/+ "images/Swamp.png";

i = Image.new(p);
i.width;
i.getPixel(50,50).postln;
Color.fromHexString(i.getPixel(50,50).asHexString(6)).postln;

i.plot;

i.free



(
	var w = Window.new.front;
	var imagePath = "~/Music/VoiceLab/largeColorWheel.png".asAbsolutePath;
	var image = Image.new(imagePath);
	var point = Point(image.bounds.width.half,image.bounds.height.half);
	var pointDelta = Point(image.bounds.width.half,image.bounds.height.half);
	var pointerColor = Color();
	var fps = 1.0/30.0;

	var channelView = UserView(w,image.bounds);

	pointDelta.addUniqueMethod(\tween,{|self,point|
		var friction = 0.05;
		self.x = (friction * point.x) + ((1 - friction) * self.x);
		self.y = (friction * point.y) + ((1 - friction) * self.y);
	});


	w.bounds_(image.bounds);
	w.view.backgroundImage_(image, 1,1,w.view.bounds);

	w.view.mouseDownAction = {|v,x,y|
		point.set(x,y)
	};
	w.view.mouseMoveAction = w.view.mouseDownAction;


	w.drawFunc = {|w|
		var size = 30;
		Pen.width = 1.0;
		Pen.strokeColor = Color.black;
		Pen.fillColor = pointerColor;
		Pen.translate(pointDelta.x,pointDelta.y);
		Pen.addOval(Rect(size.half.neg,size.half.neg,size,size));
		Pen.fillStroke;
		Pen.translate(pointDelta.x.neg,pointDelta.y.neg);
		pointDelta.tween(point);


	};

	w.onClose = {
		image.free;
	};
	~routine = Routine{ |in|
		inf.do{|i|

			pointerColor = Color.fromHexString(
				image.getPixel(pointDelta.x.asInt,pointDelta.y.asInt).asHexString(6));

			w.refresh();
			fps.wait;


		}
	};

	~routine.play(AppClock);


)
