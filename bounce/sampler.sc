

// Execute the following in order
(
// allocate a Buffer
s = Server.local;
b = Buffer.alloc(s, 44100 * 1.0, 1); // a 1 second 1 channel Buffer
)


(
	SynthDef(\sampler1, { |out=0, bufnum = 0, degree=0, gate=1, amp=0.3, pan=0.0, attack=0.01, sustain=0.5, release=0.1|
	var env = EnvGen.kr(Env.adsr(attack, sustain, sustain, release), gate, doneAction:2);
	var rate = degree + 1;
	var sig = PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum) * rate);
	Out.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;
);




(  
SynthDef(\help_RecordBuf, { arg out = 0, bufnum = 0;
    var sig;
    sig = AudioIn.ar(1);//Formant.ar(XLine.kr(400,1000, 4), 2000, 800, 0.125);
    RecordBuf.ar(sig * 2, bufnum, doneAction: 2, loop: 0);
Out.ar(out, sig);
}).play(s,[\out, 0, \bufnum, b]);
)

// play it back
(
SynthDef(\help_RecordBuf_overdub, { arg out = 0, bufnum = 0;
    var playbuf;
    playbuf = PlayBuf.ar(1,bufnum, loop:true);
    //FreeSelfWhenDone.kr(playbuf); // frees the synth when the PlayBuf is finished
    Out.ar(out, playbuf);
}).play(s, [\out, 0, \bufnum, b]);
)









var ptn = "pattern1";

Pdef(ptn,
	Pbind(
//        \degree, Pseq([0,2,4,6,8,7,5,3,1], inf),
       \degree, Pseq([0], inf),
		\dur, Pseq([0.5,0.25,0.375,0.125],inf),
		 \args, #[],
		\amp, Pexprand(0.6,0.9,inf),
		\pan, Pwhite(-0.4,0.4,inf)

));

// use this to test patter/synth with default gui
 Pdef(ptn).play.gui;	
 Pdef(ptn).set(\instrument,\sampler1);
 Pdef(ptn).set(\bufnum, b);
 //Pdef(ptn).set(\dur,0.2);
// Pdef(ptn).set(\octave,4);

 Pdef(ptn).set(\attack,0.001);
 Pdef(ptn).set(\sustain,0.27);
 Pdef(ptn).set(\release,0.02);






Pdef(ptn).stop;
b.close; b.free; // cleanup
