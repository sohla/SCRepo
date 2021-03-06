

(
	var name = "show1.sc";
//	var fullpath = File.realpath(Platform.userConfigDir
//				+/+".."+/+".."+/+".."+/+"Develop"+/+"SuperCollider"+/+"SCRepo"
//				+/+"urbancoccoon"+/+"data"+/+name);
	var fullpath = File.realpath(Platform.userConfigDir
				+/+".."+/+".."+/+".."+/+"Documents"+/+"cocoon"+/+"SCRepo"
				+/+"urbancoccoon"+/+"data"+/+name);

	var file = CSVFileReader.read(fullpath, true);
	var cues = Array.new(file.size);
	var cueNames = Array.new(file.size);
	
	var window,cuesListView,goButton,nextText;

	
	var netAddress = NetAddr.localAddr;
	var oscResponder;
		
	
	s.boot;
	s.loadSynthDef("monoSamplePlayer");
	s.loadSynthDef("monoSamplePlayer");
	s.loadSynthDef("streetscape");
	
	//------------------------------------------------------
	// DATA
	//------------------------------------------------------
	file.size.do({|i|
		cues.add(Dictionary.newFrom(file[i]));
	});

	cues.do({|o|
		
		cueNames.add(o.at("q"));
	});
	
	//------------------------------------------------------
	// MIDI / OSCResponder
	//------------------------------------------------------

	MIDIClient.init;
	MIDIClient.destinations;


	oscResponder = OSCresponderNode.new(n, "/midi", { |time, resp, msg| 
		
		[time,resp,msg].postln; 

		// basic example of sending a singe midi note
		MIDIOut(0).noteOn(msg[1],msg[2],msg[3]);
	
	}).add; 
	
	
	//------------------------------------------------------
	// GUI
	//------------------------------------------------------
	window = SCWindow.new("",Rect(300, 50, 700, 440)).front;

	cuesListView = SCListView.new(window,Rect(10, 10, 400, 420))
		.font_(Font.sansSerif(16))
		.hiliteColor_(Color.grey(1.0,0.1))
		.selectedStringColor_(Color.black)
		.items_(cueNames)
		.action_{|v| 

			var o = file.at(v.value-1);
			var msg = Array.newFrom(o.copyToEnd(2));
			var raw = Array.new(o.size);
			var next = file.at(v.value)[1];

			msg.do({|a|
			// need to turn any numbers into floats for raw OSC messgaing
				if( ("^[0-9\-]+(\.[0-9]{1,2})?$").matchRegexp(a) ,{
					raw.add(a.asFloat);
				},{
					raw.add(a.replace("\"",""));
				});
			});

			if(msg.size == 0,{
				"nothing".postln
			},{
				if(raw[0] == "/midi",{
					netAddress.sendMsg(*raw);
				},{	
					s.sendMsg(*raw);	
				});
			});
			
			
			if( next == "|" ,{
				cuesListView.valueAction = cuesListView.value + 1;
		});
			
			
//			nextText.string_(v.items[v.value+1]);
			
//			("["+cueNames.at(v.value)+"]").postln;
//			v.items[v.value].postln;
		};
//	nextText = SCTextView.new(window,Rect(700-260, 10, 250, 20))
//			.font_(Font.sansSerif(16))
//			.backColor_(Color.gray)
//			.string_("hello");

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
		netAddress.disconnect;
		oscResponder.remove;
		s.quit;
	});

)


				