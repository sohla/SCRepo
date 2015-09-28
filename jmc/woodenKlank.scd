(
{
// Klank - excited by noise bursts
var n, p;
var exciter, spec;
var harmonics = [1, 2.572, 4.644, 6.984, 9.723, 12];
n = 5;	// number of simultaneous instruments
p = 8;	// number of partials per instrument
		exciter = Decay.ar(Impulse.ar(2.0,0.5, 0.01), 0.001);
		spec = Array.fill(2, {
			`[
			harmonics * Rand(200,400),
				nil,
			0.1
			]
		});
		Klank.ar(spec, exciter)
}.play;
)


