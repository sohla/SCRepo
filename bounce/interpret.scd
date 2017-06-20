



(
var window, fun;
var fileNames = ["george","harry"];
var personalities = Dictionary();

var on = {|v|
	["on",v.name].postln;
	v.rout.reset().play(AppClock);
};

var off = {|v|
	["off",v.name].postln;	
	v.rout.stop();
};


fileNames.do{|n|
	var path = PathName.new("~/Develop/SuperCollider/Projects/SCRepo/bounce/"++n++".sc");
	var file = File.new(path.asAbsolutePath,"r");
	var str = file.readAllString;
	var env = Environment.make {interpret(str)};
	personalities.put(n,(\name:n, \env:env, \rout: Routine { 
		var i=0;
		loop{ 
			env.use{
				~next.(i);
				(1.0/~fps.()).yield;
				i=i+1;
			};
		}
	}));
	env.use{~init.()};
	file.close;

};






window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

// personalities.keysValuesDo({|k,v| 
// 	window.layout.add(Button()
// 		.states_([[k],[k]])
// 		.action_({|b|
// 			b.value.asBoolean.if({ on.(v) },{ off.(v) })
// 		})
// 	);
// });

on.(personalities.at("george"));




window.onClose = ({
	personalities.keysValuesDo({|k,v| off.(v) });
	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});

)

/*

e = Environment.make { ~aa = 7 }
g = Environment.make { ~aa = 5 }

e.use{ ~aa }
g.use{ ~aa }

a = g
a.use{ ~aa }
*/

/*

b = [1,2,3,4]
c = [b,0].lace(b.size)
m = Dictionary.newFrom(c).pairsDo{|k,v,i| v = 100 + i}

*/