(
SynthDef(\sinNote, {| note = 69|

	var osc = SinOsc.ar(note.midicps,0,0.2);
	Out.ar(0,osc);

}).send(s);
)
(
SynthDef(\playBuffer, {|buffer = 0, note = 69|

	var player;
	var pitch = (note.midicps / 440.0) * BufRateScale.kr(buffer);
	 player = PlayBuf.ar(buffer.numChannels,buffer,(note.midicps / 440.0) * BufRateScale.kr(buffer));
	Out.ar(0,player);

}).send(s);
)



n = s.sendMsg("/s_new",\sinNote,1,1,0,"note",32);
s.sendMsg("/n_set",1,"note",58);
s.sendMsg("/n_free",1);

c = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/darkforest.wav");
n = s.nextNodeID;

s.sendMsg("/s_new",\playBuffer,n,0,0,\buffer,c,\note,57);// for some reason note is not sent
s.sendMsg("/n_set",n,"note",58);
s.sendMsg("/n_free",n);

s.queryAllNodes

SynthDescLib.global[\playBuffer]

x = "Name" -> 100
x.key
x.value

f = Array.newClear(128)
f.size
f.put(2,x)

f.at(2)

(
	var notesOn = Array.newClear(128);
	var buf = Buffer.read(s, "/Applications/SuperCollider3.6/sounds/darkforest.wav");

	MIDIClient.init;
	MIDIIn.connectAll;

	NoteOnResponder({ |src, chan, num, vel|

		[src, chan, num, vel].postln;

		a = Synth(\playBuffer,[\buffer,buf,\note,num]);
		notesOn.put(num,a);

	});


	NoteOffResponder({ |src, chan, num, vel|
		[src, chan, num, vel].postln;

		a = notesOn.at(num);
		a.free;
	});

	CCResponder({ |src,chan,num,value|
        [src,chan,num,value].postln;

		if(value == 0x7f,{


		},{

		});

    },num:64);

)
(
NoteOnResponder.removeAll;
NoteOffResponder.removeAll;
CCResponder.removeAll
)


