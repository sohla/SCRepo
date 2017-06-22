var ptn = \someting;

SynthDef(\xylo, { |out=0, freq=440, gate=1, amp=0.3, sustain=0.2, pan=0, patch=1, attack = 0.001|
	var sig = StkBandedWG.ar(freq, instr:patch, mul:20);
	var env = EnvGen.kr(Env.adsr(attack, sustain, sustain, 1.3), gate, doneAction:2);
	Out.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;


Pdef(ptn,
	Pbind(
        \degree, Pseq([1,5,3,8,6,2,4,7], inf),
		\amp, Pexprand(0.1,0.4,inf),
		\pan, Pwhite(-0.8,0.8,inf)
));


Pdef(ptn).set(\octave,2);
Pdef(ptn).set(\dur,0.125);
Pdef(ptn).set(\patch,0);
Pdef(ptn).set(\attack,0.01);
Pdef(ptn).set(\legato,1);


Pdef(ptn).set(\instrument,\xylo);

(

	~fps = 0.125;
	~init = { 
		"init HARRY".postln;
	//Pdef(ptn).quant_([1,0]);
	Pdef(ptn).play;
	};
	~next = {|f,d| 
		var tween = {|input,history,friction = 0.5|
			(friction * input + ((1 - friction) * history))
		};


			//d.accelEvent.mass = tween.(d.accelEvent.sumabs.half,d.accelEvent.mass,0.08);

			d.rrateMass = tween.(d.rrateEvent.sumabs.half / 3.0,d.rrateMass,0.9);

			if(d.rrateMass < 0.07,{
				Pdef(ptn).pause;
			},{
				if(Pdef(ptn).isPlaying.not,{Pdef(ptn).resume});
			});

		 // 	// set pattern
		  	if(Pdef(ptn).isPlaying, {

				Pdef(ptn).set(\patch,((d.gyroEvent.pitch + pi).div(pi.twice/4.0)).floor);
				
				Pdef(ptn).set(\gtranspose,9 + [0,12,24].at(((d.gyroEvent.roll + pi).div(pi.twice/3.0)).floor));

				//Pdef(ptn).set(\c3,(10 + ((d.gyroEvent.roll + pi)/(pi.twice) * 500)));
				
				// Pdef(ptn).set(\legato,(0.1 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 10)));
				
				// Pdef(ptn).set(\position,(0.0 + ((d.gyroEvent.yaw + pi)/(pi.twice) * 1.0)));

			 });
			
			 if(Pdef(ptn).isPlaying, {

				Pdef(ptn).set(\attack,(1.0 + d.rrateEvent.sumabs).pow(4).reciprocal);

			 	Pdef(ptn).set(\dur,Array.geom(8, 1, 2).at((d.rrateEvent.sumabs.sqrt).floor).twice.reciprocal);
			
			 });

	};
	~deinit = {
		"deinit HARYY".postln;
		Pdef(ptn).stop;
	};

)