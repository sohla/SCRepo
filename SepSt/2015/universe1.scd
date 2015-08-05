(
{
	var n, p;
	var exciter, spec,scale,root,out;
	root = #[40,52,64,76];
	scale = #[0,7,16,2];


	p = 6;
	exciter = Decay.ar(BrownNoise.ar(0.00007), 0.001);
	spec = Array.fill(4, {
		`[
			Array.fill(p, { arg i; (scale.choose  + root.choose -2).midicps } ),
			nil,
			Array.fill(p, { 4.02 + 0.1.linrand } )
		]
	});
	out = Klank.ar(spec, exciter);


	out = HPF.ar(out,
		Lag.kr(
			MouseX.kr(50,8000,1),
			0.5)
	);

	//10.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });


	Splay.arFill(p,
		out,
		1,
		0.2,
		0);

	out = LeakDC.ar(out) * Lag.kr(MouseX.kr(0.3,10,1,0.2),lagTime:20.5);

	out


}.play;
)

//Server.default.makeGui


