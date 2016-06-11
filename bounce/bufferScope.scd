

(
var window, routine;
var scopeView, buffer;



b = Bus.audio(s,2);

//------------------------------------------------------

buffer = Buffer.alloc(s,1024,2);
//------------------------------------------------------
window = Window("",Rect(0,0,Window.screenBounds.width, Window.screenBounds.height/3)
	.center_(Window.availableBounds.center)
	).front;

window.layout = HLayout();

window.layout.add(
	scopeView = ScopeView();
);


scopeView.bufnum = buffer.bufnum;
scopeView.server_(s);
//------------------------------------------------------
a=SynthDef("monoscope", { arg bus, bufnum;
                var z;
                z = In.ar(bus,2);
                // ScopeOut writes the audio to the buffer
                ScopeOut2.ar(z, bufnum);
            }).play(
                RootNode(s),
                [\bus,b.index, \bufnum, buffer.bufnum] ,
                \addToTail // make sure it goes after what you are scoping
            );
d=SynthDef("noise", { arg bus;
                var z;
                z = LFSaw.ar(SinOsc.kr(0.1).range(300,1000),[0,1]*pi) * 0.1;
                Out.ar(bus, z);
            }).play(
                s,
                [\bus,b.index]
            );

//------------------------------------------------------

routine = Routine { arg inval;
    loop {
        // thisThread refers to the routine.
        postf("count: % beats: % seconds: % time: % \n",
            thisThread.beats - inval, thisThread.beats, thisThread.seconds, Main.elapsedTime
        );
        0.1.yield;

    }
};

//routine.play;
scopeView.start;
//------------------------------------------------------

window.onClose = ({

	routine.stop;
	buffer.free;

});
CmdPeriod.doOnce({window.close});



)
