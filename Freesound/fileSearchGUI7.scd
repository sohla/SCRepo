// (
// Freesound.clientId = "f2880da706c6d92d7ce3";
// Freesound.clientSecret = "bfa791a021762f7c6cb70088c720855a0c5f8f49";
// Freesound.authType = "oauth2";
// Freesound.refreshToken;
// )


// o = Server.local.options;
// o.outDevice

//
// // Post the number of output channels
//
// o.numOutputBusChannels.postln;
//
// // Set them to a new number
//
// o.numOutputBusChannels = 10; // The next time it boots, this w
//
//

// (
// SynthDef("bufplayerMonoFS", { |bufnum = 0, volume = 0.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
// 	* EnvGen.kr(Env.asr(2.8,1.0,2.8,\sine),gate,doneAction:2) * volume;
//
// 	Out.ar(0, son!2);
// 	//	Out.ar(0, son!2);
// }).load(s);
//
// SynthDef("bufplayerStereoFS", { |bufnum = 0, volume = 0.0, gate = 1|
// 	var son;
// 	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
// 	* EnvGen.kr(Env.asr(2.8,1.0,2.8,\sine),gate,doneAction:2) * volume;
//
// 	Out.ar(0, son);
// 	//	Out.ar(0, son);
// }).load(s);
//
// )
//



(

var window, mainView,newSearchView,stackView,queryView,resultsView,waitingView,playView;
var addStack,removeStack,addResult,switchToStack;
var searchViews = [];
var stackIndexes = [\newSearchIdx,\queryIdx,\waitingIdx,\resultsIdx,\playIdx];
var dir = PathName.new("~/Music/SoundNarative/");
var fastSearch;

//var dirPath = "/Volumes/Steph2015/*".postln;
//var dirPath = "/Volumes/Steph2015/Samples:Loops:SFX/*".postln;
var dirPath = "~/Music/*";

s.boot;

fastSearch = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	// start building find command string
	var cs = ("find % \\(").format(dir);

//	var cs = ("find % -iname \"*%*\" -a \\(").format(dir,searchString);
	var data = 0;


	// itr each word in search string
	searchString.split($ ).do({|ss|
			cs = cs ++ (" -iname \"*%*\" -%").format(ss,"a");//(o)R/(a)ND
	});

	cs = cs.copyFromStart(cs.size-3)++ " \\) -a \\(";

	//cs.postln;

	// add each of the extensions in the find
	fileTypes.split($|).do({|type|type.postln;
		cs = cs ++ " -iname \"*.%\" -o".format(type);
	});
	// remove last -o and complete the command string
	cs = cs.copyFromStart(cs.size-3)++ " \\)";
	// send it off and get results, fast
	data = cs.unixCmdGetStdOutLines;
	data.do({|o,i|itrFunc.(o,i)});
	completeFunc.(data.size);

};

//------------------------------------------------------
// addStack
//------------------------------------------------------
addStack =({|index|
	var view  = stackView.(index);
	searchViews = searchViews.insert(index,view);
	{window.layout.add(searchViews[index]);}.defer;
	"addStack->".post;
	searchViews.postln;
});

//------------------------------------------------------
// removeStack
//------------------------------------------------------
removeStack =({|index|
	searchViews[index].removeAll;
	searchViews[index].remove;
	searchViews = searchViews.put(index,0);// put 0 and never use again!

	"removeStack->".post;
	searchViews.postln;
});

//------------------------------------------------------
// newSearchView
//------------------------------------------------------
newSearchView =({|i|

	var buttonAction = {|a|
		"action".postln;
		searchViews[i].layout.index = stackIndexes.find([\queryIdx]);
		// hack! ever growing array!
		addStack.(i+1);
	};

	View().layout_( HLayout(
		Button()
			.string_("+")
			.font_(Font(size:48))
			.action_(buttonAction)
		)
	);
});

//------------------------------------------------------
// waitingView
//------------------------------------------------------
waitingView =({|i|
	View().layout_( HLayout(
		StaticText()
			.string_("searching.....")
		.align_(\center)
			.font_(Font(size:24))
		)
	);
});

