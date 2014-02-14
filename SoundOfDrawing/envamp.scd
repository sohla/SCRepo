


(
{

	var pba,pbb,sn,sc,cmp,si,verb;
	
	d = Buffer.read(s,"sounds/darkforest.wav");

	si = SoundIn.ar(0);
	
	pba = PlayBuf.ar(2,d,BufRateScale.kr(d)*2,loop: 1);
	pbb = PlayBuf.ar(1,d,BufRateScale.kr(d)/1,loop: 1);
	
	sn = PeakFollower.ar(si,0.01);
	
	cmp = Compander.ar(pbb, sn,
		thresh: 0.09,
		slopeBelow: 4.0,
		slopeAbove: 1.0,
		clampTime: 0.24,
		relaxTime: 0.08
	);
	
	
	verb = FreeVerb2.ar(cmp,cmp,0.75,1.0,0.0);

		
	[cmp,cmp]
	



}.play;
)



//d.free;

