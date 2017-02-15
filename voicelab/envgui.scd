(
QtGUI.palette = QPalette.dark;

a = Window("text-boxes", Rect(0, 0, Window.screenBounds.width, Window.screenBounds.height));



b = EnvelopeView(a, Rect(0, 0, 440, 440))
    .thumbWidth_(50.0)
    .thumbHeight_(50.0)
    .style_(\dots)
    .step_(0.001)
    .drawLines_(false)
    .drawRects_(true)
    .selectionColor_(Color.red)
    .strokeColor_(Color.white)
    .fillColor_(Color.white)
    .value_([[0.1, 0.4, 0.3, 0.6], [0.1, 0.2, 0.5, 0.9]]);


4.do({arg i;
    b.setString(i, [
    	"welcome to voice lab?", 
    	"how old are you?", 
    	"what makes you happy?", 
    	"what is your favourite colour?"].at(i));
    b.setFillColor(i,Color.black);
});

a.view.layout = HLayout(b);


a.front;
)



(
w = Window("envelope", Rect(
	0, 
	Window.screenBounds.height/2, 
	Window.screenBounds.width, 
	Window.screenBounds.height/2)).front;

f = {|ev|
	ev.postln;
};

b = EnvelopeView(w)
    .thumbWidth_(250.0)
    .thumbHeight_(30.0)
    .style_(\dots)
    .step_(0.001)
    .drawLines_(false)
    .drawRects_(true)
    .selectionColor_(Color.red)
    .strokeColor_(Color.white)
    .fillColor_(Color.white)
    .action_(f)
    .value_([[0.1, 0.4, 0.3, 0.6], [0.1, 0.2, 0.5, 0.9]]);


4.do({arg i;
    b.setString(i, [
    	"🐸 welcome to voice lab? 🔴", 
    	"🐬 how old are you?", 
    	"🐈 what makes you happy?", 
    	"🌴 what is your favourite colour?"].at(i));
    b.setFillColor(i,Color.black.alpha_(0.1));
});

r = Routine({
	
	var angle = 0;

	inf.do{|i|

		4.do({|j|

			if(b.index != j){
				var x = (0.2 * (j+1)) + (sin( (pi/180) * angle * (1 * j+1)) * 0.01);
				var y = (0.5) + (cos( (pi/180) * angle * (1 * j+1)) * 0.02);

				var ax = b.value.at(0);
				var ay = b.value.at(1);

				ax = ax.put(j,x);
				ay = ay.put(j,y);

				b.value = b.value.put(0,ax);
				b.value = b.value.put(1,ay);
			};

		});

		0.01.wait;
		angle = angle + 1;

	};


});


w.view.layout = HLayout(b);

AppClock.play(r);


w.onClose = ({AppClock.clear;});
CmdPeriod.doOnce({w.close});




)






