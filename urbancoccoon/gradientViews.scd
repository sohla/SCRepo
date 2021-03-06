
(
	var rate = 0.1;

	var width = 4;
	var height = 5;
	var degrees = 0;
	var alpha = 0.5;

	//------------------------------------------------------

	var changeViewWithRGB = ({ |v,c|
		v.background = Color(c.red,c.green,c.blue,alpha);
	});

	var colorForValue = ({ |v|
		var radians = (pi / 180.0) * v;
		var r = sin(radians);
		var g = cos(radians + 2.0 * pi / 3.0);
		var b = sin(radians + 3.0 * pi / 3.0);
		
		Color(r,g,b);
	});
	
	var changeViewAtIndexWithValue = ({ |i,v|
		changeViewWithRGB.value(w.view.children[i],colorForValue.value(v) );
		
	});
	
	//------------------------------------------------------
	// UPDATE
	//------------------------------------------------------
	var updateCell = ({ |tick|

		20.do({|i|
			v = degrees + (i*2);
			changeViewAtIndexWithValue.value(i,v);
		});
			
		("running["+tick+"]").postln;
	});
	
	//------------------------------------------------------

	w = Window.new("hello",Rect(250,240,325,500)).front;
	w.view.decorator = FlowLayout( w.view.bounds, 0@0, 0@0 );

	// build some views	
	20.do{ UserView( w.view,80@80 ).background_( colorForValue.value(0)) };
	
	// alpha controller
	b = ControlSpec(0.0, 1.0, \linear, 0.01); // min, max, mapping, step
	c = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	a = Slider(w, Rect(20, 50, 325, 20))
	� � � � .value_(alpha)
	� � � � .action_({
		
				alpha = b.map(a.value);
	� � � � � � � � c.string_(b.map(a.value).asString)
	� � � � � � � � // round the float so it will fit in the NumberBox
	� � � � � � � � });

	// color controller
	d = ControlSpec(0, 360, \linear, 1); // min, max, mapping, step
	e = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	f = Slider(w, Rect(20, 50, 325, 20))
	� � � � .value_(degrees)
	� � � � .action_({
				degrees = d.map(f.value);
	� � � � � � � � e.string_(d.map(f.value).asString)
	� � � � � � � � // round the float so it will fit in the NumberBox
	� � � � � � � � });

	
	
	// thread
	r = Routine ({ |i|
		loop {
			updateCell.value(r.seconds);	
			rate.yield;
		}
	});
	
	AppClock.play(r);


	//------------------------------------------------------

	w.onClose = ({
		r.stop();
	});

)


