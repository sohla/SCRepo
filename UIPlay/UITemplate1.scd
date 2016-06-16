(
var window;

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();





window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)