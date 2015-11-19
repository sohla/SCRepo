
b = Array.fill(8,{|i|0});
a = Rduino(SerialPort.devices.last,9600);

a.start;

(2..7).do({|i| a.mode_(i,1)});


a.bitCallback = {|pin,val|


	if(b[pin]!=val,{

		b[pin] = b[pin].asBoolean.not.asInteger;

		if(b[pin].asBoolean,{
			("["++pin++"]ON").postln;
		},{
			("["++pin++"]OFF").postln;
		});
	});

};

r = Task.new({ inf.do({
		(2..7).do({|i|a.readBit(i)});
		0.1.wait;
	})
}).play;


CmdPeriod.doOnce {
	r.stop;
	r.free;
	a.close;

};




