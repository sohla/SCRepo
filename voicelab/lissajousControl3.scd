(
var data = Dictionary();
var fps = 1.0/60.0;
var arduino;
var window, xyView, listView;

//--------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------

try{
	arduino = RduinoDMX(SerialPort.devices.last,115200);
}{|error|
	[\Connecting:error.errorString].postln;
};


//--------------------------------------------------------------------------------
~createOscilParams = {|f,a,s|
	Dictionary.newFrom(List[\frq,f,\amp,a,\add,s]);
};
~createDataObject = {|x,y|

	d = Dictionary.newFrom(List[\title,"-",\x,x,\y,y]);
	d["\title"] = d.hash.postln;
	d

};

~addItemToListView = {|l,i|

};

data = ~createDataObject.(~createOscilParams.(0.03,1,0.5),~createOscilParams.(0.06,0.4,0.8));

//--------------------------------------------------------------------------------

window = Window.new(bounds:Rect(100,100,400,400)).front.layout_(
	HLayout([

		VLayout(
			[xyView = Slider2D()
				, stretch:1],

			[View().layout_(
				HLayout(
					// X axis
					[Slider()
						.value_(data[\x][\frq])
						.step_(0.01)
						.action_({|v|
							data[\x][\frq] = v.value;
						})
					],
					[Slider()
						.value_(data[\x][\amp])
						.step_(0.01)
						.action_({|v|
							data[\x][\amp] = v.value;
						})
					],
					[Slider()
						.value_(data[\x][\add])
						.step_(0.01)
						.action_({|v|
							data[\x][\add] = v.value;
						})
					],
					// Y axis
					[Slider()
						.value_(data[\y][\frq])
						.step_(0.01)
						.action_({|v|
							data[\y][\frq] = v.value;

						})
					],
					[Slider()
						.value_(data[\y][\amp])
						.step_(0.01)
						.action_({|v|
							data[\y][\amp] = v.value;
						})
					],
					[Slider()
						.value_(data[\y][\add])
						.step_(0.01)
						.action_({|v|
							data[\y][\add] = v.value;
						})
					]
				));


		])
	]);
);
//--------------------------------------------------------------------------------

window.onClose = {
	~routine.stop;
	arduino!?{
		3.do({|i|arduino.dmxc_(i+1,0,0,0)});
		arduino.close;
	};
	"onClose".postln;
};

//--------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------


~calcWithFAS = {|i,f,a,s|
	s + (sin((f * 1 * fps)* i * (180.0 / pi)) * 0.5 * a )
};

~routine = Routine{ |in|
	inf.do{|i|
		var x,y,c,r;
		var colors = [];
		var dif = 0.02;
		x = ~calcWithFAS.(i,data[\x][\frq],data[\x][\amp],data[\x][\add]);
		y = ~calcWithFAS.(i,data[\y][\frq],data[\y][\amp],data[\y][\add]);



		3.do({|i|
			colors = colors.add(Color.hsv(
				max(min(x - (i * dif),0.999),0.0),
				1,
				max(min(y - (i * dif),0.999),0.0)
				,1
			));
		});


		xyView.background_(colors[0]);
		xyView.setXYActive(x,y);
		arduino!?{
			r = 255;
			3.do({|i|
				c = colors[i];
				arduino.dmxc_(i+1,c.red*r,c.green*r,c.blue*r);
			});
		};
		fps.wait;
	}
};


~routine.play(AppClock);
)




