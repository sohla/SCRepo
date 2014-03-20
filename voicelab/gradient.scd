(
	var fps = 10;


	w = Window.new("grad",Rect(300,240,325,580)).front;


	r = Routine ({ |i|
		loop {

			(1.0/fps).yield;

		}
	});

	AppClock.play(r);

)