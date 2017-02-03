b = NetAddr.new("10.1.1.3", 53000);

b.sendMsg("/select/1", "");
b.sendMsg("/cue/1/start", "");
b.sendMsg("/cue/1/stop", "");

b.sendMsg("/cue/2/start", "");


b.sendMsg("/cue/2/sliderLevel/2", -4.0);



(
b = NetAddr.new("10.105.160.135", 53000);
b.sendMsg("/cue/1/start", "");

r = Routine({|in|
	var f;
	    loop {
		f = thisThread.beats.fold(1,10) * 5;
		b.sendMsg("/cue/1/sliderLevel/0", f.neg);
		0.01.yield;
    }
});

TempoClock.default.sched(0, r);
)
(
b = NetAddr.new("10.1.1.3", 53000);

w = Window.new.front;
c = NumberBox(w, Rect(20, 20, 150, 20));
d = ControlSpec(-60, 0, \linear, 1);

a = Slider(w, Rect(20, 60, 150, 20))
    .action_({
	        c.value_(d.map(a.value));
	b.sendMsg("/cue/2/sliderLevel/2", d.map(a.value));
        });
a.action.value;
)

