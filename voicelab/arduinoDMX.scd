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
        .y_(0)   // initial location of y_
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			//b.value(sl.x*0.999,sl.y*0.999,t);
        });
		
	v=UserView(w, 10@10);
	v.background_(Color.black);
	t.x_(0.5);	
	
	r = Task.new({ inf.do({ |i|

		{
			x = (t.x + (0.1 * sin(0.001*i*(180.0/pi)))).clip(0,0.999);
			y = (t.y + (0.1 * cos(0.001*i*(180.0/pi)))).clip(0,0.999);

			//("x;"++x++" y:"++y).postln;
			b.value(x,y,t);
			v.moveTo(x * w.view.bounds.width, w.view.bounds.height - (y * w.view.bounds.height));
			

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
s.boot

