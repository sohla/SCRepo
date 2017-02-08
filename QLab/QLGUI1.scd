(
var window;
var mainView;
var connectView;
var headerView,numberTextView,nameTextView;
var levelsView;
var speakerView;

var speakerArray;
var speakerBuffer;
var panBus, widthBus;
var speakerList;
var onLevels;
var level;
var slidersArray = [];

//------------------------------------------------------

speakerList = [ [60, "R"], [0, "C"], [120, "Rs"],[-60, "L"],[-120, "Ls"],[-180, "Ll"]];

//------------------------------------------------------

mainView = {


	View().layout_(

		GridLayout.rows([
			connectView.(),
			[speakerView.(), rows:3]
		],[
			headerView.()
		],[
			levelsView.()
		],[
		]);
	);	
};



//------------------------------------------------------
speakerView = {



	var roundView;



	var widthSpec = [0,180].asSpec;
	var widthSlider;
	var x=200, y=150, targx=200, targy=150;


	widthSlider = Slider()
				.maxHeight_(30)
				.orientation_(\horizontal)
				.action_({|v|
					//widthSpec.map(v.value).postln;
					widthBus.set(widthSpec.map(v.value));
					roundView.refresh;
				});

	roundView = UserView()
		.minHeight_(400)
		.minWidth_(400)
		.canFocus_(false)
		.mouseMoveAction_({|v,inx,iny| x = inx; y = iny; roundView.refresh;})
		.mouseDownAction_({|v,inx,iny| x = inx; y = iny; roundView.refresh;})
		.drawFunc_({

			var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
			var targRotate, actRotate, targPoint;
			var maxShiftPerFrame = 20, frameInterval = 0.01;
			var resched = false, count = 0;
			var actPoint;

			maxShiftPerFrame = maxShiftPerFrame * atorad;
			actPoint = Point(x, y) - Point(200, 200);

		    Color.black.set;
		    // draw the speaker layout
		    Pen.translate(200,200);
		    (((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString++"º").drawCenteredIn(Rect.aboutPoint(0@10, 40, 10), Font.new("Arial", 10), Color.grey(0.3));
		    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
		    Pen.rotate(pi);
		    speakerList.do({|spkr|
			    Color.grey(0.2).set;

		        Pen.use({
		            Pen.rotate(spkr[0] * atorad);
		            Pen.moveTo(0@170);
		            Pen.fillRect(r = Rect.aboutPoint(0@170, 10, 10));
		            if(spkr[0].abs < 90, {
		                Pen.use({
		                    Pen.translate(0, 170); 
		                    Pen.rotate(pi);
		                    spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10), 
		                        GUI.font.new("Arial", 10), Color.white);
		                });
		            },{ 
		                spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.white);
		            });
		        });
		    });

		    Pen.moveTo(0@0);

			Color.red.alpha_(0.1).set;
		    // draw the pan point
		    Pen.rotate(actPoint.theta + 0.5pi);
		    targPoint = Point(x, y) - Point(200, 200);
		    // trunc to avoid loops due to fp math
		    targRotate = (targPoint.theta - actPoint.theta).trunc(1e-15);
		    // wrap around
		    if(targRotate.abs > pi, {targRotate = (2pi - targRotate.abs) * targRotate.sign.neg}); 
		    actRotate = targRotate.clip2(maxShiftPerFrame).trunc(1e-15);
		    actPoint = actPoint.rotate(actRotate);
		    Pen.rotate(actRotate);
		    Pen.lineTo(0@150);
			Color.grey(0.5).set;
		    Pen.stroke;
		    Pen.fillOval(Rect.aboutPoint(0@150, 7, 7));
			Color.red.alpha_(0.1).set;
		    Pen.addWedge(0@0, 140, neg(widthSpec.map(widthSlider.value) * 0.5) * atorad + 0.5pi, widthSpec.map(widthSlider.value) * atorad);
		    Pen.fill;
		    Color.grey(0.8).alpha_(0.1).set;
		    Pen.addWedge(0@0, 140, neg(widthSpec.map(widthSlider.value) * 0.5) * atorad + 0.5pi, widthSpec.map(widthSlider.value) * atorad);
		    Pen.fill;

		//    if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
		    if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
		});


	panBus = Bus.control;
	widthBus = Bus.control.set(60);
	widthSlider.value_(widthSpec.unmap(60));


	(VLayout(
		widthSlider,
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		// Slider().orientation_(\horizontal),
		roundView
	));

	
};


