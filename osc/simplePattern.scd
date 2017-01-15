
(

Pbind(
	\instrument,\cfstring1,
	\octave,3,
    \note, Pseq([0, 5, 7],inf),
    \sustain, Pseq([1, 0.5, 1],inf),
	\amp, Pseq([1,0.4,0.1],inf),
    \dur, Pseq([2,1,1].normalize(4,8),inf),
).play(quant:1);

Pbind(
	\instrument,\cfstring1,
	\octave,4,
    \note, Pseq([0, 5, 7],inf),
    \sustain, Pseq([1, 0.5, 1],inf),
	\amp, Pseq([1,0.4,0.1],inf),
    \dur, Pseq([2,1,1].normalize(2,4),inf),
).play(quant:1);

Pbind(
	\instrument,\cfstring1,
    \note, Pseq([0, 5, 4],inf),
    \sustain, Pseq([1, 0.5, 1],inf),
	\amp, Pseq([1,0.4,0.1],inf),
    \dur, Pseq([2,1,1],inf),
).play(quant:1);


Pbind(
	\instrument,\cfstring1,
	\octave,7,
    \note, Pseq([0, 4, 2],inf),
    \sustain, Pseq([1, 0.5, 1],inf),
	\amp, Pseq([1,0.4,0.1],inf),
    \dur, Pseq([2,1,1].normalize(0.5,1),inf),
).play(quant:1);

)