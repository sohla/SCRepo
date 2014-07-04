
(
	var titles = [
		"SFX_1021_23.wav"

	];
		p = ("~/Music/sounds/"++titles[0]).standardizePath;
		b = Buffer.read(s, p);
Synth(\simpleEnvSample,[\bufnum,b.bufnum,\pch,1]);


)
