
(


//var dirPath = "/Volumes/Steph2015/Samples:Loops:SFX/*";
var dirPath = "~/Music/*";

// faster search
// can improve on search term using regex....

var fastSearch = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	// start building find command string
	var cs = ("find % -iname \"*%*cave*\" -a \\(").format(dir,searchString);
	var data = 0;
	// add each of the extensions in the find
	fileTypes.split($|).do({|type|type.postln;
		cs = cs ++ " -iname \"*.%\" -o".format(type);
	});
	// remove last -o and complete the command string
	cs = cs.copyFromStart(cs.size-3)++ " \\)";
	// send it off and get results, fast
	data = cs.unixCmdGetStdOutLines;
	data.do({|o,i|itrFunc.(o,i)});
	completeFunc.(data.size);

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

// let's do the search
fastSearch.(
	dirPath,
	"wav|wave|aif|aiff|caf|flac|mp3",
	"water",// using '.' will give every file
	{|a,i| "% : %".format(i,a).postln},
	{|c|("sound files found"+c).postln;}
);


)









//------------------------------------------------
(
// quick hack example

// much much faster
a = ("find /Volumes/Steph2015/Samples\:Loops\:SFX/* -iname \"*kick*\" ").unixCmdGetStdOutLines
a.size
a[a.size-1]

// and checking file exensions
b  = 0;
a = ("find /Volumes/Steph2015/Samples\:Loops\:SFX/* -iname \"*kick*\" -a \\( -iname \"*.aif\" -o -iname \"*.aiff\" -o -iname \"*.wav\" \\)");
b = a.unixCmdGetStdOutLines;
b.size

)

//------------------------------------------------

(

//short hand version


a = "aif|aiff|wav"; // extension list
//p = "/Volumes/Steph2015/Samples:Loops:SFX/*"; // searh dir
p = "~/Music/*";

z = "water"; // search string

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



