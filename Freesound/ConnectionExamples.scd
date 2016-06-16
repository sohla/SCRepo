(
~notifier = Object();
~recipient = { |a,b,c| [a,b,c].value.post;"I've been notified!".postln };
~notifier.addDependant(~recipient);
~notifier.changed(\foo, "bar");
~notifier.removeDependant(~recipient);
)







(
~notifier = Object();
~recipient = { |a,b,c| [a,b,c].value.post;"I've been notified!".postln };
~connection = Connection(~notifier, ~recipient);
~notifier.changed(\foo, "bar");
~connection.disconnect();
)








(
~sliders = 20.collect { Slider() };
~view = View(bounds:600@200).layout_(HLayout(*~sliders)).front;
~connections = ~sliders.collect({
	|slider, i|
	slider.action = { |v| v.changed(\value) };
	slider.connectTo({
		|slider|
		"Slider % changed: %".format(i, slider.value).postln;
	})
});
~view.onClose = { ~connections.do(_.disconnect) };
)

(
~sliders = 20.collect { |i|Slider().action_({		[i,~data[i]].postln;
}) };
~numbers = 20.collect { NumberBox().fixedWidth_(30) };
~data = 20.collect{(value:0)};
~view = View(bounds:600@200).layout_(GridLayout.rows(~sliders, ~numbers)).front;
~connections = ConnectionList.newFrom(
	~sliders.collect {
		|slider, i|
		slider.signal(\value).connectTo(~numbers[i].valueSlot);
		//slider.signal(\value).connectTo(~data[i].valueSlot(\no));

		//~numbers[i].signal(\value).connectTo(slider.valueSlot);
	}
);
//~numbers[0].value_(0.3).changed(\value,0.3);
~view.onClose = { ~connections.disconnect };

)


(
~object = Object();
~dependant = (
	scored: 	{ |self, points| "Points scored: %".format(points).postln },
	touchdown: 	{ "Touchdown!".postln },
	fieldGoal:	{ "Field Goal!".postln },
);
~connections = ConnectionList.makeWith {
	~object.signal(\scored)		.connectTo(~dependant.methodSlot("scored(value)"));
	~object.signal(\touchdown)	.connectTo(~dependant.methodSlot("touchdown"));
	~object.signal(\fieldGoal)	.connectTo(~dependant.methodSlot("fieldGoal"));
};
~object.changed(\touchdown);
~object.changed(\scored, 6);
~object.changed(\fieldGoal);
~object.changed(\scored, 3);
~connections.disconnect();
)





(
~sliders = [
	~amp 	= Slider(),
	~freq 	= Slider(),
	~delay 	= Slider(),
	~decay	= Slider()
];
~view = View(bounds:600@200).layout_(HLayout(*~sliders)).front;

s.waitForBoot {
	SynthDef(\connDemo, {
		|amp=1, freq=1, delay=0.2, decay=1, filterFreq=8000|
		Out.ar(0, 1 * amp * CombC.ar(LPF.ar(Impulse.ar(freq), filterFreq), 1, delay, decay*4))
	}).add;
	s.sync;
	~synth = Synth(\connDemo);
	~connections = ConnectionList.makeWith {
		~amp.signal(\value).connectTo(~synth.argSlot(\amp));
		~freq.signal(\value).connectTo(~synth.argSlot(\freq));
		~delay.signal(\value).connectTo(~synth.argSlot(\delay));
		~decay.signal(\value).connectTo(~synth.argSlot(\decay));
	};
	~view.onClose = { ~connections.disconnect; ~synth.free; }
};
)


(
~controls = [
	~amp 	= NumericControlValue(spec:ControlSpec(0, 1, default:1)),
	~freq 	= NumericControlValue(spec:ControlSpec(1, 20, default:1)),
	~delay 	= NumericControlValue(spec:ControlSpec(0.05, 2, default:0.3)),
	~decay	= NumericControlValue(spec:ControlSpec(1, 8, default:5)),
	~filterFreq = NumericControlValue(spec:ControlSpec(2000, 10000, default:8000)),
];

~view = View(bounds:600@200).layout_(GridLayout.rows(
	~sliders = 5.collect { Slider() },
	~numbers = 5.collect { NumberBox() }
)).front;

~view.onClose = { ~synth.free; ~connections.disconnect };

~connections = ConnectionList.makeWith {
	~controls.connectEach(~sliders, \value, "value_(object.input)");
	~controls.connectEach(~numbers, \value, "value_(object.value)");
	~sliders.connectEach(~controls, \value, "input_(value)");
	~numbers.connectEach(~controls, \value, "value_(value)");
};

s.waitForBoot {
	s.makeBundle(nil, {
		~synth = Synth(\connDemo);
		~connections.addAll(
			~controls.connectEach([
				~synth.argSlot(\amp),
				~synth.argSlot(\freq),
				~synth.argSlot(\delay),
				~synth.argSlot(\decay),
				~synth.argSlot(\filterFreq),
			]);
		);
	})
}
)
