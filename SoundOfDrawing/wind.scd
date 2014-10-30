(
{

	var num = 15,gen,sp,verb,fltl,fltr;
	gen = Splay.arFill(num,{
		var freq,mx,my;

		mx = MouseX.kr(0.1,10);
		my = MouseY.kr(1,4,1,10);
		freq= rrand(30,40.3);
		Pan2.ar(SinOsc.ar(Gendy1.ar(26.rand,26.rand,SinOsc.kr(0.1,0,0.49,0.51),
		� � SinOsc.kr(0.13,0,0.49,0.51),freq * mx ,freq , SinOsc.kr(0.17,0,0.49,0.51),
		� � SinOsc.kr(0.19,0,0.49,0.51), 12, 12, 70, 200*my), 0, 0.1), 1.0.rand2);

	});


	fltl = HPF.ar(gen[0],MouseY.kr(5000,50,1.0,10));
	fltr = HPF.ar(gen[1],MouseY.kr(5000,50,1.0,10));

	verb = FreeVerb2.ar(fltl,fltr,0.112,1.0,0.3);


	verb

}.play
)
