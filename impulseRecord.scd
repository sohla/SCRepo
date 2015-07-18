s.recHeaderFormat = "wav"
s.prepareForRecord

{
	s.record;
	Impulse.ar(1, 0.0, 0.9, 0)!2

}.play

s.stopRecording