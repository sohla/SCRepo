
(
	var rate = 1000;

	var itr = 0;
	var delta = 0.1;
	var width = 4;
	var height = 5;
	var count = 2;
	var speed = 0.1;
	var cells = Array.new(count);
	var degrees = 0;
	var alpha = 0.0;
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
	
	


	
	//------------------------------------------------------
	// UPDATE
	//------------------------------------------------------
	var updateCell = ({ |cells,tick|
		
//		cells.do({ |cell|
//
//			
//			var ni = cell.at(\index)+1;
//			if(ni>=(width*height),{ni=0});
//			cell.add(\index -> ni);
//			cell.add(\x -> indexToX.value(ni));
//			cell.add(\y -> indexToY.value(ni));
//
//		});
//		
		
		
		// update ui
		20.do({|i|
			changeViewWithRGB.value(w.view.children[i],Color(0,0,0));
		});
		20.do({|i|
			v = degrees + (i*2);
			changeViewWithRGB.value(w.view.children[i],colorForValue.value(v) );
		});


//		cells.do({|cell,i|
//			changeViewWithRGB.value(w.view.children[cell.at(\index)],colorForValue.value(1-v));
//		});


			
	});
	
	
	
	//------------------------------------------------------
	var cellData = Dictionary.newFrom(
		List[
			\index, 1, 
			\x, 0, 
			\y, 0,
			\vx, 0,
			\vy, 0
			]);

	var indexToX = ({ |i|
		(i % width);
	});
	var indexToY = ({ |i|
		(i / width).floor;
	});
	
	
	var makeCell = ({ |i,x,y|
	
		var c = cellData.copy;
		c.add(\index -> i);	
		c.add(\x -> x);	
		c.add(\y -> y);	
	});
	
	//------------------------------------------------------
	//------------------------------------------------------

	count.do({ |i|
		cells.add( makeCell.value(i,indexToX.value(i),indexToY.value(i)));
	});	
	
	
	
	cells.do({ |cell|
		cell.at(\x).postln;
	});
	
//	20.do({ |i|
//		
//		indexToX.value(i).post;
//		indexToY.value(i).postln;
//	});
	
	

	w = Window.new("hello",Rect(5,240,325,500)).front;
	w.view.decorator = FlowLayout( w.view.bounds, 0@0, 0@0 );
	
	20.do{ UserView( w.view,80@80 ).background_( colorForValue.value(0)) };
	
	
	
	b = ControlSpec(0.0, 1.0, \linear, 0.01); // min, max, mapping, step
	c = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	a = Slider(w, Rect(20, 50, 325, 20))
	Ê Ê Ê Ê .value_(alpha)
	Ê Ê Ê Ê .action_({
		
				alpha = b.map(a.value);
	Ê Ê Ê Ê Ê Ê Ê Ê c.string_(b.map(a.value).asString)
	Ê Ê Ê Ê Ê Ê Ê Ê // round the float so it will fit in the NumberBox
	Ê Ê Ê Ê Ê Ê Ê Ê });


	d = ControlSpec(0, 360, \linear, 1); // min, max, mapping, step
	e = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	f = Slider(w, Rect(20, 50, 325, 20))
	Ê Ê Ê Ê .value_(degrees)
	Ê Ê Ê Ê .action_({
		
				degrees = d.map(f.value);
	Ê Ê Ê Ê Ê Ê Ê Ê e.string_(d.map(f.value).asString)
	Ê Ê Ê Ê Ê Ê Ê Ê // round the float so it will fit in the NumberBox
	Ê Ê Ê Ê Ê Ê Ê Ê });

	
	
	r = Routine ({ |i|
	Ê Ê Ê Ê loop {
	Ê Ê Ê Ê Ê Ê Ê Ê 
			updateCell.value(cells,r.seconds);	
			
			 speed.yield;
	
	Ê Ê Ê Ê }
	});
	
	AppClock.play(r);




)


