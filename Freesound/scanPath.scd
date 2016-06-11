
(


var dirPath = "/Volumes/Steph2015/Samples:Loops:SFX/*".postln;
//var dirPath = "~/Music/*";

// faster search
// can improve on search term using regex....

var fastSearch = {|dir, fileTypes, searchString, itrFunc, completeFunc|

	// start building find command string
	var cs = ("find % \\(").format(dir);

//	var cs = ("find % -iname \"*%*\" -a \\(").format(dir,searchString);
	var data = 0;


	// itr each word in search string
	searchString.split($ ).do({|ss|
			cs = cs ++ (" -iname \"*%*\" -%").format(ss,"a");//(o)R/(a)ND
	});

	cs = cs.copyFromStart(cs.size-3)++ " \\) -a \\(";

	cs.postln;

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
	"wav|wave|aif|aiff",
	"cave",// using '.' will give every file
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

c = 0;
a = "aif|aiff|wav|wave|mp3"; // extension list

//p = "/Volumes/Steph2015/Samples:Loops:SFX/*"; // searh dir
p = "~/Music/*";

z = "wind"; // search string

t = "a"; // aND/oR the search string words

// start building find command string
c = ("find % \\(").format(p);

// itr each word in search string
z.split($ ).do({|ss|
	c = c ++ (" -iname \"*%*\" -%").format(ss,t);
});

c = c.copyFromStart(c.size-3)++ " \\) -a \\(";

//c = ("find % \\( -iname \"*%*\" \\) -a \\(").format(p,z);
c.postln;


// add each of the extensions in the find
a.split($|).do({|type|type.postln;
	c = c ++ " -iname \"*.%\" -o".format(type);
});
// remove last -o
c = c.copyFromStart(c.size-3)++ " \\)";
// complete the command string

// send it off and get results, fast
e = c.unixCmdGetStdOutLines;

e.postln;
e.size;
)



