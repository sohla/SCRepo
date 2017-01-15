MIDIClient.init;
MIDIClient.sources
MIDIClient.destinations


m = MIDIOut(0)

m.noteOn(16, 61, 60);
m.noteOff(16, 61, 60);



m.smpte(25, 16)
m.midiClock
m.reset
m.start
m.continue
m.stop

m.disconnect
(
    // substitute your own device here
var    mOut = MIDIOut.new(0).latency_(Server.default.latency);

p = Pbind(
    \type, \midi,
        // this line is optional b/c noteOn is the default
        // just making it explicit here
    \midicmd, \noteOn,
    \midiout, mOut,    // must provide the MIDI target here
    \chan, 0,
        // degree is converted to midinote, not just frequency
    \degree, Pwhite(-7, 12, inf),
    \dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
    \legato, sin(Ptime(inf) * 0.5).linexp(-1, 1, 1/3, 3),
    \amp, Pexprand(0.5, 1.0, inf)
).play(quant: 1);
)

p.stop;


MIDIClient.disposeClient