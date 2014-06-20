
// use with SCCommDMX2 arduino sketch

a = RduinoDMX(SerialPort.devices.last,115200);

a.dmxc_(0,0,0);
a.dmx_(1,255);
a.dmx_(2,255);
a.dmx_(3,255);


// basic example controlling hue and satuation
(

	a = RduinoDMX(SerialPort.devices.last,115200);
	w = Window.new.front;
	w.onClose = {
		a.dmxc_(0,0,0);
	};

	b = {|hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(c.red*r,c.green*r,c.blue*r);
//		a.dmx_(3,hue*255);
};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			b.value(sl.x*0.999,sl.y*0.999,t);
        });
)

