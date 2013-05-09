//[40,52,64,76,88,100]
(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[52,64,76,88,100];
		scale = #[0,2,4,5,7];

		p = 150;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 9.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);
		
	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });
		out = LeakDC.ar(out);

}.play;
)

 