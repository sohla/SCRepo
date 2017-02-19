
~objectFactory = { |pos = 1|

	var object = (	
		p:pos,
		f:{|self,args| [self,args].postln}
	);
	object;

};

// a = ~objectFactory.(pos:22);
// a.f("hello world")



(

{
	AllpassN.ar(
	PMOsc.ar(40,SinOsc.ar(0.07,0,30,80),SinOsc.ar(0.7,0.4,3),mul:0.3)!2,
	0.2,
	[0.145,0.189])


}.scope(zoom:3).play;
)