(

SynthDef(\ringme, {|buffer = 0, pitch = 51, range = 1,delay = 0.04, decay = 0.19|

	var player,sel,fol;
	var modulator;
	var notes = #[0,4,7];
	var root = 42;
	var dly;
	//player = SoundIn.ar(0);
	player = PlayBuf.ar(2,buffer,BufRateScale.kr(buffer),loop: 1) ;
		fol = (PeakFollower.ar(player,0.1) * range).lag(0,0.7);

	modulator = SinOsc.ar( pitch.midicps + fol.midicps,0,player) ;

	dly = CombN.ar((modulator).dup,0.3,[delay,delay+0.01],decay);
	Out.ar(0,dly);

}).send(s);
)





p = "~/Music/VoiceLab/b/Questions/2 How old are you RAW.aif".standardizePath;
p = "~/Music/VoiceLab/templateQuestions/2 How old are you RAW.aif".standardizePath;
c = Buffer.read(s,p);

(
x = Synth(\ringme,[\buffer,c]).autogui(specs:
	(
		\pitch: [10,100,\lin,1,51],
		\range: [0,400.0,\lin,1,1],
		\delay: [0.001,0.3,\lin,0.001,0.04],
		\decay: [0.001,0.5,\lin,0.001,0.19]
));
)

