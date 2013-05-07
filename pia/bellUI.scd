(
	SynthDef(
		"piaBell",{
			arg amp=0.0,density=1.0,note = 64;

			var trig, p, exc, x, s;
	
			trig = Impulse.kr(density, 0, [0.04,0.03]);

			exc = BrownNoise.ar(Decay2.kr(trig,5.5,0.01));
			s = (DynKlank.ar(
				`[Array.fill(1, {note.midicps}),nil,
				Array.fill(16, {rrand(0.1,2.0)})], 
				exc) * 0.001 * amp).softclip;

			Out.ar(0,[s,s])
			
		}
	).send(s);
)


s.sendMsg("/s_new", "piaBell", -1, 1, 1,"amp",1.0,"density",0.5,"note",68);

(
	var syn;
	
	w = Window.new("BELL",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[64];
	b = #[0,2,4,5,7,9,11];
	c = a.choose + b.choose;
	w.name = "BELL" + c;
	w.refresh();
	syn = Synth(\piaBell,[\amp,0.0,\density,8.0,\note,c]);
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x);
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
