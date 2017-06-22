
var ptn = \ohyea;

//------------------------------------------------------------	
// SYNTH DEF
//------------------------------------------------------------	

(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0, position = 0.5 attack = 0.001|
    var env = Env.new([0,1, 1, 0],[attack,0.006, 0.005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked.ar(freq, amp, gate,position,1,c3,inp,0.1);
	var sig = 0, verb = 0;
    //Out.ar(out, Pan2.ar(son * 0.1, pan));
	sig = Pan2.ar(son * 0.1, pan);
	//verb = FreeVerb2.ar(sig[0],sig[1],0.3,200);
    //DetectSilence.ar(sig, 0.001, doneAction:2);

	Out.ar(out,sig);
}).add;
);

//x = Synth(\help_dwgplucked);s.sendBundle(0.5,[\n_set,x.nodeID,\gate,0]);

//------------------------------------------------------------	
// PATTERN DEF
//------------------------------------------------------------	

Pdef(ptn,
	Pbind(
//        \degree, Pseq([7,8,2,4,3,1,2,2], inf),
        \degree, Pseq([0,4,2,7,1,2,3,5], inf),
		\args, #[],
		\amp, Pexprand(0.1,0.4,inf),
		\pan, Pwhite(-0.8,0.8,inf)
));

//x = Synth(\help_dwgplucked);s.sendBundle(0.5,[\n_set,x.nodeID,\gate,0]);


// Pdef(ptn).set(\instrument,\help_dwgplucked);
// Pdef(ptn).play;
// Pdef(ptn).set(\attack,0.01);
// Pdef(ptn).set(\release,4.0);

// Pdef(ptn).set(\octave,7);
// Pdef(ptn).set(\dur,0.2);

//------------------------------------------------------------	
// PERSONALITY
//------------------------------------------------------------	
(

	~fps = 0.03;

	//------------------------------------------------------------	
	~init = { 

		"init GEORGE".postln;

		Pdef(ptn).set(\octave,3);
		Pdef(ptn).set(\dur,0.5);
		Pdef(ptn).set(\attack,0.001);
		Pdef(ptn).set(\c3,50);
		Pdef(ptn).set(\legato,10);
		Pdef(ptn).set(\instrument,\help_dwgplucked);

		Pdef(ptn).play;
	};

	//------------------------------------------------------------	
	~next = {|f,d| 
		
		var tween = {|input,history,friction = 0.5|
			(friction * input + ((1 - friction) * history))
		};

		// ["running GEORGE...",f%7].postln;
		// d.postln;
		//Pdef(ptn).set(\octave,1 + (f%7));

			d.accelMass = tween.(d.accelEvent.sumabs.half,d.accelMass,0.08);

			d.rrateMass = tween.(d.rrateEvent.sumabs.half / 3.0,d.rrateMass,0.9);

			if(d.rrateMass < 0.07,{
				Pdef(ptn).pause;
			},{
				if(Pdef(ptn).isPlaying.not,{Pdef(ptn).resume});
			});

		 // 	// set pattern
		  	if(Pdef(ptn).isPlaying, {

				//Pdef(ptn).set(\patch,((gyroEvent.pitch + pi).div(pi.twice/4.0)).floor);
				
				Pdef(ptn).set(\gtranspose,-3 + [0,12,24].at(((d.gyroEvent.roll + pi).div(pi.twice/3.0)).floor));

				Pdef(ptn).set(\c3,(12 + ((d.gyroEvent.roll + pi)/(pi.twice) * 500)));
				
				Pdef(ptn).set(\legato,(0.1 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 3)));
				
				Pdef(ptn).set(\position,(0.0 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 1.0)));

			 });
			
			 if(Pdef(ptn).isPlaying, {

				Pdef(ptn).set(\attack,(1.0 + d.rrateEvent.sumabs).pow(4).reciprocal);

			 	Pdef(ptn).set(\dur,Array.geom(8, 1, 2).at((d.rrateEvent.sumabs.sqrt).floor).twice.reciprocal);
			
			 });

	};

	//------------------------------------------------------------	
	~deinit = {

		"deinit GEORGE".postln;
		
		Pdef(ptn).stop;
	};

);
