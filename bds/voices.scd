

p = ("~/Music/SCSamples/iAmWatchingYou4.MP3").standardizePath;
b = MP3.readToBuffer(s, p);



z = Synth(\warp,[\buffer,b,\ws,0.3,\pch,(69).midicps / 435.0]);
z = Synth(\warp,[\buffer,b,\ws,0.3,\pch,(68).midicps / 435.0]);
z = Synth(\warp,[\buffer,b,\ws,0.3,\pch,(70).midicps / 435.0]);
z = Synth(\warp,[\buffer,b,\ws,0.3,\pch,(71).midicps / 435.0]);






b.free;


