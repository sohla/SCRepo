// 38,50,62,74,86,98,110,122
(
{
var n, p;
var exciter, spec,scale,root,out,eq;
		root = #[50,62,74,86,98,110];
		scale = #[0,2,5,8];

		p = 50;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 9.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);
		
		eq = MoogFF.ar(out,MouseX.kr(1000,10000), MouseY.kr(0,3));

		
		
	60.do({ out = AllpassN.ar(out+eq, 0.04, [0.04.rand, 0.04.rand], 2) });
		out = LeakDC.ar(out*0.4);

}.play;
)

 	