//------------------------------------------------------
// playView
//------------------------------------------------------
playView =({|i,sndResult|

	var buffer,sfv,sliderView,view;
	var samplerNode = s.nextNodeID;

	var cancelButtonAction = {|button|
		s.sendMsg("/n_free", samplerNode);
		buffer.close;
		buffer.free;
		searchViews[i].layout.index = stackIndexes.find([\newSearchIdx]);
		removeStack.(i);

	};

	var buttonAction = {|button|

		button.value.switch(

			1,{"playing...".postln;

			buffer.numChannels.switch(
			1,{s.sendMsg("/s_new", "bufplayerMonoFS", samplerNode, 0, 0,\bufnum, buffer.bufnum);},
			2,{s.sendMsg("/s_new", "bufplayerStereoFS", samplerNode, 0, 0,\bufnum, buffer.bufnum);});
			s.sendMsg("/n_set",samplerNode,\volume,sliderView.value);

			},
			0,{"stopped".postln;
			//s.sendMsg("/n_free", samplerNode);
			s.sendMsg("/n_set",samplerNode,\gate,0);
		});

	};

	var sliderAction = {|slider|
		s.sendMsg("/n_set",samplerNode,\volume,slider.value);

	};

	var onBufferRead = {|localBuf|
		localBuf.loadToFloatArray(action:{ |data|
			{
				sfv.setData(data,
					512,// QT not using this
					0,
					localBuf.numChannels,
					localBuf.sampleRate.asInteger // need to cast!?!
				);
				view.enabled_(true);
			}.defer;
		});
	};

	// //• encapsulate as a service (either freesound or a HD)

	//• sndResult could be a path to local path or URL to freesound
	//• if it's freesound, need to download, process mp3->local
	//• local->buffer...let's go!





//	buffer = Buffer.read(s, sndResult,action:onBufferRead);

	// load sound into buffer





	sndResult.retrievePreview(dir.asAbsolutePath,{|a|
		"*".postln;
		sndResult.postln;
		p = dir +/+ PathName(sndResult.name.splitext[0]++".mp3");
		buffer = MP3.readToBuffer(s, p.asAbsolutePath,action:onBufferRead);
	},"hq","mp3");


	view = View().layout_(
	GridLayout.rows(
			[
				Button()
					.states_([["cancel"]])
					.maxWidth_(50)
					.minHeight_(30)
					.action_({|b|cancelButtonAction.(b)}),

				StaticText()
					.string_(sndResult.name.splitext[0])
					.align_(\center)
					.font_(Font(size:24)),
				
				Button()
					.minHeight_(30)
					.maxWidth_(50)
					.states_([
						["Play"],
						["Stop",Color.black,Color.green.alpha_(0.3)]])
					.action_({|b|buttonAction.(b)}),

				
				StaticText().string_("volume"),
				
				sliderView = Slider()
					.orientation_(\horizontal)
					.maxHeight_(40)
					.value_(0.5)
					.action_({|a|sliderAction.(a)});



			],[
				[sfv = SoundFileView()
					.maxHeight_(120)
					.gridOn_(false)
					.backColor_(Color.white.alpha_(0.7))
					.rmsColor_(Color.blue.alpha_(0.4))
					.peakColor_(Color.blue.alpha_(0.3))
					//.selectionColor_(0, Color.black.alpha_(0.2))

					,columns:5],



		]
	).setMinColumnWidth(1,350)
	).enabled_(false)
	.background_(Color.rand(0.1,0.9))
	.maxHeight_(200)




	// view = View().layout_(
	// GridLayout.rows(
	// 		[
	// 			Button()
	// 				.states_([["cancel"]])
	// 				.maxWidth_(50)
	// 				.action_({|b|cancelButtonAction.(b)}),

	// 			StaticText()//• name vs basename
	// 				.string_(sndResult.name.splitext[0])
	// 				.align_(\center)
	// 				.font_(Font(size:24))
	// 		],[
	// 			[sfv = SoundFileView()
	// 				.maxHeight_(120)
	// 				.gridOn_(false)
	// 				.backColor_(Color.grey)
	// 				.rmsColor_(Color.blue.alpha_(0.4))
	// 				.peakColor_(Color.blue.alpha_(0.3))
	// 				//.selectionColor_(0, Color.black.alpha_(0.2))

	// 				,columns:2]


	// 	],[
	// 			[Button()
	// 				.minHeight_(40)
	// 				.states_([
	// 					["Play"],
	// 					["Stop",Color.black,Color.green.alpha_(0.3)]])
	// 				.action_({|b|buttonAction.(b)})

	// 			,columns:2]

	// 	],
	// 		// [
	// 		//
	// 		// 	CheckBox().string_("auto-fade"),
	// 		// 	CheckBox().string_("loop")
	// 		//
	// 		//
	// 		// ],
	// 		[
	// 			StaticText().string_("volume").maxWidth_(100),
	// 			sliderView = Slider()
	// 				.orientation_(\horizontal)
	// 				.maxHeight_(40)
	// 				.value_(0.5)
	// 				.action_({|a|sliderAction.(a)});

	// 	]
	// )
	// ).enabled_(false);




});


