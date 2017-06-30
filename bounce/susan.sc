
// unique name for pattern 
var ptn = Array.fill(16,{|i|i=90.rrand(65)}).asAscii;

//------------------------------------------------------------	
// SYNTH DEF
//------------------------------------------------------------	

(
SynthDef(\harpsichord1, { arg out = 0, freq = 440, amp = 0.1, pan = 0, rls = 0.5, width = 0.5;
    var env, snd;
	env = Env.perc(releaseTime:rls,level: amp).kr(doneAction: 2);
	snd = Pulse.ar(freq, width, 0.75);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;
);

// use to hear this synth onces
//x = Synth(\harpsichord1);s.sendBundle(0.5,[\n_set,x.nodeID,\gate,0]);

//------------------------------------------------------------	
// PATTERN DEF
//------------------------------------------------------------	

Pdef(ptn,
	Pbind(
        \degree, Pseq([[0,4,8],[3,8,11],[2,5,9]], inf),
		\args, #[],
		//\dur,Pseq(#[1.0,0.5,0.5],inf),
		\amp, Pexprand(0.1,0.4,inf),
		\pan, Pwhite(-0.8,0.8,inf)
		//\strum, 0.06
));

// use this to test patter/synth with default gui
// Pdef(ptn).play.gui;
// Pdef(ptn).set(\instrument,\harpsichord1);
// Pdef(ptn).set(\dur,2);
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

		"init SUSAN".postln;

		Pdef(ptn).set(\instrument,\harpsichord1);
		Pdef(ptn).set(\dur,1.0);
		Pdef(ptn).set(\octave,3);


		Pdef(ptn).play;
	};

	//------------------------------------------------------------	
	// do all the work(logic) taking data in and playing pattern/synth
	//------------------------------------------------------------	
	~next = {|f,d| 
		
		var val = 0;
		var tween = {|input,history,friction = 0.5|
			(friction * input + ((1 - friction) * history))
		};


		d.rrateMass = tween.(d.rrateEvent.sumabs.half / pi,d.rrateMass,0.9);

		if(d.rrateMass < 0.06,{
			Pdef(ptn).pause;
		},{
			if(Pdef(ptn).isPlaying.not,{Pdef(ptn).resume});
		});
		
		val = (3+d.rrateMass.ceil);
		Pdef(ptn).set(\octave,val);
		
		val = Array.geom(8, 1, 2).at((d.rrateEvent.sumabs.sqrt).floor).reciprocal;
		Pdef(ptn).set(\dur,val);

		val = pi - d.rrateMass;
		Pdef(ptn).set(\rls,val);

		val = d.rrateEvent.sumabs / 3.0 / pi.twice;
		Pdef(ptn).set(\width,val);

		val = (1.0-(d.rrateEvent.sumabs / 3.0 / pi.twice)) * 0.1;
		Pdef(ptn).set(\strum,val);

	};

	//------------------------------------------------------------	
	// cleanup
	//------------------------------------------------------------	
	~deinit = {

		"deinit SUSAN".postln;
		Pdef(ptn).stop;
	};

	//------------------------------------------------------------	
	// min and max of plotters output
	//------------------------------------------------------------	

	~plotMin = 0;
	~plotMax = 0.1;

	//------------------------------------------------------------	
	// utility for output to a plotter : returns a value that
	// that will be put at the end of plotters data array
	//------------------------------------------------------------	

	~plot = { |d,p|
		(1.0-(d.rrateEvent.sumabs / 3.0 / pi.twice)) * 0.1;
	};
	

)

