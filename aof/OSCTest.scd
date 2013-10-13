NetAddr.langPort; // retrieve the current port SC is listening to

NetAddr.localAddr; // retrieve the current IP and port

n = NetAddr.new("192.168.0.116", 58100); // create the NetAddr
// create the OSCresponderNode
o = OSCresponderNode.new(nil, "/model0", { arg time, resp, msg; [time,resp,msg].postln; } ).add; 


o.remove; // remove the OSCresponderNode when you are done.


// post all incoming traffic except the server status messages
(
thisProcess.recvOSCfunc = { |time, addr, msg| 
	if(msg[0] != 'status.reply') {
		"time: % sender: %\nmessage: %\n".postf(time, addr, msg); 
	}  
}
);

// stop posting.
thisProcess.recvOSCfunc = nil;
