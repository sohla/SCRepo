
(
{
// Klank - excited by noise bursts
var n, p;
var exciter, spec,scale,root,out;
		root = #[40,52,64,76,88,100];
		scale = #[0,2,4,5,7,9,11];

n = 10;	// number of simultaneous instruments
p = 10;	// number of partials per instrument
		exciter = Decay.ar(Dust.ar(MouseY.kr(0.1, 10, 1), 0.01), 9.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 4.0.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);
		
	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });
		out = LeakDC.ar(out);

}.play;
)

