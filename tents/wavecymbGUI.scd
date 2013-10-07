(
	SynthDef(
		"piaWavecymb",{
			arg amp=0.0,density=1.0,note = 64;

		var root,scale,freqs, ringtimes,trig,dec,out;
		scale = #[0,2,4,7,9];

		freqs = Array.fill(12, {(scale.choose  + note).midicps});
//		freqs = Array.rand(12, 400.0, 14000.0) + SinOsc.kr(0.1, 0.0,5.0);
		ringtimes = [1, 1, 1, 1] * 1;
		trig = Impulse.kr(density, 0, 1);
		dec = EnvGen.kr(Env.perc(0.01), trig, 0.2, doneAction: 0);
	
	Ê Ê Êout = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.4 * amp;
	
		6.do({ out = AllpassN.ar(out, 0.01, [0.01.rand, 0.01.rand],1) });
		out = LeakDC.ar(out);


			Out.ar(0,out);
		}
	).send(s);
)

a = Synth(\piaWavecymb,[\amp,0.5,\density,1.1,\note,52]);


(
	var syn;
	
	w = Window.new("WAVE",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[86];
	b = #[0,2,4,7,9];
	c = a.choose + b.choose;
	w.name = "WAVE" + c;
	w.refresh();
	syn = Synth(\piaWavecymb,[\amp,0.0,\density,8.0,\note,c]);
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x);
		syn.set(\density,slider.y*20);
		});
	g.setXYActive(0.5,0.5);

	w.onClose = {
		syn.free;
	};
	


 )
