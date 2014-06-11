(
var w;

w = Window("~",);
w.layout_(
	VLayout(
		StaticText().string_("Welcome to Voice Lab").align_(\center).font_(Font(size:24)),
		Button().maxHeight_(100).states_([["New Session"]]),
		Button().maxHeight_(100).states_([["Open Session"]]),
		Button().maxHeight_(100).states_([["Template Session"]]))
	);
w.front;
w.onClose = {  };
)

(
	
var stack;
var loadView,sessionView;

loadView = ({
	View().layout_( VLayout(
		StaticText().string_("Welcome to Voice Lab").align_(\center).font_(Font(size:48)),
		
		[Button()
			.states_([["New Session"]])
			.action_({|b| stack.index = 1})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center],
		
		[Button()
			.states_([["Open Session"]])
			.minWidth_(400)
			.minHeight_(70)
			, align:\center],
		
		
		
		[Button()
			.maxHeight_(100)
			.states_([["Template Session"]])
			.minWidth_(400)
			.minHeight_(70)
			, align:\center]
			
		)
	)
});


sessionView = ({
	
	var btnHeight = 180;
	
	View().layout_( HLayout(
		ListView()
			.maxHeight_(340)
			.items_([ "SinOsc", "Saw", "LFSaw", "WhiteNoise", "PinkNoise", "BrownNoise", "Osc" ])
			.font_(Font("Helvetica", 44)),
			
		View().layout_( GridLayout.rows([
			
			Button()
				.maxHeight_(btnHeight)
				.states_([["PREV"]]),

			Button()
				.maxHeight_(btnHeight)
				.states_([["PLAY"]])
				.action_({|v|
						("play").postln;
					}),
				

			Button()
				.maxHeight_(btnHeight)
				.states_([["NEXT"]])

			],[

			Button()
				.maxHeight_(btnHeight)
				.states_([["Import"]]),

				Button()
					.maxHeight_(btnHeight)
					.states_([["Delete"]]),

			Button()
				.maxHeight_(btnHeight)
				.states_([["Record"]])
			],[
			
			UserView(),
			
			UserView()
				.drawFunc_({
					Pen.fillColor_( Color.grey( 0.0, 0.1 ));
					Pen.fillRect( Rect( 0, 0, 120, 120));
					Pen.fillColor= Color.new255(226, 49, 140);
					Pen.strokeColor= Color.new255(226, 49, 140);
					Pen.fillOval(Rect.aboutPoint(Point(60, 55), 20*1, 20*1));
				})
				.animate_(true)
				.clearOnRefresh_(false),
		
			
			Button()
				.maxHeight_(btnHeight)
				.states_([["Exit"]])
				.action_({|b| stack.index = 0})
			])
		
		
		).minWidth_(400)

	))

/*	View().layout_( VLayout(
		
		Button()
			.maxHeight_(100)
			.states_([["a"]]),
		
		Button()
			.maxHeight_(100)
			.states_([["b"]]),
		
		
		
		Button()
			.maxHeight_(100)
			.states_([["c"]]))
		)
*/});



w = Window("",Rect(50, 100, 1000, 400)).layout_( VLayout(
stack = StackLayout(
	
		loadView.value(),
		sessionView.value(),
        TextView().string_("This is a chunk of text..."),
        TextView().string_("...and this is another..."),
        TextView().string_("...and another.")
    );
)).front;

)

43.asUnicode
0x02ff.asAscii
U+02FF.postln
String("d")

(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;  [char, keycode].postln; };
w.front;
)



500.do{|i| i.asAscii.postln}

"underlined".underlined;
"underlined".underlined($~);
"hi. welcome to voice lab".speak;

"before we begin, you may select the voice you want to hear".speak

"question one. are you happy".speak

"do you like this music".speak

"i am enjoying it, to".speak

"cann you please stay".speak

"i enjoy talking, to you".speak

"please, don't go. please".speak


