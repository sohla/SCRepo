(
	~arduino = RduinoDMX(SerialPort.devices.last,115200);

	~fps = 1.0/60.0;

	~xf = 0.1;
	~xa = 1.0;
	~xs = 0.5;

	~yf = 0.1;
	~ya = 0.1;
	~ys = 0.9;


	~window = Window.new(bounds:Rect(100,100,200,400)).front.layout_(
		VLayout(
	        [~xyView = Slider2D()
			, stretch:1],

		[View().layout_(
			HLayout(
				// X axis
				[Slider()
					.value_(~xf)
					.step_(0.01)
					.action_({|v|
						~xf = v.value;
					})
			],
				[Slider()
					.value_(~xa)
					.step_(0.01)
					.action_({|v|
						~xa = v.value;
					})
			],
				[Slider()
					.value_(~xs)
					.step_(0.01)
					.action_({|v|
						~xs = v.value;
					})
			],
				// Y axis
				[Slider()
					.value_(~yf)
					.step_(0.01)
					.action_({|v|
						~yf = v.value;

					})
			],
				[Slider()
					.value_(~ya)
					.step_(0.01)
					.action_({|v|
						~ya = v.value;
					})
			],
				[Slider()
					.value_(~ys)
					.step_(0.01)
					.action_({|v|
						~ys = v.value;
					})
			]
			));


		]

	    )
	);

	~window.onClose = {
		~routine.stop;
		3.do({|i|~arduino.dmxc_(i+1,0,0,0)});
		~arduino.close;

		"onClose".postln;
	};

	~calcWithFAS = {|i,f,a,s|
		s + (sin((f * 1 * ~fps)* i * (180.0 / pi)) * 0.5 * a )
	};

	~routine = Routine{ |in|
		inf.do{|i|
			var x,y,c,r;

			x = ~calcWithFAS.value(i,~xf,~xa,~xs);
			y = ~calcWithFAS.value(i,~yf,~ya,~ys);

			c = Color.hsv(max(min(x,0.999),0.0),1,max(min(y,0.999),0.0),1);

			~xyView.background_(c);
			~xyView.setXYActive(x,y);
			r = 255;
			~arduino.dmxc_(1,c.red*r,c.green*r,c.blue*r);

			~fps.wait;
		}
	};


	~routine.play(AppClock);
)




