

(
	SynthDef(\dualSin, { |lfoA=0.1, lfoB=0.4 |


		var sig = SinOsc.ar([90,360],0,[LFTri.ar(lfoA,0.1),LFTri.ar(lfoB,0.2)]);
		var imp = Impulse.kr(60);
		var delimp = Delay1.kr(imp);


		sig.do({ |a,i|
			SendReply.kr(imp, '/onLevels', [i,Amplitude.kr(sig[i]), K2A.ar(Peak.ar(sig[i], delimp).lag(0, 0.01))]);
		});
		
		//.ar(0,sig);

	}).send(s);
)

(
var window;
var synthNode = s.nextNodeID;
var onLevels;
var level;
var sliders = Array.newFrom([Slider(),Slider()]);



onLevels = OSCFunc({|msg, time, addr, recvPort|

	{

		level = msg[5].ampdb.linexp(-40, 0, 1, 2.0) - 1.0;
		//[msg[3],level].postln;

		sliders[msg[3]].value_(level);
	}.defer;

}, '/onLevels');



window = Window("")
	.bounds_(Rect(
		0,0,
		Window.screenBounds.width/6,
		Window.screenBounds.height/2)
		.center_(Window.availableBounds.center)
	)
	.front;


window.layout = HLayout(sliders[0],sliders[1]);

s.sendMsg("/s_new", "dualSin", synthNode, 0, 0,\lfoA,0.025,\lfoB,0.5);





window.onClose = ({


			onLevels.free;



	s.sendMsg("/n_free",synthNode);
	Buffer.freeAll;
	s.freeAll;

});
CmdPeriod.doOnce({window.close});


)











