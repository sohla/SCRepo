

// get some details of sc server/machine
NetAddr.localAddr.port
NetAddr.localAddr.ip


// listen to a OSC message. default is listening to sc (127.0.0.1 / 57120)
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/helloWorld');

// create an address which to send from. For a loopback, it is SC server defaults
m = NetAddr(NetAddr.localAddr.ip, NetAddr.localAddr.port); // loopback
m.sendMsg("/helloWorld", "HI!");

// to stop listening
o.free


// local sc server
m = NetAddr(NetAddr.localAddr.ip, NetAddr.localAddr.port); // loopback

// listen to a OSC message. this time set it manually
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/localServer', m);

// send a message
m.sendMsg("/localServer", "set manual oscfunc");

// to stop listening
o.free




m = NetAddr(NetAddr.localAddr.ip, NetAddr.localAddr.port); // loopback
m.sendMsg("/ard", "HI!");

o = OSCresponderNode(nil, '/ard', { |t, r, msg| [t,r,msg].postln }).add;
o.remove


m = NetAddr(NetAddr.localAddr.ip, NetAddr.localAddr.port); // loopback
m.sendMsg("/ard", "HI!");

o = OSCFunc({ |msg, time, addr, recvPort|
	[msg, time, addr, recvPort].postln;
}, '/ard');

o.free



m = NetAddr(NetAddr.localAddr.ip, 9000); // loopback
m.sendMsg("/ard", "HI!");

n = NetAddr("127.0.0.1", 9000); // loopback
n.sendMsg("/ard1", 0.6);


m = NetAddr("10.1.1.6", 9000); // loopback
m.sendMsg("/go", 1.0);
m.sendMsg("/go", 0);



o = OSCFunc({ |msg, time, addr, recvPort|
	[msg, time, addr, recvPort].postln;
}, '/ard');

o.free
