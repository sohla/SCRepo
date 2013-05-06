(
	SynthDef("samplePlayer", { |out=0,bufnum|
	
	Ê Ê Out.ar( out,
	Ê Ê Ê Ê Ê Ê PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum))
	Ê Ê )
	}).send(s);


)

s.sendMsg("/b_allocRead",111)
s.sendMsg("/s_new", "samplePlayer", 2003, 1, 1,"bufnum",111);

