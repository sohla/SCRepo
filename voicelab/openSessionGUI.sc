
(
	
var window,mainView;
var loadView,sessionView;

say = ({|s|
	if(true,{s.speak});
});

loadView = ({
	View().layout_( VLayout(
		StaticText().string_("Welcome to Voice Lab").align_(\center).font_(Font(size:48)),
		
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
				"Open Voice Lab Session".speak;
			})
			.minWidth_(400)
			.minHeight_(70)
			, align:\center],
		
		
		
		[Button()
			.maxHeight_(100)
			.states_([["Template Session"]])
			.action_({|b| 
				"Creating Voice Lab Session from Template".speak;
			})
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



window = Window("",Rect(50, 100, 1000, 400))
	.layout_( VLayout(
		mainView = StackLayout(
	
			loadView.value(),
			sessionView.value()
		);
	))

	.toFrontAction_({
		"welcome to, voicelab".speak;
	
		})
	.front;




)
