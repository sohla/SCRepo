b = NetAddr.new("10.1.1.3", 53000);

b.sendMsg("/select/1", "");
b.sendMsg("/cue/1/start", "");
b.sendMsg("/cue/1/stop", "");

b.sendMsg("/cue/2/start", "");


b.sendMsg("/cue/2/sliderLevel/2", -4.0);


// connect to QLab, start a cue and change volume
(
b = NetAddr.new("10.1.1.3", 53000);
b.sendMsg("/cue/1/start", "");

r = Routine({|in|
	var f;
	    loop {
		f = thisThread.beats.fold(1,10) * 5;
		b.sendMsg("/cue/1/sliderLevel/0", f.neg);
		0.01.yield;
    }
});

TempoClock.default.sched(0, r);
)

// stop the above
(
r.stop;
b.sendMsg("/cue/1/stop", "");
b.sendMsg("/cue/1/sliderLevel/0", 0);
)

// send via gui
(
b = NetAddr.new("10.1.1.3", 53000);

w = Window.new.front;
c = NumberBox(w, Rect(20, 20, 150, 20));
d = ControlSpec(-60, 0, \linear, 1);

a = Slider(w, Rect(20, 60, 150, 20))
    .action_({
	        c.value_(d.map(a.value));
	b.sendMsg("/cue/2/sliderLevel/2", d.map(a.value));
        });
a.action.value;
)



OSCFunc.trace(true,true);
OSCFunc.trace(false);

s.reboot
s.quit
s.unmute
s.dumpOSC(1)


// local info
NetAddr.localAddr
NetAddr.langPort
NetAddr.disconnectAll

// send to QLab
b = NetAddr.new("10.1.1.12", 53000);
b.sendMsg("/cue/2/start", "");
b.disconnect

// listen to reply : use defer to post!!!
o = OSCFunc({ arg msg, time, addr, recvPort;
	{
		[msg, time, addr, recvPort].postln;

	}.defer;
},"/reply/version",recvPort:53001);// qlab sends back on 53001

// send msg to get back some data
b.sendMsg("/version");
o.free;



(
a = "/workspaces";
b = NetAddr.new("10.5.14.98", 53000);

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
//		[msg, time, addr, recvPort].postln;
		msg[0].postln;
		d = msg[1].asString.parseYAML["data"][0];
		d["uniqueID"].postln;

	}.defer;
},"/reply"++a,recvPort:53001);
b.sendMsg(a);
)
o.free;




(
a = "/workspace/394E714B-AD2C-4058-ADA3-AB53C4052912/cueLists";
b = NetAddr.new("10.1.1.3", 53000);

o = OSCFunc({ arg msg, time, addr, recvPort;
	{
//		[msg, time, addr, recvPort].postln;
		msg[0].postln;
		d = msg[1].asString.parseYAML["data"][0];
		d.postln;
		d["cues"].do({|o,i|
			[i,o["number"],o["name"]].postln;
		});

	}.defer;
},"/reply"++a,recvPort:53001);
b.sendMsg(a);
)
o.free;

