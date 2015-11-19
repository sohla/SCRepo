//[40,52,64,76,88,100]
(
{
var n, p;
var exciter, spec,scale,root,out;
	// root = #[62,74,86];
	// scale = #[0,2,5,7,9,11];
	// root = #[69,81,93,105];
	// scale = #[0,2,7];
	//
	root = #[60,72,84,96];
	scale = #[0];
	//
	//
	root = #[52,64,76];
	scale = #[0,2,7,9];
// root = #[57];
	// scale = #[0];

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

//	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });


	Splay.arFill(50,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)},
	1,
	1,
	0);

		out = LeakDC.ar(out*0.8);

}.play;
)

 Server.local.makeWindow