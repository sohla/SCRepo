


(
var nChans = 4;
{
	var sig;

	// sig = ClipNoise.ar;
	sig = Gendy1.ar(minfreq:10,maxfreq:40)*0.6;

    PanAz.ar(
        nChans,
        sig,
        LFSaw.kr(MouseX.kr(0.2, 180, 'exponential')),
        0.5,
        1
    );
}.play;
s.scope(nChans);
s.meter(numOuts:nChans);
s.makeGui

)


{Pan2.ar(Gendy1.ar(minfreq:10,maxfreq:40))*0.6}.play
