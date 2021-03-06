(
a = {
	var modulator, mod1, mod2, mod3;

	// repeat time is 0.7s: equates to 1.43 Hz.
	modulator = LFSaw.ar(MouseX.kr(1.43,40), 1, 0.5, 0.5);
	mod2 = (modulator * 40.6 * 2pi).cos.squared;
	mod3 = modulator * 3147;
	mod3 = (mod3 * 2pi).cos + ((mod3 * 2 * 2pi).cos * 0.3);
	mod1 = ((Wrap.ar(modulator.min(0.1714) * 5.84) - 0.5).squared * (-4) + 1) * (mod2 * mod3);
	mod1 = (mod1 * 0.1)!2;
}.play;
)

