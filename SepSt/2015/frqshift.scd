

{
	a = FreqShift.ar(
		SoundIn.ar([0,1]),
		MouseX.kr(0,800),
		0.1,
		[0.5,0.5],
		mul:MouseY.kr(0,1)
	);


	LPF.ar( HPF.ar(a,100),8000)

}.play(s);


{
	a = FreqShift.ar(
		SoundIn.ar([0,1]),
		0,//MouseX.kr(0,800),
		MouseX.kr(0,2pi),
		[0.5,0.5],
		mul:MouseY.kr(0,1)
	)+SoundIn.ar([0,1],mul:MouseY.kr(1,0));


	LPF.ar( HPF.ar(a,100),2000)

}.play(s);
