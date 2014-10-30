(
{Pluck.ar(WhiteNoise.ar(0.1), Impulse.kr(4),[40.reciprocal,80.reciprocal], [40.reciprocal,80.reciprocal], 100,
		coef:MouseX.kr(-0.999, 0.999))!2
	}.play(s)
)

