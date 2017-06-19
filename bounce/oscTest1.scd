(

n = s.nextNodeID;
s.sendMsg("/s_new", "default", n, 0, 0, "freq", 200);

o = OSCFunc({ arg msg, time, addr, recvPort;

	//[msg, time, addr, recvPort].postln;

	((msg[2].asFloat + 1pi) / 1 ).postln;

	// s.sendMsg("/n_set", n, "freq", 100 + (80 * msg[3].asFloat) );
	// s.sendMsg("/n_set", n, "amp", 0.1 +  (msg[2].asFloat + 1pi) / 2pi );

}, '/gyro');

)
o.free;
s.sendMsg("/n_free", n);

s.queryAllNodes;
{SinOsc.ar(120,0,0.1)}.play

// talking to QLAb

b = NetAddr.new("172.20.10.8", 53000);    // create the NetAddr
b.sendMsg("/qlab", "go");    // send the application the messa

OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off


b.sendMsg("/select/2", "");    // send the application the messa
b.sendMsg("/cue/5/start", "");    // send the application the messa
b.sendMsg("/cue/1/stop", "");    // send the application the messa

b.sendMsg("/cue/2/translationX -100", "");    // send the application the messa


o = OSCMonitor.new;     // make one
o.enable;            // turn it on
o.show;                // show them on gui, no po
o.watchStatus = true;
s.boot;
o.verbose = true;

o.disable;
o.watchStatus = false;

NetAddr.langPort;
n = NetAddr("127.0.0.1",5403)
n.ip.class
n.port

a = (\e:"hello", \f:(\a:1,\b:2))
a.class

a.f

a


b = Event.new(proto:a)

b.f.a = 2
b.e = 99
b.f = 


a
b
b.class
b.e = "world"

a.e
b.e

a[\e] = "world"

b = (\a:a)


x = true
x.not



b[\a][\e]

b[\a][\e] = "hello world"

c = (\pnt: (\x:0,\y:1,\z:2))

c[\pnt][\y]

c.pnt.y

d= Dictionary.newFrom(["1":4])
d.trueAt("1") == 4



["a","b","c"].find(["b"])

~a = {"oh yes".postln}
~a.()