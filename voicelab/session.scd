

(
	SynthDef(\playBuffer, {|buffer = 0, note = 69|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		);
		Out.ar(0,[player,player]);

	}).send(s);

	SynthDef(\micin, {|buffer = 0|
	var player = SoundIn.ar(0);
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


	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var buildSession, loadSession, createSession, loadTemplate, initMidi, closeMidi, initGUI, refreshGUI;
	var addQuestion;
	var playModeState,recordModeState;

var noteOnResponder;

	broadcaster = NetAddr("127.0.0.1", NetAddr.langPort);

	// setup
	sessionData.put("keyPaths",Dictionary.new);



	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {

//		loadSession.value(loadTemplate.value(createSession.value()));
		loadSession.value(createSession.value());



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

	noteOnResponder = NoteOnResponder({ |src, chan, num, vel|
			t = sessionData["keyPaths"].findKeyForValue(num.asString).postln;
			p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
			a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);

		},nil,nil,{|val|sessionData["keyPaths"].values.asInteger.includes(val)});

};


recordModeState = {

	var buffer,newPath;

noteOnResponder.remove;
	playerSynth.free;

	// micInputSynth = Synth.new(\sinImpulse);//tester
		micInputSynth = Synth.new(\micInput);//tester
		MIDIdef.noteOn(\noteOnRecordMode, {arg ...args;

		{
		buffer = Buffer.alloc(s,65536,1);
			//create file and start recording
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
			addQuestion.value(newPath,args[1]);
		("Finished recording "++t).postln;
		}.defer(1);


		});

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
		var recordButton;
		var onRecordMsg;
		var recordMode=0;

		window.onClose = ({
			closeMidi.value();
			onRecordMsg.free;
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
					a = (1..127);
					b = sessionData["keyPaths"].collect(_.asInteger);
					c = difference(a,b).choose;

					addQuestion.value(path,c);
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
				0,{playModeState.value();},
				1,{recordModeState.value();
			});

		}.defer;
		// {AppClock.sched(0, {recordButton.valueAction(recordButton.valueAction)})}
	}, '/onRecordMsg');

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

	};




	//------------------------------------------------------
	// BUILD
	//------------------------------------------------------

 	initGUI.value();
 buildSession.value();
	initMidi.value();
// refreshGUI.value();


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





//------------------------------------------------------
// IDEAS
//------------------------------------------------------

pedal as record state : turns on rec button


rename question files
