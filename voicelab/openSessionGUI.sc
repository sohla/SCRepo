
(
	
var window, mainView;
var loadView, sessionView, errorView, errorText;
var say;
var width = 400, height = 400, xspeed = 3, yspeed = 2, x = width*0.5, y = height*0.5;

say = ({|s|
	if(false,{s.speak});
});
errorView = ({
	View().layout_( VLayout(
		
		StaticText().string_("Error").align_(\center).font_(Font(size:48)),
		errorText = StaticText().string_("-").align_(\center).font_(Font(size:24)),
		
		[Button()
			.states_([["Ok"]])
			.action_({|b| 
				mainView.index = 0;
			})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center]
	))
});


loadView = ({
	
	View().layout_( VLayout(
		StaticText().string_("Welcome to VoiceLab").align_(\center).font_(Font(size:48)),
		
		[Button()
			.states_([["New Session"]])
			.action_({|b| 
				mainView.index = 1;
				say.value("New, Voice Lab Session");
			})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center],
		
		[Button()
			.states_([["Open Session"]])
			.action_({|b|
				errorText.string = "oh no, you did something weird!"; 
				mainView.index = 2;
				say.value("Open Voice Lab Session");
			})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center],
		
		
		
		[Button()
			.maxHeight_(100)
			.states_([["Template Session"]])
			.action_({|b| 
				say.value("Creating Voice Lab Session from Template");
			})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center]
			
		)
	);
	
});


sessionView = ({
	
	var btnHeight = 180;
	var listView;
	View().layout_( HLayout(
		listView = ListView()
			.maxHeight_(900)
			.items_([ "SinOsc", "Saw", "LFSaw", "WhiteNoise", "PinkNoise", "BrownNoise", "Osc", "BOsc", "SOsc" , "FOsc" ])
			.font_(Font("Helvetica", 44)),
			
//			Slider2D(),
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



window = Window("",Rect(0, 800, 1200, 400))
	.layout_( VLayout(
		mainView = StackLayout(
	
			loadView.value(),
			sessionView.value(),
			errorView.value()
		
		);
	))

	.toFrontAction_({
		say.value("welcome to, voicelab");
	
		})
	.front;




)
