a = Rduino(SerialPort.devices.last,115200);
a.mode_(1,0);
a.start;
r = Task.new({ inf.do({
	a.readAnalog(1);
    0.01.wait;
	})

});
r.play;
r.stop;
a.close;



a = Rduino(SerialPort.devices.last,115200);
a.mode_(9,0);
a.start;
r = Task.new({ inf.do({
	a.readBit(9);
    0.1.wait;
	})

});
r.play;
r.stop;
a.close;



a = Rduino(SerialPort.devices.last,115200);
a.start;
r = Task.new({ inf.do({
	a.readCap();
    0.1.wait;
	})

});
r.play;
r.stop;
a.close;



8.do({|i|i.postln})