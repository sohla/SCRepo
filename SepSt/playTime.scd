(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[77,65,89];
//		root = #[69,57,81];
		scale = #[0,4,7,9,11,14];

		p = 10;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 0.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps + 21} ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, Decay.ar(Impulse.ar(1.0,0.1),10.0)) * 0.001;
		
		
//		out = HPF.ar(out,MouseX.kr(50,2000,1));
		
//	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });
	
	
	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.4, [0.4.rand, 0.4.rand], 1)},
	2,
	3,
	0);
	
		out = LeakDC.ar(out) * (MouseX.kr(0.3,10,1,0.2));
		
		[out*0.7,out*0.7,out,out,0,0]

}.play;
)

