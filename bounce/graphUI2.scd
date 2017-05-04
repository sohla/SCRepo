
(
var window, routine, graphView, drawGrid, sliderView;
var updateGraphView;
var freq = 1, amp = 0.5;
var idx = 0;
var width = 640, height = 480, theta = 0;
var gridHeight = 100;
var data = Array.fill(512,0);

//------------------------------------------------------
updateGraphView = {|view|

	Pen.smoothing_(true);
	Pen.strokeColor_(Color.green(0.9,0.4));
	drawGrid.draw();

	data.do({|v,i|
		p= Point(i, (0.5*gridHeight) + 20.0);
		Pen.moveTo(p);
		p= Point(i, (v*gridHeight) + 20.0);
		Pen.lineTo(p);
		Pen.stroke;
	});

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
	.clearOnRefresh_(true)

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


drawGrid = DrawGrid(Rect(0,20,512,gridHeight), \unipolar.asSpec.grid, \pan.asSpec.grid);


//------------------------------------------------------

routine = Routine { arg inval;
	loop {
		// thisThread refers to the routine.
		// postf("count: % beats: % seconds: % time: % \n",
		// 	thisThread.beats - inval, thisThread.beats, thisThread.seconds, Main.elapsedTime
		// );
		data = Array.fill(data.size, { |i| 0.5 - (((i+idx/data.size * 2pi * freq).sin * 0.5) * amp)});

		0.01.yield;

idx = idx + 1;
	}
};

routine.play;
//------------------------------------------------------

window.onClose = ({

	routine.stop;

});
CmdPeriod.doOnce({window.close});



)






