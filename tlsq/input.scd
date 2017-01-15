o = Server.local.options;
o.device = "MOTU UltraLite"
o.device
o.numOutputBusChannels = 8
o.numOutputBusChannels
o.numInputBusChannels = 8
o.numInputBusChannels
o.sampleRate = 44000
o.sampleRate

s.quit
s.boot



(
SynthDef("tlsq1",{ |out=0, inputBus = 1, gain = 1, time = 0.5, fb = 0.95|

	var input, fBLoopIn, fBLoopOut, processing, filter;

	input = AudioIn.ar(inputBus);

	filter = HPF.ar(input,90.0);

	fBLoopIn =LocalIn.ar(1);


	processing = filter +LeakDC.ar((DelayC.ar(fBLoopIn,4.0, time,fb)));

	fBLoopOut=LocalOut.ar(processing);
	Out.ar([0,1], processing)



}).send(s);
)


a = Synth(\tlsq1,[\inputBus,1,\gain,1,\time,0.8,\fb,0.9]);
b = Synth(\tlsq1,[\inputBus,2,\gain,1,\time,0.4,\fb,0.95]);

a.free;
b.free;



