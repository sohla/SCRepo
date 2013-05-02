
(
	SynthDef(
		"piaKlang",{
			arg amp=0.0,density=1.0,note = 64,trig =0;
			var freqs, ringtimes,trig,dec,out;
		
			freqs = Array.fill(10, { |i| note.midicps + (i.linrand)} );
			ringtimes = [1, 1, 1, 1] * 9;
//			trig = Impulse.kr(density, 0, 0.1);
//			dec = Decay2.kr(trig, 0.3 * trig, 0.9 * trig);
			dec = EnvGen.kr(Env.adsr, trig,0.1, doneAction:0);


		Ê Ê Êout = DynKlank.ar(`[freqs, nil, ringtimes ], K2A.ar(dec)) * 0.05 * amp;
		
			6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
			out = LeakDC.ar(out);
			Out.ar(0,[out,out])
		}
	).send(s);
)

a = Synth(\piaKlang,[\amp,0.5,\density,1.0,\note,57,\trig,1]);




s.sendMsg("/n_set", n, \trig, 1,\note,45);



s.sendMsg(\piaKlang,\trig,1);

(
	w = Window.new("hello",Rect(5,240,325,400)).front;
	w.view.decorator = FlowLayout( w.view.bounds, 1@1, 1@1 );
	20.do{ UserView( w.view,80@80 ).background_( Color.rand ) };
	
	s.sendMsg(\s_new, \piaKlang, n=s.nextNodeID, 0, 1, \amp, 0.5, \note, 60);

	t = 100/1000;
	r = Routine ({ |i|
	Ê Ê Ê Ê loop {
	Ê Ê Ê Ê Ê Ê Ê Ê 
			var f = (r.beats * 10 % 127);
	
			20.do({ |j|
				w.view.children[j].background = Color(f/127.0,0x00,0x00);
			});
			
			s.sendMsg("/n_set", n, \trig, 0);
			
			s.sendMsg("/n_set", n, \trig, 1,\note,(40 + (f/10)));
	Ê Ê Ê Ê Ê
			 t.yield;
			(r.beats * 10 % 127).postln;
	
	Ê Ê Ê Ê }
	});
	
	AppClock.play(r);




)


