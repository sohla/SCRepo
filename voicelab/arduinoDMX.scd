
// use with SCCommDMX2 arduino sketch

a = RduinoDMX(SerialPort.devices.last,115200);

a.dmxc_(0,0,0)
a.dmx_(1,255)
a.dmx_(2,255)
a.dmx_(3,0)


// basic example controlling hue and satuation
(
	

	a = RduinoDMX(SerialPort.devices.last,115200);
	w = Window.new.front;
o=0;
	w.onClose = {
		a.dmxc_(0,0,0);
	};

	b = {|hue,sat,slider|
		c = Color.hsv(hue,sat,1,1);
		slider.background_(c);
		a.dmxc_(c.red*255.0,c.green*255.0,c.blue*255.0);
	};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			b.value(sl.x*0.99,sl.y*0.99,t);
        });
)

