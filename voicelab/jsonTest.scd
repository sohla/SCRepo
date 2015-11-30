// JSON/JSONSerializer required


(
g = File("~/Music/VoiceLab/template.json".asAbsolutePath,"r");
	a = g.readAllString;
	b = a.parseYAML;
Dictionary.newFrom(b["keyPaths"]).keys.asSortedList.postln;
	g.close;
)

(

	g = File("~/Music/VoiceLab/testdata.json".asAbsolutePath,"r");
	a = g.readAllString;// as a string
	b = a.parseYAML;// as a dictionary
	g.close;

	b.postln;

	f = File("~/Music/VoiceLab/saveddata.json".asAbsolutePath,"w");
	JSONSerializer.writeToFile(b,f);
	f.close;

)


(
~dictionaryFromJSONFile = {|path|
	g = File("~/Music/VoiceLab/testdata.json".asAbsolutePath,"r");
	a = g.readAllString;// as a string
	g.close;
	a.parseYAML// as a dictionary
};



~writeJSONFileWithDictionary = {|path,dict|
	f = File(path,"w");
	JSONSerializer.writeToFile(dict,f);
	f.close
};
)

b = "~/Music/VoiceLab/testdata.json".asAbsolutePath;
a = ~dictionaryFromJSONFile.(b)

p = "~/Music/VoiceLab/saveddata.json".asAbsolutePath;
~writeJSONFileWithDictionary.(p,a);


c = "~/Music/VoiceLab/saveddata.json".asAbsolutePath;
d = ~dictionaryFromJSONFile.(b)

