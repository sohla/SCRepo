(
MIDIClient.init;
MIDIIn.connectAll;
m = MIDIFunc.noteOn({ |vel, num|
    "note % @ velocity %\n".postf(num, vel);
});
)

// when finished
m.free;



(
	NoteOnResponder({ |src, chan, num, vel|
		[src, chan, num, vel].postln
	},nil,0,64,{ |vel| vel > 50 });



)
NoteOnResponder.removeAll;

(

c = CCResponder({ |src,chan,num,value|
        [src,chan,num,value].postln;

    },num:64);
)

CCResponder.removeAll