(

a = Rduino(SerialPort.devices.last,115200);
a.mode_(9, 1);
a.bit_(9, 255);
a.pw_(9, 32)
)



SerialPort.device0
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

a.close



(
	a = Rduino(SerialPort.devices.last,115200);
	i = 0;
	d = 1;
	r = Task.new({ inf.do({

		i = i + d;

		if(i>127,{d = d * -1; i = 127;});
		if(i<0,{d = d * -1; i = 0;});
		i.postln;
		a.pw_(9,i);

        0.4.wait;
	})

	});

	r.play;
)