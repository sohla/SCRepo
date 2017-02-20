SOMain {

	*new {
		|server|

		var path = PathName.new(String.scDir +/+"voiceLabSynths2.4.scd");
		var x = File.new(path.asAbsolutePath,"r");
		var c = x.readAllString;
		interpret(c);
		x.close;

		path = PathName.new(String.scDir +/+"voiceLabApp2.4.scd");
		x = File.new(path.asAbsolutePath,"r");
		c = x.readAllString;
		interpret(c);
		x.close;
	}

}
