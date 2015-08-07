


(
SynthDef(\AHPitchShifter, {|out=0, channel = 0, grainSize=0.3, pitch = 1.0|
	var signal,source;
	signal =  SoundIn.ar(channel);

	source = PitchShift.ar(signal,
				grainSize,
				pitch,//MouseY.kr(0.8, 1.2,0.1),
				0.001, 			// pitch dispersion
				MouseX.kr(0.001,0.03,0.2)	// time dispersion
		);


	Out.ar(out,[source,source]);
}).send(s);
)



(
SynthDef(\AHSimpleDelay, {|out=0, channel = 0, delay|
	var signal;
	signal =  In.ar(out,2);

	ReplaceOut.ar(out,
		  	DelayN.ar(signal,
				delay,
				delay,
				mul:0.5
			)
	);
}).send(s);
)

(


SynthDef(\FreeVerb2x2, {|outbus, mix = 0.25, room = 0.15, damp = 0.5, amp = 1.0|


	var signal;

	signal = In.ar(outbus, 2);

	ReplaceOut.ar(outbus,
		FreeVerb2.ar( // FreeVerb2 - true stereo UGen
			signal[0], // Left channel
			signal[1], // Right Channel
			mix, room, damp, amp)); // same params as FreeVerb 1 chn version

}).send(s);
)




g = Group.new();
f = Group.new();

s.queryAllNodes;


a = Synth(\AHPitchShifter, [\out, 0, \channel, 0, \pitch, 0.5])
a = Synth(\AHPitchShifter, [\out, 0, \channel, 1, \pitch, 1.5])


a = Synth(\AHPitchShifter, [\out, 0, \channel, 0, \pitch, 0.5],g,addAction:\addToTail);
b = Synth(\AHPitchShifter, [\out, 0, \channel, 1, \pitch, 1.5],f,addAction:\addToTail);

s.queryAllNodes;

c = Synth(\AHSimpleDelay, [\out, 0, \channel, 0, \delay, 0.5],g,addAction:\addToTail)
d = Synth(\AHSimpleDelay, [\out, 0, \channel, 1, \delay, 0.3],f,addAction:\addToTail)



c.set(\delay,0.002);
c.free;


e = Synth(\FreeVerb2x2, [\out, 0, \room,0.9,\mix,0.9],f,addAction:\addToTail)

e.set(\room,0.3,\mix,0.2);
e.set(\amp,4);



f = Synth(\FreeVerb2x2, [\out, 0, \room,0.4,\mix,0.6],g,addAction:\addToTail)
f.set(\amp,1);

a.free;
x.free;
b.free;
y.free;
g.free;
f.free;
d.free;
