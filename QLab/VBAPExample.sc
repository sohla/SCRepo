

// (
// 	SynthDef(\VBAP5chan, { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf|
// 	var panned, source;
// 	source = SinOsc.ar([140, 204], 0, 0.2);
// 	azi = azi.circleRamp;
// 	panned = VBAP.ar(5, source, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
// 	// 'standard' channel order for 5.1
// 	[0, 1, 2, 4, 5].do({arg bus, i; Out.ar(bus, panned[0][i])});
// 	[0, 1, 2, 4, 5].do({arg bus, i; Out.ar(bus, panned[1][i])});

// 	}).send(s);
// )

(
var speakerList, x=200, y=150, targx=200, targy=150;
var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
var targRotate, actRotate, targPoint, actPoint;
var maxShiftPerFrame = 20, frameInterval = 0.01;
var resched = false, count = 0;
var panBus, widthBus, recButton;
var a, b, c, e;
var synthNode = s.nextNodeID;
var synth;
var onLevels;
var level;

var signal;

maxShiftPerFrame = maxShiftPerFrame * atorad;
actPoint = Point(x, y) - Point(200, 200);
panBus = Bus.control;
widthBus = Bus.control.set(60);

w = Window.new("5.1 Panner", Rect(128, 64, 400, 450)).front;
w.view.background_(Color.grey(0.3));
w.view.decorator = FlowLayout(w.view.bounds);
speakerList = [ [90, "R"], [30, "C"], [150, "Rs"],[-30, "L"],[-90, "Ls"],[-150, "Ll"]];
c = UserView.new(w,Rect(0, 0, 400, 380));
c.canFocus = false;

c.drawFunc = {
    Color.grey(0.8).set;
    // draw the speaker layout
    Pen.translate(200,200);
    ((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString.drawCenteredIn(Rect.aboutPoint(0@170, 30, 10), Font.new("Arial", 10), Color.grey(0.8));
    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
    Pen.rotate(pi);
    speakerList.do({|spkr|
        Pen.use({
            Pen.rotate(spkr[0] * atorad);
            Pen.moveTo(0@170);
            Pen.strokeRect(r = Rect.aboutPoint(0@170, 30, 10));
            if(spkr[0].abs < 90, {
                Pen.use({
                    Pen.translate(0, 170); 
                    Pen.rotate(pi);
                    spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10), 
                        GUI.font.new("Arial", 10), Color.grey(0.8));
                });
            },{ 
                spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.grey(0.8));
            });
        });
    });

    Pen.moveTo(0@0);

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
e.value = 60;
w.refresh;

onLevels = OSCFunc({|msg, time, addr, recvPort|

	{

		level = msg[4].ampdb.linexp(-40, 0, 1, 2.0) - 1.0;
		[msg[3],level].postln;

		//sliders[msg[3]].value_(level);
	}.defer;

}, '/onLevels');


w.onClose = ({


	onLevels.free;



	s.sendMsg("/n_free",synthNode);
	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({w.close});

// VBAP

a = VBAPSpeakerArray.new(2, speakerList.collect(_.first));
b = a.loadToBuffer;


SynthDef('VBAP 5 chan', { |azi = 0, ele = 0, spr = 0, width = 60, vbapBuf|

	var panned, source;
	var imp = Impulse.kr(60);
	var delimp = Delay1.kr(imp);

	source = SinOsc.ar([140, 204], 0, 0.2);
	azi = azi.circleRamp;
	panned = VBAP.ar(6, source, vbapBuf, [azi - (0.5 * width), azi + (0.5 * width)], ele, spr);
	// 'standard' channel order for 5.1

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 
		
			SendReply.kr(imp, '/onLevels', [i,Amplitude.kr(panned[0][i]), K2A.ar(Peak.ar(panned[0][i], delimp).lag(0, 0.01))]);

		Out.ar(bus, panned[0][i]);

	});

	[0, 1, 2, 4, 5, 6].do({arg bus, i; 

		Out.ar(bus, panned[1][i])

	});



}).play(s, [vbapBuf: b.bufnum, azi: panBus.asMap, width: widthBus.asMap]);

)

//s.meter(0,8)
