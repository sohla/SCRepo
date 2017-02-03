b = NetAddr.new("10.1.1.3", 53000);

b.sendMsg("/select/1", "");
b.sendMsg("/cue/1/start", "");
b.sendMsg("/cue/1/stop", "");

b.sendMsg("/cue/2/start", "");


b.sendMsg("/cue/2/sliderLevel/2 -1.2", "");
