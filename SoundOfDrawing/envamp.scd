


(
{

	var pba,pbb,sn,sc,cmp,si,verb;
	p = ("~/Music/SCSamples/spookySinging.wav").standardizePath;

	d = Buffer.read(s,p);

	si = SoundIn.ar(0);

	pba = PlayBuf.ar(2,d,BufRateScale.kr(d)/1,loop: 1);
	pbb = PlayBuf.ar(2,d,BufRateScale.kr(d)/2,loop: 1);

	sn = PeakFollower.ar(si,0.01);

	cmp = Compander.ar((pba*1.1)+(pbb*0.5), sn,
		thresh: 0.09,
		slopeBelow: 4.0,
		slopeAbove: 1.0,
		clampTime: 0.24,
		relaxTime: 1.4
	);


	verb = FreeVerb2.ar(cmp,cmp,0.35,0.7,0.0);


	[verb,verb,verb,verb]




}.play;
)
