
(

	
	SynthDef(\forestdrone, { |octave = 3, note = 0|
		
			var n, p;
			var exciter, spec,scale,root,out;

			root = 28 + (octave * 12) + note;//#[52,64,76,88,100,112,124];
			scale = #[0,2,4,5,7];
	
			p = 10;
			exciter = Decay.ar(PinkNoise.ar(0.0001), 9.1);
			spec = Array.fill(2, {
				`[
					Array.fill(p, { arg i; (scale.choose  + root).midicps } ),
					nil,
					Array.fill(p, { 0.2 + 0.1.linrand } )
				]
		});
		
		out = Klank.ar(spec, exciter);
			
		60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });
		out = LeakDC.ar(out);
		
		Out.ar(0,out);	
		
	}).send(s);

)

x = Synth(\forestdrone,[\octave,4,\note,2]);
x.free;



//[52,64,76,88,100,112,124]
(
{
var n, p;
var exciter, spec,scale,root,out;
		root = #[52,64,76,];
		scale = #[0,2,4,5,7];

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
		
	60.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2) });
		out = LeakDC.ar(out);

}.play;
)

 