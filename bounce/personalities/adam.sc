
// unique name for pattern 
var ptn = Array.fill(16,{|i|i=90.rrand(65)}).asAscii;

//------------------------------------------------------------	
// SYNTH DEF
//------------------------------------------------------------	

(
	SynthDef(\adamSynth, { |out=0, freq=240, gate=1, amp=0.3, pan=0.0, attack=0.01, sustain=0.5, release=1.3|
	var env = EnvGen.kr(Env.adsr(attack, sustain, sustain, release), gate, doneAction:2);
	var sig = SinOsc.ar(freq,0,1.0)!2;
	var verb = FreeVerb2.ar(sig[0],sig[1],0.3 ,500);
	Out.ar(out, Pan2.ar(verb, pan, env * amp));
}).add;
);

// use to hear this synth onces
//x = Synth(\adamSynth);s.sendBundle(0.5,[\n_set,x.nodeID,\gate,0]);

//------------------------------------------------------------	
// PATTERN DEF
//------------------------------------------------------------	

Pdef(ptn,
	Pbind(
//        \degree, Pseq([0,2,4,6,8,7,5,3,1], inf),
        \degree, Pseq([0,1,2,0,2,0,2,1,2,3,3,2,1,3,2,3,4,2,4,2,4,3,4,5,5,4,3,5,4,0,1,2,3,4,5,5,1,2,3,4,5,6,6,2,3,4,5,6,7,6,5,5,3,6,4,7,4,3,1], inf),
		\args, #[],
		\amp, Pexprand(0.1,0.4,inf),
		\pan, Pwhite(-0.8,0.8,inf)
));

// use this to test patter/synth with default gui
// Pdef(ptn).play.gui;
// Pdef(ptn).set(\instrument,\adamSynth);
// Pdef(ptn).set(\dur,0.2);
// Pdef(ptn).set(\octave,4);

// Pdef(ptn).set(\attack,0.001);
// Pdef(ptn).set(\sustain,0.27);
// Pdef(ptn).set(\release,0.92);



(

	//------------------------------------------------------------	
	// how ofter does ~next() get called from engine
	//------------------------------------------------------------	
	~secs = 0.03;

	//------------------------------------------------------------	
	// intial state
	//------------------------------------------------------------	
	~init = { 

		"init ADAM".postln;

		Pdef(ptn).set(\instrument,\adamSynth);
		Pdef(ptn).set(\dur,0.2);
		Pdef(ptn).set(\octave,5);

		Pdef(ptn).set(\attack,0.001);
		Pdef(ptn).set(\sustain,0.27);
		Pdef(ptn).set(\release,0.92);

		Pdef(ptn).play;
	};

	//------------------------------------------------------------	
	// do all the work(logic) taking data in and playing pattern/synth
	//------------------------------------------------------------	
	~next = {|f,d| 
		
		var tween = {|input,history,friction = 0.5|
			(friction * input + ((1 - friction) * history))
		};


		//d.accelEvent.mass = tween.(d.accelEvent.sumabs.half,d.accelEvent.mass,0.08);

		d.rrateMass = tween.(d.rrateEvent.sumabs.half / 3.0,d.rrateMass,0.9);

		if(d.rrateMass < 0.06,{
			Pdef(ptn).pause;
		},{
			if(Pdef(ptn).isPlaying.not,{Pdef(ptn).resume});
		});
			

			//(d.gyroEvent.roll + pi).postln;//• how can we get this to plot? 

	 	// set pattern
	  	if(Pdef(ptn).isPlaying, {

			Pdef(ptn).set(\patch,((d.gyroEvent.pitch + pi).div(pi.twice/4.0)).floor);
			
			//Pdef(ptn).set(\gtranspose,9 + [0,12,24].at(((d.gyroEvent.roll + pi).div(pi.twice/3.0)).floor));

			//Pdef(ptn).set(\c3,(10 + ((d.gyroEvent.roll + pi)/(pi.twice) * 500)));
			
			// Pdef(ptn).set(\legato,(0.1 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 10)));
			
			// Pdef(ptn).set(\position,(0.0 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 1.0)));

		 });
		// (d.rrateEvent.sumabs.sqrt).postln;
		
		// if(Pdef(ptn).isPlaying, {

		Pdef(ptn).set(\octave,(3+d.rrateMass.ceil));

			Pdef(ptn).set(\attack,(1.0 + d.rrateEvent.sumabs).pow(4).reciprocal);

		 	Pdef(ptn).set(\dur,Array.geom(8, 1, 2).at((d.rrateEvent.sumabs.sqrt.half).floor).twice.reciprocal);
		// });

	};

	//------------------------------------------------------------	
	// cleanup
	//------------------------------------------------------------	
	~deinit = {

		"deinit ADAM".postln;
		Pdef(ptn).stop;
	};

	//------------------------------------------------------------	
	// min and max of plotters output
	//------------------------------------------------------------	

	~plotMin = 0;
	~plotMax = 1;

	//------------------------------------------------------------	
	// utility for output to a plotter : returns a value that
	// that will be put at the end of plotters data array
	//------------------------------------------------------------	

	~plot = { |d,p|
		//[0,12,24].at(((d.gyroEvent.roll + pi).div(pi.twice/3.0)).floor);
		//(10 + ((d.gyroEvent.roll + pi)/(pi.twice) * 100));
		//(0.1 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 10));
		Array.geom(8, 1, 2).at((d.rrateEvent.sumabs.sqrt.half).floor).twice.reciprocal;
	};
	

)