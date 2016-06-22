(
(
SynthDef("bufplayerMono", { |bufnum = 0, amp = 1.0, gate = 1|
	var son;
	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * 1,loop:1,doneAction:0)
	* EnvGen.kr(Env.asr(0.02,1.0,0.1,\sine),gate,doneAction:0) * amp;

	Out.ar(0, son!2);
	//	Out.ar(0, son!2);
}).load(s);

SynthDef("bufplayerStereo", { |bufnum = 0, amp = 1.0, gate = 1|
	var son;
	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum) * 1,loop:1,doneAction:0)
	* EnvGen.kr(Env.asr(0.02,1.0,0.1,\sine),gate,doneAction:0) * amp;

	Out.ar(0, son);
	//	Out.ar(0, son);
}).load(s);

)


//----




(
var window;
var nodes = [], buffers = [];
var soundFiles = [];

var defaultPath = PathName.new("~/Music/SCSamples/mmsingloops2");
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
		//.center_(Window.availableBounds.center)
	)
	.front;

	window.layout = GridLayout();


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
		var state = false;
		var cols = 3;
		Buffer.read(s, file.absolutePath,action:{|buf|

		// buffers = buffers.add(buf);
		// nodes = nodes.add(node);
			buf.numChannels.switch(
				1,{s.sendMsg("/s_new", "bufplayerMono", node, 0, 0,
					\bufnum, buf.bufnum,\gate,0.0);},
				2,{s.sendMsg("/s_new", "bufplayerStereo", node, 0, 0,
					\bufnum, buf.bufnum,\gate,0.0);

			});

			MIDIFunc.noteOn({ |vel, num|

				{
				window.view.children[i].background_(window.view.children[i].background.alpha_(1));
				}.defer;
				s.sendMsg("/n_set",node,\gate,1.0);
				// s.sendMsg("/n_set",node,\gate,state.not);
			},48+i);


			MIDIFunc.noteOff({ |vel, num|
				{
				window.view.children[i].background_(window.view.children[i].background.alpha_(0.3));
			}.defer;
				s.sendMsg("/n_set",node,\gate,0.0);

				// s.sendMsg("/s_get",node, \gate);
				// OSCpathResponder(s.addr, ['/n_set', node], { |time, resp, msg|
				// 	state = msg[3].asBoolean;
				// 	resp.remove;
				// }).add;

			},48+i);

		});

		[i,node].postln;


		window.layout.add(
			StaticText()
			.background_(Color.rand.alpha_(0.3))
				.string_(file.absolutePath.basename.splitext[0])
				.align_(\center),
			(i/cols).floor,
			i%cols);

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