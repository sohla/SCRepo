
(
{

	// metallic
	var trig, p, exc, x, s,root,scale,g;

		g = EZSlider(label:" vol ");
		g.controlSpec = ControlSpec(0, 1.0, \lin, 0.01, 0.5, "Vol");
		g.action_({ |ez| (ez.value.asString ++" is the value of " ++ ez).postln });

			root = 64;
		scale = #[0,2,4,5,7,9,11];
		trig = Impulse.kr(MouseY.kr(0.05, 10, 1), 0, [0.04,0.03]);

//	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[0.125,0.25,0.375,0.5,0.75,1,1.5,2].normalize,0,[0.04,0.04]), 5.5, 0.05));
	exc = BrownNoise.ar(Decay2.kr(trig,5.5,0.01));
	s = (Klank.ar(
		`[Array.fill(1, {(scale.choose  + root).midicps}),nil,
		Array.fill(16, {rrand(0.1,2.0)})],
		exc) * 0.001).softclip;
}.play
)
