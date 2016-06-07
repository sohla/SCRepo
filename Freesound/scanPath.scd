(
a = "aif|aiff|wav"; // extension list
p = "/Volumes/Steph2015/Samples:Loops:SFX/*"; // searh dir
z = "bird"; // search string

// start building find command string
c = ("find % -iname \"*%*\" -a \\(").format(p,z);
// add each of the extensions in the find
a.split($|).do({|type|type.postln;
	c = c ++ " -iname \"*.%\" -o".format(type);
});
// remove last -o
c = c.copyFromStart(c.size-3)++ " \\)";
// complete the command string
//d = d ++ " \\)";
// send it off and get results, fast
e = c.unixCmdGetStdOutLines;

d.postln;
e.size;
)


(


//var dirPath = PathName.new("~/Music/*");
var dirPath = "/Volumes/Steph2015/Samples:Loops:SFX/*";


var fastSearch = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	var cs = ("find % -iname \"*%*\" -a \\(").format(dir,searchString);
	var data = 0;
	fileTypes.split($|).do({|type|type.postln;
		cs = cs ++ " -iname \"*.%\" -o".format(type);
	});
	cs = cs.copyFromStart(cs.size-3)++ " \\)";
	data = cs.unixCmdGetStdOutLines;
	data.postln;


};






var search = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	var count = 0;

	PathName.new(dir).filesDo({|pathname|
		if(	"^.*\.(%)$".format(fileTypes).matchRegexp(pathname.fileName)){

			if(pathname.fileName.find(searchString,true) != nil){
				//		if(("(?i)"++searchString).matchRegexp(pathname.fileName.basename)){
				itrFunc.(pathname,count);
				count = count + 1;
			}
		}
	});
	completeFunc.(count);

};

search.(
	dirPath,
	"wav|wave|aif|aiff|caf|flac",
	"bird",// using '.' will give every file
	{|a,i| "% : %".format(i,a).postln},
	{|c|("sound files found"+c).postln;}
);


)


// much much faster
a = ("find /Volumes/Steph2015/Samples\:Loops\:SFX/* -iname \"*kick*\" ").unixCmdGetStdOutLines
a.size
a[a.size-1]

// and checking file exensions
b  = 0;
a = ("find /Volumes/Steph2015/Samples\:Loops\:SFX/* -iname \"*kick*\" -a \\( -iname \"*.aif\" -o -iname \"*.aiff\" -o -iname \"*.wav\" \\)");
b = a.unixCmdGetStdOutLines;
b.size

