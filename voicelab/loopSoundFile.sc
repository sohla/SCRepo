
(   
	p = "~/Music/sounds/4SecSig.wav".standardizePath;
	f = SoundFile.openRead(p);
	r = Routine { arg inval;
		loop {
			// thisThread refers to the routine.
			postf("beats: % seconds: % time: % \n",
			hisThread.beats, thisThread.seconds, Main.elapsedTime
			);
	
	
			e = f.cue((amp:0.1),playNow:true,closeWhenDone:false);

			f.duration.wait;

		}
	}.play;
)




