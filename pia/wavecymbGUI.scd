(
	SynthDef(
		"piaWavecymb",{
			arg amp=0.0,density=1.0,note = 64;

		var root,scale,freqs, ringtimes,trig,dec,out;
		scale = #[0,7,14,16];

		freqs = Array.fill(12, {(scale.choose  + note).midicps});
//		freqs = Array.rand(12, 400.0, 14000.0) + SinOsc.kr(0.1, 0.0,5.0);
		ringtimes = [1, 1, 1, 1] * 5;
		trig = Dust.kr(density, 1);
		dec = EnvGen.kr(Env.perc(0.01), trig, 0.2, doneAction: 0);
	
	� � �out = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.4 * amp;
	
		6.do({ out = AllpassN.ar(out, 0.01, [0.01.rand, 0.01.rand],1) });
		out = LeakDC.ar(out*0.1);


			Out.ar(0,out);
		}
	).send(s);
)

a = Synth(\piaWavecymb,[\amp,0.5,\density,1.1,\note,54]);


(
	var syn;
	
	w = Window.new("WAVE",Rect.new(0,0,160,160)).front;
	q = w.addFlowLayout( 10@10, 20@5 );
	g = Slider2D( w.view,140@140 ).background_( Color.rand );
		
	a = #[72];
	b = #[0,2,5,7,10];
	c = a.choose + b.choose;
	w.name = "WAVE" + c;
	w.refresh();
	syn = Synth(\piaWavecymb,[\amp,0.0,\density,2.0,\note,c]);
	
	
	
	
	g.action_({ 
		|slider| 
		syn.set(\amp,slider.x);
		syn.set(\density,slider.y*100);
		});
	g.setXYActive(0.5,2/100);

	w.onClose = {
		syn.free;
	};
	


 )
