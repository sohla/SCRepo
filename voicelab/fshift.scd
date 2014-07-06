(
SynthDef(\ss,{

	Out.ar(0,SinOsc.ar(120,0,0.1).dup);

}).send(s);




SynthDef(\fshift, {|buffer = 0, frq = 52, mul = 131, add = 0.4|

	var player,voco,kernal;
	var a = 0;

	player = In.ar(0,2);//PlayBuf.ar(1,buffer,BufRateScale.kr(buffer),loop: 1) ;

	kernal = LFTri.kr(frq,0,mul,add);

	a= FreqShift.ar(player,kernal);
		ReplaceOut.ar(0, a.dup);

}).send(s);

	SynthDef(\playBuffer, {|buffer = 0, note = 69|
		var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
		var player = PlayBuf.ar(
			buffer.numChannels,
			buffer,
			pitch,
			doneAction:2
		);
	    var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);
	    SendReply.kr(imp, '/onPlayLevel', [0,Amplitude.kr(player), K2A.ar(Peak.ar(player, delimp).lag(0, 1))]);

		Out.ar(0,[player,player,player,player]);

	}).send(s);

)
p = "~/Music/sounds/Original Intro and Questions.aif".standardizePath;
c = Buffer.read(s,p);


a = Group.new;
b = Group.new;
e = Synth.head(a,\ss);
x = Synth.head(b,\playBuffer,[\buffer,c]);
y = Synth.after(x,\fshift,[\buffer,c])

s.queryAllNodes

(
x = Synth(\fshift,[\buffer,c]).autogui(specs:
	(
		\frq: [0.001,400,\lin,0.01,52],
		\mul: [0,1400,\lin,1,131],
		\add: [0.1,10,\lin,0.1,0.4]
));
)

