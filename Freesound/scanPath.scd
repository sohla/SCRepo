(


var dirPath = PathName.new("~/Music/*");
var count = 0;
var recursiveSearch = {|dir, fileName, foundFunc|


dir.pathMatch.do{|a|


	if(	File.type(a) == \directory){
		recursiveSearch.(a.catArgs("*"),fileName,foundFunc)// recursive call into child dir

	}
	{ // we are a file...further testing


		//a.basename.splitext[0].postln; count = count + 1;

			if(	"^.*\.(wav|wave|aif|aiff|caf|flac)$".matchRegexp(a.basename))
			{
				if(("(?i)"++fileName).matchRegexp(a.basename)){
				//a.basename.postln;
				foundFunc.value(a);
				count = count + 1;
				}
			}
	};

};

};

recursiveSearch.(dirPath,"kick",{|a| a.postln});
("sound files found"+count).postln;
)