//------------------------------------------------------
levelsView = {

	var count = 9;
	var layout;
	var sliders,values;
	//var slidersArray = [];
	var valuesArray = [];

	sliders = {
		HLayout (

			*{|i|Slider()
				.minHeight_(200)
				.maxWidth_(50)
				.background_(if (i==0){Color.grey(0.1)}{Color.grey(0.2)})
			}!count;
		)
	};

	values = {
		HLayout (

			*{|i|TextField()
				.minHeight_(30)
				.maxWidth_(50)
				.background_(if (i==0){Color.grey(0.1)}{Color.grey(0.2)})
				.stringColor_(Color.grey)
				.string_("1.0")
				.align_(\center)
			}!count;
		)
	};


	layout = View().layout_( VLayout(
		sliders.(),
		values.()
	));

	slidersArray = layout.children(Slider);
	valuesArray = layout.children(TextField);

	slidersArray.do({|o,i|
		o.action_({|sl|
			valuesArray[i].value = sl.value.asStringPrec(2);
			":".postln;
		});
	});

	valuesArray.do({|o,i|
		o.action_({|vl|
			slidersArray[i].value = vl.value;
		});
	});


	layout
};
//------------------------------------------------------

headerView = {

	View().layout_( HLayout(

			numberTextView = StaticText()
				.maxHeight_(50)
				.minHeight_(50)
				.maxWidth_(50)
				.minWidth_(50)
				.string_("1")
				.align_(\center)
				.stringColor_(Color.grey)
				.background_(Color.grey),

			nameTextView = StaticText()
				.maxHeight_(50)
				.string_("  Name of Cue")
				.align_(\left)
				.stringColor_(Color.black)
				.background_(Color.grey),

			VLayout( 
				Button()
					.states_([["▲"]])
					.maxWidth_(30),

				Button()
					.states_([["▼"]])
					.maxWidth_(30),

			)
		);	
	);

};
//------------------------------------------------------

connectView = {
	View().layout_( HLayout(
	TextField()
		.maxWidth_(200)
		.string_("10.1.1.3"),
	Button()
		.states_([["Connect"]])
	))

};

//------------------------------------------------------
window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width * 0.7,
		Window.screenBounds.height / 2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

window.layout.add(mainView.());


//------------------------------------------------------

window.onClose = ({

	onLevels.free;
	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


//------------------------------------------------------

onLevels = OSCFunc({|msg, time, addr, recvPort|

	{

		level = msg[5].ampdb.linexp(-40, 0, 1, 2.0) - 1.0;
		//[msg[3],level].postln;

		slidersArray[msg[3]+1].valueAction_(level);
	}.defer;

}, '/onLevels');


//------------------------------------------------------
// VBAP
//------------------------------------------------------

speakerArray = VBAPSpeakerArray.new(2, speakerList.collect(_.first));
speakerBuffer = speakerArray.loadToBuffer;


SynthDef('VBAP 5 chan', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf|

	var panned, source;	
	var imp = Impulse.kr(10);
	var delimp = Delay1.kr(imp);

	source = SinOsc.ar([140, 204], 0, 0.2);
	azi = azi.circleRamp;
	panned = VBAP.ar(6, source, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
	// 'standard' channel order for 5.1

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 
		
		var sum = panned[0][i] + panned[1][i];

			SendReply.kr(imp, '/onLevels', [i,Amplitude.kr(sum), K2A.ar(Peak.ar(sum, delimp).lag(0, 0.1))]);

		//Out.ar(bus, panned[0][i]);

	});

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 

		//Out.ar(bus, panned[1][i])

	});



}).play(s, [vbapBuf: speakerBuffer.bufnum, azi: panBus.asMap, width: widthBus.asMap]);


)