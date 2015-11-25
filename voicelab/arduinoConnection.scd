
(

	~arduinoPath = "/dev/tty.usbmodem1421";

	if(SerialPort.devices.find([~arduinoPath]).notNil,{

		~arduino = RduinoDMX(~arduinoPath,115200);
		"serial porting connecting...".postln;
	},{
		"couldn't find arduino on serial port.".postln;
	});





	~isArduinoConnected = { |f|if(~arduino.sp.isOpen,{f.value()},{})};

	~isArduinoConnected.value({
		"WIN".postln;
	});

	//~arduino.close;
)



(


var arduino;

try{
arduino = RduinoDMX(SerialPort.devices.last,115200);
}{|error| [\Connecting:error.errorString].postln};

a = false;
case{arduino.notNil}{"a is true".postln};


)

