
(
	var rate = 1000;

	var itr = 0;
	var delta = 0.1;
	var width = 4;
	var height = 5;
	var count = 20;
	var num = 4;
	var direction = 1;
	var speed = 0.1;
	var cells = Array.new(count);
	var degrees = 180;
	var alpha = 1.0;
	var changeViewWithRGB = ({ |v,c|
		v.background = Color(c.red,c.green,c.blue,alpha);
	});

	var colorForValue = ({ |v|
		var radians = (pi / 360.0) * v;
		var r = cos(radians);
		var g = cos(radians + 2.0 * pi / 3.0);
		var b = cos(radians + 3.0 * pi / 3.0);

		Color(r.wrap(0,1),g.wrap(0,1),b.wrap(0,1));
	});





	//------------------------------------------------------
	// UPDATE
	//------------------------------------------------------
	var updateCell = ({ |cells,tick|

		cells.do({ |cell|
			var ni = cell.at(\index)+direction;
			if(ni>=(width*height),{ni=ni-(width*height)});
			if(ni<0,{ni=ni+(width*height)});


			cell.add(\index -> ni);
			cell.add(\x -> indexToX.value(ni));
			cell.add(\y -> indexToY.value(ni));

		});



		// update ui
		20.do({|i|
			changeViewWithRGB.value(w.view.children[i],Color(0,0,0));
		});

//		20.do({|i|
//			v = degrees + (i*2);
//			changeViewWithRGB.value(w.view.children[i],colorForValue.value(v) );
//		});


	num.do({|i|
			changeViewWithRGB.value(
				w.view.children[cells.at(i).at(\index)],
				colorForValue.value(degrees)
				);
//			alpha = cells.size / (i+1);
		});


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



	w = Window.new("moon controller",Rect(300,240,325,580)).front;
	w.view.decorator = FlowLayout( w.view.bounds, 1@1, 1@1 );

	20.do{ UserView( w.view,80@80 ).background_( colorForValue.value(0)) };



	b = ControlSpec(0.0, 360, \linear, 1); // min, max, mapping, step
	c = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	a = Slider(w, Rect(20, 50, 325, 20))
				.value_(degrees)
				.action_({

				degrees = b.map(a.value);
				c.string_(b.map(a.value).asString);// round the float so it will fit in the NumberBox

				colorForValue.value(degrees).postln;
	});


	d = ControlSpec(0.001, 1.0, \linear, 0.01); // min, max, mapping, step
	e = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	f = Slider(w, Rect(20, 50, 325, 20))
			.value_(speed)
			.action_({

				speed = d.map(f.value);
				e.string_(d.map(f.value).asString)
		// round the float so it will fit in the NumberBox
			});


	g = ControlSpec(1, 20, \linear, 1,num); // min, max, mapping, step
	h = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	i = Slider(w, Rect(20, 50, 325, 20))
			.value_(num)
			.action_({

				num = g.map(i.value);
				h.string_(g.map(i.value).asString)
		// round the float so it will fit in the NumberBox
		});


	j = ControlSpec(-20, 20, \linear, 1,direction); // min, max, mapping, step
	k = StaticText(w, Rect(20, 20, 325, 20)).align_(\center);
	l = Slider(w, Rect(20, 50, 325, 20))
			.value_(direction)
			.action_({

				direction = j.map(l.value);
				k.string_(j.map(l.value).asString)
				// round the float so it will fit in the NumberBox
				});



	r = Routine ({ |i|
		loop {

			updateCell.value(cells,r.seconds);

			 speed.yield;

		}
	});

	AppClock.play(r);




)


