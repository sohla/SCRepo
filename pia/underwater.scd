(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[76];
		scale = #[-12,0,7,9,14,16];

		p = 10;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 9.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);



	Splay.arFill(2,{
		out = AllpassN.ar(out, 0.1, [0.09.rand, 0.09.rand], 4)},
	1,
	1,
	0);

		out = LeakDC.ar(out);

}.play;
)

 