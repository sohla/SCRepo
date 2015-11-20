(


//	a = RduinoDMX(SerialPort.devices.last,115200);
	~deviceWindow = Window.new(bounds:Rect(100,100,200,200)).front.layout_(
		VLayout(
	        [~listView = ListView()
				.items_(SerialPort.devices)

				.action_({|v|
					//v.items.at(v.value).postln;
				})
			, stretch:1]

			,[Button()
			.states_([["connect"]])
			.action_({|b|
				SerialPort.devices[~listView.value].postln;
			});


			]
	    )
	);

	~deviceWindow.toFrontAction = {
		"toFront".postln;
	};


	~deviceWindow.onClose = {
		"onClose".postln;
	};

)



(
	~arduinoPath = "/dev/tty.usbmodem1411"


	a = RduinoDMX(~arduinoPath,115200);


	w = Window.new.front;

	w.onClose = {
		a.dmxc_(d,0,0,0);
		a.close;

	};


	f = {|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			b.value(sl.x*0.999,sl.y*0.999,t);
        };

	b = {|hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(d,c.red*r,c.green*r,c.blue*r);
	};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_(f);
)
List[1, 2, 3, 4].detect({ arg item, i; item.even});


