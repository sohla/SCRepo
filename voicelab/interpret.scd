a = ("\"HeLlo WOrlD\"".postln;)

interpret(a)


(
	var path = PathName.new("~/Develop/SuperCollider/SCRepo/voicelab/helloWorld.scd");

x = File.new(path.asAbsolutePath,"r");

c = x.readAllString;


interpret(c);


x.close;
)