//------------------------------------------------------
// queryView
//------------------------------------------------------
queryView =({|i|

	var textFieldAction = {|a|

		searchViews[i].layout.index = stackIndexes.find([\waitingIdx]);

		//• HD version
		//• time to start making a protocol
		//•
		//• either search should return data including path, channels, length, shape?
		//• soundInfo structure should be passed on to results view
		//searchViews[i].layout.index = stackIndexes.find([\resultsIdx]);

		// fastSearch.(
		// 	dirPath,
		// 	"wav|wave|aif|aiff",
		// 	a.string,// using '.' will give every file
		// 	{|a,count|
		//
		// 		//[i,a].postln;
		// 		//Routine{
		// 		addResult.(i,a,count);
		// 		//}.play(AppClock);
		//
		// 	},
		// 	{|c|("sound files found"+c).postln;
		// 	}
		// );

		//• encapsulate as a service (either freesound or a HD)

		//freesound basic text search

		Freesound.defaultFields =
			"id,name,tags,username,license,previews,channels,images,type,download,duration";

		FSSound.textSearch(
			query: a.string,
			filter: "duration:[0 TO 30]",
			params:('page':1),
			action: {|p|
				var count = 0;
				searchViews[i].layout.index = stackIndexes.find([\resultsIdx]);
				p.do({|snd|

					Routine{
						addResult.(i,snd,count);
						count = count + 1;
					}.play(AppClock);

				});
			}
		);
	};

	View().layout_( VLayout(
		TextField()
			.string_("")
			.align_(\center)
			.font_(Font(size:48))
			.stringColor_(Color.red)
			.focusGainedAction_({|a|a.string ="";})//always clear
			.action_(textFieldAction)
		)
	);

});

//------------------------------------------------------
// resultsView
//------------------------------------------------------
resultsView =({|i|

	var scroll = ScrollView(bounds:Rect(0,50,500,300).center_(Window.availableBounds.center));
	var canvas = View();
	var button;
	var layout;

	canvas.layout = VLayout();
	button = Button().states_([["cancel"]]).action_({
		searchViews[i].layout.index = stackIndexes.find([\newSearchIdx]);
		removeStack.(i);
	}).maxWidth_(50);

	canvas.layout.add(nil); // stretch remaining empty space

	scroll.canvas = canvas;
	//scroll.front;
	scroll.hasHorizontalScroller_(false);

	View().layout_( VLayout(
			button,
			scroll
		)
	);

});//------------------------------------------------------
// addResult
//------------------------------------------------------

addResult =({|i,sndResult,count|


	var buttonAction = {|button|

		searchViews[i].layout.add(playView.(i,sndResult).front);
		searchViews[i].layout.index = stackIndexes.find([\playIdx]);
	};

	var makeEntry = {
		var view = View()
			.background_(Color.hsv((0.165*i),1.0,1.0).vary(0.4,0.4,0.9,0.4))
			.layout_( HLayout(
				 Button()
				.states_([[
				count +"\t"+ sndResult.name.splitext[0] +
				"\nDur:" + sndResult.duration,//•name
					Color.black,
					Color.hsv((0.165*i),1.0,1.0).vary(0.4,0.4,0.9,0.4)
				]])
				.action_(buttonAction)
				.minHeight_(80)
				.maxWidth_(100),
				
				WebView().url_(sndResult.images.dict["waveform_l"])
				.maxWidth_(360)
				.enabled_(false)
	        )
	    );
		view.layout.margins = [0,0,0,0];
	    view;
	};

	searchViews[i].children(View)[3].children(ScrollView)[0].canvas.layout.add( makeEntry.() );

	//searchViews[i].children(ScrollView)[0].canvas.layout.add( makeEntry.() );
	//sndResult.images.dict["waveform_l"].postln;
});

//------------------------------------------------------
// stackView
//------------------------------------------------------
stackView =({|i|

	View().layout_( StackLayout(
			newSearchView.(i),
			queryView.(i),
			waitingView.(i),
			resultsView.(i),
			//playView.(i)

		)
	);
});

//------------------------------------------------------
// build UI
//------------------------------------------------------
window = Window("",Rect(0,0,Window.screenBounds.width * 0.7, Window.screenBounds.height)
	//.center_(Window.availableBounds.center)
	).front;

window.layout = VLayout();

// add our first stack
addStack.(0);




window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});



)





