
(

	var winenv;
	winenv = Env([0, 1, 0], [0.01, 0.01], [-2, 2]);
	z = Buffer.sendCollection(s, winenv.discretize, 1);
	
	SynthDef(\warppadxy, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5, xx = 0.2,yy = 0.2;
		
		Out.ar(0,
			Splay.arFill(24,
				{ |i| Warp1.ar(2, buffer, xx+0.01, pch,yy, envbuf, 4, 1, 4)  },
				1,
				1,
				0
			) * 0.2
		);	
	}).send(s);

)

c = Buffer.read(s, "sounds/alleg.wav");
//c = Buffer.read(s, "sounds/SFX_1020_44.wav");
x = Synth(\warppadxy,[\buffer,c,\ws,3.3,\pch,1.0]);
x.set(\xx,0.5);


(
	//var buf = Buffer.read(s, "sounds/70986__jppi-stu__sw-countdownfrom10.wav");
	//var buf = Buffer.read(s, "sounds/23875__Connum__spoon_in_cup.wav");
	var buf = Buffer.read(s, "sounds/55208__noisecollector__kidstory.wav");
	
	var sy = Synth(\warppadxy,[\buffer,buf,\ws,3.3,\pch,1.0]);
	
	var res = OSCresponderNode.new(nil, "/1/xy1", { 
		arg time, resp, msg; 
		sy.set(\xx,msg[1]); 
		sy.set(\xx,msg[2]); 
	
	} ).add; 

)
