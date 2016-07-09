(
var window;

window = Window("")
	.bounds_(Rect(
		0,0,
		400,
		100)
		.center_(Window.availableBounds.center)
	)
	.front;

// window.layout = HLayout(WebView().url_("https://www.freesound.org/data/displays/25/25656_48671_wave_L.png"));


	ScrollView(window)
		.bounds_(Rect(0,0,400,100))
		.canvas_(WebView().url_("https://www.freesound.org/data/displays/25/25656_48671_wave_L.png"));





window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});

CmdPeriod.doOnce({window.close});


)


