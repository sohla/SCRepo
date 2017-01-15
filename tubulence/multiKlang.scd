
(

	var exciter, spec,scale,root,out;
	root = #[62,74,86,98,110];
	scale = #[0,2,5,7];

{ Klang.ar([
	`[ Array.rand(10, 100, 200.0), nil, nil ],
	`[ Array.rand(10, 200.0, 300.0), nil, nil ],
	`[ Array.rand(10, 400.0, 500.0), nil, nil ],
	`[ Array.rand(10, 600.0, 700.0), nil, nil ],
	`[ Array.rand(10, 700.0, 800.0), nil, nil ]
], 1, 0) * 0.05;

}.play;

s.scope(5);
)







(

	var p,exciter, spec,scale,root,out;
	p = 10;
	root = #[62,74,86];
	scale = #[0,2,5,7];
	exciter = Decay.ar(LFDNoise0.ar(16000,0.00001), 1);

{ Klang.ar([
	`[ Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ), nil, nil ],
	`[ Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ), nil, nil ],
	`[ Array.rand(10, 400.0, 500.0), nil, nil ],
	`[ Array.rand(10, 600.0, 700.0), nil, nil ],
	`[ Array.rand(10, 700.0, 800.0), nil, nil ]
], 1, 0) * 0.05;

}.play;

//s.scope(5);
)





(
{
	var n, p;
	var exciter, spec,scale,root,out,octave;
	octave =  1;
	root = #[62];
	scale = #[0,4,7];

	p = 10;
	exciter = Decay.ar(LFDNoise0.ar(16000,0.00001), 1);
	spec = Array.fill(2, {
		`[
			Array.fill(p, { arg i; (scale.choose  + root.choose + (12 * octave)+2).midicps - 3 } ),
			nil,
			Array.fill(p, { 0.8 + 0.1.linrand } )
		]
	});

	out = Klank.ar(spec, exciter);

	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)
	},1,1,0);

	out = LeakDC.ar(out*2)!8;

}.play;
)
s.scope(5);

s.meter(numOuts:8)



o = Server.local.options;

o.device = "Dante Virtual Soundcard"
o.device
o.numOutputBusChannels = 8
o.numOutputBusChannels
o.sampleRate = 48000
o.sampleRate
s.boot
s.quit
