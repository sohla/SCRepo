


(
	SynthDef(\simplesine, {arg frq=440.0, amp = 0.4;
		
		Out.ar(0,
				[SinOsc.ar(frq,0,amp),SinOsc.ar(frq,0.01,amp)]
		);	
	}).send(s);

)



(
	SynthDef(\simplering, {arg frq=240.0, amp = 0.5, modfrq = 120, modamp = 0.5;
			
		var	mod;
		var	os;
		mod = SinOsc.ar(modfrq,0,modamp);
		os = SinOsc.ar(frq * mod,0,1.0);
		
		Out.ar(0,[os,os]);
		
	}).send(s);

)





c = Buffer.read(s, "sounds/alleg.wav");
//c = Buffer.read(s, "sounds/SFX_1020_44.wav");
x = Synth(\warppadxy,[\buffer,c,\ws,3.3,\pch,1.0]);
x.set(\xx,0.5);
a = Synth(\simplesine);
a = Synth(\simplering);


a.set(\frq,620);
a.set(\frq,120);

//------------------------------------------------------------------------
// sinewave test
//------------------------------------------------------------------------

(
	var sy1 = Synth(\simplesine);
	
	
	
	var i=0;	
	
	var res = OSCresponderNode.new(nil, "/model"++i, { 
		arg time, resp, msg; 
		sy1.set(\frq,50 + (msg[1] * 600)); 
		sy1.set(\amp,msg[2]); 
	
	} ).add; 


	res = OSCresponderNode.new(nil, "/model"++i++"on", { 
		arg time, resp, msg; 
		sy1.run(true); 
	} ).add; 
	res = OSCresponderNode.new(nil, "/model"++i++"off", { 
		arg time, resp, msg; 
		sy1.run(false); 
	} ).add; 
	
	sy1.run(false);
	
)
//------------------------------------------------------------------------
// 2 rings
//------------------------------------------------------------------------

(
	var sy1 = Synth(\simplering);	
//	var sy2 = Synth(\simplering);	
	
	
	var i=0;	
	
	var res = OSCresponderNode.new(nil, "/model"++i, { 
		arg time, resp, msg; 
		sy1.set(\frq,50 + (msg[1] * 600)); 
		sy1.set(\frqamp,msg[2]); 
	
	} ).add; 


	res = OSCresponderNode.new(nil, "/model"++i++"on", { 
		arg time, resp, msg; 
		sy1.run(true); 
	} ).add; 
	res = OSCresponderNode.new(nil, "/model"++i++"off", { 
		arg time, resp, msg; 
		sy1.run(false); 
	} ).add; 
	

	i =1;

	res = OSCresponderNode.new(nil, "/model"++i, { 
		arg time, resp, msg; 
		sy1.set(\modfrq,50 + (msg[1] * 600)); 
		sy1.set(\modamp,msg[2]); 
	
	} ).add; 

//	res = OSCresponderNode.new(nil, "/model"++i++"on", { 
//		arg time, resp, msg; 
//		sy1.run(true); 
//	} ).add; 
//	res = OSCresponderNode.new(nil, "/model"++i++"off", { 
//		arg time, resp, msg; 
//		sy1.run(false); 
//	} ).add; 
	
	
	sy1.run(false);
	
)
(

	var winenv;
	winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
	z = Buffer.sendCollection(s, winenv.discretize, 1);
	
	SynthDef(\warppadxy, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5, xx = 0.2,yy = 0.2,vol=0.2;
		
		Out.ar(0,
			Splay.arFill(24,
				{ |i| Warp1.ar(2, buffer, xx+0.01, pch,yy, envbuf, 4, ws, 4)  },
				1,
				1,
				0
			) * vol
		);	
	}).send(s);

)



//------------------------------------------------------------------------
// 2 blobs
//------------------------------------------------------------------------

