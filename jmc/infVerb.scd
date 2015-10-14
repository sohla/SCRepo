(
{

	var sig,local,max;

	sig = SoundIn.ar.(0);
	local = LocalIn.ar(2) + sig.dup;
	max = 0.09;

	10.do{
		local = AllpassN.ar(local,max,Rand(0.001,max),3)
	};

	LocalOut.ar(local * 0.0);

	Out.ar(0, sig + local);

}.play;
)


