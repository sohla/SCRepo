
(
var window, routine, graphView, drawGrid, sliderView;
var updateGraphView;
var data;
var freq = 1, amp = 0.5;
var idx = 0;
var width = 640, height = 480, theta = 0;
//------------------------------------------------------
data = Array.fill(512,0);
data = Array.fill(data.size, { |i| 0.5 - (((i/512 * 2pi * freq).sin * 0.5) * amp)});




//------------------------------------------------------
updateGraphView = {|view|

	 Pen.strokeColor_(Color.blue(0.8));
	// Pen.line(0@150,800@300);

	Pen.smoothing_(true);
	// data.do({|val,i|

	idx = idx.mod(data.size-1);

	v = data[idx];
	[idx,v].postln;

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

// });
	idx = idx + 1;
		Pen.stroke;

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
	//.clearOnRefresh_(false)

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
		data = Array.fill(data.size, { |i| 0.5 - (((i/512 * 2pi * freq).sin * 0.5) * amp)});

		0.01.yield;

	}
};

routine.play;
//------------------------------------------------------

window.onClose = ({

	routine.stop;

});
CmdPeriod.doOnce({window.close});



)

