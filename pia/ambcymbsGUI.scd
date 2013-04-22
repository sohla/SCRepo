(
	SynthDef(
		"piaAmbcymbs",{
			arg amp=0.0,density=1.0,note = 64;


		var root, scale, s;
		var trig, p, n, exc, x, base, range,out;
			n = 5;
			exc = BrownNoise.ar([0.007,0.007]) * 
				max(0, LFNoise1.kr(exprand(0.125,0.5), 1.25, -0.25));
			out = (Klank.ar(
				`[Array.fill(n, {note.midicps}),
				nil,
				Array.fill(n, {rrand(0.1,2.0)})], 
				exc) * 0.2 * amp).softclip;
			
			density.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
			out = LeakDC.ar(out);

			Out.ar(0,out)
		}
	).send(s);
)

a = Synth(\piaAmbcymbs,[\amp,0.5,\density,10.0,\note,57]);
b = Synth(\piaAmbcymbs,[\amp,0.5,\density,10.0,\note,76	]);


(
	var syn;
	
	w = Window.new("AMBCYMBS",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[64];
	b = #[0,2,4,5,7,9,11];
	c = a.choose + b.choose;
	w.name = "ACYMBS" + c;
	w.refresh();
	syn = Synth(\piaAmbcymbs,[\amp,0.0,\density,8.0,\note,c]);
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x);
		syn.set(\density,slider.y * 10.0);
		});
	g.setXYActive(0.5,0.5);

	w.onClose = {
		syn.free;
	};
	)
