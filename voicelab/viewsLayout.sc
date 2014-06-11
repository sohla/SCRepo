(
	
	w = Window.new("Layout").front;
	
	
	w.view.decorator = FlowLayout( w.view.bounds, 10@10, 20@5 );
	
	16.do{ 
		Button( w.view,80@80 )
			.background_( Color.rand )
			.states_([
				["hello world, how are you today?"],
				["hello again"]
				])
	
	
	};
	
	
)

