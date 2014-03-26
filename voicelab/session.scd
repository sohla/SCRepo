

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
	var buildSession, initMidi, closeMidi, initGUI;




	//------------------------------------------------------
	//
	//------------------------------------------------------
	buildSession = {


		// generate session dir name

		// create all the dirs
		var sessionDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle);
		var quesiotnsDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle+/+"Questions");
		var answersDir = File.mkdir(appPath.asAbsolutePath+/+sessionTitle+/+"Answers");


		var templateSounds = [];

		// load a template (json)
		var jsonFile = File(appPath.asAbsolutePath+/+"template.json","r");
		var templateData = jsonFile.readAllString.parseYAML;

		// save data as achive inside session dir
		var sessionArchivePath = appPath.asAbsolutePath+/+sessionTitle+/+"session";

		templateData.writeArchive(sessionArchivePath);

		// re-read data into sessionData
		sessionData = Object.readArchive(sessionArchivePath);

		sessionData["keyPaths"]["1"].postln;
		// get list of template sounds
		SoundFile.collect(appPath.asAbsolutePath+/+"templateQuestions/*").do{ |f,i|

			var newPath = appPath.asAbsolutePath+/+sessionTitle+/+"Questions";
			templateSounds = templateSounds.add(f.path);
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

			//[src, chan, num, vel].postln;

			t = sessionData["keyPaths"][num.asString].postln;
			p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
			a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);

		},nil,nil,{ |val|sessionData["keyPaths"].keys.includes(val.asString)});



		NoteOffResponder({ |src, chan, num, vel|
		//	[src, chan, num, vel].postln;

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

		var window = Window.new("",Rect(50, 50, 700, 440)).front;
		var listview;

		window.onClose = ({
			closeMidi.value();
		});

		window.view.decorator = FlowLayout( window.view.bounds, 10@10, 10@10 );
		listview = EZListView.new(window,
		    400@400,
		    "Questions:",nil,
		    globalAction: { |a| ("this is a global action of "++a.asString ).postln },
		    initVal: 0,
		    initAction: false,
		   	labelWidth: 120,
		    labelHeight: 32,
		    layout: \vert,
		    gap: 8@8,
			margin: 16@16
	    );

		listview.font = Font("Helvetica", 18);

		sessionData["keyPaths"].do({ |o|
			o.value.postln;
			listview.addItem(o.value);

		});


		b = Button(window, 50@50)
	        .states_([
	            ["PLAY", Color.black, Color.green]
	        ])
	        .action_({ arg butt;
	            listview.value.postln;
		t = sessionData["keyPaths"].asArray.at(listview.value).postln;
				p = appPath.asAbsolutePath+/+sessionTitle+/+"Questions"+/+t;
				a = Synth(\playBuffer,[\buffer,Buffer.read(s, p)]);

	        });
	};


	//------------------------------------------------------
	// BUILD
	//------------------------------------------------------



	buildSession.value();
	initGUI.value();
	initMidi.value();



)



a = [ \a->123,\b->345345]
a.at(0)
a.do({ |o|
o.value.postln;
})