(

a = Rduino(SerialPort.devices.last,115200);
a.mode_(9, 1);
a.bit_(9, 255);
a.pw_(9, 32)
)



SerialPort.devices
a = Rduino(SerialPort.devices.last,115200);
(2..13).do{ | i | a.mode_(i,1) };
(2..13).do{ | i | a.bit_(i,0) };
a.bit_(12, 1);
a.bit_(9,1)
a.pw_(9,1)
a.pwClock_(9,5)


a.bit_(9, 0);
a.start
f = { | i, val | [i,val].postln };
a.atodCallback = Array.fill(a.atodCallback.size, f);
a.readAnalog(1)
a.atods

(2..13).do{ | i | a.mode_(i,1) };
(2..13).do{ | i | a.bit_(i,0) };
a.close



(
	a = Rduino(SerialPort.devices.last,115200);
	i = 0;
	d = 4;
	r = Task.new({ inf.do({

		i = i + d;

		if(i>127,{d = d * -1; i = 127;});
		if(i<0,{d = d * -1; i = 0;});
		i.postln;
		a.pw_(9,i);

        0.01.wait;
		})

	});

	r.play;
)




(
	a = Rduino(SerialPort.devices.last,115200);
	i = 0;
	d = 4;
	r = Task.new({ inf.do({

		i = i + d;

		if(i>127,{d = d * -1; i = 127;});
		if(i<0,{d = d * -1; i = 0; r.stop;});
		i.postln;
		a.pw_(9,i);

        0.01.wait;
		})

	});

	r.play;
)

(
	 var arduino = Rduino(SerialPort.devices.last,115200);


	arduino.pw_(9,127);
	{arduino.pw_(9,0)}.defer(1.0);
)


a = 1;

if((a!=0),{"a".postln})
a = Rduino(SerialPort.devices.last,115200);





a = RduinoDMX(SerialPort.devices.last,115200);

a.dmxc_(0,0,0)
a.dmx_(1,255)
a.dmx_(2,0)
a.dmx_(3,0)

(
	a = RduinoDMX(SerialPort.devices.last,115200);
	i = 1;
	f = 1;
	m = 20;
r = Task.new({ inf.do({ |i|


	// if(i>=m,{i=1; f = f * -1;});

	u = i/m;
	t = u * pi;

	b = (127 * cos(t)) + 127;
	c = (127 * cos(t + 2.0 * pi / 3.0)) + 127;
	d = (127 * cos(t + 3.0 * pi / 3.0)) + 127;

	a.dmxc_(b,c,d);

	//(u+":"+b+"."+c+"."+d).postln;

        0.01.wait;
		})

	});

	r.play;
)
