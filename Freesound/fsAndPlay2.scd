(
SynthDef("bufplayer", { |numChannels, bufnum = 0|
	var son = PlayBuf.ar(numChannels,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
			* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine));

	Out.ar(0, son!2);
}).load(s);
)


(
var dir = PathName.new("~/Music/SoundNarative/");
var buffer,sfv,synth;

w = Window.new.bounds_(Rect(0,200,740,200)).front;
sfv = SoundFileView.new(w, Rect(20,20, 700, 160));

sfv.gridOn = false;            // time grid, 1 second by default,
sfv.backColor_(Color.grey);
sfv.rmsColor_(Color.blue.alpha_(0.4));
sfv.peakColor_(Color.blue.alpha_(0.3));
sfv.setSelectionColor(0, Color.black.alpha_(0.2));  // set...( index, value )


FSSound.textSearch(
	query: "120 synth loop",
	filter: "duration:[1 TO 4]",
	params:('page':1),
	action: {|snd|

		snd[0].retrievePreview(dir.asAbsolutePath,{|a|



			p = dir +/+ PathName(snd[0].name.splitext[0]++".mp3");

			buffer = MP3.readToBuffer(s, p.asAbsolutePath,action:{|a|
				synth = {
					PlayBuf.ar(buffer.numChannels,buffer.bufnum,BufRateScale.kr(buffer.bufnum),loop:1,doneAction:2)
					* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine));
				}.play;
				Routine{
					buffer.loadToFloatArray(action:{ |data|

						{sfv.setData(data,2,0,buffer.numChannels,buffer.sampleRate.asInteger);}.defer;

					});

				}.play(AppClock);
			});
		},"hq","mp3");
	}
);

w.onClose = ({
	synth.free;
	buffer.close;
	buffer.free;

//	Buffer.freeAll;
//	s.freeAll;

});
CmdPeriod.doOnce({
	synth.free;
	buffer.close;
	buffer.free;

	w.close;
//	Buffer.freeAll;
//	s.freeAll;


});



)
