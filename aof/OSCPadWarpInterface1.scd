

(

	SynthDef(\warpSynth, {arg buffer = 0, envbuf = -1, ws = 0.5, pch = 1.0, xx = 0.2,yy = 0.2,vol=0.2;
		
		Out.ar(0,
			Splay.arFill(10,
				{ |i| Warp1.ar(1, buffer, xx+0.01, 1.0,0.4, envbuf, 4, 0.001, 4)  },
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
	
	var synthName = "\warpSynth";
	var numOfBlobs = 2;
	var res;

	var synths = Array.new(numOfBlobs);
	
	var paths = [
	"darkforest.wav",
	"MysticAlienClay04.wav",
	"SFX_1021_15.wav",
	"SFX_1021_23.wav",
	"06-08ambDm7.wav",
	"23875__Connum__spoon_in_cup.wav"

	];
	
	var buffers = Array.new(paths.size);
	var buf;
	var sampleIndex = 0;
	
	var window = SCWindow.new("",Rect(341, 738, 400, 400)).front;


	window.view.keyDownAction = {|a,b,c,d|
			
		b.asString.switch(
		
			"="	,	{ sampleIndex = sampleIndex + 1;},
			"-"	,	{ sampleIndex = sampleIndex - 1;}
		
		);
		
		sampleIndex = sampleIndex % paths.size;
		
		buffers.at(sampleIndex).postln;
				
		numOfBlobs.do({|i|

			synths.at(i).set(\buffer,buffers.at(sampleIndex));
		});
	};
		
	paths.do({ |path,i|
		
		
		buf = Buffer.read(s,"sounds/"++path); 
					 
		("loading..."++i++" : "++path++" into "++buf).postln;
		
		buffers = buffers.add(buf);
		
	});

	
	numOfBlobs.do({|i|
		
		
		synths = synths.add(Synth(synthName,[\buffer,buffers.at(sampleIndex),\ws,1.3,\pch,1.0]));
		
		
		synths.at(i).run(false);
	
		res = OSCresponderNode.new(nil, "/model"++i, { 
			arg time, resp, msg; 
			synths.at(i).set(\xx,msg[2]); 
			synths.at(i).set(\yy,0.75 + msg[1]); 
		
		} ).add; 

		res = OSCresponderNode.new(nil, "/model"++i++"on", { 
			arg time, resp, msg; 
			synths.at(i).set.run(true); 
		} ).add; 
		res = OSCresponderNode.new(nil, "/model"++i++"off", { 
			arg time, resp, msg; 
			synths.at(i).set.run(false); 
		} ).add; 
	
	});
			
	window.onClose = {
		numOfBlobs.do({|i|
			// handy way to clear or responders
			OSCresponderNode.removeAddr(nil);
			synths.at(i).free;
		});
	}
	
)
