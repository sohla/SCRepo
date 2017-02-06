a

(
{
		var imp = Impulse.kr(10);
	    var delimp = Delay1.kr(imp);

	a = SinOsc.ar(80,0,MouseX.kr(0,1));


	c = K2A.ar(Peak.ar(a, imp).lag(0, 0.01)).poll;

	b = SinOsc.ar(80,0,c);

	Out.ar(0,[a,b]);

}.play
)