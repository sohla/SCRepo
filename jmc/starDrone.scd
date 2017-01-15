//[40,52,64,76,88,100]
(
{
	var n, p;
	var exciter, spec,scale,root,out;
	root = #[62,74,86,98,110];
	scale = #[0,2,5,7];

	p = 10;
	exciter = Decay.ar(LFDNoise0.ar(16000,0.00001), 0.5);
	spec = Array.fill(2, {
		`[
			Array.fill(p, { arg i; (scale.choose  + root.choose).midicps } ),
			nil,
			Array.fill(p, { 0.2 + 0.1.linrand } )
		]
	});

	out = Klank.ar(spec, exciter);

	Splay.arFill(10,{
		out = AllpassN.ar(out, 0.04, [0.04.rand, 0.04.rand], 2)
	},1,1,0);

	out = LeakDC.ar(out);

}.play;
)



(

SynthDef("starDrone",{ |out, atk=9.0, gate=1.0, dcy=1.0, rls=1.0, amp=2.0, dns=16000|

	var n, p,sig;
	var exciter, spec;
	var roots = NamedControl.kr(\roots, #[60,60,60,60]).asArray;
	var harms = NamedControl.kr(\harms, #[0,0,0,0,0]).asArray;

	p = 10;
	exciter = Decay.ar(LFDNoise0.ar(dns,0.00005), 0.1);
	spec = Array.fill(2, {
		`[
			Array.fill(p, { arg i; (harms.choose  + roots.choose).midicps } ),
			nil,
			Array.fill(p, { 0.2 + 0.1.linrand } )
		]
	});

	sig = Klank.ar(spec, exciter) * EnvGen.kr(Env.adsr(atk,dcy,1,rls),gate) * amp;



	Splay.arFill(10,{
		sig = AllpassN.ar(sig, 0.04, [0.04.rand, 0.04.rand], 2)
	},1,1,0);

	sig = LeakDC.ar(sig);

	Out.ar(out,sig);

	}).send(s);

)
z = Synth(\starDrone,[\atk,46,\amp,0.2,\roots,#[57,45,50,50],\harms,#[0,0,0,7]]);
z.set(\rls,51,\gate,0)

z = Synth(\starDrone,[\amp,0.05,\roots,#[38,38,50,50],\harms,#[-2,-2,-2,-2]]);
z.set(\rls,21,\gate,0)

z = Synth(\starDrone,[\amp,0.2,\roots,#[26,38,50,50],\harms,#[2,2,2,2]]);
z.set(\rls,21,\gate,0)



x = Synth(\starDrone,[\roots,#[74,86,98,110],\harms,#[0,2,4,7]]);
x.set(\rls,46,\gate,0)


x = Synth(\starDrone,[\roots,#[62,74,86,98,110],\harms,#[0,2,4,7]]);
x.set(\rls,26,\gate,0)

x = Synth(\starDrone,[\roots,#[62,74,86,98],\harms,#[0,2,5,8]]);
x.set(\rls,56,\gate,0)



y = Synth(\starDrone,[\atk,6,\roots,#[86,98,110,98],\harms,#[0,2,4,7]]);
y.set(\rls,56,\gate,0)




w = Synth(\starDrone,[\atk,36,\roots,#[74,86,98],\harms,#[0,2,5,7]]);
w.set(\rls,46,\gate,0)


s.recHeaderFormat = "wav";

Server.local.makeWindow