//------------------------------------------------------------------------
// 2 blobs
//------------------------------------------------------------------------

(
	
	var synthName = "\warpSynth";
	var numOfBlobs = 2;
	var res;

	var synths = Array.new(numOfBlobs);
	
	var paths = [
		"52.wav",	
		"34.wav",
		"01 Orchestra Tuning.aif",
		"23 Breathing Heavy.aif",
		"alleg.wav",
		"70986__jppi-stu__sw-countdownfrom10.wav",
		"hurtfull.aif",
		"gong  1.wav",
		"BlenderRun1 -6M.wav"
	
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
			synths.at(i).set(\xx,msg[1]); 
			synths.at(i).set(\ws,1.0 + msg[2]); 
		
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
