(
	SynthDef("samplePlayerAmbi", { |out=0,bufnum|
	
		var w, x, y, p, a, b, c, d,gate,verb;
		var buf = PlayBuf.ar(bufnum.numChannels, bufnum, BufRateScale.kr(bufnum));
		var mix = 0.25, room = 1.15, damp = 0.0;
	
//� � � � #w, x, y = PanB2.ar(LPF.ar(buf,1000), MouseX.kr(-1,1), 0.5);



� � � � #w, x, y = PanB2.ar(buf, MouseX.kr(-1,1), 1.0);

� � � � #a, b= DecodeB2.ar(2, w, x, y) * 10;
		
		
� � � � 
		verb = GVerb.ar(
� � � � � � � � a,
� � � � � � � � 26,
� � � � � � � � 1.24,
� � � � � � � � 0.1,
� � � � � � � �0.95,
� � � � � � � � 15,
� � � � � � � � -3.dbamp,
� � � � � � � � -22.dbamp,
� � � � � � � � -17.dbamp,
� � � � � � � � 26, 0.3);



		Out.ar( out,[a+verb,b+verb])
	
	}).send(s);


)

s.sendMsg("/b_allocRead",111,"sounds/memo1.wav");
s.sendMsg("/s_new", "samplePlayerAmbi", 2003, 1, 1,"bufnum",111);

