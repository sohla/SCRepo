(
FSSound.textSearch(
	query: "cave drip",
	filter: "duration:[20 TO 40]",
	params:('page':1),
	action: {|p|

		var snd = p[0]; // first result
		var path = PathName.new("~/Music/SoundNarative/").asAbsolutePath;

		// snd.postln;
		// snd.name.splitext[0].postln;
		// snd.tags.postln;
		// snd.images.waveform_l.postln;


		snd.retrievePreview(path,{|a|
			"retrievePreview".postln;


			p = PathName.new("~/Music/SoundNarative/"++(snd.name.splitext[0]++".mp3")).asAbsolutePath;
			p.postln;
			b = MP3.readToBuffer(s, p,action:{|a|
			"done".postln;
			b.numChannels.postln;
			b.bufnum.postln;
			{
				PlayBuf.ar(b.numChannels,b.bufnum,BufRateScale.kr(b.bufnum),loop:1,doneAction:2)
				* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine))

			}.play;

	});

		},"hq","mp3");

	});
)

