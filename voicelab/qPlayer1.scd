(

	var appPath = PathName.new("~/Music/VoiceLab");

	g = File(appPath.asAbsolutePath+/+"data.json","r");
	a = g.readAllString;
	b = a.parseYAML;
	g.close;


	p = appPath.asAbsolutePath+/+"archive";
	b.writeArchive(p);

	e = Object.readArchive(p);
	e["keyPaths"].postln;
)

File.getcwd


PathName.new("~/Music/VoiceLab").asAbsolutePath
