// (
// (
// SynthDef("bufplayerMono", { |bufnum = 0, amp = 1.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * 1.0,loop:1,doneAction:0)
// 	* EnvGen.kr(Env.asr(0.02,1.0,0.1,\sine),gate,doneAction:0) * amp;
//
// 	Out.ar(0, son!2);
// }).load(s);
//
// SynthDef("bufplayerStereo", { |bufnum = 0, amp = 1.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum) * 1.0,loop:1,doneAction:0)
// 	* EnvGen.kr(Env.asr(0.02,1.0,0.1,\sine),gate,doneAction:0) * amp;
//
// 	Out.ar(0, son);
// }).load(s);
//
// )
//

//----




(
var window;
var nodes = [], buffers = [];
var soundFiles = [];

var defaultPath = PathName.new("~/Music/SCSamples/mmsingloops17");
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
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
	.center_(Window.availableBounds.center)
	)
	.front;

	window.layout = GridLayout();


	window.onClose = ({

		MIDIdef.freeAll;
		MIDIClient.disposeClient;
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
		var cols = 3;
		var state = false;


		Buffer.read(s, file.absolutePath,action:{|buf|

			// buffers = buffers.add(buf);
			// nodes = nodes.add(node);
			buf.numChannels.switch(
				1,{s.sendMsg("/s_new", "bufplayerMono", node, 0, 0,
					\bufnum, buf.bufnum,\gate,0.0);},
				2,{s.sendMsg("/s_new", "bufplayerStereo", node, 0, 0,
					\bufnum, buf.bufnum,\gate,0.0);

			});

			MIDIdef.noteOn("ON"+i,{ |vel, num|

				["ON",i,num,vel].postln;

				{window.view.children[i].background_(window.view.children[i].background.alpha_(1));}.defer;

				s.sendMsg("/n_set",node,\gate,1.0);

			},36+i);

			MIDIdef.noteOff("OFF"+i,{ |vel, num|
				["OFF",i,num,vel].postln;
{window.view.children[i].background_(window.view.children[i].background.alpha_(0.3));}.defer;

					s.sendMsg("/n_set",node,\gate,0.0);

			},36+i);






		});

		//[i,node].postln;


		window.layout.add(
			StaticText()
			.background_(Color.rand.alpha_(0.3))
			.string_(file.absolutePath.basename.splitext[0])
			.align_(\center),

			(i/cols).floor,
			i%cols);

	});

	window.view.keyDownAction_({ |view,char,mod,uc,kc,key|
		//MIDISim.control(0,0,key+63,0);
	});
	window.view.keyUpAction_({ |view,char,mod,uc,kc,key|
		//MIDISim.control(0,0,key+63,127);
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



