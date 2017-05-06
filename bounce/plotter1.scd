(
    var width = Window.screenBounds.width, height = Window.screenBounds.width / 3;
    var plotter;
    var window, routine,i=0;
    var data = Array.fill(10000,{|i|sin(pi/1000 * i)});

	window = Window("plotter demo", Rect(0, 0, width, height), false)
        .front;

	plotter = Plotter("plot", parent: window);

	routine = Routine {|inval|
		loop {
			plotter.value = {data.rotate(i.asInt)}.dup(3);
			i =i - 100;
			0.03.yield;
		}
	}.play(AppClock);

	window.onClose = {
		routine.stop;
	};
	CmdPeriod.doOnce({window.close});


)
