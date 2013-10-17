(
	SynthDef(
		"piaKlang",{
			arg amp=0.0,density=1.0,note = 64;
			var freqs, ringtimes,trig,dec,out;
		
			freqs = Array.fill(10, { |i| note.midicps + (i.linrand)} );
			ringtimes = [1, 1, 1, 1] * 9;
			trig = Impulse.kr(density, 0, 0.1);
			dec = Decay2.kr(trig, 0.3 * trig, 0.9 * trig);
		
		Ê Ê Êout = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.05 * amp;
		
			6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
			out = LeakDC.ar(out);
			Out.ar(0,[out,out])
		}
	).send(s);
)

a = Synth(\piaKlang,[\amp,0.5,\density,1.0,\note,57]);

(
	var syn;
	
	w = Window.new("KLANG",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[0,12,24];
	b = #[64,66,68];
	c = a.choose + b.choose;
	w.name = "KLANG" + c;
	w.refresh();
	syn = Synth(\piaKlang,[\amp,0.0,\density,8.0,\note,c]);
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x);
		syn.set(\density,slider.y * 1.0);
		});
	g.setXYActive(0.5,0.5);

	w.onClose = {
		syn.free;
	};
	


)
