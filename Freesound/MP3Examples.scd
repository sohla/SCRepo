(
SynthDef("help_mp3_01", { |bufnum = 0|
	var son, wibble;
	 son = DiskIn.ar(1, bufnum);
	// wibble = LFPar.kr(0.1).range(0.5, 2.0);
	//son = PitchShift.ar(son, pitchRatio: wi1bble);
	Out.ar(0, son!2);
}).load(s);
)

// Now let's create the MP3 object and cue it into a Buffer.

// Choose one of these two:
// (a) a stream URL - note the use of the second argument to indicate a remote stream
m = MP3("http://www.tonycuffe.com/mp3/girlwho_lo.mp3", \readurl);
// (b) a local file
m = MP3("/Users/dan/Music/SqueezeTheTrigger(Version1).mp3");
m = MP3("/tmp/Boy Scream.mp3");




m = MP3("http://www.tonycuffe.com/mp3/girlwho.mp3", \readurl);
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


/////////////////////////////////////////////////////

// Reading into a buffer is possible, but you *must* specify the number of (uncompressed) frames to read.
m = MP3("http://icecast.commedia.org.uk:8000/resonance.mp3", \readurl);
m = MP3("https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3", \readurl);
m.start;
b= Buffer.read(s, m.fifo, 0, 50000);
// After a second or two, should be able to play a snatch of the stream
b.play;

// Please remember to tidy up after yourself:
b.close; b.free;
m.finish;


/////////////////////////////////////////////////////

// Alternatively, a method is provided for reading a local MP3 file more easily (won't work on streams)
s.boot;
b = MP3.readToBuffer(s, "/tmp/Boy Scream.mp3");
b.play;

b.free;


/////////////////////////////////////////////////////

// Writing an MP3 file using DiskOut. See the DiskOut helpfile for more on this.
(
SynthDef("help_mp3_02", { |bufnum = 0|
	var son;
	son = SinOsc.ar(SinOsc.ar(Line.kr(1, 100, 10, doneAction:2)).range(220, 550)) * 0.1;
	son = son.dup;
	Out.ar(0, son);
	DiskOut.ar(bufnum, son);
}).load(s);
)
// Create an MP3 object for writing
m = MP3("recordings/mp3test.mp3", \writefile);
m.start;
// allocate a disk i/o buffer
b = Buffer.alloc(s, 65536, 2);
// Start writing
b.write(m.fifo, "raw", "int16", 0, 0, true);

x = Synth("help_mp3_02", [\bufnum, b.bufnum], addAction:\addToTail);

// once the writing has stopped, tidy up
b.close; b.free;
m.finish;