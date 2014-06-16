// 38,50,62,74,86,98,110,122


// 29,41,53,65,77,89,101,113,125
(
{
var n, p;
var exciter, spec,scale,root,out,eq,envelope;
		root = #[65,77,89,101];
		scale = #[0,7,16,19];

		p = 26;
		exciter = Decay.ar(PinkNoise.ar(0.0001), 0.1);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { arg i; (scale.choose  + root.choose - 48).midicps } ),
				nil,
				Array.fill(p, { 0.2 + 0.1.linrand } )
			]
	});
		out = Klank.ar(spec, exciter);
		
		eq = HPF.ar(out,50);

		out = eq;
		
	10.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 4) });
		out = LeakDC.ar(out*2.3);
		
				envelope = EnvGen.kr(Env.asr(5,1.0,5, curve: \sin), 1, doneAction:2);

		Out.ar(0,out*envelope);

}.play;
)





(
	SynthDef( "forestdrone",{
			arg gate=1;
			var n, p;
			var exciter, spec,scale,root,out,eq,envelope;
			root = #[29,41,53];
			scale = #[0];
	
			p = 10;
			exciter = Decay.ar(PinkNoise.ar(0.0001), 0.1);
			spec = Array.fill(2, {
				`[
					Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
					nil,
					Array.fill(p, { 0.2 + 0.1.linrand } )
				]
			});
			out = Klank.ar(spec, exciter);
			eq = HPF.ar(out,300);
			out = eq;
			
			10.do({ out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 4) });
			out = LeakDC.ar(out*2.3);
			envelope = EnvGen.kr(Env.asr(5,1.0,5, curve: \sin), gate, doneAction:2);
	
			Out.ar(0,out*envelope);
		}).send(s);
)


s.sendMsg("/s_new", "forestdrone", 2000, 1, 1);
s.sendMsg("/n_set",2000,"gate",0);


s.sendMsg("/s_new", "forestdrone", 2001, 1, 1);
s.sendMsg("/n_set",2001,"gate",0);

s.sendMsg("/s_new", "forestdrone", 2002, 1, 1);
s.sendMsg("/n_set",2002,"gate",0);
