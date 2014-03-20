
(
s.boot.doWhenBooted{
~fftsize = 1024;
b = Buffer.alloc(s, ~fftsize, 1);
d = Buffer.alloc(s, ~fftsize, 1);

c = Buffer.read(s,"Applications/SuperCollider3.6/sounds/darkforest.wav");
e = Buffer.read(s,"Applications/SuperCollider3.6/sounds/STRNGD1.wav");

f = Buffer.alloc(s, ~fftsize, 1);
	f.sine2([1,2,3,4],1.0 / [1, 2, 3, 4], true, true, true);
}
)

(
x = {
	var in, chain, in2, chain2, out;
	in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);

	//in2 = SinOsc.ar([200,400],0,[0.3,0.1]);
	// in2 = PlayBuf.ar(1, f, BufRateScale.kr(f)*10, loop: 1);
	in2 = Klank.ar(`[2*[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar([0.007, 0.007])) ;

	chain = FFT(b, in);
	chain2 = FFT(d, in2);

	chain = chain.pvcalc2(chain2, b.numFrames, {|mags, phases, mags2, phases2|
		[mags * mags2, phases2 + phases]
	}, frombin: 0, tobin: 125, zeroothers: 1);

	out = IFFT(chain);
	Out.ar(0,0.5 * out.dup);
}.play(s);
	)
x.free;
