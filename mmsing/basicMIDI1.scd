// (
// SynthDef("bufplayerMono", { |bufnum = 0, amp = 0.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
// 	* EnvGen.kr(Env.asr(2.8,1.0,2.8,\sine),gate,doneAction:2) * amp;
//
// 	Out.ar(0, son!2);
// 	//	Out.ar(0, son!2);
// }).load(s);
//
// SynthDef("bufplayerStereo", { |bufnum = 0, amp = 0.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
// 	* EnvGen.kr(Env.asr(2.8,1.0,2.8,\sine),gate,doneAction:2) * amp;
//
// 	Out.ar(0, son);
// 	//	Out.ar(0, son);
// }).load(s);
//
// )


// folder selection
// grab all samples in folder -> to buffers
// layout buffers->synths->midi note

//----




(
var window;
var nodes = [], buffers = [];
var soundFiles = [];

var defaultPath = PathName.new("~/Music/SCSamples/mmsingloops1");
var soundsPath = defaultPath;

var openFolderDialog, onFolderPath;
var buildWindow,buildMIDI;
//------------------------------------------------------
// UI
//------------------------------------------------------

buildWindow = ({

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/3,
		Window.screenBounds.height/3)
		//.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});

});


//------------------------------------------------------
// FILES
//------------------------------------------------------

onFolderPath = ({|path|

	buildWindow.();

	path.filesDo({|file,i|

		var node = s.nextNodeID;

		Buffer.read(s, file.absolutePath,action:{|buf|

		// buffers = buffers.add(buf);
		// nodes = nodes.add(node);
			buf.numChannels.switch(
				1,{s.sendMsg("/s_new", "bufplayerMono", node, 0, 0,
					\bufnum, buf.bufnum,\amp,1.0);},
				2,{s.sendMsg("/s_new", "bufplayerStereo", node, 0, 0,
					\bufnum, buf.bufnum,\amp,1.0);

			});

			MIDIFunc.noteOn({ |vel, num|
				s.sendMsg("/n_set",node,\amp,1.0);
			},48+i);


			MIDIFunc.noteOff({ |vel, num|
				s.sendMsg("/n_set",node,\amp,1.0);
			},48+i);

		});

		[i,node].postln;

	});

});


openFolderDialog = ({|onSuccess|

FileDialog.new(
	okFunc:{ |paths| onSuccess.(paths.first)},
	fileMode:2);
});

soundsPath.isNil.if(
	{openFolderDialog.(onFolderPath)},
	{onFolderPath.(defaultPath)}
);


//------------------------------------------------------
// MIDI
//------------------------------------------------------
buildMIDI = ({

MIDIClient.init;
MIDIIn.connectAll;

});

buildMIDI.();

)