NetAddr.langPort; // retrieve the current port SC is listening to

NetAddr.localAddr; // retrieve the current IP and port

NetAddr.disconnectAll
n = NetAddr.new("192.168.0.116", 58100); // create the NetAddr
// create the OSCresponderNode
o = OSCresponderNode.new(nil, "/cue/1/start", { arg time, resp, msg; [time,resp,msg].postln; } ).add;


o.remove; // remove the OSCresponderNode when you are done.


o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/goodbye', n);
o.free;    // remove the OSCFunc when you are done.


OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false);






o = OSCresponderNode.new(nil, "/yo", { arg time, resp, msg; [time,resp,msg].postln; msg.postln;} ).add;
o.remove;
