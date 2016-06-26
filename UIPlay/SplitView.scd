(
var window,viewA,viewB,viewC;

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout(
	viewA = UserView().background_(Color.rand),
	viewB = UserView().background_(window.background)
		.maxWidth_(16)
		.mouseMoveAction_({|view,x,y|
			viewA.maxWidth_(viewA.bounds.width+x);
			viewC.maxWidth_(viewC.bounds.width-x);
		}),
	viewC = UserView().background_(Color.rand)
).margins_([0,0,0,0]).spacing_(0);

viewA.layout = VLayout(
	Button(),Button(),
	StaticText()
		.string_("hello world")
		.align_(\center)
	.font_(Font(size:32))
		.background_(Color.rand)
);

viewC.layout = VLayout(
	HLayout(
		Knob(),Knob(),Knob()
	).margins_([60,0,60,0]),
	HLayout(
		Slider(),Slider(),Slider()
	).margins_([60,0,60,0])


);

window.onClose = ({

});
CmdPeriod.doOnce({window.close});
)

