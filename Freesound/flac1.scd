(
p = PathName.new("~/Music/SoundNarative/");

f = SoundFile.new.headerFormat_("FLAC").numChannels_(1);

(p.asAbsolutePath++"myfile.aiff").postln;

f.openWrite(p.asAbsolutePath++"myfile.flac");
    // sawtooth
b = Signal.sineFill(100, (1..20).reciprocal);
    // write multiple cycles (441 * 100 = 1 sec worth)
441.do({ f.writeData(b) });
f.close;
)


