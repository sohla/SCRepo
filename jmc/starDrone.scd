//[40,52,64,76,88,100]
(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[72,86,98,110];
		scale = #[0,2,5,7];

		p = 10;
		exciter = Decay.ar(LFDNoise0.ar(16000,0.00001), 0.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);

//	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });


	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)},
	1,
	1,
	0);

		out = LeakDC.ar(out);

}.play;
)





(
SynthDef("help-LFClipNoise", { arg out=0;
    Out.ar(out,
        LFClipNoise.ar(1000, 0.25)
    )
}).play;
)
