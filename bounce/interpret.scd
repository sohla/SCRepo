



(
var window, fun;

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout(
	Button()
		.action_({
				var path = PathName.new("~/Develop/SuperCollider/Projects/SCRepo/bounce/test.sc");
				var file = File.new(path.asAbsolutePath,"r");
			 	var str = file.readAllString;

				interpret(str);

				file.close;

				f.();
				~at.();

			});
);





window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)