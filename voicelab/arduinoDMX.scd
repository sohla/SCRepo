SerialPort.devices



a = RduinoDMX(SerialPort.devices.last,115200);
a.dmxc_(254,0,0);
a.dmxc_(1,0,0,0);
a.close
// basic example controlling hue and satuation
(

	d = 3;
	a = RduinoDMX(SerialPort.devices.last,115200);
	w = Window.new.front;
	w.onClose = {
		a.dmxc_(1,0,0,0);
		a.dmxc_(2,0,0,0);
		a.dmxc_(3,0,0,0);
		a.close;

	};

	b = {|hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(1,c.red*r,c.green*r,c.blue*r);
		a.dmxc_(2,c.red*r,c.green*r,c.blue*r);
		a.dmxc_(3,c.red*r,c.green*r,c.blue*r);
	};

	t = Slider2D(w, w.view.bounds.insetBy(10,10))
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
        .action_({|sl|
            //[\sliderX, sl.x, \sliderY, sl.y].postln;
			b.value(sl.x*0.999,sl.y*0.999,t);
        });
)



c = 2
d = 1 + ((c-1)*3)
d
(
var fx=0,fy=0;

	a = RduinoDMX(SerialPort.devices.last,115200);
	w = Window.new.front;

	b = {|hue,sat,slider|
		r = 255;
		c = Color.hsv(hue,1,sat,1);
		slider.background_(c);
		a.dmxc_(1,c.red*r,c.green*r,c.blue*r);
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
l = 0;
m = 0;

~so  = LFO.ar(

	r = Task.new({ inf.do({ |i|

		{

			f = 0.001;
			fx = f * t.x + (1.000-f) * fx;
			fy = f * t.y + (1.000-f) * fy;

			x = (fx + (0.1 * sin(0.001*i*(180.0/pi)))).clip(0,0.999);
			y = (fy + (0.1 * cos(0.001*i*(180.0/pi)))).clip(0,0.999);

			("x;"++x++" y:"++y).postln;
			//b.value(x,y,t);
			//v.moveTo(x * w.view.bounds.width, w.view.bounds.height - (y * w.view.bounds.height));

			}.defer;
        0.02.wait;
		})

	});

	r.play;

	w.onClose = {
		r.stop;
		r.free;
		a.dmxc_(1,0,0,0);
		a.close;
	};

)
s.boot

