
//load a json file
(

	g = File("~/Music/VoiceLab/template.json".asAbsolutePath,"r");
	a = g.readAllString;
	b = a.parseYAML;
Dictionary.newFrom(b["keyPaths"]).keys.asSortedList.postln;
	g.close;
)



(
File.saveDialog("Create Folder","TodaysSession",{|path|
	path.postln;
},{});
)


(
	f = File("test.txt","wb");

	d = Dictionary();
	d["a"] = 123;
	d["b"] = 456;

	e = Dictionary();
	e["object"] = d;

	f.write( e.asCompileString );
	f.close;
)
(
	g = File("test.txt","r");

	d = g.readAllString;

	//???

	d.postln;

d.class.postln;

	g.close;

)

(

	p = ("~/Music/VoiceLab").asAbsolutePath+/+"test";
	d = Dictionary();
	d["a"] = 123;
	d["b"] = 456;
	d["c"] = [4.5,6.7,8.9];

	d.writeArchive(p);

e = Object.readArchive(p);

e["c"];

)


