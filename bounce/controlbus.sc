(
var window, slider;
var cs = ControlSpec(100, 1000, \linear, 0.01,0.1); // min, max, mapping, step, default
var bc = Bus.control(s).value_(cs.map(cs.default));

// bus represents a bus on the server
var synth;

SynthDef(\help_Bus, { |ffreq = 100 ,ff = 0.2|
    Out.ar(0,
        RLPF.ar(
            LFPulse.ar(SinOsc.kr(ff, 0, 50, 61), [0,0.1], 0.1),
            ffreq, 0.9
        ).clip2(0.4)
    );
}).send;

window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/2,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;

slider = EZSlider(window,80@300,"test", initAction:true, initVal: 0.9 ,layout:\vert, margin: 20@20)
		.controlSpec_(cs)
		.action_({|o|
			bc.set(o.value);   
			});

// window.layout = VLayout(

// 	Slider()//• should try EZSlider too
// 		.maxWidth_(30)
// 		.valueAction_(cs.default)
// 	    .action_({|o|
// 	        //(cs.map(o.value).asString).postln;
// 			bc.set(cs.map(o.value));       
// 	    });
// );

synth = Synth.head(s,\help_Bus);

// here is the magic! map each arg
synth.map(\ffreq,bc);

//bc.scope;

window.onClose = ({
	Buffer.freeAll;
	s.freeAll;
});
CmdPeriod.doOnce({window.close});

)











