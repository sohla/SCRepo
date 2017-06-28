



(

// synth to make some noise
SynthDef("help-Infreq", { arg bus;
    Out.ar(0, SinOsc.ar(In.kr(bus) * 200 + 400, 0, 0.5)!2);
}).send(s);

// synth generating some control rate values
SynthDef("help-Outfreq", { arg freq = 8, bus;
    Out.kr(bus, LFPulse.kr(freq));
}).send(s);

// synth to filter bus values
SynthDef("thruMe", { |bus=0,in=0, fc = 20|
        ReplaceOut.kr(bus, LPF.kr(In.kr(in),fc));
}).send;

b = Bus.control(s,1);
)

x = Synth.tail(s,"help-Outfreq", [\bus, b.index]);
y = Synth.tail(s,"thruMe", [\bus, b.index, \in, b.index]);
z = Synth.tail(s,"help-Infreq", [\bus, b.index]);

c.scope;

y.set(\fc,2);
x.set(\freq,2);



a = [1,2,3]
b = [5,6,7]

a.reverse.addFirst(4).reverse.removeAt(0)

