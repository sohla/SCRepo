s.boot;

Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(2).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 2, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );

Ndef(\lfo, { LFNoise1.kr(3, 400, 800) });
Ndef(\sound).map(\freq, Ndef(\lfo));
Ndef(\sound, { arg freq; SinOsc.ar([600, 635] + freq, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\lfo, { LFNoise1.kr(300, 400, 800) });

Ndef.clear; //clear all Ndefs




(
SynthDef("bufplayerMono", { |bufnum = 0, volume = 1.0|
	 var son;
	son = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
	* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine)) * volume;

	Out.ar(0, son!2);
}).load(s);

SynthDef("bufplayerStereo", { |bufnum = 0, volume = 1.0|
	 var son;
	son = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum),loop:1,doneAction:2)
	* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine)) * volume;

	Out.ar(0, son);
}).load(s);

)


p = ("~/Music/SCSamples/screamTexture1.wav").standardizePath;
c = Buffer.read(s, p);
d = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

b = c;

Ndef(\sound).play;
Ndef(\sound).fadeTime = 5;
Ndef(\sound, {

	 var son;
	son = PlayBuf.ar(1,b.bufnum,BufRateScale.kr(b.bufnum),loop:1)
	* EnvGen.kr(Env.asr(1.8,1.0,1.8,\sine)) * 1;

	Out.ar(0, son!2);

});


c.free;
d.free;
Ndef.clear; //clear all Ndefs






b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
s.sendMsg("/s_new", "bufplayerMono", 1001, 0, 0,\bufnum, b.bufnum);
s.sendMsg("/n_free", 1001);
b.free;