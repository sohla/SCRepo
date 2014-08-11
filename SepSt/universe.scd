(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[50];
//		root = #[69,57,81];
		scale = #[0,7,10];

		p = 10;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 9.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps + 21} ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);


		out = HPF.ar(out,MouseX.kr(50,2000,1));

//	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });


	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)},
	1,
	1,
	0);

		out = LeakDC.ar(out) * (MouseX.kr(0.3,10,1,0.2));

		[out*0.1,out*0.1,out,out,0,0]


}.play;
)

