// (
// Freesound.clientId = "f2880da706c6d92d7ce3";
// Freesound.clientSecret = "bfa791a021762f7c6cb70088c720855a0c5f8f49";
// Freesound.authType = "oauth2";
// Freesound.refreshToken;
// )
//
(

var window, mainView,newSearchView,stackView,queryView,resultsView,waitingView,playView;
var addStack,removeStack,addResult,switchToStack;
var searchViews = [];
var stackIndexes = [\newSearchIdx,\queryIdx,\waitingIdx,\resultsIdx,\playIdx];
var dir = PathName.new("~/Music/SoundNarative/");

s.boot;
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

	var buffer,sfv,slider,view;

	var cancelButtonAction = {|button|
		buffer.close;
		buffer.free;
		searchViews[i].layout.index = stackIndexes.find([\newSearchIdx]);
		removeStack.(i);

	};

	var playButtonAction = {|button|

		// buffer.numChannels.switch(
		//
		// 	1,{s.sendMsg("/s_new", "bufplayerMono", 1001, 0, 0,\bufnum, buffer.bufnum);},
		// 	2,{s.sendMsg("/s_new", "bufplayerStereo", 1001, 0, 0,\bufnum, buffer.bufnum);}
		//
		// );

	};


	//• encapsulate as a service (either freesound or a HD)
	sndResult.retrievePreview(dir.asAbsolutePath,{|a|
		"*".postln;
		sndResult.postln;
		p = dir +/+ PathName(sndResult.name.splitext[0]++".mp3");
		buffer = MP3.readToBuffer(s, p.asAbsolutePath,action:{|a|


			Routine{
				buffer.loadToFloatArray(action:{ |data|

					{
						sfv.setData(data,
							512,// QT not using this
							0,
							buffer.numChannels,
							buffer.sampleRate.asInteger // need to cast!?!
						);

					view.enabled_(true);
					}.defer;




				// slider.action_({|c|
				// 	s.sendMsg("/n_set",1001,\volume,c.value);
				// });

			});

			}.play(AppClock);
		});
	},"hq","mp3");


	view = View().layout_(
	GridLayout.rows(
			[
				Button()
					.states_([["cancel"]])
					.maxWidth_(50)
					.action_({|b|cancelButtonAction.(b)}),

				StaticText()
					.string_(sndResult.name.splitext[0])
					.align_(\center)
					.font_(Font(size:24))
			],[
				[sfv = SoundFileView()
					.maxHeight_(120)
					.gridOn_(false)
					.backColor_(Color.grey)
					.rmsColor_(Color.blue.alpha_(0.4))
					.peakColor_(Color.blue.alpha_(0.3))
					//.selectionColor_(0, Color.black.alpha_(0.2))

					,columns:2]


		],[
				[Button()
					.minHeight_(40)
					.states_([["Play"]])
					.action_({|b|playButtonAction.(b)})

				,columns:2]

		],[

				CheckBox().string_("auto-fade"),
				CheckBox().string_("loop")


		],[
				StaticText().string_("volume").maxWidth_(100),
				Slider()
					.orientation_(\horizontal)
					.maxHeight_(40)
					.value_(1.0)

		]
	)
	).enabled_(false);




});


//------------------------------------------------------
// queryView
//------------------------------------------------------
queryView =({|i|

	var textFieldAction = {|a|

		searchViews[i].layout.index = stackIndexes.find([\waitingIdx]);

		//• encapsulate as a service (either freesound or a HD)

		//freesound basic text search
		FSSound.textSearch(
			query: a.string,
			filter: "duration:[0 TO 10]",
			params:('page':1),
			action: {|p|
				searchViews[i].layout.index = stackIndexes.find([\resultsIdx]);
				p.do({|snd|

					Routine{
						addResult.(i,snd);
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
	var layout;

	canvas.layout = VLayout();
	canvas.layout.add(Button().states_([["cancel"]]).action_({
		searchViews[i].layout.index = stackIndexes.find([\newSearchIdx]);
		removeStack.(i);
	}).maxWidth_(50));

	canvas.layout.add(nil); // stretch remaining empty space

	scroll.canvas = canvas;
	//scroll.front;
	scroll.hasHorizontalScroller_(false);

});
//------------------------------------------------------
// addResult
//------------------------------------------------------

addResult =({|i,sndResult|


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
					sndResult.name.splitext[0],
					Color.black,
					Color.hsv((0.165*i),1.0,1.0).vary(0.4,0.4,0.9,0.4)
				]])
				.action_(buttonAction)
				.minHeight_(80)
	        )
	    );
		view.layout.margins = [0,0,0,0];
	    view;
	};

	searchViews[i].children(ScrollView)[0].canvas.layout.add( makeEntry.() );

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
window = Window("",Rect(0,0,Window.screenBounds.width, Window.screenBounds.height/3)
	.center_(Window.availableBounds.center)
	).front;

window.layout = HLayout();

// add our first stack
addStack.(0);




window.onClose = ({


});
CmdPeriod.doOnce({window.close});



)





