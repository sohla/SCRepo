

(
	var path = "data/data.sc";
	var file = CSVFileReader.read(path, true);
	var cues = Array.new(file.size);
	var cueNames = Array.new(file.size);

	var window,cuesListView,goButton;

	var a = ["a","b"];
	

	//------------------------------------------------------
	// DATA
	//------------------------------------------------------
	file.size.do({|i|
		cues.add(Dictionary.newFrom(file[i]));
	});

	cues.do({|o|
		cueNames.add(o.at("cue"));
	});
	

	//------------------------------------------------------
	// GUI
	//------------------------------------------------------
	window = SCWindow.new("",Rect(300, 50, 700, 440)).front;

	cuesListView = SCListView.new(window,Rect(10, 10, 400, 420))
		.font_(Font.sansSerif(16))
		.hiliteColor_(Color.green(1.0,0.2))
		.items_(cueNames)
		.action_{|v| 

			var o = file.at(v.value);
			var msg = Array.newFrom(o.copyToEnd(2));
			var raw = Array.new(o.size);

			// need to turn any numbers into floats for raw OSC messgaing
			msg.do({|a|
//				(a+"::"+("^[0-9]+(\.[0-9]{1,2})?$").matchRegexp(a)).postln;
				if( ("^[0-9]+(\.[0-9]{1,2})?$").matchRegexp(a) ,{
					raw.add(a.asFloat);
				},{
					raw.add(a.replace("\"",""));
				});
			});

			
			if(msg.size == 0,{
				"nothing".postln
			},{
				s.sendRaw(raw.asRawOSC);	
			});
			
//			("["+cueNames.at(v.value)+"]").postln;
//			v.items[v.value].postln;
		};


//	goButton = SCButton.new(window,Rect(700-110, 440-110, 100, 100))
//			.font_(Font.sansSerif(16))
//			.states_([[ "go", Color(0.0, 0.0, 0.0, 1.0), Color.green(1.0,0.2) ]])
//			.action_{|v|
//				var nextCue = cuesListView.items[cuesListView.value+2];
//				 cuesListView.valueAction = cuesListView.value + 1;
//	
//				 v.states = [[ nextCue, Color(0.0, 0.0, 0.0, 1.0), Color.green(1.0,0.2) ]];
//			};

	window.onClose = ({
		s.sendMsg("/g_freeAll",1);
		s.queryAllNodes;
	});

)


			