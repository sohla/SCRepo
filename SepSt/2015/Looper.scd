// allocate buffer. Your loops should be shorter
b = Buffer.alloc(s, s.sampleRate * 16, 2);

(
l = {arg t_trig=0, t_reset=1, t_switch, plvl=1, ticknum=4, frombeat=0, grainsize=0, buf=b;
	var in, gate, time, ticklength, firsttrig, ticks, beats, grainstarts, grainlengths,
		grainend, startfrombeat, bufswitch, rlvl, playenv, player, grainer;

	var beatnum = 4;
	// audio input. Change to use other inputs
	in = SoundIn.ar(0) ! 2;

	gate = PulseCount.kr(t_trig, t_reset) > 1;
	time = Latch.kr(Timer.kr(t_trig), gate);
	ticklength = time / (beatnum * ticknum);
	// initial trigger to set play- and recbuf to index 0
	firsttrig = Trig.kr(SetResetFF.kr(t_trig, t_reset), 0.05);

	ticks = TDuty.kr(ticklength, gate, 1) * gate;

	// triggers at each loop cycle beginning + extra trigger at start of first recording
	beats = Trig.kr(PulseCount.kr(ticks, t_reset) % (beatnum * ticknum), 0.1) + firsttrig;
	//Poll.kr(ticks, ticks);

	// values for the loopbuf and switching between it and the playbuf
	grainstarts = Array.series(beatnum, 0, (SampleRate.ir * ticklength * ticknum).round(1));
	grainlengths = [0.25, 0.5, 1, 2, 3, 4];
	startfrombeat = Select.kr(frombeat, grainstarts);
	grainend = startfrombeat + (ticklength * SampleRate.ir / Select.kr(grainsize, grainlengths)).round(1);
	bufswitch = (((PulseCount.kr(t_switch, t_reset) % 2) * 2 ) -1);

	// reclevel gate is read from controlbus index 3
	rlvl = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), PulseCount.kr(t_trig, t_reset) % 2);
	playenv = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), gate);

	player = PlayBuf.ar(2, buf, BufRateScale.kr(buf), beats, loop:1);
	grainer = LoopBuf.ar(2, buf, BufRateScale.kr(buf), bufswitch,
			startfrombeat, startfrombeat, grainend, 2);

	RecordBuf.ar(in <! in, buf, recLevel: rlvl, preLevel:plvl, loop:1, trigger:beats);

	Out.ar(0, LinXFade2.ar(player, grainer, Lag.kr(bufswitch, 0.1), playenv) + in);
}.play;
)
// start recording first loop
l.set(\t_trig, 1);
// stop recording, start looping
l.set(\t_trig, 1);

// switch to LoopBuf
l.set(\t_switch, 1)
// beat 1-4, as 0-3
l.set(\frombeat, 1)
// size of the looped grain 0 - 5
l.set(\grainsize, 2)

// switch back to PlayBuf
l.set(\t_switch, 1)

// overdub
l.set(\t_trig, 1);

// reset and start again
l.set(\t_reset, 1);
b.zero;


//finally, clean up
l.free; b.free;