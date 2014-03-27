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
MIDIClient.init;
MIDIIn.connectAll;
MIDIFunc.cc({"foot".postln}, 64);


c = CCResponder({ |src,chan,num,value|
        [src,chan,num,value].postln;

    },num:64);
)

CCResponder.removeAll


(
MIDIIn.connectAll;
MIDIFunc.cc({"foot".postln}, 64);
)





MIDIdef.noteOn(\test4, {arg ...args; args.postln},(64..68)); // match any
MIDIdef.freeAll;      // free all registered MIDIdefs


a = [64,66,67,69];
MIDIdef.noteOn(\noteOnPlayMode, {arg ...args; args[1].postln},a);
MIDIdef.noteOn(\noteOnPlayMode, {arg ...args; args.postln},argTemplate:{arg...args;[54,64,65].includes(args[1])}); // match any
