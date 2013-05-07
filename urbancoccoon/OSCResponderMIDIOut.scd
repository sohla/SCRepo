(
	MIDIClient.init;
	MIDIClient.destinations;

	n = NetAddr.localAddr;
	o = OSCresponderNode.new(n, "/midi", { |time, resp, msg| 
	
		[time,resp,msg].postln; 
		
		
		MIDIOut(0).noteOn(msg[1],msg[2],msg[3]);
	
	}).add; 
	
	)
	
p = ["/midi",0,60,60];	
p.asRawOSC
n.sendMsg(*p); Ê 

n.disconnect;
//o.remove; 
