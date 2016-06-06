(

var window, mainView,newSearchView,stackView,queryView,resultsView,waitingView,playView;
var addStack,removeStack,addResult;
var searchViews = [];
var stackIndexes = [\newSearchIdx,\queryIdx,\waitingIdx,\resultsIdx,\playIdx];

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
playView =({|i|
	View().layout_( HLayout(
		StaticText()
			.string_("PLAY")
		.align_(\center)
			.font_(Font(size:48))
		)
	);
});


//------------------------------------------------------
// queryView
//------------------------------------------------------
queryView =({|i|

	var textFieldAction = {|a|

		searchViews[i].layout.index = stackIndexes.find([\waitingIdx]);

		//freesound basic text search
		FSSound.textSearch(
			query: a.string,
			filter: "duration:[0 TO 10]",
			params:('page':1),
			action: {|p|
				searchViews[i].layout.index = stackIndexes.find([\resultsIdx]);
				p.do({|snd|
					var str = "";
					str = str + snd.name.splitext[0];

					Routine{
						addResult.value(i,str);
						str.postln;
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
	scroll.front;
	scroll.hasHorizontalScroller_(false);

});

///------------------------------------------------------
// addResult
//------------------------------------------------------

addResult =({|i,resultString|

	var makeEntry = {
		var view = View()
			.background_(Color.hsv((0.165*i),1.0,1.0).vary(0.4,0.4,0.9,0.4))
			.layout_( HLayout(
				 Button()
				.states_([[
					resultString,
					Color.black,
					Color.hsv((0.165*i),1.0,1.0).vary(0.4,0.4,0.9,0.4)
				]])
				.action_({
					"PLAY".postln;


					searchViews[i].layout.index = stackIndexes.find([\playIdx]);
				})
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
		playView.()

		)
	);
});

//------------------------------------------------------
// build UI
//------------------------------------------------------
window = Window("",Rect(0,0,Window.screenBounds.width, Window.screenBounds.height/3)
	.center_(Window.availableBounds.center))
	.front;

window.layout = HLayout();

// add our first stack
addStack.(0);




window.onClose = ({


});
CmdPeriod.doOnce({window.close});



)





