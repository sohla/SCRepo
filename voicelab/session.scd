

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
)


(

	//------------------------------------------------------
	// GLOBALS
	//------------------------------------------------------
	var sessionData;
	var date = Date.getDate;
	var appPath = PathName.new("~/Music/VoiceLab");
	var sessionTitle;



	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var buildSession, loadSession, createSession, initMidi, closeMidi, initGUI, refreshGUI;




	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {

		loadSession.value(createSession.value().postln);


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
	createSession = {

		var genTitle= date.format("%A_%d:%m:%Y_%R:%S");
			// create all the dirs
		var sessionDir = File.mkdir(appPath.asAbsolutePath+/+genTitle);
		var quesiotnsDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Questions");
		var answersDir = File.mkdir(appPath.asAbsolutePath+/+genTitle+/+"Answers");

	// load a template (json)
		var jsonFile = File(appPath.asAbsolutePath+/+"template.json","r");
		var templateData = jsonFile.readAllString.parseYAML;

		// save data as achive inside session dir
		var sessionArchivePath = appPath.asAbsolutePath+/+genTitle+/+"session";
		templateData.writeArchive(sessionArchivePath);

		jsonFile.close;

		// get list of template sounds
		SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

			var newPath = appPath.asAbsolutePath+/+genTitle+/+"Questions";
			SoundFile.normalize(f.path,newPath+/+f.path.basename);
		};

		// return path
		sessionArchivePath;
	};

	//------------------------------------------------------
	// MIDI
	//------------------------------------------------------

	initMidi = {
		MIDIClient.init;
		MIDIIn.connectAll;

		NoteOnResponder({ |src, chan, num, vel|

			t = sessionData["keyPaths"].findKeyForValue(num.asString).postln;
			p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
			a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);

		},nil,nil,{|val|sessionData["keyPaths"].values.asInteger.includes(val)});

		NoteOffResponder({ |src, chan, num, vel|
		});

	};

	//------------------------------------------------------
	closeMidi = {
		NoteOnResponder.removeAll;
		NoteOffResponder.removeAll;

	};


	//------------------------------------------------------
	// UI
	//------------------------------------------------------


	initGUI = {

		var window = Window.new("",Rect(50, 50, 600, 500)).front;
		var listView, numberView,playButton,importButton, deleteButton;

		window.onClose = ({
			closeMidi.value();
		});

		window.view.decorator = FlowLayout( window.view.bounds, 10@10, 10@10 );

		listView = EZListView.new(window,
		    550@400,
		    "Questions:",nil,
			globalAction:nil,
		    initVal: 0,
		    initAction: true,
		   	labelWidth: 100,
		    labelHeight: 20,
		    layout: \vert,
		    gap: 8@8,
			margin: 16@16
	    );

		listView.font = Font("Helvetica", 18);

		numberView = EZNumber(window,
             150@20,
             "note",
             ControlSpec(0, 127, \lin, 1, 64, "MidiNote"),
             nil,
		      64,
             false
		);


		playButton = Button(window, 100@50)
	        .states_([["PLAY", Color.black, Color.green]])
	        .action_({ arg butt;
	            listView.value.postln;
				t = listView.items.at(listView.value).key;
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);
	        });

		importButton = Button(window, 120@50)
	        .states_([["Import Question", Color.black, Color.grey]])
	        .action_({ arg butt;

				File.openDialog("Select an awesome new question",{|path|

					// copy this file to our questions dir
					var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
					SoundFile.normalize(path,newPath+/+path.basename);

					// we have to copy the dict since parseYAML returns an unmutable collection!!
					n = Dictionary.newFrom(sessionData["keyPaths"]);

					// generate a unique note number
					a = (1..127);
					b = sessionData["keyPaths"].collect(_.asInteger);
					c = difference(a,b).choose;

					// insert new question into datastore
					n.put(path.basename,c.asString);
					sessionData["keyPaths"]  = n;

					p = appPath.asAbsolutePath+/+sessionTitle+/+"session";
					sessionData.writeArchive(p);
					sessionData = Object.readArchive(p);

					refreshGUI.value(listView,numberView);
				},{
					// cancel file open dialog
				});
			});


		deleteButton = Button(window, 120@50)
	        .states_([["Delete Question", Color.black, Color.red]])
	        .action_({ arg butt;

				var key = listView.items.at(listView.value).key;
				var path = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+key;

		if(File.exists(path),{

			File.delete(path);

			sessionData["keyPaths"].removeAt(key.asString);
			p = appPath.asAbsolutePath+/+sessionTitle+/+"session";
			sessionData.writeArchive(p);
			sessionData = Object.readArchive(p);

			refreshGUI.value(listView,numberView);

		},{
				("Error : Can't find Question to delete").postln;
		});

				// we have to copy the dict since parseYAML returns a unmutable collection!!
				// n = Dictionary.newFrom(sessionData["keyPaths"]);
				// n.put(path.basename,1.asString);
				// sessionData["keyPaths"]  = n;
				//
				// p = appPath.asAbsolutePath+/+sessionTitle+/+"session";
				// sessionData.writeArchive(p);
				// sessionData = Object.readArchive(p);
				//
				// refreshGUI.value(listView,numberView);
			});




	// finished building ui
		refreshGUI.value(listView,numberView);

		numberView.action_({ |ez|

			t = listView.items.at(listView.value).key;
			if( sessionData["keyPaths"].findKeyForValue(ez.value.asString) == nil ,{

				sessionData["keyPaths"].removeAt(t.asString);
				sessionData["keyPaths"].put(t.asString,ez.value.asString);
			 	refreshGUI.value(listView,numberView);

			},{
				ez.value = sessionData["keyPaths"].at(t.asString);
			});
		});


	};

	//------------------------------------------------------
	refreshGUI = { |listView,numberView|

		// clear listView
		listView.items = Array.newClear;

		// repopulate in order of assigned midi note
		sessionData["keyPaths"].values.asSortedList.do({ |val|
			t = sessionData["keyPaths"].findKeyForValue(val.asString);
			listView.addItem(t,{
				numberView.value_(val);
			});
		});
	};

	//------------------------------------------------------
	// BUILD
	//------------------------------------------------------

	buildSession.value();
 	initGUI.value();
 	initMidi.value();



)


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

