
(
var window, routine, graphView, drawGrid, sliderView;
var updateGraphView;
var freq = 1, amp = 0.5;
var idx = 0;
var width = 640, height = 480, theta = 0;
var data = Array.fill(512,0);

//------------------------------------------------------
updateGraphView = {|view|

	Pen.smoothing_(true);
	Pen.strokeColor_(Color.blue(0.8));

	idx = idx.mod(data.size-1);

	v = data[idx];
	//[idx,v].postln;

	if(idx==0, {
		view.clearDrawing;
		Pen.moveTo(p);
	}, {
		drawGrid.draw();

		Pen.moveTo(p);
		p= Point(idx+1, v*(view.bounds.height-40) + 20);
		Pen.lineTo(p);
	});

	p= Point(idx, v*(view.bounds.height-40) + 20);

	Pen.stroke;
	idx = idx + 1;

};
//------------------------------------------------------
window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/2)
	.center_(Window.availableBounds.center)
).front;

window.layout = HLayout();

window.layout.add(
	graphView = UserView()
	.drawFunc_(updateGraphView)
	.animate_(true)
	.clearOnRefresh_(false)

);
window.layout.add(
	sliderView = Slider()
		.maxWidth_(40.0)
	.action_({|slider| freq = 1.0 + (slider.value * 8.0);

	});
);
window.layout.add(
	sliderView = Slider()
		.maxWidth_(40.0)
	.value_(amp)
		.action_({|slider| amp = (slider.value * 1.0);

	});
);


drawGrid = DrawGrid(Rect(0,20,512,340), \unipolar.asSpec.grid, \pan.asSpec.grid);


//------------------------------------------------------

routine = Routine { arg inval;
	loop {
		// thisThread refers to the routine.
		// postf("count: % beats: % seconds: % time: % \n",
		// 	thisThread.beats - inval, thisThread.beats, thisThread.seconds, Main.elapsedTime
		// );
		data = Array.fill(data.size, { |i| 0.5 - (((i/data.size * 2pi * freq).sin * 0.5) * amp)});

		0.1.yield;

	}
};

routine.play;
//------------------------------------------------------

window.onClose = ({

	routine.stop;

});
CmdPeriod.doOnce({window.close});



)

