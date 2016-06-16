(
~sliders = 20.collect { |i|Slider().action_({		}) };
~numbers = 20.collect { NumberBox().fixedWidth_(30) };
//~data = 20.collect{(no:0)};
~view = View(bounds:600@200).layout_(GridLayout.rows(~sliders, ~numbers)).front;
~connections = ConnectionList.newFrom(
	~sliders.collect {
		|slider, i|
		slider.signal(\value).connectTo(~numbers[i].valueSlot);
		~numbers[i].signal(\value).connectTo(slider.valueSlot);

		// slider.signal(\value).connectTo(~data[i].valueSlot(\no));
		// ~data[i].signal(\no).connectTo(~numbers[i].methodSlot(\valueAction_));
	}
);

~sliders[0].valueAction_(0.3);
//[0,~data[0]].postln;



~view.onClose = { ~connections.disconnect };

)



(
~size = 20;
~model = ~size.collect { |i| NumericControlValue(spec:ControlSpec(0, 1, default:(i/~size))) };
~sliders = ~size.collect { |i|Slider() };
~numbers = ~size.collect { |i|NumberBox().fixedWidth_(30) };
~view = View(bounds:600@200).layout_(GridLayout.rows(~sliders, ~numbers)).front;

~connections = ConnectionList.makeWith {
	 ~model.connectEach(~sliders, \value, "value_(object.input)");
	 ~model.connectEach(~numbers, \value, "value_(object.value)");
	 ~sliders.connectEach(~model, \value, "input_(value)");
	 ~numbers.connectEach(~model, \value, "value_(value)");
};

~model[0].value_(0.9);
~model[1].value_(0.7);
~model[2].value_(0.5);

~view.onClose = { ~connections.disconnect };

)
