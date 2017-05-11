

(
Pdef(\pat1).set(\octave,4);
Pdef(\pat1).set(\dur,0.25);
Pdef(\pat1,
	Pbind(
        \degree, Pseq([0, 7, 4, 3, 9, 5, 1, 4], inf),
		\gtranspose, Pstutter(8,Pseq([0,3,8,-2],inf),inf),
		\amp, Pexprand(0.1,0.4,inf),
		\pan, 0
));

~spec = ControlSpec(0,3,step:1);
~window = Window.new("mixers", Rect(10, 100, 320, 60));
~window.view.decorator = FlowLayout(~window.view.bounds, 2@2);
EZSlider(~window, 310@20, "low part", \amp, { |ez| 
	Pdef(\pat1).set(\dur,Array.geom(4, 1, 2).at(~spec.map(ez.value)).reciprocal); 
}, 0.5);
~window.front.onClose_({ Pdef(\pat1).stop });

Pdef(\pat1).play;
)