(
//	var buf1 = Buffer.read(s, "sounds/55208__noisecollector__kidstory.wav");
//	var buf2 = Buffer.read(s, "sounds/alleg.wav");
//	var buf2 = Buffer.read(s, "sounds/Jazz 130bpm.wav");
//	var buf2 = Buffer.read(s, "sounds/Church Bells 1.aiff");

	var buf2 = Buffer.read(s, "sounds/Peeling potatoes.aiff");


//	var buf2 = Buffer.read(s, "sounds/70986__jppi-stu__sw-countdownfrom10.wav");
//	var buf1 = Buffer.read(s, "sounds/hurtfull.aif");
	
	var sy1 = Synth(\warppadxy,[\buffer,buf2,\ws,3.3,\pch,1.0]);
	var sy2 = Synth(\warppadxy,[\buffer,buf2,\ws,3.3,\pch,0.5]);
	
	
	var numOfBlobs = 2;
	
			
	
	var i=0;	
	
	var res = OSCresponderNode.new(nil, "/model"++i, { 
		arg time, resp, msg; 
		sy1.set(\xx,msg[1]); 
		sy1.set(\pch,0.5 + (msg[2] * 0.5)); 
	
	} ).add; 


	res = OSCresponderNode.new(nil, "/model"++i++"on", { 
		arg time, resp, msg; 
		sy1.run(true); 
	} ).add; 
	res = OSCresponderNode.new(nil, "/model"++i++"off", { 
		arg time, resp, msg; 
		sy1.run(false); 
	} ).add; 
	

	i =1;

	res = OSCresponderNode.new(nil, "/model"++i, { 
		arg time, resp, msg; 
		sy2.set(\xx,msg[1]); 
		//sy2.set(\yy,msg[2]); 
	
	} ).add; 

	res = OSCresponderNode.new(nil, "/model"++i++"on", { 
		arg time, resp, msg; 
		sy2.run(true); 
	} ).add; 
	res = OSCresponderNode.new(nil, "/model"++i++"off", { 
		arg time, resp, msg; 
		sy2.run(false); 
	} ).add; 
	
	
	sy1.run(false);
	sy2.run(false);

	sy1.set(\vol,0.4);
	sy2.set(\vol,0.4);
	
)


(
	//var buf = Buffer.read(s, "sounds/70986__jppi-stu__sw-countdownfrom10.wav");
	//var buf = Buffer.read(s, "sounds/23875__Connum__spoon_in_cup.wav");
	var buf1 = Buffer.read(s, "sounds/55208__noisecollector__kidstory.wav");
	var buf2 = Buffer.read(s, "sounds/alleg.wav");
	
	var sy1 = Synth(\warppadxy,[\buffer,buf,\ws,3.3,\pch,1.0]);
	
	var res = OSCresponderNode.new(nil, "/model", { 
		arg time, resp, msg; 
		sy.set(\xx,msg[1]); 
		//sy.set(\yy,msg[2]); 
	
	} ).add; 

	res = OSCresponderNode.new(nil, "/on", { 
		arg time, resp, msg; 
		sy.run(true); 
	} ).add; 
	res = OSCresponderNode.new(nil, "/off", { 
		arg time, resp, msg; 
		sy.run(false); 
	} ).add; 

)



(
	var buf = Buffer.read(s, "sounds/70986__jppi-stu__sw-countdownfrom10.wav");
	//var buf = Buffer.read(s, "sounds/23875__Connum__spoon_in_cup.wav");
	//var buf = Buffer.read(s, "sounds/55208__noisecollector__kidstory.wav");
	
	var sy = Synth(\warppadxy,[\buffer,buf,\ws,3.3,\pch,1.0]);
	
	var r1 = OSCresponderNode.new(nil, "/1/multixy1/1", { 
		arg time, resp, msg; 
		sy.set(\xx,msg[1]); 
		sy.set(\xx,msg[2]); 
	
	} ).add; 

	var r2 = OSCresponderNode.new(nil, "/1/multixy1/2", { 
		arg time, resp, msg; 
		sy.set(\ws,msg[1]); 
		sy.set(\pch,0.5 + msg[2]); 
	
	} ).add; 

)

(
    // strummable guitar
    // use mouse to strum strings
{
	var pitch, mousex, out,xx,yy,r1;
	// e a d g b e
	pitch = [ 52, 57, 62, 67, 71, 76 ];
	mousex = MouseX.kr;
	
	
	r1 = OSCresponderNode.new(nil, "/1/multixy1/1", { 
		arg time, resp, msg; 
		xx = msg[1] * 500; 
	
	} ).add; 
	
	out = Mix.arFill(pitch.size, { arg i;
		var trigger, pluck, period, string;
		// place trigger points from 0.25 to 0.75
		trigger = HPZ1.kr(mousex > (0.25 + (i * 0.1))).abs;
		pluck = PinkNoise.ar(Decay.kr(trigger, 0.05));
		period = pitch.at(i).midicps.reciprocal;
		string = CombL.ar(pluck, period, period, 4);
		Pan2.ar(string, i * 0.2 - 0.5);
	});
	LPF.ar(out, 12000);
	LeakDC.ar(out);
}.play;
)

