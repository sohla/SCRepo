(

	SynthDef("streetscape", { |out=0,bufnum,gate = 1 ,attack = 0.001, release = 0.001, 
						frq=15000, amp = 1.0, decaytime = 0.01,chaosfreq=0,chaosamp=400|
	
		var envelope = EnvGen.kr(Env.asr(attack,1.0,release, curve: \sin), gate, doneAction:2);
		var buf = PlayBuf.ar(bufnum.numChannels, bufnum, BufRateScale.kr(bufnum));
		var sampleplayer = buf * envelope * 4;
		var verb;
		var eq;
		var comp;
		
		
		comp =     Compander.ar(sampleplayer*2,sampleplayer*2
				        thresh: MouseX.kr(0.1, 1),
				        slopeBelow: 1,
				        slopeAbove: 0.3,
				        clampTime: 0.01,
				        relaxTime: 0.01
				    );

		4.do({
			verb = AllpassL.ar(
					comp, 
					0.3, 	
	 				[rrand(0.01,0.3),rrand(0.01,0.3)],
	 				decaytime
	 			)
		});

		eq = MoogFF.ar(verb,Lag.ar(LorenzL.ar(chaosfreq),3e-3)*chaosamp+frq, amp);
	    Out.ar( out, eq);

	}).send(s);


)



(
	var w;
	var nodeID = 2000;
	var bufferID = 111;
	var frq = 10000,amp = 1.0;


	//------------------------------------------------------
	// SYNTH
	//------------------------------------------------------
//	s.sendMsg("/b_allocRead",bufferID,"sounds/memo1.wav");
//	s.sendMsg("/b_allocRead",bufferID,"sounds/pad_autumn.wav");
//	s.sendMsg("/b_allocRead",bufferID,"sounds/132_SN_HH_1.wav");

	s.sendMsg("/b_allocRead",bufferID,"sounds/69865__duophonic__city-street-ambience-5-0.wav");
	s.sendMsg("/s_new", "streetscape", nodeID, 1, 1,"bufnum",bufferID);

	//------------------------------------------------------
	// GUI
	//------------------------------------------------------

	w = SCWindow.new("city-wind-scape").front;	
	w.view.decorator = FlowLayout( w.view.bounds, 5@5, 10@10 );
	w.view.background = Gradient(Color(0.9, 0.83, 0.3),Color(0.9, 0.36, 0.3),\v);
	
	g = ControlSpec(100.0, 15000, \exp, 1, 15000, "Hz");
	a = EZSlider(w,390@20,"frq",g,initAction:true,)
		.action_({|ez|
			s.sendMsg("n_set",nodeID,\frq,ez.value);
		});
	a.setColors(Color.clear,numBackground:Color.clear);

	g = ControlSpec(1, 3, \linear, 0.01, 1);
	b = EZSlider(w,390@20,"amp",g,initAction:true)
		.action_({|ez|
			s.sendMsg("n_set",nodeID,\amp,ez.value);
		});
	b.setColors(Color.clear,numBackground:Color.clear);

	g = ControlSpec(0.01, 10.0, \linear, 0.01, 0.01);
	c = EZSlider(w,390@20,"decaytime",g,initAction:true)
		.action_({|ez|
			s.sendMsg("n_set",nodeID,\decaytime,ez.value);
		});
	c.setColors(Color.clear,numBackground:Color.clear);


	g = ControlSpec(0.0, 20.0, \linear, 0.01, 1);
	d = EZSlider(w,390@20,"chaosfreq",g,initAction:true)
		.action_({|ez|
			s.sendMsg("n_set",nodeID,\chaosfreq,ez.value);
		});
	d.setColors(Color.clear,numBackground:Color.clear);

	g = ControlSpec(0.0, 400, \linear, 1, 400);
	e = EZSlider(w,390@20,"chaosamp",g,initAction:true)
		.action_({|ez|
			s.sendMsg("n_set",nodeID,\chaosamp,ez.value);
		});
	e.setColors(Color.clear,numBackground:Color.clear);

	f = Button(w,Rect(20,20,50,50))
		.states_([["out"]])
		.action_({|b|
			[
				"\"frq\"",a.value,
				"\"amp\"",b.value,
				"\"decaytime\"",c.value,
				"\"chaosfreq\"",d.value,
				"\"chaosamp\"",e.value].postln;


		});
	
	w.onClose = ({
		s.sendMsg("/g_freeAll",1);
		s.sendMsg("/b_free",bufferID);
	});

)




{LFCub.kr(0.5,0.0,0.15,0.14,0.01)}.plot(2,maxval:0.5)



{ SinOsc.ar(Lag.ar(LorenzL.ar(MouseX.kr(1, 200)),3e-3)*80+800)*0.4 }.play(s);
