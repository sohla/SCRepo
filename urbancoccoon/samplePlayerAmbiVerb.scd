(
	SynthDef("samplePlayerAmbi", { |out=0,bufnum|
	
		var w, x, y, p, a, b, c, d,gate,verb;
		var buf = PlayBuf.ar(bufnum.numChannels, bufnum, BufRateScale.kr(bufnum));
		var mix = 0.25, room = 1.15, damp = 0.0;
	
//Ê Ê Ê Ê #w, x, y = PanB2.ar(LPF.ar(buf,1000), MouseX.kr(-1,1), 0.5);



Ê Ê Ê Ê #w, x, y = PanB2.ar(buf, MouseX.kr(-1,1), 0.3);

Ê Ê Ê Ê #a, b= DecodeB2.ar(2, w, x, y) * 10;
		
		
Ê Ê Ê Ê 
		verb = GVerb.ar(
Ê Ê Ê Ê Ê Ê Ê Ê a,
Ê Ê Ê Ê Ê Ê Ê Ê 26,
Ê Ê Ê Ê Ê Ê Ê Ê 1.24,
Ê Ê Ê Ê Ê Ê Ê Ê 0.1,
Ê Ê Ê Ê Ê Ê Ê Ê0.95,
Ê Ê Ê Ê Ê Ê Ê Ê 15,
Ê Ê Ê Ê Ê Ê Ê Ê -3.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê -22.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê -17.dbamp,
Ê Ê Ê Ê Ê Ê Ê Ê 26, 0.3);



		Out.ar( out,[a+verb,b+verb])
	
	}).send(s);


)

s.sendMsg("/b_allocRead",111,"sounds/memo1.wav");
s.sendMsg("/s_new", "samplePlayerAmbi", 2003, 1, 1,"bufnum",111);
s.sendMsg("/n_free",2003);
