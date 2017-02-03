(
var window;
var mainView;
var connectView;
var headerView,numberTextView,nameTextView;
var levelsView;
var speakerView;

//------------------------------------------------------

mainView = {


	View().layout_(

		GridLayout.rows([
			connectView.()
		],[
			headerView.()
		],[
			levelsView.()
		],[
			speakerView.()
		]);
	);	
};



speakerView = {

	var b = EnvelopeView(window, Rect(0, 0, 500, 500))
    .drawLines_(false)
    .selectionColor_(Color.red)
    .drawRects_(true)
    .resize_(5)
    .step_(0.005)
    .action_({arg b; [b.index, b.value].postln})
    .thumbSize_(20)

    .value_([[0.5, 0.5, 0.15, 0.85, 0.15, 0.85],[0.5,0.9,0.9,0.9,0.1,0.1]]);

    b.setString(0,"Listener");
	b.setFillColor(0,Color.green);

	b.setString(1,"Source");
	b.setFillColor(1,Color.red);

	b.setString(2,"L");
	b.setFillColor(2,Color.grey);

	b.setString(3,"R");
	b.setFillColor(3,Color.grey);


	b.setString(4,"BL");
	b.setFillColor(4,Color.grey);

	b.setString(5,"BR");
	b.setFillColor(5,Color.grey);

	b
};
//------------------------------------------------------
levelsView = {

	var count = 9;
	var layout;
	var sliders,values;
	var slidersArray = [];
	var valuesArray = [];

	sliders = {
		HLayout (

			*{|i|Slider()
				.minHeight_(200)
				.maxWidth_(50)
				.background_(if (i==0){Color.yellow}{Color.green})
			}!count;
		)
	};

	values = {
		HLayout (

			*{|i|TextField()
				.minHeight_(30)
				.maxWidth_(50)
				.background_(if (i==0){Color.yellow}{Color.green})
				.string_("1.0")
				.align_(\center)
			}!count;
		)
	};


	layout = View().layout_( VLayout(
		sliders.(),
		values.()
	));

	slidersArray = layout.children(Slider);
	valuesArray = layout.children(TextField);

	slidersArray.do({|o,i|
		o.action_({|sl|
			valuesArray[i].value = sl.value.asStringPrec(2);
		});
	});

	valuesArray.do({|o,i|
		o.action_({|vl|
			slidersArray[i].value = vl.value;
		});
	});


	layout
};
//------------------------------------------------------

headerView = {

	View().layout_( HLayout(

			numberTextView = StaticText()
				.maxHeight_(50)
				.minHeight_(50)
				.maxWidth_(50)
				.minWidth_(50)
				.string_("1")
				.align_(\center)
				.stringColor_(Color.green)
				.background_(Color.grey),

			nameTextView = StaticText()
				.maxHeight_(50)
				.string_("  Name of Cue")
				.align_(\left)
				.stringColor_(Color.black)
				.background_(Color.grey),

			VLayout( 
				Button()
					.states_([["▲"]])
					.maxWidth_(30),

				Button()
					.states_([["▼"]])
					.maxWidth_(30),

			)
		);	
	);

};
//------------------------------------------------------

connectView = {
	View().layout_( HLayout(
	TextField()
		.maxWidth_(200)
		.string_("10.1.1.3"),
	Button()
		.states_([["Connect"]])
	))

};

//------------------------------------------------------
window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/3,
		Window.screenBounds.height)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

window.layout.add(mainView.());


//------------------------------------------------------

window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)