
(

	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------
	var sessionData = Dictionary.new;
	var date = Date.getDate;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle,broadcaster,noteOnResponder;
	var micInputSynth,playerSynth,recorderSynth,pluginSynth;
	var pluginName=\freqShift;

	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var buildSession, createSession, loadTemplate,loadSession;
	var initMidi, closeMidi, initGUI, refreshGUI, initArduino,closeArduino;
	var addQuestion, getNextNoteNumber;
	var playModeState,recordModeState;


	// contect locally so we can send msgs
	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup dummy datastore
	sessionData.put("keyPaths",Dictionary.new);


	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {

		loadTemplate.value(createSession.value());
//		createSession.value();
//		loadSession.value(createSession.value());

		// ready to play
		"Ready to play!".postln;

	};


	//------------------------------------------------------
	loadTemplate = { |path|

		// load a template (json)
		var jsonFile = File(appPath.asAbsolutePath+/+"template.json","r");
		var templateData = jsonFile.readAllString.parseYAML;

		jsonFile.close;

		templateData.writeArchive(path);

		//get list of template sounds
		SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

			var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";

			SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:true);


		};
		
		// load  session data 
		sessionData = Object.readArchive(path);
		
		// return
		path;

	};
	
	loadSession = { |path|
		

		File.openDialog("Select a VoiceLab Session ",{|p|

			if(p.basename.splitext[1] == "vls",{

				// load archive from found path
				var templateData = Object.readArchive(p);
				var sourceDirPath = p.dirname;
			
				// save data as achive inside session dir
				templateData.writeArchive(path);

				p.basename.splitext[1].postln;
			
			
				SoundFile.collect(sourceDirPath.asAbsolutePath+/+"Questions/*").do{ |f,i|

					var newPath = appPath.asAbsolutePath+/+path.asRelativePath(appPath.absolutePath).dirname+/+"Questions";

					SoundFile.normalize(f.path,newPath+/+f.path.basename,threaded:true);

				};
			
				// load  session data 
				sessionData = Object.readArchive(path);
			
				refreshGUI.value();
			},{
				// not a .vls file, so reload load dialog
				loadSession.value(path);
				
			});
		},{
			// cancel file open dialog
		});
		
		
		// return
		path;
	};
	
	//------------------------------------------------------
	createSession = {

		var genTitle= date.format("%A_%d:%m:%Y_%H_%M_%S");
			// create all the dirs
		var sessionDir = File.mkdir(appPath.asAbsolutePath+/+genTitle);
		var quesiotnsDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Questions");
		var answersDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Answers");
		var sessionArchivePath = appPath.asAbsolutePath+/+genTitle+/+"session.vls";


		// create empty datastore
		var templateData = Dictionary.new;
		templateData.put("keyPaths",Dictionary.new);

		// save data as achive inside session dir
		templateData.writeArchive(sessionArchivePath);


		sessionTitle = sessionArchivePath.asRelativePath(appPath.absolutePath).dirname;

		// load  session data 
		sessionData = Object.readArchive(sessionArchivePath);

		// return path
		sessionArchivePath;
	};
	//------------------------------------------------------
	// MIDI
	//------------------------------------------------------

	initMidi = {
		MIDIClient.init;
		MIDIIn.connectAll;

		playModeState.value();

		NoteOffResponder({ |src, chan, num, vel|
		});

		CCResponder({ |src,chan,num,value|
			broadcaster.sendMsg("/onRecordMsg");



    	},num:64,value:127);
	};

	//------------------------------------------------------
	closeMidi = {
		NoteOnResponder.removeAll;
		NoteOffResponder.removeAll;
		CCResponder.removeAll;

		MIDIdef.freeAll;

	};

	playModeState = {


		"PLAY MODE".postln;

		MIDIdef(\noteOnRecordMode).free;
		MIDIdef(\noteOffRecordMode).free;

		micInputSynth.free;

		// use NoteOnResponder to filter for note num
		noteOnResponder = NoteOnResponder({ |src, chan, num, vel|
			t = sessionData["keyPaths"].findKeyForValue(num.asString).postln;
			p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
			a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);

			//pluginSynth = Synth.tail(nil,pluginName);

			s.queryAllNodes;
			a.onFree({
				// pluginSynth.free;
				s.queryAllNodes;
			});
		},nil,nil,{|val|sessionData["keyPaths"].values.asInteger.includes(val)});

		MIDIdef.noteOff(\noteOffPlayMode, {arg ...args;
		{
		}.defer(0.01);

		});

	};


	recordModeState = {

		var buffer,newPath;

		"RECORD MODE".postln;

		noteOnResponder.remove;
		MIDIdef(\noteOffPlayMode).free;

		playerSynth.free;

		// micInputSynth = Synth.new(\sinImpulse);//tester
		micInputSynth = Synth.new(\micInput);
		//pluginSynth = Synth.tail(nil,pluginName);

		s.queryAllNodes;


		MIDIdef.noteOn(\noteOnRecordMode, {arg ...args;

			{
				//create buffer and write to disk
				buffer = Buffer.alloc(s,65536,1);
				g = Date.getDate.format("%H_%M_%S");
				t = "Question_"++g++".wav";
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				buffer.write(p,"wav","int16",startFrame:65536,leaveOpen:true);
				recorderSynth = Synth.tail(nil,\diskOut,[\frq,189,\mul,76,\add,232]);
				("Recording "++t).postln;
				s.queryAllNodes;

				newPath = p;
			}.defer;
		});

		MIDIdef.noteOff(\noteOffRecordMode, {arg ...args;
			{
				buffer.close;
				recorderSynth.free;
				buffer.free;

			// p = newPath.dirname+/+newPath.basename.splitext[0]++"Norm."++newPath.basename.splitext[1];
			//
			// SoundFile.normalize(newPath,p,threaded:false);
			// File.delete(newPath);
				addQuestion.value(newPath,args[1]);
				("Finished recording "++t).postln;

				s.queryAllNodes;
			}.defer(1);
		});
	};


	getNextNoteNumber = {
		a = (60..127);
		b = sessionData["keyPaths"].collect(_.asInteger);
		difference(a,b).first;

	};

	addQuestion = { |path,num|

		// we have to copy the dict since parseYAML returns an unmutable collection!!
		n = Dictionary.newFrom(sessionData["keyPaths"]);

		// insert new question into datastore
		n.put(path.basename,num.asString);
		sessionData["keyPaths"]  = n;

		p = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";
		sessionData.writeArchive(p);
		sessionData = Object.readArchive(p);

		refreshGUI.value();
	};
	//------------------------------------------------------
	// UI
	//------------------------------------------------------


	initGUI = {

		var window = Window.new("Voicelab",Rect(50, 100, 800, 550)).front;
		var listView, numberView,playButton,importButton, deleteButton;

		var playLevelView,circleView;
		var recordButton,noteButton;
		var onRecordMsg;
		var onPlayLevel;
		var recordMode=0;
		var scale = 1.0;
		var noteOnVal = 0;

		window.onClose = ({
			closeMidi.value();
			onRecordMsg.free;
			onPlayLevel.free;

		});

		window.view.decorator = FlowLayout( window.view.bounds, 10@10, 10@10 );
		window.view.background = Color.new255(230,230,230);


		listView = EZListView.new(window,
		    750@400,
		    "Questions:",nil,
			globalAction:nil,
		    initVal: 0,
		    initAction: true,
		   	labelWidth: 20,
		    labelHeight: 70,
		    layout: \vert,
		    gap: 10@10,
			margin: 10@10
	    );
		listView.font = Font("Helvetica", 44);
		playLevelView = LevelIndicator(window, Rect(0, 0, 10, 100));
		playLevelView.background=Color.grey;
		playLevelView.warning = 0.8;
		playLevelView.critical = 0.9;


		circleView = UserView(window, Rect(0, 0, 100, 100));
		circleView.drawFunc= {
			Pen.fillColor_( Color.grey( 0.0, 0.1 ));
			Pen.fillRect( Rect( 0, 0, 100, 100));
			Pen.fillColor= Color.new255(226, 49, 140);
			Pen.strokeColor= Color.new255(226, 49, 140);
			Pen.fillOval(Rect.aboutPoint(Point(50, 50), 20*scale, 20*scale));
		};
		circleView.animate= true;
		circleView.clearOnRefresh = false;

		numberView = EZNumber(window,
             150@50,
             "Note",
             ControlSpec(0, 127, \lin, 1, 64, "MidiNote"),
             nil,
		      0,
             false
		);


		playButton = Button(window, 100@50)
	        .states_([["Play", Color.black, Color.green(alpha:0.2)]])
	        .action_({ arg butt;
				window.view.enabled = false;
				
	            listView.value.postln;
				t = listView.items.at(listView.value).key;
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);
			//pluginSynth = Synth.tail(nil,pluginName);

			s.queryAllNodes;
			a.onFree({
				s.queryAllNodes;
				{
					listView.value = listView.value + 1;
					window.view.enabled = true;
				}.defer;
			});
		});

		importButton = Button(window, 120@50)
			.states_([["Import Question", Color.black, Color.blue(alpha:0.2)]])
	        .action_({ arg butt;

				File.openDialog("Select an awesome new question",{|path|

					// copy this file to our questions dir
					var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
					SoundFile.normalize(path,newPath+/+path.basename);
					// generate a unique note number

					addQuestion.value(path,getNextNoteNumber.value());
				},{
					// cancel file open dialog
				});
			});


		deleteButton = Button(window, 120@50)
	        .states_([["Delete Question", Color.black, Color.red(alpha:0.2)]])
	        .action_({ arg butt;

				var key = listView.items.at(listView.value).key;
				var path = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+key;

				if(File.exists(path),{

					File.delete(path);

					sessionData["keyPaths"].removeAt(key.asString);
					p = appPath.asAbsolutePath+/+sessionTitle+/+"session.vls";
					sessionData.writeArchive(p);
					sessionData = Object.readArchive(p);

					refreshGUI.value();

				},{
						("Error : Can't find Question to delete").postln;
				});

			});

		recordButton = Button(window, 80@50)
	        .states_([
					["REC", Color.black, Color.grey(alpha:0.2)],
					["REC", Color.black, Color.red]
					])
	        .action_({ arg butt;
				broadcaster.sendMsg("/onRecordMsg");
			});

		noteButton = Button(window, 80@50)
	        .states_([
					["NOTE ON", Color.black, Color.grey(alpha:0.2)],
					["NOTE OFF", Color.green, Color.grey(alpha:0.2)]
					])
	        .action_({ arg butt;
				
				if(butt.value == 1,{
					"on".postln;
					noteOnVal = getNextNoteNumber.value;
					MIDIIn.doNoteOnAction(1, 1, noteOnVal, 64);
				},{
					"off".postln;
					MIDIIn.doNoteOffAction(1, 1, noteOnVal, 64);
					noteOnVal = 0;
				});
				//MIDIIn.doNoteOnAction(1, 1, getNextNoteNumber.value, 64);
			});



		// finished building ui
		refreshGUI.value();

		numberView.action_({ |ez|

			t = listView.items.at(listView.value).key;
			if( sessionData["keyPaths"].findKeyForValue(ez.value.asString) == nil ,{

				sessionData["keyPaths"].removeAt(t.asString);
				sessionData["keyPaths"].put(t.asString,ez.value.asString);
			 	refreshGUI.value();

			},{
				ez.value = sessionData["keyPaths"].at(t.asString);
			});
		});

		onRecordMsg = OSCFunc({|msg, time, addr, recvPort|
			{
				recordMode = recordMode.even.asInteger;
				recordButton.value = recordMode;

				playLevelView.value = 0;
				playLevelView.peakLevel = 0;
				scale = 1.0;

				switch(recordMode,
				0,{
					playModeState.value();
					playLevelView.background=Color.grey;


				},
				1,{
					recordModeState.value();
					playLevelView.background=Color.red(1,0.5);

				}
				);

			}.defer;
		}, '/onRecordMsg');

		onPlayLevel = OSCFunc({|msg, time, addr, recvPort|
    		{
				scale = msg[4].ampdb.linexp(-40, 0, 1, 1.5);
				playLevelView.value = msg[4].ampdb.linlin(-40, 0, 0, 1);
				playLevelView.peakLevel = msg[5].ampdb.linlin(-40, 0, 0, 1);

  			}.defer;

		}, '/onPlayLevel');

		//------------------------------------------------------
		refreshGUI = {

			// clear listView
			listView.items = Array.newClear;
			
			if(sessionData["keyPaths"].isEmpty == false,{
				sessionData["keyPaths"].values.collect(_.asInteger).asSortedList.postln;
				// repopulate in order of assigned midi note
				sessionData["keyPaths"].values.asSortedList.collect(_.asInteger).do({ |val|
					t = sessionData["keyPaths"].findKeyForValue(val.asString);
					listView.addItem(t,{
						numberView.value = val;
					});
				});
				t = listView.items.at(listView.value).key;
				numberView.value = sessionData["keyPaths"].at(t.asString);
			});
		};

		CmdPeriod.doOnce({
			closeArduino.value();
			window.close;
		});

	};

	//------------------------------------------------------
	// BUILD
	//------------------------------------------------------

	initArduino.value();
 	initGUI.value();
 	buildSession.value();
	initMidi.value();

	refreshGUI.value();


)

