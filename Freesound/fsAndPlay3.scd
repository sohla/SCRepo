(
SynthDef("bufplayerMono", { |bufnum = 0, volume = 0.0, gate = 1|
	 var son;
	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
	* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine),gate) * volume;

	Out.ar(0, son!2);
}).load(s);

SynthDef("bufplayerStereo", { |bufnum = 0, volume = 0.0, gate = 1|
	 var son;
	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
	* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine),gate) * volume;

	Out.ar(0, son);
}).load(s);

)


(
var dir = PathName.new("~/Music/SoundNarative/");
var buffer,sfv,slider,title;
var samplerNode;

w = Window.new.bounds_(Rect(0,200,740,200)).front;
sfv = SoundFileView.new(w, Rect(20,20, 700, 160));
slider = Slider(w, Rect(20, 0, 700, 20)).value_(0.0);
title = StaticText(w,Rect(20, 180, 700, 20)).string_("-");


sfv.gridOn = false;            // time grid, 1 second by default,
sfv.backColor_(Color.grey);
sfv.rmsColor_(Color.blue.alpha_(0.4));
sfv.peakColor_(Color.blue.alpha_(0.3));
sfv.setSelectionColor(0, Color.black.alpha_(0.2));  // set...( index, value )

//check repsonse by checking if result responds to....

FSSound.textSearch(
	query: "synth loop",
	filter: "duration:[1 TO 5]",
	params:('page':1),
	action: {|snd|

		snd[0].retrievePreview(dir.asAbsolutePath,{|a|



			p = dir +/+ PathName(snd[0].name.splitext[0]++".mp3");
			p.postln;
			buffer = MP3.readToBuffer(s, p.asAbsolutePath,action:{|a|
			buffer.postln;
				samplerNode = s.nextNodeID;
				buffer.numChannels.switch(

					1,{s.sendMsg("/s_new", "bufplayerMono", samplerNode, 0, 0,\bufnum, buffer.bufnum);},
					2,{s.sendMsg("/s_new", "bufplayerStereo", samplerNode, 0, 0,\bufnum, buffer.bufnum);}

				);

				Routine{
					buffer.loadToFloatArray(action:{ |data|

						{
							sfv.setData(data,
								2,
								0,
								buffer.numChannels,
								buffer.sampleRate.asInteger);

								title.string_(snd[0].name.splitext[0]);

						}.defer;


						slider.action_({|c|
							s.sendMsg("/n_set",samplerNode,\volume,c.value);
						});
					});

				}.play(AppClock);
			});
		},"hq","mp3");
	}
);

w.onClose = ({
	s.sendMsg("/n_free", samplerNode);
	buffer.close;
	buffer.free;

//	Buffer.freeAll;
//	s.freeAll;

});
CmdPeriod.doOnce({
	s.sendMsg("/n_free", samplerNode);
	buffer.close;
	buffer.free;

	w.close;
//	Buffer.freeAll;
//	s.freeAll;


});



)
