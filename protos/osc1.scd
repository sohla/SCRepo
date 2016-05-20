NetAddr.localAddr
NetAddr.langPort



NetAddr.matchLangIP("169.254.143.85");
NetAddr.matchLangIP("127.0.0.1");
NetAddr.matchLangIP("169.254.27.1");



n = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr
n.sendMsg("/hello world");
n.ip


b = NetAddr.new("10.1.1.7", 9999);
b.sendMsg("/hello world");

// create the OSCresponderNode
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/goodbye', b);
o.free;    // remove the OSCFunc when you are done.


o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/goodbye'); // create the OSCresponderNode
o.free;    // remove the OSCresponderNode when you are done.



OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off



l = OSCresponderNode(nil, '/test', { |t, r, msg| msg.postln }).add;
o.remove;




e = NetAddr.new("10.1.1.7", 9000);
e.sendMsg("/hello world");


o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/hi'); // create the OSCresponderNode
o.free;    // remove the OSCresponderNode when you are done.


