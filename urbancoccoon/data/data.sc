q,Send MIDI note,"/midi",0,60,60
q,Play Sound and Sample,"/s_new","pulsop",2003,1,1,"freq",110,"rate",1
q,|,"/b_allocRead",111,"sounds/SC_130306_133611.aiff"
q,|,"/s_new","samplePlayer",2004,1,1,"bufnum",111,"attack",1
q,Make Sound Hi,"/n_set",2003,"freq",1040,"amp",1.0,"rate",12
q,StopSample,"/n_set",2004,"gate",0,"release",2
q,Move,"/n_set",2003,"freq",840,"rate",8
q,People,"/n_set",2003,"freq",240,"rate",3
q,PiaBell,"/s_new","piaBell",2006,1,1,"amp",1.0,"density",0.9,"note",68
q,end	