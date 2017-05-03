(
o = Server.local.options;
o.device = "MOTU UltraLite"
o.device
o.numOutputBusChannels = 8
o.numOutputBusChannels
o.numInputBusChannels = 8
o.numInputBusChannels
o.sampleRate = 48000
o.sampleRate

s.quit
s.boot
)

(
SynthDef("tlsq1",{ |out=0, inputBus = 1, gain = 1, time = 0.5, fb = 0.95|

	var input, fBLoopIn, fBLoopOut, processing, filter;

	input = AudioIn.ar(inputBus) * gain;

	filter = HPF.ar(input,90.0);

	fBLoopIn =LocalIn.ar(1);


	processing = filter +LeakDC.ar((DelayC.ar(fBLoopIn,3.5, time,fb)));

	fBLoopOut=LocalOut.ar(processing);
	Out.ar([0,1], processing)



}).send(s);
)

(
var window,playerView;
var playerButtons = [];
var synths = [0,0,0,0,0];
var midiFunc, resetFunc, reset;

//------------------------------------------------------
// newSearchView
//------------------------------------------------------
playerView =({|index,name|

	var onButtonAction = {|a|
		var time;
		var zoeAmp = 1;
		time = [0.25,0.5,1.0,2.0,4.0].choose;


		a.states = [[time.asStringPrec(2),Color.white,Color.blue.vary(3,0.3,0.8)]];

		if(synths[index] != 0,{
			("free synth ["++synths[index].nodeID++"]").postln;
			synths[index].free;
			synths[index] = 0;
		},{});


		if( (name == "Biddy"),{
			zoeAmp = 1.0;

			});
		synths[index] = Synth(\tlsq1,[\inputBus,index,\gain,zoeAmp,\time,time,\fb,0.9]);
		("new synth ["++synths[index].nodeID++"] for "++name).postln;

		s.queryAllNodes;

	};



	var but = Button()
		.minHeight_(Window.screenBounds.height/2)
		.states_([["Off",Color.white,Color.black]])
		.font_(Font(size:120))
		.action_(onButtonAction);

	playerButtons = playerButtons.add(but);


	View().layout_( VLayout(
		StaticText()
			.string_(name)
			.font_(Font(size:48))
			.align_(\center)
		,but)
	).background_(Color.green.vary(0.5,0.2,0.7));
});

//------------------------------------------------------
// build UI
//------------------------------------------------------

MIDIIn.connectAll;




window = Window("",Rect(0,0,Window.screenBounds.width, Window.screenBounds.height/3)
	.center_(Window.availableBounds.center))
	.front;

window.layout = HLayout(
	playerView.(1,"Lizzy"),
	playerView.(2,"Stephë"),
	playerView.(3,"Biddy"),
	playerView.(4,"Zoë")

);

reset = {
	
	playerButtons.do({|button,index|
		button.states = [["Off",Color.white,Color.black]];
	});
		
	synths.do({|synth,index|
		if(synth != 0,{
			("free synth ["++synth.nodeID++"]"++index).postln;
			synth.free;
			synths[index] = 0;
		},{});
	});

	s.queryAllNodes;

};

midiFunc = MIDIFunc.noteOn({arg ...args;
	var index = 4.rand;
	{playerButtons[index].valueAction = 1;}.defer;
},67);


resetFunc = MIDIFunc.noteOff({arg ...args;
	{reset.()}.defer;	
},70);

window.view.keyDownAction_({|view,char,mod,unicode,keycode|

	if( (keycode >= 18) && (keycode <= 21),{
		playerButtons[keycode-18].valueAction = 1;
	});

	// r - reset
	if ( (keycode == 15),{
		reset.();
	});

	// q - random all 4
	if ( (keycode == 12),{
		var index = 4.rand;
		{playerButtons[index].valueAction = 1;}.defer;
	});

});

window.onClose = ({

	synths.do({|a|
		a.free;

	});
	midiFunc.free;
	resetFunc.free;

});
CmdPeriod.doOnce({window.close});



)

