

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
	var sessionTitle = date.format("%A_%d:%m:%Y_%R:%S");
	var appPath = PathName.new("~/Music/VoiceLab");



	//------------------------------------------------------
	// FUNCTIONS
	//------------------------------------------------------
	var buildSession, initMidi, closeMidi, initGUI, refreshGUI;




	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {


		// generate session dir name

		// create all the dirs
		var sessionDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle);
		var quesiotnsDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle+/+"Questions");
		var answersDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle+/+"Answers");


	// var templateSounds = [];

		// load a template (json)
		var jsonFile = File(appPath.asAbsolutePath+/+"template.json","r");
		var templateData = jsonFile.readAllString.parseYAML;

		// save data as achive inside session dir
		var sessionArchivePath = appPath.asAbsolutePath+/+sessionTitle+/+"session";

		templateData.writeArchive(sessionArchivePath);

		// re-read data into sessionData
		sessionData = Object.readArchive(sessionArchivePath);

		//sessionData["keyPaths"]["1"].postln;
		// get list of template sounds
		SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

			var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
		// templateSounds = templateSounds.add(f.path);
			//("\""++i++"\""+":"++"\""++f.path.basename++"\""++",").postln;
			SoundFile.normalize(f.path,newPath+/+f.path.basename);
		};

		// ready to play
		"Ready to play!".postln;

		//sessionData["keyPaths"][5.asString].postln;
		//soundBuffers.postln;

		jsonFile.close;
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

	closeMidi = {
		NoteOnResponder.removeAll;
		NoteOffResponder.removeAll;

	};


	//------------------------------------------------------
	// UI
	//------------------------------------------------------


	initGUI = {

		var window = Window.new("",Rect(50, 50, 600, 500)).front;
		var listView, numberView,importButton;

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


		b = Button(window, 100@50)
	        .states_([
	            ["PLAY", Color.black, Color.green]
	        ])
	        .action_({ arg butt;
	            listView.value.postln;
				t = listView.items.at(listView.value).key;
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);
	        });

importButton = Button(window, 150@50)
	        .states_([
	            ["Import Question", Color.black, Color.grey]
	        ])
	        .action_({ arg butt;

		File.openDialog("Select an awesome new question",{|path|


			// copy this file to our questions dir
			var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
			SoundFile.normalize(path,newPath+/+path.basename);


			//•••NOW WHAT?
			// sessionData["keyPaths"].postln;
			//refreshGUI.value(listView,numberView);
			},{
				// cancel;


		});

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

	refreshGUI = { |listView,numberView|

		listView.items = Array.newClear;

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


a = [ ("1.welcomeToVoiceLab.wav" -> 64), ("10.whatMakesYouLaugh.wav" -> 73)]

