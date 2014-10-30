(
{
	var n, p;
	var exciter, spec,scale,root,out;
	root = #[36,48];
	scale = #[0,11,14,15];

	// root = #[40];
	// scale = #[0,7,12];

	p = 10;
	exciter = Decay.ar(BrownNoise.ar(0.00005), 0.001);
	spec = Array.fill(4, {
		`[
			Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
			nil,
			Array.fill(p, { 4.02 + 0.1.linrand } )
		]
	});
	out = Klank.ar(spec, exciter);


	out = HPF.ar(out,MouseX.kr(50,2000,1));

	//	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });


	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)},
		1,
		0.2,
		0);

	out = LeakDC.ar(out) * (MouseX.kr(0.3,10,1,0.2));

	out


}.play;
)

