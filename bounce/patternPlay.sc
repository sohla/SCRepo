a = Routine {
    var    i = 0;
    loop {
        i.yield;
        i = i + 1;
    };
};

a.nextN(10);

a = Pseries(start: 0, step: 1, length: inf).asStream;

a.nextN(10);

p = Pseries(0, 1, 10);
p.next;    // always returns the Pseries, not actual numbers

q = p.asStream;
q.next;    // calling this repeatedly gets the desired increasing integers


r = p.asStream;
r.next;    // starts from zero, even though q already gave out some numbers

q.next;    // resumes where q left off, with no effect from getting values from r

[q.next, r.next]    // and so on...



a = Pseq([0,2,4,6],inf,2).asStream
a.next

a = Pshuf([0,1,2,3],inf).asStream
a.next


a = Pwrand([0,1,2,3],[0.4,0.3,0.2,0.1],inf).asStream
a.next


a = Pseries(0,0.1,10).asStream
a.next

a = Pgeom(1,2,10).asStream
a.nextN(5)

a = Pwhite(0.2,0.4).asStream
a.nextN(5)

a = Pfunc({"hello"},{"reset"}).asStream
a.nextN(5)



a = Pser([0,1,2,3,4],3,0).asStream
a.nextN(5)


a = Pslide([0,1,2,3,4],5,3,2).asStream
a.nextN(6)

a = Place([0,1,[10,11],[12,13]],inf).asStream
a.nextN(8)


a = Place([0,1,[10,11],[12,13]],2).asStream.all


Pseq(#[1, 2, 3], 4).asStream.all;  

(-6, -4 .. 12)


Pseries(0, 1, 8).asStream
Ppatlace([Pseries(0, 1, 8), Pseries(2, 1, 7)],inf).asStream.nextN(8)

(\freq:520,\pan:-0.8).play




(
Pdef(\pat1).set(\octave,4);
Pdef(\pat1).set(\dur,0.25);
Pdef(\pat1,
	Pbind(
        \degree, Pseq([0, 7, 4, 3, 9, 5, 1, 4], inf),
		\gtranspose, Pstutter(8,Pseq([0,3,8,-2],inf),inf),
		\amp, Pexprand(0.1,0.4,inf),
		\pan, 0
));

~spec = ControlSpec(0,3,step:1);
~window = Window.new("mixers", Rect(10, 100, 320, 60));
~window.view.decorator = FlowLayout(~window.view.bounds, 2@2);
EZSlider(~window, 310@20, "low part", \amp, { |ez| 
	Pdef(\pat1).set(\dur,Array.geom(4, 1, 2).at(~spec.map(ez.value)).reciprocal); 
}, 0.5);
~window.front.onClose_({ Pdef(\pat1).stop });

Pdef(\pat1).play;
)


Array.geom(6, 1, 2).at(0);