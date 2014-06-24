a = RduinoDMX(SerialPort.devices.last,115200);
a.dmxc_(254,254,254);
a.dmxc_(0,0,0);
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
	};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			b.value(sl.x*0.999,sl.y*0.999,t);
        });
)


(

	a = RduinoDMX(SerialPort.devices.last,115200);
	w = Window.new.front;

	b = {|hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(c.red*r,c.green*r,c.blue*r);
	};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			//b.value(sl.x*0.999,sl.y*0.999,t);
        });
		
		
	t.x_(0.5);	
	r = Task.new({ inf.do({ |i|

		x = (0.5 + (0.5 * sin(0.00001*i*(180.0/pi))));
		y = (0.8 + (0.1 * sin(0.00002*i*(180.0/pi))));
		{

			m = 255;
			c = Color.hsv(x,1,y,1);
			t.background_(c);
			t.x_(x);
			t.y_(y);
			a.dmxc_(c.red*m,c.green*m,c.blue*m);

			}.defer;
        0.02.wait;
		})

	});

	r.play;
		
	w.onClose = {
		r.stop;
		r.free;
		a.dmxc_(0,0,0);
		a.close;
	};
		
)
