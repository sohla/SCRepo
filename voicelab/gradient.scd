(
	var fps = 60;
	var degrees = 0;

	var colorFor = ({ |v|
		var radians = (pi / 360.0) * v;
		var r = sin(radians);
		var g = cos(radians + 2.0 * pi / 3.0);
		var b = sin(radians + 3.0 * pi / 3.0);

		Color(r.wrap(0,1),g.wrap(0,1),b.wrap(0,1));
	});


	w = Window.new("grad",Rect(300,240,325,580)).front;

	r = Routine ({ |i|
		loop {

			degrees = degrees + 1;
			if(degrees > 360,{
				degrees = 0;
			});
			w.background = colorFor.value(degrees);
			(1.0/fps).yield;

		}
	});

	AppClock.play(r);

)