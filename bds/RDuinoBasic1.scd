d = Rduino(SerialPort.devices.last, 115200);

(4..13).do{ | i | d.mode_(i,1) };
(13).do{ | i | d.bit_(i,0) };

d.bit_(13, 1)
d.bit_(13, 0)





///

d = Rduino(SerialPort.devices.last, 115200);

d.mode_(2,0);
d.start;
d.readBit(2);

d.bitCallback = {|pin,val|
	("Digital Pin["++pin++"] -> "++val).postln;
};

d.start;


r = Task.new({ inf.do({
	d.readBit(2);
    0.1.wait;
	})

});
r.play;
r.stop;


d.close;
