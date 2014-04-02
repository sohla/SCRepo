

(
	SynthDef(\playBuffer, {|buffer = 0, note = 69|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
	    SendReply.kr(imp, '/onPlayLevel', [0,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player]);

	}).send(s);

	SynthDef(\micInput, {|buffer = 0|
		var player = SoundIn.ar(0);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
		 SendReply.kr(imp, '/onPlayLevel', [1,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player]);

	}).send(s);

	// sin impulse for testing
	SynthDef(\sinImpulse,{|freq=440,amp=0.8|
			var trg = Decay2.ar(Impulse.ar(2,0,0.3), 0.01, 0.3);
			var sig = SinOsc.ar(freq,0,trg*amp);
			Out.ar(0,[sig,sig])
		}
	).send(s);

	// simple disk out
	SynthDef(\diskOut, {arg bufnum;
	    DiskOut.ar(bufnum, In.ar(0,1));
	}).send(s);

)


(

	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------
	var sessionData = Dictionary.new;
	var date = Date.getDate;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle,broadcaster;
	var micInputSynth,playerSynth,recorderSynth;
	var arduino,arduinoTask;

	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var buildSession, loadSession, createSession, loadTemplate;
	var initMidi, closeMidi, initGUI, refreshGUI, initArduino,closeArduino;
	var addQuestion, getNextNoteNumber;
	var playModeState,recordModeState;

	var noteOnResponder;

	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup
	sessionData.put("keyPaths",Dictionary.new);



	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {

		loadSession.value(loadTemplate.value(createSession.value()));
//		loadSession.value(createSession.value());



		// ready to play
		"Ready to play!".postln;

	};


	//------------------------------------------------------
	loadSession = { |path|

		sessionData = Object.readArchive(path);
		sessionTitle = path.asRelativePath(appPath.absolutePath).dirname;
		(sessionTitle ++ " session loaded").postln;
		//sessionData["keyPaths"].postln;
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
		var sessionArchivePath = appPath.asAbsolutePath+/+genTitle+/+"session";


		// create empty datastore
		var templateData = Dictionary.new;
		templateData.put("keyPaths",Dictionary.new);

		// save data as achive inside session dir
		templateData.writeArchive(sessionArchivePath);




		// return path
		sessionArchivePath;
	};
	//------------------------------------------------------
	// ARDUINO
	//------------------------------------------------------
initArduino = {

	arduino = Rduino(SerialPort.devices.last,115200);
	arduino.pw_(9,127);
	{arduino.pw_(9,0)}.defer(1.0);

	// arduinoTask = Task.new({ inf.do({
	//
	// 	i = i + d;
	//
	// 	if(i>127,{d = d * -1; i = 127;});
	// 	if(i<0,{d = d * -1; i = 0;});
	// 	i.postln;
	// 	arduino.pw_(9,i);
	//
	// 	0.01.wait;
	// 	})
	//
	// });
	//
	//
};



closeArduino = {

	// turn everything off
	(2..13).do{ | i | arduino.mode_(i,1) };
	(2..13).do{ | i | arduino.bit_(i,0) };

	arduino.close;
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

		MIDIdef(\noteOnRecordMode).free;
		MIDIdef(\noteOffRecordMode).free;

		micInputSynth.free;

		// use NoteOnResponder to filter for note num
		noteOnResponder = NoteOnResponder({ |src, chan, num, vel|
			t = sessionData["keyPaths"].findKeyForValue(num.asString).postln;
			p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
			a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);


		},nil,nil,{|val|sessionData["keyPaths"].values.asInteger.includes(val)});

		MIDIdef.noteOff(\noteOffPlayMode, {arg ...args;
		{
		}.defer(0.01);

		});

	};


	recordModeState = {

		var buffer,newPath;

		noteOnResponder.remove;
		MIDIdef(\noteOffPlayMode).free;

		playerSynth.free;

		// micInputSynth = Synth.new(\sinImpulse);//tester
		micInputSynth = Synth.new(\micInput);

		MIDIdef.noteOn(\noteOnRecordMode, {arg ...args;

			{
				//create buffer and write to disk
				buffer = Buffer.alloc(s,65536,1);
				g = Date.getDate.format("%H_%M_%S");
				t = "Question_"++g++".wav";
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				buffer.write(p,"wav","int16",startFrame:65536,leaveOpen:true);
				recorderSynth = Synth.tail(nil,\diskOut,[\bufnum,buffer.bufnum]);
				("Recording "++t).postln;
				newPath = p;
			}.defer;
		});

		MIDIdef.noteOff(\noteOffRecordMode, {arg ...args;
			{
				buffer.close;
				recorderSynth.free;
				buffer.free;

				p = newPath.dirname+/+newPath.basename.splitext[0]++"Norm."++newPath.basename.splitext[1];

				SoundFile.normalize(newPath,p,threaded:false);
				File.delete(newPath);
				addQuestion.value(p,args[1]);
				("Finished recording "++t).postln;

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

		p = appPath.asAbsolutePath+/+sessionTitle+/+"session";
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
		var recordButton;
		var onRecordMsg;
		var onPlayLevel;
		var recordMode=0;
		var scale = 1.0;

		window.onClose = ({
			closeMidi.value();
			onRecordMsg.free;
			closeArduino.value();

		});

		window.view.decorator = FlowLayout( window.view.bounds, 10@10, 10@10 );
		window.view.background = Color.new255(230,230,230);


		listView = EZListView.new(window,
		    750@400,
		    "Questions:",nil,
			globalAction:nil,
		    initVal: 0,
		    initAction: true,
		   	labelWidth: 100,
		    labelHeight: 20,
		    layout: \vert,
		    gap: 10@10,
			margin: 10@10
	    );

		listView.font = Font("Helvetica", 18);
		playLevelView = LevelIndicator(window, Rect(0, 0, 10, 100));
		playLevelView.background=Color.grey;
		playLevelView.warning = 0.8;
		playLevelView.critical = 0.9;


		circleView = UserView(window, Rect(0, 0, 100, 100));
		circleView.drawFunc= {
			Pen.fillColor_( Color.black( 0.3, 0.1 ));
			Pen.fillRect( Rect( 0, 0, 100, 100));
			Pen.fillColor= Color.new255(226, 49, 140);
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
	            listView.value.postln;
				t = listView.items.at(listView.value).key;
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);
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
					p = appPath.asAbsolutePath+/+sessionTitle+/+"session";
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
				switch(recordMode,
				0,{playModeState.value();playLevelView.background=Color.grey;},
				1,{recordModeState.value();playLevelView.background=Color.red(1,0.5);}
				);

			}.defer;
		}, '/onRecordMsg');

		onPlayLevel = OSCFunc({|msg, time, addr, recvPort|
    		{
				scale = msg[4].ampdb.linexp(-40, 0, 1, 0.3);
				playLevelView.value = msg[4].ampdb.linlin(-40, 0, 0, 1);
				playLevelView.peakLevel = msg[5].ampdb.linlin(-40, 0, 0, 1);

				if( msg[5].ampdb.linlin(-40, 0, 0, 1) > 0.3,{
					 arduino.pw_(9,msg[5].ampdb.linexp(-40, 0, 5, 127));
				},{
						 arduino.pw_(9,0);
				});
  			}.defer;

		}, '/onPlayLevel');

	//------------------------------------------------------
	refreshGUI = {

		// clear listView
		listView.items = Array.newClear;
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
	};

	//CmdPeriod.doOnce({window.close});

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

//------------------------------------------------------
// WORKBENCH
//------------------------------------------------------





c="5"
c.asInteger
a = [34,5,76,9];
a.includes(5)


b = ["34","5","76","9"].asInteger.includes(6);
b = b.asInteger
b.includes(5)


a.asSortedList

a = [ \a->123,\b->345345]
a.at(0)
a.do({ |o|
o.value.postln;
})




d = [(\robot->99),(\robot2->29)];
d.class
d.associationAt(\robot);    // Get the value associated with key


a = Dictionary.new(); // return a new Event.
b = \foo ->2.718
a.add(b);
b = \foo2 ->24.718
a.add(b);
a.at("foo".asSymbol);

a.gui
a = [ ("1.welcomeToVoiceLab.wav" -> 64), ("10.whatMakesYouLaugh.wav" -> 73)]





f = { |a|
	(a+7);
};


c = f.value(5)
c
a = (1..127); b = [2, 3, 4, 5];
difference(a, b);

differnce((0..127),[1,2,3])


(1..127)

a = (1..127)
a.flat

["4", 12, 4, 22, 51, 63, 2, 6, 73, 2 ].collect(_.asInteger)



a = (1..10);
b = [1,2,5,8].collect(_.asInteger);
c = difference(a,b).first;
b = b.add(difference(a,b).first);

(
f = {
	var test = "oh yes";
	"f".postln;
	g = {
	test.postln;
	};

};
)


f.value()
g.value()




	a = ("~/Music/VoiceLab/x.wav");
a.dirname+/+a.basename.splitext[0]++"Norm."++a.basename.splitext[1]
//------------------------------------------------------
// IDEAS
//------------------------------------------------------

pedal as record state : turns on rec button


rename question files
