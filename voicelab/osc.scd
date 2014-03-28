n = OSCFunc({|msg, time, addr, recvPort| "BOOM!!!!".postln}, '/test');


m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

m.sendMsg("/test", "Hello App 1");

n.free;
m.disconnect;




a = 0
a = a.even.asInteger