(

TempoClock.default.tempo = 30/60;

~rhythm = Pbind(
    \dur, Pwrand(#[0.125, 0.25, 0.5], #[0.3, 0.5, 0.2], inf),
	\octave, 5,
    \legato, Pwrand(#[0.1, 0.6, 1.01], #[0.1, 0.3, 0.6], inf),
	\instrument, \marimba,
	\amp, 0.05
);
~melody = Pbind(
    \degree, Pwhite(-4, 11, inf),
	\imsturment, \wood
);


p = Pchain(~melody, ~rhythm).play;
f = Pfx(p,\fbVerb).play;

)
p.stop;