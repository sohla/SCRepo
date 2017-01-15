


(
var nChans = 6;
{
    PanAz.ar(
        nChans,                 // numChans
        ClipNoise.ar,     // in
        LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')), // pos
        0.5,            // level
        1           // width
    );
}.play;
s.scope(nChans);
s.meter(numOuts:nChans);

s.makeGui
)