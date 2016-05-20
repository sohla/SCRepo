


(
{

	var pba,pbb,sn,sc,cmp,si,verb, nz, pd,ls;
	p = ("~/Music/SCSamples/ding.wav").standardizePath;

	d = Buffer.read(s,p);

	si = SoundIn.ar(0);

	sn = PeakFollower.ar(si,0.5);

	pba = PlayBuf.ar(2,d,BufRateScale.kr(d)/1 + sn,loop: 1);
	pbb = PlayBuf.ar(2,d,BufRateScale.kr(d)/2,loop: 1);

	pd = Pitch.kr(PitchShift.ar(si,0.2,2),400);
	nz = SinOscFB.ar(pd,0.5pi,0.4);

	cmp = Compander.ar(nz, sn,
		thresh: 0.15,
		slopeBelow: 4.0,
		slopeAbove: 1.0,
		clampTime: 0.24,
		relaxTime: 0.1
	);


//	verb = FreeVerb2.ar(cmp,cmp,0.35,0.7,0.0);

	ls = LeakDC.ar(cmp);
	[0,0,0,0,0,0,0,0,ls]



}.play;
)

o = Server.local.options;
o.numOutputBusChannels.postln;
o.numOutputBusChannels = 10; // The next time it boots, this will t