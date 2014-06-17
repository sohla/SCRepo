(
	w = Window.new.front;
	
	w.layout_( VLayout(
		
		View()
			.background_(Color.red),

			View()
		.background_(Color.red.blend(Color.yellow)),

		View()
			.background_(Color.yellow),
			
			View()
				.background_(Color.green),
			
		View()
			.background_(Color.blue),

			View()
				.background_(Color.blue.blend(Color.blue.blend(Color.red))),

				View()
					.background_(Color.blue.blend(Color.red)),
			
			));
)