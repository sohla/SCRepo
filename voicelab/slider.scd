
var ox,oy;
w = Window("Slider2D", Rect(100, 100, 500, 300));
w.view.decorator = FlowLayout(w.view.bounds);
t = Slider2D(w, Rect(20, 20, 280, 280))
        .x_(0.5) // initial location of x
        .y_(1)   // initial location of y
        .background_(Color.rand)
        .action_({|sl|

            [ox, sl.x, oy, sl.y].postln;
			ox = sl.x;
			oy = sl.y
        })
.mouseDownAction_({|a,b,c,d|
	[a,b,c,d].postln;
})
.mouseUpAction_({|a,b,c,d|
	[a,a.x,c,d].postln;
})

;
t.step_(0.01);
w.front;