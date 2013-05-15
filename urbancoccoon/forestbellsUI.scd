(
	SynthDef(
		"forestbells",{
			arg amp=0.2,density=1.0,note = 64,pan=1.0.rand2;
			
			var trig = Dust.kr(density, 0.04);
			var exc = BrownNoise.ar(Decay2.kr(trig,5.5,0.01));
			
			b = #[0,5,7,14,19];
			p = 15;	
			z = `[	
					Array.fill(p, {(note + b.choose).midicps} ),					Array.fill(p, { 0.1.rand2 }), 						Array.fill(p, {rrand(0.1,2.0)} )		
				];
			Out.ar(0,Pan2.ar(
				Klank.ar(z, exc)*amp,
				pan)
			)
			
		}
	).send(s);
)


s.sendMsg("/s_new", "forestbells", -1, 1, 1,"amp",0.01,"density",2.5,"note",90);
	
(
	var syn;
	
	w = Window.new("BELL",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[50];
	b = #[0,2,4,5,7];
	c = a.choose + b.choose;
	w.name = "BELL" + c;
	w.refresh();
	
		syn = Synth(\forestbells,["amp",0.1,\density,0.1,\note,c,\pan,1.0.rand2]);
	
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x*0.1);
		syn.set(\density,slider.y * 10.0);
		});
	g.setXYActive(1.0,0.2);

	w.onClose = {
		syn.free;
	};
	


)

//a = Synth(\piaBell,[\amp,1.0,\density,8.0,\note,64]);
//a.set(\note,54);
//a.set(\amp,0.4);
//
