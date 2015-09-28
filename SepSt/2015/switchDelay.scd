

// this time, change the buffer read pointer periodically.
(
SynthDef('help-switchdelay-2', { arg out=0, bufnum, delaytime;
    Out.ar(out,
        Pan2.ar(
            SwitchDelay.ar(
                PlayBuf.ar(numChannels: 1, bufnum: bufnum, loop: 1) * 0.5,
				drylevel: 0.1,
                wetlevel: 1.0,
                delaytime: Select.kr(
                    Stepper.kr(Impulse.kr(MouseX.kr(1, 100, 0.1)), 0, 0, 3),
                    #[ 0.05,0.2]
                ),
				delayfactor: 0.0
            )
        )
    );
}).send(s);
)

p = ("~/Music/sounds/emilyCasual.wav").standardizePath;
b = Buffer.read(s, p);
x = Synth('help-switchdelay-2', [\bufnum, b, \delaytime, 2.0]);
x.free;




(
SynthDef('help-switchdelay-3', { arg out=0, bufnum, delaytime;
    Out.ar(out,
        Pan2.ar(
            SwitchDelay.ar(
                AudioIn.ar([1,2], 0.5);,
				drylevel: 0.0,
                wetlevel: 1.0,
                delaytime: Select.kr(
                    Stepper.kr(Impulse.kr(MouseX.kr(1, 100, 0.1)), 0, 0, 3),
                    #[ 0.05,0.18]
                ),
				delayfactor: 0.0
            )
        )
    );
}).send(s);
)

x = Synth('help-switchdelay-3', [\bufnum, b, \delaytime, 2.0]);
