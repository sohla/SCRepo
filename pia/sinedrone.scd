{  
	var p=10;
	var root = 90;
	var z=0.0;
	var ptchs = Array.geom(p, root, 2);
	var vlms = Array.geom(p, 1, 0.12);
	var amps = Array.rand(p, 4,50);
	var pans = Array.rand(p, -0.5,0.5);
	
	root = MouseX.kr(50,2000);

	p.do ({ arg i;
	

		z = SinOsc.ar(
			ptchs.at(i), 
			0, 
			LFNoise2.ar(
				amps[i],
				[pans.at(i),pans.at(i)]
			)* vlms.at(i),
			z
		) 
	
	
	});
	ptchs = Array.geom(p, root+2, 2);

	p.do ({ arg i;
	

		z = SinOsc.ar(
			ptchs.at(i), 
			0, 
			LFNoise2.ar(
				amps[i],
				[pans.at(i),pans.at(i)]
			)* vlms.at(i),
			z
		) 
	
	
	});
	DelayC.ar(z, 0.2, 0.2, 1,z)
}.play;

