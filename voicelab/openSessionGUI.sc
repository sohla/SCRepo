
(
	
var window,mainView;
var loadView,sessionView;

loadView = ({
	View().layout_( VLayout(
		StaticText().string_("Welcome to Voice Lab").align_(\center).font_(Font(size:48)),
		
		[Button()
			.states_([["New Session"]])
			.action_({|b| mainView.index = 1})
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
	var listView;
	View().layout_( HLayout(
		listView = ListView()
			.maxHeight_(340)
			.items_([ "SinOsc", "Saw", "LFSaw", "WhiteNoise", "PinkNoise", "BrownNoise", "Osc", "BOsc", "SOsc" , "FOsc" ])
			.font_(Font("Helvetica", 44)),
			
		View().layout_( GridLayout.rows([
			
			Button()
				.maxHeight_(btnHeight)
				.states_([["PREV"]])
				.action_({|v|
					if(listView.value > 0,{listView.value = listView.value - 1});
				}),

			Button()
				.maxHeight_(btnHeight)
				.states_([["PLAY"]])
				.action_({|v|
						("play").postln;
					}),
				

			Button()
				.maxHeight_(btnHeight)
				.states_([["NEXT"]])
				.action_({|v|
					listView.value.postln;
					listView.items.size.postln;
					if(listView.value + 1 < listView.items.size,{listView.value = listView.value + 1});
				})

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
				.action_({|b| mainView.index = 0})
			])
		
		
		).minWidth_(400)

	))

});



window = Window("",Rect(50, 100, 1000, 400)).layout_( VLayout(
mainView = StackLayout(
	
		loadView.value(),
		sessionView.value()
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


