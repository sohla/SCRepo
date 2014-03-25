
(
SynthDef(\playBuffer, {|buffer = 0, note = 69|



	var player;
	var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
	 player = PlayBuf.ar(buffer.numChannels,buffer,(note.midicps / 440.0) * BufRateScale.kr(buffer), doneAction:2);
	Out.ar(0,[player,player]);

}).send(s);
)


(

	var appPath = PathName.new("~/Music/VoiceLab");

	// generate session dir name
	var date = Date.getDate;
	var sessionTitle = date.format("%A_%d:%m:%Y_%R:%S");

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
	var sessionData;

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


)
(
NoteOnResponder.removeAll;
NoteOffResponder.removeAll;
)



a = [4,76,2,99,1].asSortedList.array.includes(1)
