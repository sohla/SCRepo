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



speakerView = {


var x=200, y=150, targx=200, targy=150;
var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
var targRotate, actRotate, targPoint, actPoint;
var maxShiftPerFrame = 20, frameInterval = 0.01;
var resched = false, count = 0;
var a, b, c, e;

maxShiftPerFrame = maxShiftPerFrame * atorad;
actPoint = Point(x, y) - Point(200, 200);
panBus = Bus.control;
widthBus = Bus.control.set(60);

w = window;
speakerList = [ [90, "R"], [30, "C"], [150, "Rs"],[-30, "L"],[-90, "Ls"],[-150, "Ll"]];
c = UserView()
	.minHeight_(400)
	.minWidth_(400);
c.canFocus = false;

c.drawFunc = {
    Color.black.set;
    // draw the speaker layout
    Pen.translate(200,200);
    (((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString++"º").drawCenteredIn(Rect.aboutPoint(0@170, 40, 10), Font.new("Arial", 20), Color.grey(0.3));
    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
    Pen.rotate(pi);
    speakerList.do({|spkr|
	    Color.green(0.5).set;

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
	Color.red.alpha_(0.5).set;
    Pen.stroke;
    Pen.fillOval(Rect.aboutPoint(0@150, 7, 7));
	Color.red.alpha_(0.1).set;
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.fill;
    Color.grey(0.8).alpha_(0.1).set;
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.fill;

    if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
    if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
};
c.mouseMoveAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
c.mouseDownAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
e = EZSlider.new(c, 380@20, "Stereo Width", [0, 180].asSpec, {arg ez; widthBus.set(ez.value); w.refresh}, labelWidth: 80);
e.labelView.setProperty(\stringColor,Color.grey(0.8));
e.value = 60;

	c

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
				.background_(if (i==0){Color.yellow}{Color.green(0.5)})
			}!count;
		)
	};

	values = {
		HLayout (

			*{|i|TextField()
				.minHeight_(30)
				.maxWidth_(50)
				.background_(if (i==0){Color.yellow}{Color.green(0.5)})
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
				.stringColor_(Color.green)
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
		[msg[3],level].postln;

		slidersArray[msg[3]].value_(level);
	}.defer;

}, '/onLevels');



// VBAP

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

		Out.ar(bus, panned[0][i]);

	});

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 

		Out.ar(bus, panned[1][i])

	});



}).play(s, [vbapBuf: speakerBuffer.bufnum, azi: panBus.asMap, width: widthBus.asMap]);


)