(
var window, mainView,queryView,resultsView;



queryView =({

			View().layout_( VLayout(
				TextField()
					.string_("")
					.align_(\left)
					.font_(Font(size:48))
					.action_({|a| "action".postln;
						mainView.index = 1;
					})

				)
			);

		});

resultsView =({

			View().layout_( VLayout(
				ListView()
					.font_(Font(size:48))
		.items_([ "SinOsc", "Saw", "LFSaw", "WhiteNoise", "PinkNoise", "BrownNoise", "Osc" ])

				)
			);

		});


		window = Window("",Rect(0,0,Window.screenBounds.width/2, Window.screenBounds.height/3).center_(Window.availableBounds.center))
			.layout_( VLayout(
				mainView = StackLayout(

		 queryView.(),
		 resultsView.()
		// errorView.(),
		// textFieldView.()

				);
			))

			.front;


		window.onClose = ({
		});


)