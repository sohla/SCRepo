
(
	var rate = 1000;

	var itr = 0;
	var delta = 0.1;

	var changeViewWithRGB = ({ |v,r,g,b|
		v.background = Color(r,g,b);
	});



	w = Window.new("hello",Rect(5,240,325,400)).front;
	w.view.decorator = FlowLayout( w.view.bounds, 1@1, 1@1 );
	20.do{ UserView( w.view,80@80 ).background_( Color.rand ) };
	
	t = 60/1000;
	r = Routine ({ |i|
	Ê Ê Ê Ê loop {
	Ê Ê Ê Ê Ê Ê Ê Ê 
			var f = (r.seconds * rate % 1000) / 1000;
	
			if(itr > 1.0,{
				delta = delta * -1.0;
			});
			
			if(itr < 0.0,{
				delta = delta * -1.0;
			});
			
			itr = itr + delta;
	
			20.do({ |j|
				
				changeViewWithRGB.value(w.view.children[j],itr,0,0);
				
			});
			
			 t.yield;
			(f).postln;
	
	Ê Ê Ê Ê }
	});
	
	AppClock.play(r);




)


