(
	var start,end;
	var register;
	var createListener, createWindow;



	createListener = {|addr|

		var ip = addr.ip;

		createWindow.(ip.asString);

	};

	createWindow = {|name|
		var window;

		window = Window(name)
			.bounds_(Rect(
				0, 
				(Window.screenBounds.height/2) - (Window.allWindows.size * 50),
				Window.screenBounds.width,
				Window.screenBounds.height/2)
			)
			.front;

		window.layout = HLayout();

		window.onClose = ({

			if(Window.allWindows.size == 1) {end.()};

		});

	};


	start = {

		CmdPeriod.doOnce({ end.() });

		register = OSCFunc({ |msg, time, addr, recvPort|
			if (msg[1] == 1 && msg[2] == 1) {{ createListener.(addr)}.defer};
		},'/gyrosc/button');
	};




	end = {

		["goodbye."].postln;
		register.free;

		Window.allWindows.do{|window|
			if(window.name.find("SuperCollider") == nil) { window.close()};//close everything except help window
		};
	};


	start.();

)

