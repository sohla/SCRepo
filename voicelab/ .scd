(

SynthDef("simpleSample",{ |bufnum,pch = 1.0,amp=0.2, pan = 0.5|
		    var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * pch, doneAction:2) * amp;

			Out.ar(0,Pan2.ar(sig,pan));
		}
	).send(s);

)

t = "Ferry Fog Horn.wav";
t = "Seagulls.wav";
t = "Ocean Surf.wav";

p = ("~/Music/sounds/"++t).standardizePath;
b = Buffer.read(s, p);

s.sendMsg("/s_new", "simpleSample", x = s.nextNodeID, 1, 1,
	\bufnum, b.bufnum,
	\pch,rrand(0.95,1.15),
	\amp,rrand(0.1,0.4),
	\pan,rrand(-1.0,1.0)

);
b.free
x.free

s.queryAllNodes
s.quit

s.boot

(
	var titles = [
		"Seagulls.wav",
		"Ferry Fog Horn.wav",
		"Ocean Surf.wav",
		"Rain Heavy Thunder.wav"
	];


	a = Rduino(SerialPort.devices.last,115200);
	a.start;
	a.capCallback = {|i|

	 p = ("~/Music/sounds/"++titles[(i/2)]).standardizePath;
	 b = Buffer.read(s, p);
		s.sendMsg("/s_new", "simpleSample", x = s.nextNodeID, 1, 1,
			\bufnum, b.bufnum,
			\pch,rrand(0.95,1.15),
			\amp,rrand(0.1,0.4),
			\pan,rrand(-1.0,1.0)

		);

	};

	r = Task.new({ inf.do({
		a.readCap();
	    0.1.wait;
		})
	}).play;

	CmdPeriod.doOnce {
		r.stop;
		r.free;
		a.close;

};



)










	8.do({ |i|

		p = ("~/Music/sounds/"++titles[(i%4)]).standardizePath;
		b = Buffer.read(s, p);

		s.sendMsg("/s_new", "simpleSample", x = s.nextNodeID, 1, 1,
			\bufnum, b.bufnum,
			\pch,rrand(0.95,1.15),
			\amp,rrand(0.1,0.4),
			\pan,rrand(-1.0,1.0)

		);

	});


