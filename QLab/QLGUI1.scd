(
var window;
var mainView;
var connectView;
var headerView,numberTextView,nameTextView;
var levelsView;
var speakerView;

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


var speakerList, x=200, y=150, targx=200, targy=150;
var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
var targRotate, actRotate, targPoint, actPoint;
var maxShiftPerFrame = 20, frameInterval = 0.01;
var resched = false, count = 0;
var panBus, widthBus, recButton;
var a, b, c, e;

maxShiftPerFrame = maxShiftPerFrame * atorad;
actPoint = Point(x, y) - Point(200, 200);
panBus = Bus.control;
widthBus = Bus.control.set(60);

w = window;
speakerList = [[-30, "L"], [30, "R"], [0, "C"], [-110, "Ls"], [110, "Rs"]];
c = UserView()
	.minHeight_(400)
	.minWidth_(400)
	.background_(Color.white.alpha_(0.2));
c.canFocus = false;

c.drawFunc = {
    Color.black(0.8).set;
    // draw the speaker layout
    Pen.translate(200,200);
    ((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString.drawCenteredIn(Rect.aboutPoint(0@170, 30, 10), Font.new("Arial", 10), Color.grey(0.8));
    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
    Pen.rotate(pi);
    speakerList.do({|spkr|
	    Color.green(0.8).set;

        Pen.use({
            Pen.rotate(spkr[0] * atorad);
            Pen.moveTo(0@170);
            Pen.strokeRect(r = Rect.aboutPoint(0@170, 30, 10));
            if(spkr[0].abs < 90, {
                Pen.use({
                    Pen.translate(0, 170); 
                    Pen.rotate(pi);
                    spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10), 
                        GUI.font.new("Arial", 10), Color.green(0.8));
                });
            },{ 
                spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.green(0.8));
            });
        });
    });

    Pen.moveTo(0@0);

Color.red(0.8).set;
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
    Pen.stroke;
    Pen.fillOval(Rect.aboutPoint(0@150, 7, 7));
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.stroke;
    Color.grey(0.8).alpha_(0.1).set;
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.fill;

    if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
    if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
};
c.mouseMoveAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
c.mouseDownAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
e = EZSlider.new(w, 380@20, "Stereo Width", [0, 180].asSpec, {arg ez; widthBus.set(ez.value); w.refresh}, labelWidth: 80);
e.labelView.setProperty(\stringColor,Color.grey(0.8));

	c

};
//------------------------------------------------------
levelsView = {

	var count = 9;
	var layout;
	var sliders,values;
	var slidersArray = [];
	var valuesArray = [];

	sliders = {
		HLayout (

			*{|i|Slider()
				.minHeight_(200)
				.maxWidth_(50)
				.background_(if (i==0){Color.yellow}{Color.green})
			}!count;
		)
	};

	values = {
		HLayout (

			*{|i|TextField()
				.minHeight_(30)
				.maxWidth_(50)
				.background_(if (i==0){Color.yellow}{Color.green})
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
		Window.screenBounds.width/3,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

window.layout = HLayout();

window.layout.add(mainView.());


//------------------------------------------------------

window.onClose = ({

	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)