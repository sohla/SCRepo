

(

	SynthDef(\warpSynth, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 0.5, xx = 0.2,yy = 0.2,vol=0.2;
		
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

