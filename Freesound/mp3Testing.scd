(
SynthDef("help_mp3_01", { |bufnum = 0|
	var son;
	 son = DiskIn.ar(2, bufnum);
	Out.ar(0, son!2);
}).load(s);
)

// local file
m = MP3("/tmp/Boy Scream.mp3");

// streamed file
m = MP3("https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3", \readurl);



m.start;




// local example
(
	m = MP3("/tmp/Boy Scream.mp3");
	m.start;
	b = Buffer.cueSoundFile(s, m.fifo, 0, 1);
	x = Synth("help_mp3_01", [\bufnum, b.bufnum], addAction:\addToTail);
)

(
	x.free;
	b.close; b.free;
	m.finish;
)


"echo one; sleep 1; echo two; sleep 1".unixCmd { |res, pid| [\done, res, pid].postln };
// stream example

m = MP3("https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3", \readurl);
m.start;


// Now you can use it almost like any other file, by reading from m.fifo
b = Buffer.cueSoundFile(s, m.fifo, 0, 1);
x = Synth("help_mp3_01", [\bufnum, b.bufnum], addAction:\addToTail);

m.playing;

// You can stop and restart the piping (with a bit of a delay) - note what happens
m.stop;
m.playing;
m.start;
m.playing;

// Please remember to tidy up after yourself:
x.free;
b.close; b.free;
m.finish;



(

	p = PathName.new("~/Music/SoundNarative/Comical Screams.mp3").asAbsolutePath;
	b = MP3.readToBuffer(s, p,action:{|a|
		"done".postln;
		b.numChannels.postln;
		b.bufnum.postln;
		{
			PlayBuf.ar(b.numChannels,b.bufnum,BufRateScale.kr(b.bufnum),doneAction:2)
			* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine))

		}.play;

	});

)

b
b.free;


