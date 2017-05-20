(
// something to play with
SynthDef(\help_Bus, { arg out=0,ffreq=100, lfor = 0.1;
    var x;
    x = RLPF.ar(LFPulse.ar(SinOsc.kr(lfor, 0, 10, 21), [0,0.1], 0.1),
            ffreq, 0.1)
            .clip2(0.4);
    Out.ar(out, x);
}).add;

)


x = Synth(\help_Bus);

// get a bus

d = DataBus.new({[100,500,1000].choose.asArray},1);

d.free

x.map(1, d.bus);

d.dT = 0.1;


b = Bus.control(s);
x.map(1, b);
b.value = 100;
b.value = 1000;
b.value = 5;


/*
n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort| [\matching,msg].postln}, '/chat', n); // path matching
m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

m.sendMsg("/chat", 100);


o = OSCBus.new('/chat',m,1);
x.map(1, o.bus);
o.value

*/



