(

var window, mainView,newSearchView,stackView,queryView,resultsView,addStack,removeStack;
var searchViews = [];
//------------------------------------------------------
// addStack
//------------------------------------------------------
addStack =({|i|
	var view  = stackView.(i);
	searchViews = searchViews.add(view);
	window.layout.add(searchViews[i]);
});

//------------------------------------------------------
// removeStack
//------------------------------------------------------
removeStack =({|i|
	searchViews[i].removeAll;
	searchViews[i].remove;
	searchViews = searchViews.put(i,nil);
});

//------------------------------------------------------
// newSearchView
//------------------------------------------------------
newSearchView =({|i|
	View().layout_( HLayout(
		Button()
			.string_("+")
			.font_(Font(size:48))
			.action_({|a|
				"action".postln;
				searchViews[i].layout.index = 1;
				addStack.(i+1);
			})
		)
	);
});

//------------------------------------------------------
// queryView
//------------------------------------------------------
queryView =({|i|

	View().layout_( VLayout(
		TextField()
			.string_("")
			.align_(\center)
			.font_(Font(size:48))
		.stringColor_(Color.red)
			.action_({|a|
				"action".postln;
				searchViews[i].layout.index = 2;
			})
			.focusGainedAction_({|a|
				a.string ="";//always clear
			})

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
	var count = 0;

	var makeEntry = {
	    var view = View().background_(Color.rand).layout_(
	        HLayout(
				StaticText().string_( ("This is number " + i.asString) ).minWidth_(250),
	            Button().states_([["Delete"]]).action_({view.remove; count = count - 1;}),
				Button().states_([["Play"]]).action_({"PLAY".postln;})
	        )
	    );
	    count = count + 1;
	    view;
	};


	canvas.layout = VLayout();
	canvas.layout.add(Button().states_([["cancel"]]).action_({
		searchViews[i].layout.index = 0;
		removeStack.(i);

	}).maxWidth_(50));

	canvas.layout.add(StaticText().string_( ("This is number " + i.asString) ).minWidth_(100));


	30.do { canvas.layout.add( makeEntry.() ) };
	canvas.layout.add(nil); // stretch remaining empty space

	scroll.canvas = canvas;
	scroll.front;

});

//------------------------------------------------------
// stackView
//------------------------------------------------------
stackView =({|i|

	View().layout_( StackLayout(
			newSearchView.(i),
			queryView.(i),
			resultsView.(i)
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





