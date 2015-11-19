SerialPort.devices



a = RduinoDMX(SerialPort.devices.last,115200);
a.dmxc_(254,0,0);
a.dmxc_(1,0,0,0);
a.close



// basic example controlling hue and satuation
(

	d = 1; // channel
	a = RduinoDMX(SerialPort.devices.last,115200);
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


// multi controller
(

	a = RduinoDMX(SerialPort.devices.last,115200);

	v = Window.screenBounds.width;
	w = Window.new("VoiceLab LX Tester",Rect(0,50,v,v/3)).front;

	w.onClose = {
		3.do({|i|a.dmxc_(i+1,0,0,0)});
		a.close;

	};

	b = {|channel,hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(channel,c.red*r,c.green*r,c.blue*r);
	};

	w.layout_( HLayout (

	f = {|sl|
		w.asView.children.find([sl]);
		b.value(w.asView.children.find([sl])+1,min(sl.x,0.999),min(sl.y,0.999),sl);
        };


	Slider2D(w).action_(f),
	Slider2D(w).action_(f),
	Slider2D(w).action_(f)
		)
	);

)
