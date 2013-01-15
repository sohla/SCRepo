(
	var startGraph;
	var closeGraph;
	
	var startSynths;
	var stopSynths;

	var allocBufferFile;
	var deallocBufferFile;
	
	var startRecording;
	var stopRecording;

	var	recID = 2000;
	var groupID = 1000;
	var synthID = 1001;
	var blipID = 1002;

	var numFiles = 4;
	var filename;
	var types;
	var frequences;
	var amps;
	var time = 0;
	//--------------------------------------------------------
	startGraph = {
		
		// create group
		s.sendMsg("/g_new",groupID);
		s.queryAllNodes(true);

	};
	
	closeGraph = {
		
		// free group
		s.sendMsg("/n_free", groupID);
		s.queryAllNodes(true);
	};

	//--------------------------------------------------------

	allocBufferFile = { arg fileName;
		
		// allocate a disk i/o buffer
		s.sendMsg("/b_alloc", 0, 65536, 2); // Buffer number is 0
		
		// create an output file for this buffer, leave it open
		//s.sendMsg("/b_write", 0, ("testfiles/"++fileName++"_"++Date.getDate.stamp++".aiff").standardizePath, "aiff", "int16", 0, 0, 1);
		s.sendMsg("/b_write", 0, ("testfiles/"++fileName++".aiff").standardizePath, "aiff", "int16", 0, 0, 1);
		
		"allocBufferFile".postln;
				
	};
	
	deallocBufferFile = {
		
		// close the file
		s.sendMsg("/b_close", 0);
		
		s.sendMsg("/b_free", 0);
		
		"deallocBufferFile".postln;
	};
	
	//--------------------------------------------------------
	startRecording = {

		// insert recorder in groupID
		
		// create the diskout node
		s.sendBundle(0.0,
			s.sendMsg("/s_new", "help-Diskout", recID, 1, groupID, "bufnum", 0);
		);
	};
	
	stopRecording = {
		
		// stop recording
		s.sendBundle(0.0,
			s.sendMsg("/n_free", recID);
		);
		
	};	

	//--------------------------------------------------------
	startSynths = {
		
		
		8.do({ |itr|
			
			
			s.sendBundle((itr*2),
				["/s_new", "sin_wave", synthID, 2, groupID,"frq",50 * (itr+1)]
			);
			s.sendBundle((itr*2) + 1.0,
				["/n_free",synthID]
			);

		});
			

		s.queryAllNodes(true);
		
	};
	
	stopSynths = {
		
		s.sendBundle(0.0,
		
			["/n_free", synthID]
			
		);
		s.queryAllNodes(true);
		
	};
	//--------------------------------------------------------



	

	//--------------------------------------------------------
	// start
	//--------------------------------------------------------

	startGraph.value();

	types = Array.with("sin_wave","saw_wave");
//	types = Array.with("brown_wave","pink_wave","white_wave");
//	frequences =  Array.with(55,110,220,440,880,4400,8800,17600);
	frequences =  Array.with(55,440,4400,17600);
	amps = Array.with(0.0,-3.0,-10.0);
	
	
	types.do({ |type|
		
		frequences.do({ |frq|
			
			amps.do({ |amp|
				
				filename = ("output/"++type++"_"++frq++"hz_"++amp++"db.wav").standardizePath;
//				filename = ("output/"++type++"_"++amp++"db.wav").standardizePath;
				s.sendBundle(time,
						["/b_alloc", 0, 65536, 2],
						["/b_write", 0, filename, "wav", "int16", 0, 0, 1]
				);
				
				
				time = time + 1;
				s.sendBundle(time,
						["/s_new", "help-Diskout", recID, 1, groupID, "bufnum", 0],
						["/s_new", type, synthID, 2, recID,"frq",frq,"db",amp]
				);
				
				
				
				time = time + 1;
				s.sendBundle(time,
						["/n_free", recID],
						["/n_free", synthID],
						["/b_close", 0],
						["/b_free",0]
				);
				time = time + 1;
				
			});
			
			
		});
		
		
		time = time + 1;
				
	});
	

)


	