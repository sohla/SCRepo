(
	var window, onButton;

	var oscResponderNode;



	window = Window("",Rect(0, 0, Window.screenBounds.width/2, Window.screenBounds.height/2))

		.layout_(HLayout(

				[onButton = Button()
		.states_([["Off", Color.red],["On",Color.green,Color.gray]])
					.action_({|b|
			if(b.value==1,{
				"Adding oscResponderNode...".postln;
				oscResponderNode = OSCresponderNode.new(nil, "/yo", { arg time, resp, msg; [time,resp,msg].postln; msg.postln;} ).add;
				},{
				"oscResponderNode removed".postln;

				oscResponderNode.remove;
			})


					})
					.minWidth_(80)
					.minHeight_(80)
					, align:\topLeft]

	)

		)


		.front;

//onButton.valueAction = onButton.value.asBoolean.not
	window.view.keyDownAction = { |view, char, modifiers, unicode, keycode|

		switch(char,
		$a, {onButton.valueAction = onButton.value.asBoolean.not}
		);

		window.onClose = ({
		onButton.valueAction = 0;
		});
	};

)


