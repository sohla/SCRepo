
(
	var notes, on, off;
	
	MIDIIn.connect;
	
	notes = Array.newClear(128); Ê Ê// array has one slot per possible MIDI note
	
	on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	Ê Ê Ê Ê notes[num] = Synth(\default, [\freq, num.midicps,
	Ê Ê Ê Ê Ê Ê Ê Ê \amp, veloc * 0.00315]);
	});
	
	off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	Ê Ê Ê Ê notes[num].release;
	});
	
	q = { on.free; off.free; };
)

